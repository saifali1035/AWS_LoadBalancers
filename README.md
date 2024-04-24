# AWS_LoadBalancers
AWS Load Balancers

Link to access LBs - https://ap-south-1.console.aws.amazon.com/ec2/home?region=ap-south-1#LoadBalancers:
<img width="670" alt="image" src="https://github.com/saifali1035/AWS_LoadBalancers/assets/37189361/1d24147e-18f1-4d45-9ae2-8e186f33770c">

As the name states LBs are used to balance the load or traffic between the target groups that you define for the LBs.

Below the 3 LBs available in AWS to use (Classic LB can be created but is not suggested by AWS) .

<img width="635" alt="image" src="https://github.com/saifali1035/AWS_LoadBalancers/assets/37189361/7ef95fc0-5e3e-4178-979c-74edf903778a">

# 1. Application Load Balancer (HTTP / HTTPS)

Steps to create.
Under **Basic configuration**
1. Give your LB a name under **Load balancer name**.
2. Under **Scheme** set it as **Internet-facing**
Under **Network mapping**
1. Under **VPC** select your VPC if you have one or AWS Default VPC will be selected.
2. In **Mappings** select the pulic AZs.
Under **Security groups**

