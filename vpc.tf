resource "aws_vpc" "newvpc" {
  
   cidr_block = "192.168.0.0/24"
   enable_dns_hostnames = true
  
  tags = {
  
   Name = "Terraform-VPC"
   Env = "Staging"
   POC = "Alaguraj Mathialagan"
   
   }

}  


locals {

   subnets = [
   
   {name = "public-subnet1", cidr = "192.168.0.0/26", az= "us-west-1a" },
   {name = "public-subnet2", cidr = "192.168.0.64/26", az= "us-west-1b" },
   

  ]
  
    subnets1 = [
   
   {name = "private-subnet1", cidr = "192.168.0.128/26", az= "us-west-1a" },
   {name = "private-subnet2", cidr = "192.168.0.192/26", az= "us-west-1b" },

  ]
      
 }
resource "aws_subnet" "public-subnets" {

 for_each = { for subnet in local.subnets : subnet.name => subnet }
 
     vpc_id = aws_vpc.newvpc.id
	 cidr_block = each.value.cidr
	 availability_zone = each.value.az
	 map_public_ip_on_launch = true
	 
	 tags = {
	 
	  Name = each.value.name
	  
	  }
	  
 }
	 
resource "aws_subnet" "private-subnets" {

 for_each = { for subnet in local.subnets1 : subnet.name => subnet }
 
     vpc_id = aws_vpc.newvpc.id
	 cidr_block = each.value.cidr
	 availability_zone = each.value.az
	 
	 tags = {
	 
	  Name = each.value.name
	  
	  }
	  
 }	 

resource "aws_internet_gateway" "igw" {

   vpc_id = aws_vpc.newvpc.id
   
   tags = {
   
     Name = "My IGW" 
	 
	 }
	 
	}
	
resource "aws_route_table" "public_rt" {

   vpc_id = aws_vpc.newvpc.id
   
  route {
   
     cidr_block = "0.0.0.0/0"
	 gateway_id = aws_internet_gateway.igw.id
	 
	 }
 
   tags = {

  Name = "Public Route Table" 

  }

}  

resource "aws_route_table" "private_rt" {

   vpc_id = aws_vpc.newvpc.id

    route {
   
     cidr_block = "0.0.0.0/0"
	 gateway_id = aws_nat_gateway.mynat.id
	 
	 }
   
   tags = {

  Name = "Private Route Table" 

  }

} 

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public-subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private-subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}


 
