#region     = "us-east-1"
#access_key = "AKIAUVOVSEDO2GUNNWM"
#secret_key = "bz0RTnPZcyRuVv2/EMoFDyeetW9SkOco61hQq25"

vpc_cidr_block              = "10.0.0.0/16"
public_subnets_cidr_blocks  = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnets_cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24"]
availability_zones          = ["us-east-1a", "us-east-1b"]

ami_id = "ami-0005e0cfe09cc9050"