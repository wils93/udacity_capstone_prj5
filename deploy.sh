#!/bin/bash

./run.sh servers delete

./run.sh network delete

./run.sh network create

./run.sh servers create

export load_balancer_link=`aws elbv2 describe-load-balancers \
    --names capstone-LoadBalancer \
    --query 'LoadBalancers[*].[DNSName]' \
    --output text | awk '{print tolower($0)}'`

echo "LoadBalancer URL: " $load_balancer_link

yq e -i '.spec.rules[0].host = env(load_balancer_link)' \
    k8s/ingress.yaml 

backend_ip=`aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].PublicIpAddress' \
    --filters "Name=tag:Name,Values=capstone-AutoscalingGroup" \
    --output text`

echo "Backend IP: " $backend_ip
echo $backend_ip >> ansible/inventory.txt

cat ansible/inventory.txt

cd ansible
ansible-playbook -i inventory.txt \
    setup-server.yaml \
    --extra-vars "backend_ip=$backend_ip"
    # --extra-vars "ansible_ssh_private_key_file=capstone.pem" \
cd ..

sed -i '2d' ansible/inventory.txt

yq e -i '(.Resources.capstonecloudfrontdistribution.Properties.DistributionConfig.Origins[0].Id,
    .Resources.capstonecloudfrontdistribution.Properties.DistributionConfig.Origins[0].DomainName,
    .Resources.capstonecloudfrontdistribution.Properties.DistributionConfig.DefaultCacheBehavior.TargetOriginId)
    = env(load_balancer_link)' \
    cloudformation/cloudfront.yaml

./run.sh cloudfront update

cloudfront_link=`aws cloudfront list-distributions --query \
    "DistributionList.Items[].{DomainName: DomainName, OriginDomainName: Origins.Items[0].DomainName}
    [?contains(OriginDomainName, '${load_balancer_link}')] | [0] | DomainName"`

echo You can now visit: $cloudfront_link