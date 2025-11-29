#!/bin/bash
set -e

# Move to backend root
cd "$(dirname "$0")/../"

# -------------------
# CONFIG VARIABLES
# -------------------
AWS_REGION="eu-central-1"
IAM_USER="workshop-deployer"
S3_BUCKET="workshop-uploads-$(date +%s)"
DB_INSTANCE="workshop-db"
DB_NAME="workshop"
DB_USERNAME="workshop"
DB_PASSWORD="StrongPasswordHere"
DB_CLASS="db.t3.micro"
DB_SUBNET_GROUP="workshop-subnets"
VPC_SG="sg-xxxxxx"            # Replace with your security group ID
SUBNETS="subnet-abc subnet-def" # Replace with your subnet IDs

# -------------------
# 1️⃣ CREATE IAM USER
# -------------------
echo "Creating IAM user: $IAM_USER"
aws iam create-user --user-name $IAM_USER 2>/dev/null || echo "User already exists"

# Check existing keys
EXISTING_KEYS=$(aws iam list-access-keys --user-name $IAM_USER --query "AccessKeyMetadata" --output json)
if [ "$(echo $EXISTING_KEYS | jq length)" -eq 0 ]; then
    echo "Creating new access keys..."
    CREDS=$(aws iam create-access-key --user-name $IAM_USER)
else
    echo "Using existing access keys..."
    CREDS=$(aws iam list-access-keys --user-name $IAM_USER | jq '.AccessKeyMetadata[0]')
    ACCESS_KEY=$(echo $CREDS | jq -r '.AccessKeyId')
    SECRET_KEY="PLEASE_RETRIEVE_SECRET_FROM_AWS" # Secret not returned on list
fi

# If CREDS contains SecretAccessKey, assign
if [ -z "$ACCESS_KEY" ]; then
    ACCESS_KEY=$(echo $CREDS | jq -r '.AccessKey.AccessKeyId')
    SECRET_KEY=$(echo $CREDS | jq -r '.AccessKey.SecretAccessKey')
fi

# Attach policies
POLICIES=(
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess"
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
)
for policy in "${POLICIES[@]}"; do
    aws iam attach-user-policy --user-name $IAM_USER --policy-arn $policy 2>/dev/null || true
done

# -------------------
# 2️⃣ CREATE S3 BUCKET
# -------------------
echo "Creating S3 bucket: $S3_BUCKET"
aws s3api create-bucket \
    --bucket $S3_BUCKET \
    --region $AWS_REGION \
    --create-bucket-configuration LocationConstraint=$AWS_REGION 2>/dev/null || echo "Bucket may already exist"

# -------------------
# 3️⃣ CREATE DB SUBNET GROUP
# -------------------
echo "Creating DB subnet group: $DB_SUBNET_GROUP"
aws rds describe-db-subnet-groups --db-subnet-group-name $DB_SUBNET_GROUP >/dev/null 2>&1 || \
aws rds create-db-subnet-group \
    --db-subnet-group-name $DB_SUBNET_GROUP \
    --db-subnet-group-description "Workshop DB subnets" \
    --subnet-ids $SUBNETS

# -------------------
# 4️⃣ CREATE RDS INSTANCE
# -------------------
echo "Creating RDS instance: $DB_INSTANCE"
aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE >/dev/null 2>&1 || \
aws rds create-db-instance \
    --db-instance-identifier $DB_INSTANCE \
    --allocated-storage 20 \
    --db-instance-class $DB_CLASS \
    --engine mysql \
    --engine-version 8.0.34 \
    --master-username $DB_USERNAME \
    --master-user-password $DB_PASSWORD \
    --backup-retention-period 7 \
    --db-name $DB_NAME \
    --vpc-security-group-ids $VPC_SG \
    --db-subnet-group-name $DB_SUBNET_GROUP \
    --publicly-accessible false

echo "Waiting for RDS to become available..."
aws rds wait db-instance-available --db-instance-identifier $DB_INSTANCE
echo "RDS instance is ready!"

# -------------------
# 5️⃣ GENERATE .ENV
# -------------------
DB_HOST=$(aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE --query "DBInstances[0].Endpoint.Address" --output text)

cat > .env <<EOL
AWS_REGION=$AWS_REGION
AWS_ACCESS_KEY_ID=$ACCESS_KEY
AWS_SECRET_ACCESS_KEY=$SECRET_KEY
S3_BUCKET=$S3_BUCKET
DB_HOST=$DB_HOST
DB_PORT=3306
DB_NAME=$DB_NAME
DB_USER=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
FRONTEND_URL=https://weldingworkshop-f4697.web.app/
EOL

echo ".env generated in backend/ folder successfully"
