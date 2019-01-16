# In this example, we're going to use the Consul Terraform module for AWS, 
# https://registry.terraform.io/modules/hashicorp/consul/aws/0.4.4
# which will set up a complete Consul cluster. 
# This and other modules can be found via the search feature on the Terraform Registry site.

provider "aws" {
  access_key = "AKIAIBL2377OYL3PZBCQ"
  secret_key = "uvyBP4JBBJjF6Z3K0svGjRWZ3vumlaN2Vj/KIFcK"
  region     = "us-east-1"
}

# The module block begins with the example given on the 
# Terraform Registry page for this module, telling Terraform 
# to create and manage this module. 
# This is similar to a resource block: 
# it has a name used within this configuration -- in this case, "consul" -- 
# and a set of input values that are listed in the module's "Inputs" documentation.
module "consul" {
  # The source attribute is the only mandatory argument for modules. 
  # It tells Terraform where the module can be retrieved. 
  # Terraform automatically downloads and manages modules for you.
  # In this case, the module is retrieved from the official Terraform Registry. 
  # Terraform can also retrieve modules from a variety of sources, including 
  # private module registries or directly from Git, Mercurial, HTTP, and local files.  
  source = "hashicorp/consul/aws"
  
  # The other attributes shown are inputs to our module. This module supports many 
  # additional inputs, but all are optional and have reasonable values for experimentation.
  # should match provider region
  # aws_region  = "us-east-1" 
  num_servers = "3"
}

# (Note that the provider block can be omitted in favor of environment variables. 
# See the AWS Provider docs for details. This module requires that your AWS account 
# has a default VPC.)

output "consul_server_asg_name" {
  value = "${module.consul.asg_name_servers}"
}



