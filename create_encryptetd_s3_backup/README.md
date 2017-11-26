## Content
* [Prerequirements](#prerequirements)
* [Changing stuff](#changing-stuff)
* [Motivation](#motivation)


## Motivation
* Createa group, a user, ec2-instance-profile, inline policies,
  a trust role, an KMS-Key with alias, an S3 Bucket,
  an corresponding bucket-policy and
  a file-retention within AWS

## Prerequirements
* get Terraform either from https://www.terraform.io/downloads.html or via terraform-omnino.sh
* Have your AWS access credentials ready with the necessary permissions (e.g. to create ec2 instances, etc.)

## Changing stuff
1. Steps in [Preprequirements](#prerequirements) are completed

2. Remove state files `rm terraform.tfstate` and `terraform.tfstate.backup` or the tfstate folder itself  normally there shouldn't be any statefiles after inital clone

3. Create or override the file `*.tfvars` in the folder `tfvars` of this repo and set the content comparatively e.g. :

```
platform        =   "projectx"
stage           =   "dev"
component       =   "backup"
region          =   "us-east-1"
filetype        =   "flatfiles"
lifecyclename   =   "30 days in s3, 90 days in Glacier"
transdays       =   "30"
storageclass    =   "GLACIER"
expdays         =   "90"

```
  In general the tfvars should be namend alike ``<platform>-<stage>-<component>-<region>.tfvars``
  There will be one *.tfvars file per setup which will correlate with the related tfstate-file.
  The name of the tfvars file will be your project/setup name. Keep this in mind.

4. Configure the Terraform-Wrapperi-Script ``terraform-omnino.sh``

```
# ============================================================
# SCRIPT CONFIG
# ============================================================
export AWS_ACCESS_KEY_ID='XXXXXXXXXX'
export AWS_SECRET_ACCESS_KEY='XXXXXXXXX'
export AWS_REGION="us-east-1"
export TF_VAR_access_key=$AWS_ACCESS_KEY_ID
export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY
export TF_VAR_region=$AWS_REGION
TERRAFORM_VERSION=0.10.6
backendbucket="com.test.terraform.state.dev" #.live suffix for live setups
backendregion="eu-west-1"
```

Without given parameters the script only installs the terraform executable if missing.

The first step after setting-up the tfvars-file will be to initialize a new TF environment

```

./terraform-omnino.sh -e <my-setup> -a init

The second step is to check whether your backend*.tf file was successfully created or not.

It's called alike backend_<platform>-<stage>-<component>-<region>.tf

```
5. The deployment will be done by calling the script alike

```

./terraform-omnion.sh -e <platform>-<stage>-<component>-<region> -a <Terraform action e.g. init>

./terraform-omnino.sh -e projectx-live-backup-eu-central-1 -a plan

```
6. Check the created environment in AWS
