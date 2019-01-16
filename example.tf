provider "aws" {
  # This uses more interpolations, this time prefixed with var. . 
  # This tells Terraform that you're accessing variables. 
  # This configures the AWS provider with the given variables.
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
  #region     = "eu-central-1"
  # Regions 
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html
}

#output "ami" {
#  value = "${lookup(var.amis, var.region)}"
#}

# In the previous section, we introduced input variables as a way 
# to parameterize Terraform configurations. In this page, we introduce 
# output variables as a way to organize data to be easily queried and 
# shown back to the Terraform user.

# Let's define an output to show us the public IP address of the elastic IP address that we create
# This defines an output variable named "ip". The name of the variable must conform to 
# Terraform variable naming conventions if it is to be used as an input to other modules. 
# The value field specifies what the value will be, and almost always contains one or more 
# interpolations, since the output data is typically dynamic. 
# In this case, we're outputting the public_ip attribute of the elastic IP address.

# Multiple output blocks can be defined to specify multiple output variables.
#output "ip" {
#  value = "${aws_eip.ip.public_ip}"
# }





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
  
  # ami           = "${lookup(var.amis, var.region)}"
  # Are configured on variables.tf

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

  #  Now let's see how to use provisioners to initialize instances when they're created.
  # If you're using an image-based infrastructure (perhaps with images created with Packer), 
  # then what you've learned so far is good enough. But if you need to do some initial setup 
  # on your instances, then provisioners let you upload files, run shell scripts, or install 
  # and trigger other software like configuration management tools, etc.
  
  #Multiple provisioner blocks can be added to define multiple provisioning steps. 
  # Terraform supports multiple provisioners, but for this example we are using 
  # the local-exec provisioner. https://www.terraform.io/docs/provisioners/index.html
  # The local-exec provisioner executes a command locally on the machine running Terraform.
  # take the ip address
  provisioner "local-exec" {
    command = "echo ${aws_instance.testing-terraform.public_ip} > ip_address.txt"
  }
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