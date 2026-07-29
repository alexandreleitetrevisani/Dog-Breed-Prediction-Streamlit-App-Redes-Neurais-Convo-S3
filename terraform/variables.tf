variable "aws_region" {
  type    = string
  default = "us-east-1"
}


variable "app_name" {
  type    = string
  default = "streamlit-dog-app" # Mudado de "streamlit-dog-classifier" para evitar o conflito
}


variable "image_tag" {
  type    = string
  default = "latest"
}

