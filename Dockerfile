# Usa uma imagem oficial do Python leve
FROM python:3.10-slim

# Define o diretório de trabalho dentro do container
WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copia o ficheiro de requisitos e instala as bibliotecas Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia todo o código do seu projeto (incluindo o script .py e o modelo .h5/.keras)
COPY . .

# Expõe a porta padrão que o Streamlit utiliza
EXPOSE 8501

# Configurações do Streamlit para funcionar corretamente na nuvem AWS
ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]

