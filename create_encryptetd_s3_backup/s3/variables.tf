# input from iam_module
# =======================
variable "kms_key_arn" {}
variable "role_arn" {}
variable "user_arn" {}

# base vars from tfvars
# ======================================================
# The stage of the setup, preprod, testing, prod, etc...
variable "stage" {
  type = "string"
}

# The component of the setup
variable "component" {
  type = "string"
}

# The platform it belongs to
variable "platform" {
  type = "string"
}

variable "region" {
  type = "string"
}

# s3-bucket-name
variable "bucket_name" {
  type    = "string"
}

# ressource name
variable "filetype" {
  type    = "string"
}

# module specific vars
# =====================================
# bucket lifecycle desc here.
# Must be passed on from
# the related tfvars file
variable "lifecyclename" {
  type = "string"
  default=""
}

# Adjust the transition to another storage class here.
# Must be passed on from
# the related tfvars file
variable "transdays" {
  type = "string"
  default=""
}

# Adjust the storageclass here.
# Must be passed on from
# the related tfvars file
variable "storageclass" {
  type = "string"
  default=""
}

# Adjust the expiration here.
# Must be passed on from
# the related tfvars file
variable "expdays" {
  type = "string"
  default=""
}
