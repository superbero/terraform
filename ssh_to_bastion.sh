

#echo " change the permission of the ssh key to 400"
#chmod 400 "/Users/admin/Desktop/script/Terraform/exam_BINKO_ONESiME/connect_to_bastion.pem"
echo " Enter the ip of the bastion server: "
read ip_address
echo " ssh command to bastion"
ssh -A -i "/Users/admin/Desktop/script/Terraform/exam_BINKO_ONESiME/connect_to_bastion.pem" ubuntu@$ip_address -p 22