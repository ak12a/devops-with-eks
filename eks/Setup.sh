

echo " ####################### Start Learning Devops #################"

echo "Install prerequisities software for devops usages"

echo "Installing  Maven" 
cd /opt
wget https://dlcdn.apache.org/maven/maven-3/3.9.3/binaries/apache-maven-3.9.3-bin.zip
unzip apache-maven-3.9.3-bin.zip
ln -s apache-maven-3.9.3 apache-maven
touch /etc/profile.d/maven.sh
echo "export MAVEN_HOME=/opt/apache-maven" >> /etc/profile.d/maven.sh
echo "export PATH=$PATH:$MAVEN_HOME/bin" >> /etc/profile.d/maven.sh

echo "####################################################"

echo " Installing Jenkins"
cd /opt/
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum upgrade
amazon-linux-extras install java-openjdk11 -y
yum install jenkins -y
systemctl enable --now  jenkins

echo "#############################################################"

echo " ############# Installing docker###############"
yum install docker -y
usermod -aG docker jenkins 
systemctl enable --now  docker
echo " ########### Docker installation completed #####" 
echo "#######################################################"
echo "####################### Installing ansible #################" 
yum -y install python3
amazon-linux-extras install ansible2


echo "############ Attach the iam role to EC2 Instances for administartion purpose ##########"

echo "################# Install Kubectl#####################"
#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.15/2023-01-11/bin/linux/amd64/kubectl
chmod +x  kubectl
mv kubectl /bin/
kubectl version --client  --short
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
sudo chmod a+r /etc/bash_completion.d/kubectl
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc
echo "done"


echo " ############# Installing eksctl ################"
wget https://github.com/eksctl-io/eksctl/releases/download/v0.150.0/eksctl_Linux_amd64.tar.gz
tar -xvf eksctl_Linux_amd64.tar.gz
mv eksctl /bin/
rm -rf eksctl_Linux_amd64.tar.gz
eksctl version


echo ### creating eks cluster ###################
eksctl create cluster --name=devops \
     --region=us-east-1 \
     --zones=us-east-1a,us-east-1b \
     --without-nodegroup

echo " Associate OIDC with VM"

eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster devops --approve 

################# Create node Group ############

eksctl create nodegroup --name demo --cluster devops --region us-east-1 --node-type=t3a.medium --nodes=2 --nodes-min=1 --nodes-max=2 --ssh-access --ssh-public-key=arvind-eks --managed --asg-access --external-dns-access --alb-ingress-access --full-ecr-access --appmesh-access




##### Get Kubeconfig ####
aws eks update-kubeconfig --name devops --region us-east-1

#### Create fargate Profile ###
## Fargate Profile is like a node Group in which you do not need to manage the worker node. you can attach fargate profile with namespace and request the desided resources like CPU,RAM

eksctl create fargateprofile --name common-app --namespace=kube-system , default --labels="deployment=common" --cluster $EKS_CLUSTER_NAME --region $REGION  


eksctl create fargateprofile --name common --selector=[{namespace="default"}, {namespace="kube-system"}]  --cluster $EKS_CLUSTER_NAME --region $REGION 

###Install helm ###
wget https://get.helm.sh/helm-v3.12.2-linux-amd64.tar.gz
tar -xvf helm-v3.12.2-linux-amd64.tar.gz 
chmod +x linux-amd64/helm 
mv linux-amd64/helm /bin/
rm -rf linux-amd64 # delete unwated folders 
rm -rf helm-v3.12.2-linux-amd64.tar.gz 
helm version --short # verify the Helm version 



############## Install Istio #########


export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo -y 



############# Delete the resources 
eksctl delete nodegroup --name demo --cluster devops --region us-east-1
