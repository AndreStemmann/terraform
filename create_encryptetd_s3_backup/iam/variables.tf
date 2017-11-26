# The stage of the setup, preprod, testing, prod, etc...

variable "aws_account_id" {
  type = "string"
}

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
  default = "projectx"
}

# ressource name
variable "filetype" {
  type    = "string"
  default = "flatfiles"
}
