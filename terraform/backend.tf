terraform {
    backend "s3" {
        bucket = "myapp-bucket"
        key = "myapp/state.tfstate"
        region = "us-east-1"
    }
}