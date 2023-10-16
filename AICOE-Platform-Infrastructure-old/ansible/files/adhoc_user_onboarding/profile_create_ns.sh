#!/bin/bash
namespace=$1
admin=$2
users=$3

#Create an IAM role and policy for the profile
aws s3api create-bucket \
    --bucket {{ cluster_name }}-storage-"$namespace" \
    --acl private \
    --region us-east-1

echo "created S3 bucket"
echo "restricting bucket public access"

aws s3api put-public-access-block \
    --bucket {{ cluster_name }}-storage-"$namespace" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "restricted bucket public access"

echo "adding S3 bucket policy"
policy_doc=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Id": "SecurePolicy",
    "Statement": [
        {
            "Sid": "AllowSSLRequestsOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::{{ cluster_name }}-storage-$namespace",
                "arn:aws:s3:::{{ cluster_name }}-storage-$namespace/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
EOF
)

aws s3api put-bucket-policy --bucket {{ cluster_name }}-storage-"$namespace" --policy "$policy_doc"
echo "added S3 bucket policy"

#Create an IAM role and policy for the profile
policy_name="s3bucketaccess-{{ cluster_name }}-$namespace"
policy_desc="to allow access to $namespace bucket"
policy_doc=$(cat <<EOF
{   
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "NotAction": "s3:*",
            "Resource": "*"
        },
        {
            "Action": "s3:*",
            "Effect": "Deny",
            "NotResource": [
                "arn:aws:s3:::{{ bucket }}-$namespace",
                "arn:aws:s3:::{{ bucket }}-$namespace/*"
            ]
        },
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::{{ bucket }}-$namespace",
                "arn:aws:s3:::{{ bucket }}-$namespace/*"
            ],
            "Sid": "AllowAllS3ActionsInUserFolder"
        },
        {
            "Action": [
                "s3:DeleteBucket"
            ],
            "Effect": "Deny",
            "Resource": "*",
            "Sid": "DenyDeleteOfBucket"
        }
    ]
}
EOF
)

echo "Creating IAM policy"
policy_arn=$(aws iam create-policy --policy-name $policy_name --description "$policy_desc" --policy-document "$policy_doc" --query "Policy.Arn" --output text --region us-east-1)

echo "Creating IAM role trust policy"
role_trust_policy=$(cat << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::{{ aws_account_id }}:oidc-provider/{{ oidc_url }}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "{{ oidc_url }}:sub": "system:serviceaccount:$namespace:default-editor",
                    "{{ oidc_url }}:aud": "sts.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
)
echo "Creating IAM role"
role_name=$(aws iam create-role --role-name "$namespace-{{ team}}-eks-cluster-role" --assume-role-policy-document "${role_trust_policy}" --query "Role.RoleName" --output text --region us-east-1)

echo "Attaching IAM policy with IAM role"
aws iam attach-role-policy --policy-arn $policy_arn --role-name $role_name


# apply profile policy for namespace admin
echo "Creating namespace admin profile"
cat profile.yaml | sed  -e "s/NAMESPACE/$namespace/g" | sed  -e "s/USERNAME/$admin/g" | kubectl apply -f -

echo "Creating setup for kubeflow pipelines"
echo "Applying envoy filter"
cat profile-envoyfilter.yaml | sed  -e "s/NAMESPACE/$namespace/g" | sed  -e "s/USERNAME/$admin/g" | kubectl apply -f -
echo "Applying authorization policy"
cat profile-authpolicy-ns.yaml | sed  -e "s/NAMESPACE/$namespace/g" | kubectl apply -f -
echo "Applying poddefault template"
cat profile-poddefault.yaml | sed  -e "s/NAMESPACE/$namespace/g" | kubectl apply -f -

export profile="cluster.local/ns/$namespace/sa/default-editor"
current_profiles=`kubectl get authorizationpolicies.security.istio.io -n kubeflow bind-ml-pipeline-nb -o json`
echo "$current_profiles" | jq '.spec.rules[0].from[0].source.principals += [env.profile]' | kubectl apply -f -

# apply role binding and auth policy for all users
echo "Adding users to the namespace"
for i in $users
do
    cat authpol.yaml | sed  -e "s/NAMESPACE/$namespace/g" | sed  -e "s/USERNAME/$i/g" | kubectl apply -f -
    cat rolebind.yaml | sed  -e "s/NAMESPACE/$namespace/g" | sed  -e "s/USERNAME/$i/g" | kubectl apply -f -
done