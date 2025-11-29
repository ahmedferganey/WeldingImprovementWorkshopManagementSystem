# Move to backend root
Set-Location (Split-Path $MyInvocation.MyCommand.Path -Parent)\..

# -------------------
# CONFIG VARIABLES
# -------------------
$AWS_REGION = "eu-central-1"
$IAM_USER = "workshop-deployer"
$S3_BUCKET = "workshop-uploads-$(Get-Date -UFormat %s)"
$DB_INSTANCE = "workshop-db"
$DB_NAME = "workshop"
$DB_USERNAME = "workshop"
$DB_PASSWORD = "StrongPasswordHere"
$DB_CLASS = "db.t3.micro"
$DB_SUBNET_GROUP = "workshop-subnets"
$VPC_SG = "sg-xxxxxx"           # Replace with your security group ID
$SUBNETS = "subnet-abc subnet-def"  # Replace with your subnet IDs

# -------------------
# 1️⃣ CREATE IAM USER
# -------------------
Write-Host "Creating IAM user: $IAM_USER"
try { aws iam create-user --user-name $IAM_USER } catch { Write-Host "User may already exist" }

# Check existing keys
$existingKeys = aws iam list-access-keys --user-name $IAM_USER | ConvertFrom-Json
if ($existingKeys.AccessKeyMetadata.Count -eq 0) {
    Write-Host "Creating new access keys..."
    $creds = aws iam create-access-key --user-name $IAM_USER | ConvertFrom-Json
} else {
    Write-Host "Using existing access keys (secret must be retrieved manually)"
    $creds = $existingKeys.AccessKeyMetadata[0]
    $creds.SecretAccessKey = "PLEASE_RETRIEVE_SECRET_FROM_AWS"
}

$ACCESS_KEY = $creds.AccessKeyId
$SECRET_KEY = $creds.SecretAccessKey

# Attach policies
$policies = @(
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
)
foreach ($policy in $policies) {
    try { aws iam attach-user-policy --user-name $IAM_USER --policy-arn $policy } catch {}
}

# -------------------
# 2️⃣ CREATE S3 BUCKET
# -------------------
Write-Host "Creating S3 bucket: $S3_BUCKET"
try { aws s3api create-bucket --bucket $S3_BUCKET --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION } catch { Write-Host "Bucket may exist" }

# -------------------
# 3️⃣ CREATE DB SUBNET GROUP
# -------------------
Write-Host "Creating DB subnet group: $DB_SUBNET_GROUP"
try { aws rds describe-db-subnet-groups --db-subnet-group-name $DB_SUBNET_GROUP } catch {
    aws rds create-db-subnet-group --db-subnet-group-name $DB_SUBNET_GROUP --db-subnet-group-description "Workshop DB subnets" --subnet-ids $SUBNETS
}

# -------------------
# 4️⃣ CREATE RDS INSTANCE
# -------------------
Write-Host "Creating RDS instance: $DB_INSTANCE"
try { aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE } catch {
    aws rds create-db-instance `
        --db-instance-identifier $DB_INSTANCE `
        --allocated-storage 20 `
        --db-instance-class $DB_CLASS `
        --engine mysql `
        --engine-version 8.0.34 `
        --master-username $DB_USERNAME `
        --master-user-password $DB_PASSWORD `
        --backup-retention-period 7 `
        --db-name $DB_NAME `
        --vpc-security-group-ids $VPC_SG `
        --db-subnet-group-name $DB_SUBNET_GROUP `
        --publicly-accessible $false
}

Write-Host "Waiting for RDS to become available..."
aws rds wait db-instance-available --db-instance-identifier $DB_INSTANCE
Write-Host "RDS instance is ready!"

# -------------------
# 5️⃣ GENERATE .ENV
# -------------------
$DB_HOST = aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE --query "DBInstances[0].Endpoint.Address" --output text

$envContent = @"
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
"@

$envContent | Out-File -FilePath ".env" -Encoding ascii
Write-Host ".env file created successfully in backend/"
