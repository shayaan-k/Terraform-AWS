# Terraform-AWS
Setup a cloud environment with Terraform

## Goals of this project: 
1. Create VPC
2. Create Internet Gateway
3. Create Custom Route Table
4. Create Subnet
5. Associate subnet with route table
6. Create security group to allow port 22, 80, 443
7. Create a network interface with an ip in the subnet
8. Assign an elastic ip to the network interface
9. Create ubuntu server an install apache2

All info can be found here: 
https://registry.terraform.io/providers/hashicorp/aws/latest


## Setup keys
AWS Dashboard -> EC2 -> key pair -> create (pem)

## Create VPC
VPC is the subnet for our servers
Create a new resource with type aws_vpc and provide a cidr block. 

## Create Internet gateway
Internet gateway allows our servers to access the internet (and be accessed via the internet)
Define internet gateway resource and pass in the ID of the vpc. Becuase the vpc is not created yet we can dynamically get the id by calling the vpc and its name with the .id extension.

## Create route table
Used to redirect traffic
Set the default route (0,0,0,0) to the internet gateway

## Create Subnet
Create a subnet within the range of the vpc
Assign it an availability zone.

## Create route table association
This association will tell the subnet to follow the rules listen in the route table.

## Create Security group
Create a primary security group in the VPC. 
From there, configure ingress and egress rules to allow certain traffic. In this project I allow HTTPS,HTTP, and SSH traffic

## Network interface
Set an arbitrary private ip for the server. It can be anything except the AWS special ips
This creates a private IP for the server but we also need a public one. Elastic IP

## Create Elastic IP
Create an elastic IP for the network interface and associate the private IP to it
Elastic IPs rely on an internet gateway being created for the VPC so ensure there is an internet gateway defined before an elastic ip
We should refernce the whole internet gateway object, not just the id

## Create Ubuntu web server
Define ubuntu ami (get id from aws dashboard)
define the instance type which is just t2.micro (free one)
and set an availability zone. This must be the same availability zone as subnet
We define the availablity zones in both resources because we dont want them to be randomly assigned to seperate availability zones.

We also pass our key generated in the beginning

Define a network interface block
In the network interface we need to specify an exact interface port. For this I used 0 (first interface)

We can also make the instance automatically run certain commands to install things. Using that I will install apache

## Check server
Navigate to the IP address listed in the dashboard and see that it says "My First web server"

## SSH to server
Putty uses ppk files but ubuntu needs pem. We need to use the pem file to generate a ppk. 
Launch Pttgeygen and load the pem file.
Save as private key.
Now I have both pem and ppk keys
Use the ppk key to launch ssh (ubuntu@IPADDRESS)
