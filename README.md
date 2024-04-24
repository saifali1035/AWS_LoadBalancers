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
1. Create inbound and outbound rules *In our case we will create an App that will be running on port 8000 so we will create inbound rule to allow traffic from anywhere on port 8080 and outbound we will allow outbound traffic to the set instance security groups*


Under **Listeners and routing**
1. Set the Protocol and Port - *In our case it will be HTTP and 8000*
2. In this stage we will be asked to select or create a taget group where our requests will be routed.
   
   2.1 Lets create , Under **Basic configuration** select Instances.
   
   2.2 Set a **Target group name** and set the port.
   
   2.3 Click on create and you will be redirected to a page where you need to register the instances.
   
   2.4 Create EC2 instances if not already created with below user data and register them as targets.
   
```HTML
touch index.html
cat <<EOT >> index.html
<!doctype html>
<html>
  <head>
    <title>This is the title of the webpage!</title>
  </head>
  <body>
          <p>This response is from ec2 instance</p>
  </body>
</html>
EOT

python3 -m http.server 8000
```   

