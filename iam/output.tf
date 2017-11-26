#
output "aws_iam_instance_profile" {
  value = "${aws_iam_instance_profile.iam-instance-profile.name}"
}
#
output "role_arn" {
  value = "${aws_iam_role.iam-role-trust-policy.arn}"
}
#
output "kms_key_arn"  {
  value = "${aws_kms_key.kms-key.arn}"
}
#
output "user_arn" {
  value = "${aws_iam_user.iam-user.arn}"
}
