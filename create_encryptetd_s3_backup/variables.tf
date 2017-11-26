# aws access key sourced by terraform-omnino.sh
variable "access_key" {
  type = "string"
}

# aws secret key sourced by terraform-omnino.sh
variable "secret_key" {
  type = "string"
}

# aws iam user
variable "aws_account_id" {
  type = "string"
  default = "1234567890"
}

# Adjust the region here.
# Must be passed on from
# the related tfvars file
variable "region" {
  type = "string"
}

# Adjust the environment here
# dev,live, etc... the puppet manifests need to match
# the tags defined
variable "stage" {
  type    = "string"
  default = "dev"
}

# The component of the setup
variable "component" {
  type    = "string"
  default = "backup"
}

# The platform it belongs to
variable "platform" {
  type    = "string"
  default = "projectx"
}

# filetype desc
# Must be passed on from
# the related tfvars file
variable "filetype" {
  type    = "string"
  default = "flatfiles"
}

# bucket lifecycle desc here.
# Must be passed on from
# the related tfvars file
variable "lifecyclename" {
  type = "string"
  default =""
}

# Adjust the transition to another storage class here.
# Must be passed on from
# the related tfvars file
variable "transdays" {
  type = "string"
  default =""
}

# Adjust the storageclass here.
# Must be passed on from
# the related tfvars file
variable "storageclass" {
  type = "string"
  default = ""
}

# Adjust the expiration here.
# Must be passed on from
# the related tfvars file
variable "expdays" {
  type = "string"
  default = ""
}
