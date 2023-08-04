

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
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
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

eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster devop --approve 
