# MAIN Terraform File

# Create Lambda Role

module "iamrole" {
  source     	  = "modules/iamrole"
  unique_name	  = "${var.unique_name}"
  stack_prefix  = "${var.stack_prefix}"
}

# Render vars.ini for Lambda function

data "template_file" "vars" {
    template = "${file("modules/lambdafn/vars.ini.template")}"
    vars {
      AWS_SOURCE_REGION           = "${var.AWS_SOURCE_REGION}"
      AWS_DEST_REGION             = "${var.AWS_DEST_REGION}"
      SOURCE_DB                   = "${var.SOURCE_DB}"
      KEEP                        = "${var.KEEP}"
    }
}

# Build and Create Lambda resources

module "lambdafn" {
  source        	   = "modules/lambdafn"
  unique_name   	   = "${var.unique_name}"
  lambda_file        = "tmp/${var.stack_prefix}-${var.unique_name}.zip"
  stack_prefix       = "${var.stack_prefix}"
  aws_iam_role_arn   = "${module.iamrole.aws_iam_role_arn}"
  vars_ini_render    = "${data.template_file.vars.rendered}"
  cron_expression    = "${var.cron_expression}"
}
