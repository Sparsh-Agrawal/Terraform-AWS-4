![](images/terraws.png)
# Terraform-AWS-4
Terraform is an open-source tool created by **HashiCorp**. It is used for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions. </br>

#### Statement:
Perform [`task-3`](https://github.com/Sparsh-Agrawal/Terraform-AWS-3) with an additional feature to be added that is NAT Gateway to provide the internet access to instances running in the private subnet.

Performing the following steps:
* Write an Infrastructure as code using terraform, which automatically create a VPC.
* In that VPC we have to create 2 subnets:
<br>  a) public  subnet [ Accessible for Public World! ] 
<br>  b) private subnet [ Restricted for Public World! ]
* Create a public facing internet gateway for connect our VPC/Network to the internet world and attach this gateway to our VPC.
* Create  a routing table for Internet gateway so that instance can connect to outside world, update and associate it with public subnet.
* Create a NAT gateway for connect our VPC/Network to the internet world  and attach this gateway to our VPC in the public network
* Update the routing table of the private subnet, so that to access the internet it uses the nat gateway created in the public subnet
* Launch an ec2 instance which has Wordpress setup already having the security group allowing  port 80 sothat our client can connect to our wordpress site. Also attach the key to instance for further login into it.
* Launch an ec2 instance which has MYSQL setup already with security group allowing  port 3306 in private subnet so that our wordpress vm can connect with the same. Also attach the key with the same.

**Note:** Wordpress instance has to be part of public subnet so that our client can connect our site. 
mysql instance has to be part of private  subnet so that outside world can't connect to it.
Don't forgot to add auto ip assign and auto dns name assignment option to be enabled.

Here I have created a infrastructure in **HCL (Hashicorp Configuration Language)** which consists of 
<br/>

* Create a VPC.                                                                     
![](images/vpc.png)

* Create a public subnet which auto-assign Public IP.                                          
![](images/publicsubnet.png)

* Create a private subnet.                                                           
![](images/privatesubnet.png)

* Create a Internet Gateway and attach it to VPC.                                          
![](images/ig.png)

* Associate an Elastic IP Address to VPC.                         
![](images/eip.png)

* Create a NAT Gateway and attach it to public subnet.               
![](images/nat.png)

* Create a routing table stating the route to Internet Gateway for the VPC.
![](images/routetableig.png)

* Create a routing table stating the route to NAT Gateway for the VPC.
![](images/routetablenat.png)

* Associate the route table to the Public Subnet and Private Subnet respectively.                                            
![](images/routeass.png)

* Create a Key to log in to the EC2 instance or to connect to it via SSH to run commands.
![](images/key.png)

* Save the key locally for the further use.                                               
![](images/keys.png)

* Create a security group for the WordPress instance, and provide inbound and outbound rules.
![](images/sgw.png)

* Create a security group for the Bastion Host instance, and provide inbound and outbound rules.
![](images/sgbh.png)

* Create a security group for the MySQL instance, and provide inbound and outbound rules.
![](images/sgs.png)

* Create an AWS instance, using WordPress AMI provided by Bitnami.                                   
![](images/wpinstance.png)

* Create an AWS instance, using Amazon Linux 2 AMI (HVM) which already have MySQL installed.
![](images/sqlinstance.png)

* Create an AWS instance, using Amazon Linux 2 AMI (HVM) as the Bastion Host.
![](images/bhinstance.png)

* Launch the webpage on the CHROME using WordPress Instance Public_IP.              
![](images/chrome.png)

### For reference<br/>
[`Infrastructure.tf`](https://github.com/Sparsh-Agrawal/Terraform-AWS-4/blob/master/infra.tf)

[`LinkedIn`]()
