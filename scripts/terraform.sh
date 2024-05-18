cat << EOF

terrform init && terraform plan   

Initializing the backend...


Successfully configured the backend "local"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing modules...


Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.50.0


Terraform has been successfully initialized!


You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.


If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create


Terraform will perform the following actions:


  + resource "aws_security_group" "ec2" {
      + arn                    = (known after apply)
      + description            = "Allow ec2 instance inbound traffic"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "ec2 HTTP from Forteclient & tunnelblick"
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "ec2 from Forteclient & tunnelblick"
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
          + {
              + cidr_blocks      = [
                  + "172.30.123.99/32",
                ]
              + description      = "allow ec2 from new ec2 master"
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "prodec2"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Component"    = "ec2"
          + "Name"         = "prod-ec2-sg"
          + "Project"      = "ec2"
          + "Subcomponent" = "ec2"
          + "environment"  = "prod"
          + "resource"     = "sg"
        }
      + tags_all               = {
          + "Component"    = "ec2"
          + "Name"         = "prod-ec2-sg"
          + "Project"      = "ec2"
          + "Subcomponent" = "ec2"
          + "environment"  = "prod"
          + "resource"     = "sg"
        }
      + vpc_id                 = "vpc-04a19f9e30bd25c50"
    }


  # module.ec2.aws_instance.instance[${3}] will be created
  + resource "aws_instance" "instance" {
      + ami                                  = "ami-0de4fe935c896dc4a"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = false
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = false
      + ebs_optimized                        = true
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "${2}"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "ec2EC2Prod"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = "subnet-09701806c769ee183"
      + tags                                 = {
          + "Backup"                 = "true"
          + "Component"              = "ec2"
          + "Managed"                = "terraform"
          + "Name"                   = "shared-prod-ec2-0"
          + "Patch Group"            = "prod"
          + "Project"                = "ec2"
          + "Subcomponent"           = "ec2"
          + "Vertical"               = "operation"
          + "dataclassification"     = ""
          + "environment"            = "prod"
          + "onboardtocyberark"      = "yes"
          + "platformname"           = "UnixSSH"
          + "resource"               = "ec2"
          + "resourceclassification" = ""
          + "resourcetype"           = ""
          + "safename"               = "OT-P"
        }
      + tags_all                             = (known after apply)
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)


      + root_block_device {
          + delete_on_termination = true
          + device_name           = (known after apply)
          + encrypted             = true
          + iops                  = (known after apply)
          + kms_key_id            = "arn:aws:kms:${1}:792287822093:key/mrk-a28f8c2f744749a880ffb4e1a1107690"
          + tags                  = {
              + "Backup"                 = "true"
              + "Component"              = "ec2"
              + "Managed"                = "terraform"
              + "Name"                   = "shared-prod-ec2-0"
              + "Project"                = "ec2"
              + "Subcomponent"           = "ec2"
              + "Vertical"               = "operation"
              + "dataclassification"     = ""
              + "environment"            = "prod"
              + "resource"               = ""
              + "resourceclassification" = ""
              + "resourcetype"           = "${5}"
            }
          + tags_all              = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = "${4}"
          + volume_type           = "gp3"
        }
    }


Plan: 2 to add, 0 to change, 0 to destroy.

EOF