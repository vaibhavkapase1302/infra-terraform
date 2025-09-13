terraform {
  backend "s3" {
    bucket         = "my-terraform-backend-bucket-vk"
    # key            = "terraform/state/terraform.tfstate"
    region         = "ap-south-1"
    # dynamodb_table = "terraform-state-lock-vk"
    # encrypt        = true
  }
}
