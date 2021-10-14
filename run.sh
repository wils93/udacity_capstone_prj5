#!/bin/bash
create ()
{
    echo Creating ${stack_name} stack
    aws cloudformation create-stack \
        --stack-name ${stack_name} \
        --template-body file://${scripts_path}${template_body} \
        --parameters file://${scripts_path}${parameters} \
        --tags Key=Name,Value=${environment_name} \
        --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" \
        --region=us-east-2

    aws cloudformation wait \
        stack-create-complete \
        --stack-name $stack_name
}

update ()
{
    echo Updating ${stack_name} stack
    aws cloudformation update-stack \
        stack-name ${stack_name} \
        template-body file://${scripts_path}${template_body} \
        --parameters file://${scripts_path}${parameters} \
        --tags Key=Name,Value=${environment_name} \
        --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" \
        --region=us-east-2
    
    aws cloudformation wait \
        stack-update-complete \
        --stack-name $stack_name
}

delete ()
{
    echo Deleting ${stack_name} stack
    aws cloudformation delete-stack \
        --stack-name ${stack_name}
        
    aws cloudformation wait \
        stack-delete-complete \
        --stack-name $stack_name        
}

main()
{
    if [ -z "$stack" ]; then
        echo "Please define the needed stack"
        echo "e.g. ./run.sh <stack> <function>"
        exit 1
    fi

    # if [ "$stack" == "servers" ]; then
    #     echo "Capturing local IP..."
    #     myIp=$(curl -s ifconfig.co)/32
    #     echo "Updating ${stack}-params.json with local IP: ${myIp}"
    #     sed -i "4s|\"ParameterValue\":.*|\"ParameterValue\": \"${myIp}\"|g" ${parameters}
    # fi

    if [[ $(type -t $function) == function ]]; then
        $function
    else
        echo "$function isn't a supported function!"
        exit 1
    fi
}

scripts_path=cloudformation/
environment_name=capstone
stack=$1
stack_name=$environment_name-$stack
template_body=$stack.yaml
parameters=$stack-params.json
function=$2

main