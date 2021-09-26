resource "aws_security_group" "allow_http_new" {
  name        = "allow_http_new"
  description = "Allow http inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ssh_new" {
  name        = "allow_ssh_new"
  description = "Allow ssh inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_jenkins_new" {
  name        = "allow_jenkins_new"
  description = "Allow Jenkins inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins-instance1" {
  ami           = "ami-00399ec92321828f5"
  instance_type = "t2.small"
  user_data = "${file("install_jenkins.sh")}"
  tags = {
    Name = "${var.instance_name1}"
  }
  key_name        = "${var.keyname}"
  security_groups = [ "${aws_security_group.allow_http_new.name}", "${aws_security_group.allow_ssh_new.name}", "${aws_security_group.allow_jenkins_new.name}" ] 
  #provisioner "local-exec" {
  #  command = "(gc jenkins_slave.sh) -replace '<master-ip-addr>', '${aws_instance.jenkins-instance1.private_ip}' | Out-File -encoding ASCII jenkins_slave.sh"
	#interpreter = ["PowerShell", "-Command"]
  #  command = "bash jenkins_slave.sh -replace '<master-ip-addr>', '${aws_instance.jenkins-instance1.private_ip}' "
  #}

    provisioner "file" {
    source      = "./ansible-jenkins"
    destination = "/tmp/ansible-jenkins"
  }
	connection {
    type        = "ssh"
	  host        = self.public_ip
    private_key = "${file("jump-server-key.pem")}"
    user        = "ubuntu"
  } 
  
  provisioner "remote-exec" {
    inline = [
      #"sleep 2m; cd /tmp/ansible-jenkins/; sleep 5s; ansible-playbook -i 127.0.0.1 jenkins.yml"
      "sleep 1m; ls -l /tmp; sudo apt-get -y update; sleep 10s; sudo apt-get install python3-pip -y; sleep 10s; sudo pip install -U pip; sleep 10s; sudo -H pip install ansible; sleep 1m; cd /tmp/ansible-jenkins/; sleep 5s; ansible-playbook -i 127.0.0.1 jenkins.yml;sudo apt-get install openjdk-11-jdk -y;sudo apt-get install maven -y; cd /tmp/ansible-jenkins/ansible_jobs; ansible-playbook -i 127.0.0.1 create_job.yaml"
    ]
	connection {
    type        = "ssh"
	  host        = self.public_ip
    private_key = "${file("jump-server-key.pem")}"
    user        = "ubuntu"
  }  
  } 
  
  

  }





resource "aws_instance" "jenkins-instance2" {
  ami           = "ami-00399ec92321828f5"
  instance_type = "t2.micro"
  user_data = "${file("jenkins_slave.sh")}"
  depends_on = [aws_instance.jenkins-instance1]
  tags = {
    Name = "${var.instance_name2}"
  }
  key_name        = "${var.keyname}"
  security_groups = [ "${aws_security_group.allow_http_new.name}", "${aws_security_group.allow_ssh_new.name}", "${aws_security_group.allow_jenkins_new.name}" ] 
  
  }
output "jenkins_ip_address" {
  value = "${aws_instance.jenkins-instance1.private_ip}"
  
  }
