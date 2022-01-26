terraform {
  cloud {
    organization = "intugine"

    workspaces {
      name = "Jenkins"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.1.0"
}

provider "aws" {
  profile = "sandbox"
  region  = var.region
}
