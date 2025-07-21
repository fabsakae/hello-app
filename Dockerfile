# Usa uma imagem base oficial do Python para construir a aplicação
FROM python:3.9-slim-buster

# Define o diretório de trabalho dentro do container
WORKDIR /app

# Copia os arquivos de requisitos e instala as dependências
# Para FastAPI, precisaremos de `fastapi` e `uvicorn`
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copia o código da sua aplicação para o diretório de trabalho
COPY . .

# Expõe a porta em que a aplicação FastAPI será executada
EXPOSE 8000

# Comando para rodar a aplicação usando Uvicorn (servidor ASGI)
# O --host 0.0.0.0 permite que a aplicação seja acessível de fora do container
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]