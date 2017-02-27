Hi.
Ok, to be honest, I didn't reinvent the wheel here.
This "project" if you want to call it that relies heavily on the original idea found here:
http://codrspace.com/gswallow/copying-amazon-rds-snapshots-with-aws-lambda/
and the ReDS github repo found here https://github.com/arielsepulveda/ReDS_terraform
All I did was to modify both these projects to work for my usecase.
We use the RDS backup script for Lambda in a few projects and Terraform
gives me the opportunity to have it easily reproducable for other projects.
That's about it.
If you like it, install Terraform, clone the repo, copy the the .example file to terraform.tfvars and fill in you variables.
The script itself will copy only automated snaphots in cronlike intervals. Check the AWS config for the correct CloudWatch Event syntax.
(and if you find any catastrophic error, please drop me a line)
