## Content
* [Prerequirements](#prerequirements)
* [Changing stuff](#changing-stuff)
* [Motivation](#motivation)


## Motivation
* This Terraform-Code provides the ability to
  * Creates an IAM Group and a User
  * Creates IAM inline-polices attached to a Role, inherited by the User
  * Creates IAM inline polices attached to an EC2-Instance Profile
  * Creates an KMS-Key with Alias
  * Create an S3-Bucket with attached Retention and a Bucket-Policy for Encrypted Upload
* The Bash Wrapper-Script "Terraform-omnino.sh" provides the features of
  * Setup via Configfile (.tfvars)
    * Backend per Setup
    * Statefile per Backend
  * Setup TF working Directory

## Prerequirements
* Get Terraform either from https://www.terraform.io/downloads.html or direct via terraform-omnino.sh
* Have your AWS access credentials ready with the necessary permissions (e.g. to create ec2 instances, etc.)

## Changing stuff
1. Steps in [Preprequirements](#prerequirements) are completed
2. Remove state files `rm terraform.tfstate `and `rm terraform.tfstate.backup` or the `.tfstate` folder itself. Normally there shouldn't be any statefiles after inital clone.
3. Copy the file template.tpl in the folder `tfvars` to something called alike  `<platform>-<stage>-<component>-<region>.tfvars` and set the content comparatively e.g.

```
platform        =   "MyFancyProjectName"
stage           =   "development"
component       =   "backup"
region          =   "us-east-1"
filetype        =   "flatfiles"
lifecyclename   =   "30 days in S3, 90 days in Glacier"
transdays       =   "30"
storageclass    =   "GLACIER"
expdays         =   "90"
```
  In general the tfvars-fileshould be namend alike ``<platform>-<stage>-<component>-<region>.tfvars``
  There will be one *.tfvars file per Ssetup which will correlate with the related tfstate-file.
  **The name of the tfvars file will be your Project/Setup name.** Keep this in mind.

4. Configure the Terraform-Wrapper-Script ``terraform-omnino.sh``
   1.  Add your AWS Access Credentials in order to work properly
   2.  Choose your Terraform Version (If not installed, it will be downloaded and installed)
   3.  Create an S3 Bucket manually, beforehand to store your Statefiles remotely
      1. There will be one Statefile per Setup
      2. It's good practicise to have one bucket for staging/testing Setups and one Bucket for your live environment to prevent unwanted changes

```
# ============================================================
# SCRIPT CONFIG
# ============================================================
export AWS_ACCESS_KEY_ID='XXXXXXXXXX'  			# Your KEY
export AWS_SECRET_ACCESS_KEY='XXXXXXXXX'		# Your Secret
export AWS_REGION="us-east-1"				# Your working Region
export TF_VAR_access_key=$AWS_ACCESS_KEY_ID
export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY
export TF_VAR_region=$AWS_REGION
TERRAFORM_VERSION='0.10.6'				# Your desired Terraform Version
backendbucket="com.test.terraform.state.dev"		# Your Bucket to store all the Statefiles
backendregion="eu-west-1"
```

Without given config parameters the script only installs the terraform executable if missing.

5. The first step after setting-up the tfvars-file will be to initialize a new TF environment

```
./terraform-omnino.sh -e <my-setup> -a init
```
The second step is to check whether your backend*.tf file was successfully created or not.

It's called alike `backend_<platform>-<stage>-<component>-<region>.tf` named just alike your Setup

6. The deployment will be done by calling the script with

```
./terraform-omnino.sh -e <platform>-<stage>-<component>-<region> -a <Terraform action e.g. init>

./terraform-omnino.sh -e myproject-development-backup-eu-central-1 -a plan
```
7. **Keep in mind to avoid adding the filename suffix to your Setupname (w/o .tfvars) when calling it by script**
8. Check the created environment in AWS