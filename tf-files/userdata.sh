#! /bin/bash
# Bash script to set up environment and deploy a Flask application on AWS EC2 instance

# Update system packages
dnf update -y 

# Install pip for Python package management
dnf install python3-pip -y

# Install Flask framework version 2.3.3
pip3 install flask==2.3.3

# Install flask_mysql library for Flask to interact with MySQL databases
pip3 install flask_mysql

# Install Git for version control
dnf install git -y

# Set environment variables from user data (provided during instance launch) 
TOKEN=${user-data-git-token}
USER=${user-data-git-name}

# Change directory to home directory and clone the Git repository
cd /home/ec2-user && git clone https://$TOKEN@github.com/$USER/order-table.git

# Set environment variable for MySQL database endpoint (replace with actual endpoint)
export MYSQL_DATABASE_HOST=${db-endpoint}

# Execute the Python script to run the Flask application
python3 /home/ec2-user/order-table/ordertable-app.py
