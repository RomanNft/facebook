#!/bin/bash
git clone -b main https://github.com/RomanNft/facebook.git > /var/log/terraform-init.log 2>&1
cd facebook
bash setup.sh >> /var/log/terraform-init.log 2>&1
bash installJenkins.sh >> /var/log/terraform-init.log 2>&1
