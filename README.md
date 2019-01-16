As you change Terraform configurations, Terraform builds an execution plan that only modifies what is necessary to reach your desired state.

By using Terraform to change infrastructure, you can version control not only your configurations but also your state so you can see how the infrastructure evolved over time.

use provisioners to initialize instances when they're created.

#Failed Provisioners and Tainted Resources

If a resource successfully creates but fails during provisioning, Terraform will error and mark the resource as "tainted". A resource that is tainted has been physically created, but can't be considered safe to use since provisioning failed.

When you generate your next execution plan, Terraform will not attempt to restart provisioning on the same resource because it isn't guaranteed to be safe. Instead, Terraform will remove any tainted resources and create new resources, attempting to provision them again after creation.

Terraform also does not automatically roll back and destroy the resource during the apply when the failure happens, because that would go against the execution plan: the execution plan would've said a resource will be created, but does not say it will ever be deleted. If you create an execution plan with a tainted resource, however, the plan will clearly state that the resource will be destroyed because it is tainted.

Provisioners can also be defined that run only during a destroy operation. These are useful for performing system cleanup, extracting data, etc.

For many resources, using built-in cleanup mechanisms is recommended if possible (such as init scripts), but provisioners can be used if necessary

# Input variables

We're still hard-coding access keys, AMIs, etc. To become truly shareable and version controlled, we need to parameterize the configurations. This page introduces input variables as a way to do this.

# Assigning variables

There are multiple ways to assign variables. Below is also the order in which variable values are chosen. The following is the descending order of precedence in which variables are considered.

## Command-line flags 

You can set variables directly on the command-line with the -var flag. Any command in Terraform that inspects the configuration accepts this flag, such as `apply`, `plan`, and `refresh`:

```
$ terraform apply \
  -var 'access_key=foo' \
  -var 'secret_key=bar'
# ...
```
Once again, setting variables this way will not save them, and they'll have to be input repeatedly as commands are executed.

## From a file

To persist variable values, create a file and assign variables within this file. Create a file named `terraform.tfvars` with the following contents:

```
access_key = "foo"
secret_key = "bar"
```

For all files which match `terraform.tfvars` or `*.auto.tfvars` present in the current directory, Terraform automatically loads them to populate variables. If the file is named something else, you can use the `-var-file` flag directly to specify a file. These files are the same syntax as Terraform configuration files. And like Terraform configuration files, these files can also be JSON.

We don't recommend saving usernames and password to version control, but you can create a local secret variables file and use `-var-file` to load it.

You can use multiple `-var-file` arguments in a single command, with some checked in to version control and others not checked in. For example:

```
$ terraform apply \
  -var-file="secret.tfvars" \
  -var-file="production.tfvars"
```

---

# From environment variables

Terraform will read environment variables in the form of `TF_VAR_name` to find the value for a variable. For example, the `TF_VAR_access_key` variable can be set to set the access_key variable.

Note: Environment variables can only populate string-type variables. List and map type variables must be populated via one of the other mechanisms.

# UI Input

If you execute `terraform apply` with certain variables unspecified, Terraform will ask you to input their values interactively. These values are not saved, but this provides a convenient workflow when getting started with Terraform. UI Input is not recommended for everyday use of Terraform.

Note: UI Input is only supported for string variables. List and map variables must be populated via one of the other mechanisms

# Variable Defaults

If no value is assigned to a variable via any of these methods and the variable has a default key in its declaration, that value will be used for the variable.

# Lists

Lists are defined either explicitly or implicitly

```
# implicitly by using brackets [...]
variable "cidrs" { default = [] }

# explicitly
variable "cidrs" { type = "list" }
```

You can specify lists in a `terraform.tfvars` file:

```
cidrs = [ "10.0.0.0/16", "10.1.0.0/16" ]
```

---

# Maps

We've replaced our sensitive strings with variables, but we still are hard-coding AMIs. Unfortunately, AMIs are specific to the region that is in use. One option is to just ask the user to input the proper AMI for the region, but Terraform can do better than that with maps.

Maps are a way to create variables that are lookup tables. An example will show this best. Let's extract our AMIs into a map and add support for the `us-west-2` region as well:

```
variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-b374d5a5"
    "us-west-2" = "ami-4b32be2b"
  }
}
```
A variable can have a map type assigned explicitly, or it can be implicitly declared as a map by specifying a default value that is a map. The above demonstrates both.

Then, replace the aws_instance with the following:

```
resource "aws_instance" "example" {
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
}
```