variable "subnet1" {
  description = "Configuration for subnet1"
  type        = map(any)
  default = {
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    name              = "subnet1"
  }

}

variable "subnet2" {
  description = "Configuration for subnet2"
  type        = map(any)
  default = {
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    name              = "subnet2"

  }

}  