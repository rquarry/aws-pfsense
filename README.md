# pfSense Terraform on AWS

![Architecture Diagram](https://docs.netgate.com/pfsense/en/latest/solutions/_images/aws-vpc-diagram.png)

**Source:** [pfSense Documentation](https://docs.netgate.com/pfsense/en/latest/solutions/aws-vpn-appliance/prerequisites-and-requirements.html) 

## Intro

This is the Terraform representation of the [pfSense Plus for Amazon AWS](https://docs.netgate.com/pfsense/en/latest/solutions/aws-vpn-appliance/index.html#pfsense-plus-for-amazon-aws) section of the pfSense documentation.

## Using This Repo

- Terraform setup with AWS credentials. The [Get Started - AWS](https://developer.hashicorp.com/terraform/tutorials/aws-get-started) tutorials are a good start for this.
- A security policy applied to your credentials that has, at minimum, the permissions listed in **policy.json**. "All" EC2 permissions is another, but less secure, avenue to take.
- Rename [terraform.tfvars.example] tp terraform.tfvars and populate the variables with actual values.
- Visit the Amazon marketplace and subscribe to access the pfSense AMI. This is still a "pay-per-use" AMI where, "Hourly users may cancel or stop using this service at any time". The whole subscription seems built around the EULA and pricing so more of a formality for my casual usage. 
- Assuming your AMI is different, update it prior to running ```terraform plan```
- Update the password for the WebGUI of the instance in line 189 of ```main.tf```. The current password is short and less complex than it should be for VPN testing.
- SSH access is accomplished by using the `-i` switch, specifying the private key, using `admin` for the user (`admin@x.x.x.x`)

## Credits

The AWS Terraform code from the Detection Lab project by Chris Long was used as the starting point for this project

---

