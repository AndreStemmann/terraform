#!/bin/bash

# author: andré stemmann
# usage: fullfill the variables below and run the script

# ============================================================
# SCRIPT CONFIG
# ============================================================
export AWS_ACCESS_KEY_ID='<KEY ID>'
export AWS_SECRET_ACCESS_KEY='<SECRET KEY>'
export AWS_REGION="<YOUR WORKING REGION>"
export TF_VAR_access_key=$AWS_ACCESS_KEY_ID
export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY
export TF_VAR_region=$AWS_REGION
TERRAFORM_VERSION='<TERRAFORM VERSION>'
backendbucket="<YOUR STATEFILE BUCKET.dev" #.live-suffix for live config
backendregion="<REGION WHERE THE STATEFILE BUCKET RESIDES>"

# ============================================================
# #check if terraform is installed, when not: install it
# ============================================================
if [ ! -d "terraform" ]; then
  for i in "wget" "unzip"; do
    command -v $i || { echo "please make sure to have ${i} on the PATH"; exit 1; }
  done

  if [ -z "${TERRAFORM_VERSION}" ]; then
    TERRAFORM_VERSION=0.10.6
  fi
  # determine platform and set downloadable
  PLATFORM=`uname`
  if [ "${PLATFORM}" == "Linux" ]; then
    TERRAFORM=terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  elif [ "${PLATFORM}" == "Darwin" ]; then
    TERRAFORM=terraform_${TERRAFORM_VERSION}_darwin_amd64.zip
  else
    echo "## no valid platform detected"
    sleep 3
    exit 1
  fi

  # download and extract terraform
  echo "## downloading terraform in version ${TERRAFORM_VERSION}"
  sleep 3
  rm -f ${TERRAFORM}
  wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM}
  rm -rf terraform/
  mkdir -p terraform
  unzip -o ${TERRAFORM} -d terraform/
  rm -f ${TERRAFORM}
fi

# ============================================================
# set terraform PATH and check if executable
# ============================================================
PATH=$PATH:$(pwd)/terraform/
TERRAFORM=$(type terraform | awk '{print $3}')

if [[ -z "${TERRAFORM}" ]]; then
  echo "## No terraform executable in environmentironment set / found"
  exit 3;
fi

function usage () {
  echo "Usage:   $(basename $0) -e <environment> -a [init|get|plan|apply|deploy|destroy]"
  echo "Example: $(basename $0) -e development -a plan"
  echo "Hint for more precise destroy by selection:"terraform plan -target=module.<MODULE>.<RESSOURCE.<NAME> -destroy""
}

function print_step () {
  echo ""
  echo -e "\e[32mRunning TF *${@}*\e[0m"
  echo -e "-------------------------"
}

function print_exit () {
  if [[ $1 -ne 0 ]]; then
    echo ""
    echo -e "\e[41mLast step threw errors / warnings\e[0m"
    exit 2;
  fi
}

function tf_cmd () {
  print_step "${1}"
  ${TERRAFORM} ${@}
  print_exit $?
}

while getopts "fe:a:" OPT; do
  case $OPT in
    f) force=$OPTARG;;
    e) environment=$OPTARG;;
    a) action=$OPTARG;;
  esac
done

if [[ -z "${environment}" ]] || [[ -z "${action}" ]]; then
  usage
  exit 2;
fi

# ============================================================
# set backend config for s3/statefile from tfvars
# ============================================================
TF_STATE_FILE="${environment}.tfstate"
TF_VAR_FILE="${environment}.tfvars"
TF_OPTIONS="-state=./tfstate/${TF_STATE_FILE} -var-file=./tfvars/${TF_VAR_FILE}"
pre_platform=$(grep "platform" tfvars/${TF_VAR_FILE}|cut -d"=" -f2)
platform=$(echo ${pre_platform/,/} | tr -d '"'|xargs)
pre_stage=$(grep "stage" tfvars/${TF_VAR_FILE}|cut -d"=" -f2)
stage=$(echo ${pre_stage/,/} | tr -d '"'|xargs)
pre_component=$(grep "component" tfvars/${TF_VAR_FILE}|cut -d"=" -f2)
component=$(echo ${pre_component/,/} | tr -d '"'|xargs)
pre_region=$(grep "region" tfvars/${TF_VAR_FILE}|cut -d"=" -f2)
region=$(echo ${pre_region/,/} | tr -d '"'|xargs)
key=${platform}-${stage}-${component}-${region}
TF_BACKEND="${key}_backend.tf"
if [ ! -d ./tfbackends/${stage} ]; then
  echo "## Initial script call. Will create environment folder for backend config"
  sleep 3
  echo "## Backend config itself will be created automatically from tfvars file"
  sleep 3
  mkdir -p ./tfbackends/${stage}
fi

if [ ! -d ./tfstate ]; then
  echo "## Initial script call. Will create folder for tfstate files"
  sleep 3
  mkdir ./tfstate
fi

if [ ! -d ./tfvars ]; then
  echo "## Initial script call. Will create folder for tfvars files"
  sleep 3
  echo "## See README.md to configure the tfvars"
  sleep 3
  mkdir ./tfvars:
fi

if [ ! -e ./tfbackends/${stage}/${TF_BACKEND} ]; then

  cat <<EOF >> ./tfbackends/${stage}/${TF_BACKEND}
#------------------------------------------------------------------------------
# File: xxxxxxxx/common/statefile.tf
# Description: Configure remote statefile/backend ${key}
#------------------------------------------------------------------------------
terraform {
  backend "s3" {
  bucket     = "${backendbucket}"
  key        = "${key}.tfstate"
  region     = "${backendregion}"
  encrypt    = "false"
  acl        = "bucket-owner-full-control"
  }
}
EOF
fi

TF_OPTIONS="-state=./tfstate/${TF_STATE_FILE} -var-file=./tfvars/${TF_VAR_FILE}"

cp ./tfbackends/${stage}/${TF_BACKEND} ./${TF_BACKEND}

function tf_run() {
case $action in
  init)
    tf_cmd ${action}
    ;;
  get)
    tf_cmd ${action}
    ;;
  plan)
    tf_cmd ${action} ${TF_OPTIONS}
    ;;
  graph)
    tf_cmd ${action}
    ;;
  show)
    tf_cmd ${action}
    ;;
  apply)
    tf_cmd ${action} ${TF_OPTIONS}
    ;;
  deploy)
    tf_cmd get
    tf_cmd plan ${TF_OPTIONS}
    tf_cmd apply ${TF_OPTIONS}
    ;;
  destroy)
		while true; do
    	read -p "Do you wish to delete the deployed TF infra, remote statefile, tfvars and backend-config?" yn
    	case $yn in
        [Yy]* )
				  tf_cmd ${action} ${TF_OPTIONS}
					aws s3 rm s3://"${backendbucket}"/${TF_STATE_FILE}
					rm -f ./tfbackends/${stage}/${TF_BACKEND}
					rm -f ./tfstate/${TF_STATE_FILE}.backup
				 	rm -f ./tfvars/${TF_VAR_FILE}
					break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    	esac
		done
    ;;
esac
}
tf_run
rm ${TF_BACKEND}
exit 0
