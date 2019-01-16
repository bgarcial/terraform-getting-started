provider "aws" {
  region     = "eu-central-1"
  # Regions 
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html
}


resource "aws_instance" "testing-terraform" {
  ami           = "ami-b2665059"
  # How to select and AMI. Is necessary select an AMI according to the region of the provider
  # I need select and AMI of eu-central-1 y aca dicen como hacerlo
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html 
  # This answer may be useful too https://github.com/hashicorp/terraform/issues/4367#issuecomment-279269939
  
  instance_type = "t2.micro"
  # I need too, that the AMI selected previously, to be t2.micro.
  # In this link says that the t2.micro AMIs are all the hvm virtualization 
  # https://serverfault.com/a/616314/499906

  # Tells Terraform that this EC2 instance must be created only after the
  # S3 bucket has been created.
  # depends_on = ["aws_s3_bucket.example"]
}


# assigning an elastic IP to the EC2 instance we're managing
#resource "aws_eip" "aws_instance" {
  #instance = "${aws_instance.iaascode-terraform.id}"
  # Read about of implicit and explicit dependencies
  # https://learn.hashicorp.com/terraform/getting-started/dependencies#implicit-and-explicit-dependencies
  # AWS Instance should be created before that aws_eip
#}

# Sometimes there are dependencies between resources that are not visible to Terraform. 
# The depends_on argument is accepted by any resource and accepts a list of resources to 
# create explicit dependencies for.
# For example, perhaps an application we will run on our EC2 instance expects to use a 
# specific Amazon S3 bucket, but that dependency is configured inside the application 
# code and thus not visible to Terraform. In that case, we can use depends_on to 
# explicitly declare the dependency:

# New resource for the S3 bucket our application will use.

#resource "aws_s3_bucket" "example" {
  # NOTE: S3 bucket names must be unique across _all_ AWS accounts, so
  # this name must be changed before applying this example to avoid naming
  # conflicts.
  #bucket = "terraform-getting-started-guide-4"
  #acl    = "private"
#}

#resource "aws_instance" "another" {
#  ami           = "ami-b374d5a5"
#  instance_type = "t2.micro"
#}








# About of share sensitive data, create modules on terraform
# https://aws.amazon.com/blogs/apn/terraform-beyond-the-basics-with-aws/
# https://github.com/aws-samples/apn-blog/tree/master/terraform_demo