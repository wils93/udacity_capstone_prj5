#!/bin/bash

./run.sh servers delete

./run.sh network delete

./run.sh network create

./run.sh servers create

export load_balancer_link=`aws elbv2 describe-load-balancers \
    --names capstone-LoadBalancer \
    --query 'LoadBalancers[*].[DNSName]' \
    --output text | awk '{print tolower($0)}'`

yq e -i '.spec.rules[0].host = env(load_balancer_link)' \
    k8s/ingress.yaml 

backend_ip=`aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].PublicIpAddress' \
    --filters "Name=tag:Name,Values=capstone-AutoscalingGroup" \
    --output text`

echo $backend_ip >> ansible/inventory.txt

pushd ansible \
    && ansible-playbook -i inventory.txt \
    setup-server.yaml \
    --extra-vars "backend_ip=$backend_ip" \
    --extra-vars "ansible_ssh_private_key_file=capstone.pem" \
    && popd

sed -i '2d' ansible/inventory.txt

yq e -i '(.Resources.cloudfrontdistribution.Properties.DistributionConfig.Origins[0].Id,
    .Resources.cloudfrontdistribution.Properties.DistributionConfig.Origins[0].DomainName,
    .Resources.cloudfrontdistribution.Properties.DistributionConfig.DefaultCacheBehavior.TargetOriginId)
    = env(load_balancer_link)' \
    cloudformation/cloudfront.yaml

./run.sh cloudfront update

cloudfront_link=`aws cloudfront list-distributions --query \
    "DistributionList.Items[].{DomainName: DomainName, OriginDomainName: Origins.Items[0].DomainName}
    [?contains(OriginDomainName, '${load_balancer_link}')] | [0] | DomainName"`

echo You can now visit: $cloudfront_link