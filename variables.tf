# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# Variables
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# Modify here or in the terraform.tfvars file
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
variable "AWS_REGION" {
  description = "AWS Region where the Lambda function shall run"
}

variable "SOURCE_DB" {
  description = "Identifier of the RDS Snapshot Source Instance"
}

variable "AWS_SOURCE_REGION" {
  description = "source region of the RDS snapshots (where the DB runs). Configure in terraform.tfvars "
}

variable "AWS_DEST_REGION" {
  description = "Destination region to which the RDS snapshots will be copied"
}

variable "KEEP" {
  default = "5"
  description = "Numbers of Snapshots that will be stored in destination region"
}

# Unique/Random for resource generation.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
variable "unique_name" {
  description = "Enter Unique Name to identify the Terraform Stack (lowercase)"
}

variable "stack_prefix" {
  default = "rds_bckup"
  description = "Stack Prefix for resource generation"
}

variable "cron_expression" {
  description = "Cron expression for firing up the Lambda Function"
}
