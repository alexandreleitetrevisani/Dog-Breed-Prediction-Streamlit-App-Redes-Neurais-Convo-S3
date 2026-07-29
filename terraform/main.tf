# 1. Cria o Novo Repositório de Imagens Docker (Amazon ECR)
resource "aws_ecr_repository" "app_new" {
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
        Service = "://amazonaws.com" 
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr_policy" {
  role       = aws_iam_role.apprunner_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# 3. O Serviço AWS App Runner
resource "aws_apprunner_service" "streamlit" {
  service_name = var.app_name

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_ecr_role.arn
    }

    image_repository {
      image_identifier      = "${aws_ecr_repository.app_new.repository_url}:${var.image_tag}"
      image_repository_type = "ECR"
      image_configuration {
        port          = "8501"
        start_command = "streamlit run app.py --server.port=8501 --server.address=0.0.0.0"
      }
    }

    auto_deployments_enabled = false # <-- POSIÇÃO CORRETA: Fica ANTES de fechar o source_configuration
  } # <-- Linha 51: Aqui sim fecha o source_configuration

  instance_configuration {
    cpu    = "2048" # 2 vCPU
    memory = "4096" # 4 GB RAM para suportar o modelo Keras de 707 MB
  }
}

# 4. Output para exibir o link final no painel do GitHub Actions
output "app_runner_url" {
  value = aws_apprunner_service.streamlit.service_url
}

