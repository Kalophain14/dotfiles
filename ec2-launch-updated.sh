# =============================================================
# Add this near your existing EC2 functions in ~/.zshrc
# =============================================================

ec2-launch() {
  local state ami sg id ip
  state=$(aws ec2 describe-instances --instance-ids $EC2_ID \
    --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null)
  if [[ $state == (pending|running|stopping|stopped) ]]; then
    echo "Instance $EC2_ID already exists ($state). Use ec2-start."
    return 1
  fi
  ami=$(aws ssm get-parameter \
    --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
    --query Parameter.Value --output text) || return
  sg=$(aws ec2 describe-security-groups --group-names ssh-only \
    --query 'SecurityGroups[0].GroupId' --output text) || return
  id=$(aws ec2 run-instances --image-id $ami --instance-type t3.micro \
    --key-name my-ec2-key --security-group-ids $sg \
    --query 'Instances[0].InstanceId' --output text) || return
  echo "Launching $id..."
  aws ec2 wait instance-running --instance-ids $id

  if grep -q '^export EC2_ID=' ~/.zshrc; then
    sed -i '' "s/^export EC2_ID=.*/export EC2_ID=$id/" ~/.zshrc
  else
    printf '\nexport EC2_ID=%s\n' $id >> ~/.zshrc
  fi
  export EC2_ID=$id

  ip=$(aws ec2 describe-instances --instance-ids $id \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

  echo "Instance running at $ip — provisioning shell now..."
  ~/dotfiles/ec2-provision.sh "$ip"
}
