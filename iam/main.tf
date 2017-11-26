# 2017_09_22 , ast

# ===========================================================
# OVERVIEW:
#
# for external access via IAM User
# - IAM GROUP <=  GROUP-POLICIES
# -- KMS (creation, ID)
# -- S3 (encryption, access mgmt, bucket ops)
# -- EC2 (describe)
# --- USER (inherits policy whilst attached to group)
# ------------------------------------------------------------
#
# for internal acccess via ec2 instance
# - IAM ROLE <= INLINE POLICIES
# -- KMS (creation, ID)
# -- S3 (encryption, access mgmt, bucket ops)
# -- EC (describe)
# --- EC2-Profile (inherits policies by assuming role)
#
# TODO:
# - store iam-inline and group policies in json policy doc for reuse
# - store iam-inline and group variables as ouput for json policy doc
# ## https://stackoverflow.com/questions/43526544/reading-terraform-variable-from-file
#
# - split IAM module in single modules for roles,groups,users,KMS to be able to destroy ressources
# ===========================================================



###########  for external access via IAM User ##########

# ===========================================================
# AWS IAM USER FOR BACKUP
# ===========================================================

# IAM user to store backups in S3 from external ISP
resource "aws_iam_user" "iam-user" {
    name = "${var.platform}-${var.component}-${var.region}-${var.stage}"
}

# ===========================================================
# AWS IAM GROUP FOR BACKUP USERS
# ===========================================================

# IAM group
resource "aws_iam_group" "iam-group" {
    name = "${var.platform}-${var.component}-users-${var.stage}"
}

# ===========================================================
# AWS IAM GROUP-POLICIES (for IAM-Users)
# ===========================================================

# Inline group-policy to grant S3 operations
resource "aws_iam_group_policy" "iam-group-policy-s3" {
		name = "${var.platform}-${var.component}-${var.region}-${var.stage}"
		group = "${aws_iam_group.iam-group.id}"
		policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
  	{
    	"Sid": "Stmt1502714609000",
      "Effect": "Allow",
      "Action": [
      	"s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucketVersions",
        "s3:ListMultipartUploadParts",
				"s3:CreateMultipartUpload",
        "s3:AbortMultipartUpload",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
		}
	]
}
EOF
}

# Inline group-policy to grant KMS operations
resource "aws_iam_group_policy" "iam-group-policy-kms-view" {
		name = "${var.platform}-${var.component}-cmk-view-${var.region}-${var.stage}"
		group = "${aws_iam_group.iam-group.id}"
		policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
   		   "kms:ListKeys",
         "kms:ListAliases",
         "kms:Encrypt"
      ],
      "Resource": [
         "*"
      ]
    }
  ]
}
EOF
}

# ===========================================================
# AWS IAM USER TO GROUP ATTACHMENTS
# ===========================================================

# User to group relation
resource "aws_iam_group_membership" "iam-group-membership" {
    name = "${var.platform}-${var.component}-user-membership"
    users = [
        "${aws_iam_user.iam-user.name}",
    ]
    group = "${aws_iam_group.iam-group.name}"
}



# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------



########## for internal acccess via ec2 instance ##########

# ===========================================================
# AWS IAM ASSUME-ROLE POLICIES (for instance-profiles)
# ===========================================================

# There are two different types of policy associated with a role.
# The assume role policy defines which principals are able to obtain temporary credentials to act as this role (via the sts:AssumeRole action).
# The role policy defines what actions are permitted when using those temporary credentials.

# Trust-Policy for ec2-instance profiles
resource "aws_iam_role" "iam-role-trust-policy" {
		name = "${var.platform}-${var.component}-role-${var.region}-${var.stage}"
		assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
    }
  ]
}
EOF
}

# ===========================================================
# AWS IAM INLINE ROLE-POLICIES (for instance-profiles)
# ===========================================================

# Inline role policy to grant S3 operations
resource "aws_iam_role_policy" "iam-role-policy-s3" {
		name = "${var.platform}-${var.component}-${var.region}-${var.stage}"
		role = "${aws_iam_role.iam-role-trust-policy.id}"
		policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
  	{
    	"Sid": "Stmt1502714609000",
      "Effect": "Allow",
      "Action": [
      	"s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucketVersions",
        "s3:ListMultipartUploadParts",
				"s3:CreateMultipartUpload",
        "s3:AbortMultipartUpload",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
		}
	]
}
EOF
}

# Inline role policy to grant KMS operations
resource "aws_iam_role_policy" "iam-role-kms-view" {
		name = "${var.platform}-${var.component}-cmk-view-${var.region}-${var.stage}"
		role = "${aws_iam_role.iam-role-trust-policy.id}"
		policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
   		   "kms:ListKeys",
         "kms:ListAliases",
         "kms:Encrypt"
      ],
      "Resource": [
         "*"
      ]
    }
  ]
}
EOF
}

# Inline role policy to grant describe on EC2
resource "aws_iam_role_policy" "iam-role-ec2-describe" {
		name = "${var.platform}-${var.component}-describe-${var.region}-${var.stage}"
		role = "${aws_iam_role.iam-role-trust-policy.id}"
		policy =  <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    }
  ]
}
EOF
}

# ===========================================================
# AWS IAM KMS
# ===========================================================

# IAM KMS customer master key
resource "aws_kms_key" "kms-key" {
		description = "${var.platform}-${var.component}-${var.region}-${var.stage}"
  	policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "key-consolepolicy-3",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.aws_account_id}"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow access for Key Administrators",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.aws_account_id}"
      },
      "Action": [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.iam-role-trust-policy.arn}",
          "${aws_iam_user.iam-user.arn}"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
        "kms:ListAliases"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow attachment of persistent resources",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.iam-role-trust-policy.arn}",
          "${aws_iam_user.iam-user.arn}"
        ]
      },
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
}
EOF
}

resource "aws_kms_alias" "kms-cmk-alias" {
  name          = "alias/${var.platform}-${var.component}-${var.region}-${var.stage}"
  target_key_id = "${aws_kms_key.kms-key.key_id}"
}

# ===========================================================
# AWS IAM INSTANCE PROFILE
# ===========================================================

# Instance Profile to attach to EC2 instance
resource "aws_iam_instance_profile" "iam-instance-profile" {
		name = "${var.platform}-${var.component}-profile-${var.region}-${var.stage}"
		role = "${aws_iam_role.iam-role-trust-policy.id}"
}
