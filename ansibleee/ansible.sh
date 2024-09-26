sudo apt update
sudo apt install ansible -y
ansible --version
apt install sshpass
ansible-galaxy collection install community.docker
apt update
ansible-playbook -i inventory.ini playbook/ping.yml playbook/docker.yml playbook/jenkins.yml playbook/kubernetes.yml playbook/terraform.yml --ask-pass --ask-become-pass





