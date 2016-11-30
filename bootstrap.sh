#!/bin/bash

scp -i ~/.ssh/access.pem install.zip ec2-user@$IP:/tmp/
scp -i ~/.ssh/access.pem install.sh ec2-user@$IP:/tmp/
ssh -i ~/.ssh/access.pem ec2-user@$IP "sudo /tmp/install.sh"
