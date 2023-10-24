#!/bin/bash
### Update attached entities to latest policy version as announced by AWS

OLD_POLICY_ARN="arn:aws:iam::aws:policy/CloudWatchFullAccess"
NEW_POLCIY_ARN="arn:aws:iam::aws:policy/CloudWatchFullAccessV2"
IAM_ROLES=( $(aws iam list-entities-for-policy --policy-arn ${OLD_POLICY_ARN} | jq -r '.PolicyRoles[].RoleName') )
IAM_USERS=( $(aws iam list-entities-for-policy --policy-arn ${OLD_POLICY_ARN} | jq -r '.PolicyUsers[].UserName') )
IAM_GROUPS=( $(aws iam list-entities-for-policy --policy-arn ${OLD_POLICY_ARN} | jq -r '.PolicyGroups[].GroupName') )

### IAM ROLES
if [ ${#IAM_ROLES[@]} -gt 0 ]; then
    for i in ${!IAM_ROLES[@]}
        do
            aws iam attach-role-policy --role-name ${IAM_ROLES[$i]} --policy-arn ${NEW_POLCIY_ARN}
            echo ${IAM_ROLES[$i]}
            aws iam detach-role-policy --role-name ${IAM_ROLES[$i]} --policy-arn ${OLD_POLICY_ARN}
            unset IAM_ROLES[$i]
        done
else
    echo "No roles attached to ${OLD_POLICY_ARN} :)"
fi

### IAM USERS
if [ ${#IAM_USERS[@]} -gt 0 ]; then
    for i in ${!IAM_USERS[@]}
        do
            aws iam attach-user-policy --user-name ${IAM_USERS[$i]} --policy-arn ${NEW_POLCIY_ARN}
            echo ${IAM_USERS[$i]}
            aws iam detach-user-policy --user-name ${IAM_USERS[$i]} --policy-arn ${OLD_POLICY_ARN}
            unset IAM_USERS[$i]
        done
else
    echo "No users attached to ${OLD_POLICY_ARN} :)"
fi

### IAM GROUPS
if [ ${#IAM_GROUPS[@]} -gt 0 ]; then
    for i in ${!IAM_GROUPS[@]}
        do
            aws iam attach-group-policy --group-name ${IAM_GROUPS[$i]} --policy-arn ${NEW_POLCIY_ARN}
            echo ${IAM_GROUPS[$i]}
            aws iam detach-group-policy --group-name ${IAM_GROUPS[$i]} --policy-arn ${OLD_POLICY_ARN}
            unset IAM_GROUPS[$i]
        done
else
    echo "No groups attached to ${OLD_POLICY_ARN} :)"
fi
