#!/bin/bash
CLUSTER="ecs-cluster-adtech-dev"
servicelist=($(aws ecs list-services --cluster ${CLUSTER} | jq .serviceArns[] | sed 's/.*\///; s/\/$//; s/"$//'))


for i in ${servicelist[@]}
    do  
        aws ecs update-service --force-new-deployment --service ${i} --cluster ${CLUSTER} 2>&1 > /dev/null
    done
