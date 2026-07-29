# 1. Cria o Repositório de Imagens Docker (Amazon ECR)
resource "aws_ecr_repository" "app" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"
}

# 2. Permissão para o App Runner puxar imagens do ECR
resource "aws_iam_role" "apprunner_ecr_role" {
  name = "${var.app_name}-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { 
        Service = "build.apprunner.amazonaws.com" 
      }
    }]
  })
}



resource "aws_iam_role_policy_attachment" "apprunner_ecr_policy" {
  role       = aws_iam_role.apprunner_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}


# 3. O Serviço App Runner
resource "aws_apprunner_service" "streamlit" {
  service_name = var.app_name

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_ecr_role.arn
    }
    image_repository {
      image_identifier      = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
      image_repository_type = "ECR"
      image_configuration {
        port          = "8501"
        start_command = "streamlit run app.py --server.port=8501 --server.address=0.0.0.0"
      }
    }
    auto_deployments_enabled = false
  }

  # REMOVEMOS O BLOCO DE HEALTH CHECK DAQUI

  instance_configuration {
    cpu    = "2048" # Mantemos os 4GB de RAM para o Keras rodar folgado
    memory = "4096" 
  }
}


output "app_runner_url" {
  value = aws_apprunner_service.streamlit.service_url
}

