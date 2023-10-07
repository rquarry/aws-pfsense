variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = "terraform"
}

variable "custom-tags" {
  type = map(string)
  description = "Optional mapping for additional tags to apply to all related AWS resources"
  default = {}
}

variable "availability_zone" {
  description = "https://www.terraform.io/docs/providers/aws/d/availability_zone.html"
  default     = ""
}

variable "shared_credentials_file" {
  description = "Path to your AWS credentials file"
  type        = string
  default     = "/home/username/.aws/credentials"
}

variable "public_key_name" {
  description = "A name for AWS Keypair. Can be anything you specify."
  default     = "id_pfsense"
}

variable "public_key_path" {
  description = "Path to the public key to be loaded into the authorized_keys file"
  type        = string
  default     = "/home/username/.ssh/id_pfsense.pub"
}

variable "private_key_path" {
  description = "Path to the private key to use to authenticate pfsense."
  type        = string
  default     = "/home/username/.ssh/id_pfsense"
}

variable "ip_whitelist" {
  description = "A list of CIDRs that will be allowed to access the EC2 instances"
  type        = list(string)
  default     = [""]
}