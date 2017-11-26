# ========================================================================================================
# AWS SETTINGS
# ========================================================================================================
provider "aws" {
  region  = "${var.region}"
}

# ========================================================================================================
# Iam module for policies, roles, profiles and keys
#  ========================================================================================================
module "iam" {
  source          = "./iam"
  aws_account_id  = "${var.aws_account_id}"
  region          = "${var.region}"
  stage           = "${var.stage}"
  component       = "${var.component}"
  platform        = "${var.platform}"
  filetype        = "${var.filetype}"
  bucket_name     = "${var.platform}-${var.stage}-${var.component}-${var.filetype}-${var.region}"
}

# ========================================================================================================
# S3 module for bucket creation
#  ========================================================================================================
module "s3" {
  source        = "./s3"
  region        = "${var.region}"
  stage         = "${var.stage}"
  component     = "${var.component}"
  platform      = "${var.platform}"
  kms_key_arn   = "${module.iam.kms_key_arn}"
  role_arn      = "${module.iam.role_arn}"
  user_arn      = "${module.iam.user_arn}"
  filetype      = "${var.filetype}"
  bucket_name   = "${var.platform}-${var.stage}-${var.component}-${var.filetype}-${var.region}"
  lifecyclename = "${var.lifecyclename}"
  transdays     = "${var.transdays}"
  storageclass  = "${var.storageclass}"
  expdays       = "${var.expdays}"
}
