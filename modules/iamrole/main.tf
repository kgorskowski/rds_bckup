# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# IAM Role variables
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

variable "unique_name"    {}
variable "stack_prefix"   {}


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# IAM Role resources
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# Create the lambda role (using lambdarole.json file)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_iam_role" "rds_bckup-role-lambdarole" {
  name               = "${var.stack_prefix}-role-lambdarole-${var.unique_name}"
  assume_role_policy = "${file("modules/iamrole/lambdarole.json")}"
}

# Create the Policy Document

/*data "aws_iam_policy_document" "lambdapolicy" {
  statement {
    sid = "1"

    actions = [
       "rds:AddTagsToResource",
       "rds:CopyDBSnapshot",
       "rdsCopyDBClusterSnapshot",
       "rds:DeleteSnapshot",
       "rds:Describe*",
       "rds:ListTagsForResource"
    ]
    effect = "Allow",
    resources = [ "*" ]
    }
  statement {
      actions = [ "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents" ]
      resources = [ "arn:aws:logs:*:*:*" ]
    }
}*/

# Apply the Policy Document we just created
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_iam_role_policy" "rds_bckup-role-lambdapolicy" {
  name = "${var.stack_prefix}-role-lambdapolicy-${var.unique_name}"
  role = "${aws_iam_role.rds_bckup-role-lambdarole.id}"
  policy = "${file("${path.module}/lambdapolicy.json")}"
}

# Output the ARN of the lambda role
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

output "aws_iam_role_arn" {
  value = "${aws_iam_role.rds_bckup-role-lambdarole.arn}"
}
