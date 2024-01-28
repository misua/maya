provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.1.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"
  subnets         = module.vpc.private_subnets

  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 10
      min_capacity     = 1

      instance_type = "t3.medium"
      key_name      = "my-key-name"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = module.eks.cluster_oidc_issuer_url
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "simple-webapp"
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        App = "simple-webapp"
      }
    }

    template {
      metadata {
        labels = {
          App = "simple-webapp"
        }
      }

      spec {
        container {
          image = "<aws_account_id>.dkr.ecr.<region>.amazonaws.com/simple-webapp:latest"
          name  = "simple-webapp"
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = "simple-webapp"
  }

  spec {
    selector = {
      App = "simple-webapp"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_ingress" "app" {
  metadata {
    name = "simple-webapp"
  }

  spec {
    rule {
      host = "maya.com.ph"

      http {
        path {
          path = "/health"

          backend {
            service_name = kubernetes_service.app.metadata[0].name
            service_port = 8080
          }
        }
      }
    }
  }
}