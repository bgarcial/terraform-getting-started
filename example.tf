provider "aws" {
  region     = "eu-central-1"
  # Regions 
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html
}

# Sometimes there are dependencies between resources that are not visible to Terraform. 
# The depends_on argument is accepted by any resource and accepts a list of resources to 
# create explicit dependencies for.
# For example, perhaps an application we will run on our EC2 instance expects to use a 
# specific Amazon S3 bucket, but that dependency is configured inside the application 
# code and thus not visible to Terraform. In that case, we can use depends_on to 
# explicitly declare the dependency:

# New resource for the S3 bucket our application will use.

resource "aws_s3_bucket" "example" {
  # NOTE: S3 bucket names must be unique across _all_ AWS accounts, so
  # this name must be changed before applying this example to avoid naming
  # conflicts.
  bucket = "terraform-p5"
  # Name of the bucket created. Above, example is the namespace which the
  # bucket belong

  acl    = "private"
}


resource "aws_instance" "testing-terraform" {
  ami           = "ami-d15d663a"
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
  depends_on = ["aws_s3_bucket.example"]
}


# assigning an elastic IP to the EC2 instance we're managing
resource "aws_eip" "aws_instance" {
  instance = "${aws_instance.testing-terraform.id}"
  # The only parameter for aws_eip is "instance" which is 
  # the EC2 instance to assign the IP to. For this value, we 
  # use an interpolation to use an attribute from the EC2 instance we 
  # managed earlier. 

  # By studying the resource attributes used in interpolation expressions, 
  # Terraform can automatically infer when one resource depends on another. 
  # In the example above, the expression ${aws_instance.example.id} creates 
  # an implicit dependency on the aws_instance named testing-terraform.
  # Terraform uses this dependency information to determine the correct order 
  # in which to create the different resources. 
  # In the example above, Terraform knows that the aws_instance must be created 
  # before the aws_eip.

  # Implicit dependencies via interpolation expressions are the primary way to 
  # inform Terraform about these relationships, and should be used whenever possible. 
  # Read about of implicit and explicit dependencies
  # https://learn.hashicorp.com/terraform/getting-started/dependencies#implicit-and-explicit-dependencies

}


# Because this new instance does not depend on any other resource, 
# it can be created in parallel with the other resources. Where possible, 
# Terraform will perform operations concurrently to reduce the total time 
# taken to apply changes.
#resource "aws_instance" "another" {
#  ami           = "ami-885e5e63"
#  instance_type = "t2.micro"
#}








# About of share sensitive data, create modules on terraform
# https://aws.amazon.com/blogs/apn/terraform-beyond-the-basics-with-aws/
# https://github.com/aws-samples/apn-blog/tree/master/terraform_demo