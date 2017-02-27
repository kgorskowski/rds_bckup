# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# LAMBDA variables
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

variable "cron_expression"    {}
variable "unique_name"        {}
variable "stack_prefix"       {}
variable "lambda_file"        {}
variable "vars_ini_render"    {}
variable "aws_iam_role_arn"   {}
# Build Lambda Zip
resource "null_resource" "buildlambdazip" {
  triggers { key = "${uuid()}" }
  provisioner "local-exec" {
  command = <<EOF
  mkdir lambda && mkdir tmp
  cp rds_bckup/rds_bckup.py lambda/rds_bckup.py
  echo "${var.vars_ini_render}" > lambda/vars.ini
  cd lambda/
  zip -r ../tmp/${var.stack_prefix}-${var.unique_name}.zip ./*
  while [ ! -f ../tmp/${var.stack_prefix}-${var.unique_name}.zip ]
  do
  sleep 2
  echo "Waiting for .zip file"
  done
  cd ..
EOF
  }
}

# Create lambda function
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_lambda_function" "rds_bckup_lambda" {
  function_name   = "${var.stack_prefix}_lambda_${var.unique_name}"
  filename        = "${var.lambda_file}"
  role            = "${var.aws_iam_role_arn}"
  runtime         = "python2.7"
  handler         = "rds_bckup.lambda_handler"
  timeout         = "60"
  depends_on      = ["null_resource.buildlambdazip"]
}

# Run the function with CloudWatch Event cronlike scheduler

resource "aws_cloudwatch_event_rule" "rds_bckup_timer" {
  name = "${var.stack_prefix}_rds_bckup_event_${var.unique_name}"
  description = "Cronlike scheduled Cloudwatch Event for copying RDS Snapshots"
  schedule_expression = "cron(${var.cron_expression})"
}

# Assign event to Lambda target
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_cloudwatch_event_target" "run_rds_bckup_lambda" {
    rule = "${aws_cloudwatch_event_rule.rds_bckup_timer.name}"
    target_id = "rds_bckup_lambda"
    arn = "${aws_lambda_function.rds_bckup_lambda.arn}"
}

# Allow lambda to be called from cloudwatch
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_lambda_permission" "allow_cloudwatch_to_call" {
  statement_id = "${var.stack_prefix}_AllowExecutionFromCloudWatch_${var.unique_name}"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.rds_bckup_lambda.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.rds_bckup_timer.arn}"
}

# Delete temporary resources
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "null_resource" "deletetmp" {
  triggers { key = "${uuid()}" }
  depends_on = ["aws_lambda_function.rds_bckup_lambda"]
  provisioner "local-exec" {
  command = "rm -rf lambda && rm -rf tmp"
  }
}

# Output function name
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

output "lambda_function_name" {
  value = "${aws_lambda_function.rds_bckup_lambda.function_name}"
}
