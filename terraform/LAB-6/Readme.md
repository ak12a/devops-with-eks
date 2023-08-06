# Setup Ansible server  and Inventory 

## *In This we will launch Configure Ansible sever and ansible server will do the following tasks*
1. *On Jenkins-Master in will install jenkins server package*
2. *On Jenkins-Slave in will install Java,Maven,node and other build tools*
3. *On Ansible Server we will be setup inventory of both Jenkins-master and slave so the Ansible can manage it.


# Install Ansible on server 
**Take the SSH to snasible server and run the following commands** 

    $ sudo apt update
    $ sudo apt install software-properties-common
    $ sudo add-apt-repository --yes --update ppa:ansible/ansible
    $ sudo apt install ansible
    $ ansible --version

