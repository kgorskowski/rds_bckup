Hi.
Ok, to be honest, I didn't reinvent the wheel here.
This "project" if you want to call it that relies heavily on the original idea found here:
http://codrspace.com/gswallow/copying-amazon-rds-snapshots-with-aws-lambda/
and the ReDS github repo found here https://github.com/arielsepulveda/ReDS_terraform
All I did was to modify both these projects to work for my usecase.
We use the RDS backup script for Lambda in a few projects and Terraform
gives me the opportunity to have it easily reproducable for other projects.
That's about it.
If you like it, install Terraform, clone the repo, copy the the .example file to terraform.tfvars and fill in your variables.
Then you run "terraform get" to initialize the modules, "terraform plan" to see what resources will be created and if you are fine with it, finally "terraform apply" to create the resources.
The script itself will copy only automated snaphots in cronlike intervals. Check the AWS config for the correct CloudWatch Event syntax.
(and if you find any catastrophic error, please drop me a line)
BTW as the Lambda function generation happens locally on your machine, the function on AWS will not get automatically replaced when you make changes in the code or vars. ~~Seems like it is necessary recreate the full stack with "terrafom destroy" and then "terraform apply" again to push changes in the function to AWS.
If I find a workaround, I will update the repository.~~
I changed the Lambda ZIP generation procedure. It now builds the zip on every run but the Lambda resource is triggert by changes in the ZIP file hash. So if you change code in the script or the variables, the Lambda gets gefreshed in AWS.
In addition I activated versioning of the Lambda function. If you want to disable that, remove the "publish = true" entry from the lambdafn/main.tf
