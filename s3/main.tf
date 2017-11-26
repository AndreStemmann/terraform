# ===========================================================
# AWS S3 BUCKETS
# ===========================================================

# ===========================================================
# OVERVIEW:
#
# external access via user, internal access via ec2 instance profile
# - Put is allowed when use dedicated kms key
# -
#
# TODO:
# - if clause for lifecycle
# ===========================================================


# Create S3 Bucket without lifecycle
resource "aws_s3_bucket" "s3-bucket" {
    count = "${var.lifecyclename == "" ? 1 : 0}"
    bucket = "${var.bucket_name}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "PutObjPolicy",
    "Statement": [
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.bucket_name}/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption-aws-kms-key-id": "${var.kms_key_arn}"
                }
            }
        },
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": {
              "AWS": [
                "${var.role_arn}",
                "${var.user_arn}"
              ]
            },
            "Action": [
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": "arn:aws:s3:::${var.bucket_name}/*"
        }
    ]
}
EOF
}

# Create Bucket with Lifecycle
resource "aws_s3_bucket" "s3-backup" {
    count = "${var.lifecyclename != "" ? 1 : 0}"
    bucket = "${var.bucket_name}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "PutObjPolicy",
    "Statement": [
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.bucket_name}/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption-aws-kms-key-id": "${var.kms_key_arn}"
                }
            }
        },
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": {
              "AWS": [
                "${var.role_arn}",
                "${var.user_arn}"
              ]
            },
            "Action": [
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": "arn:aws:s3:::${var.bucket_name}/*"
        }
    ]
}
EOF
    acl = "private"
    region = "${var.region}"
    lifecycle_rule {
        id      = "${var.lifecyclename}"
        enabled = true
        transition {
            days = "${var.transdays}"
            storage_class = "${var.storageclass}"
        }
        expiration {
            days = "${var.expdays}"
        }
    }
}
