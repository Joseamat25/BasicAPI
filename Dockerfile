# Imagen base con Python 3.13
FROM python:3.13-slim

# Variables de entorno para evitar que Poetry cree una virtualenv dentro del contenedor
ENV POETRY_VIRTUALENVS_CREATE=false \
    POETRY_NO_INTERACTION=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Instalar dependencias del sistema necesarias para poetry y compilación
RUN apt-get update && apt-get install -y \
    curl build-essential libffi-dev libpq-dev gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar Poetry
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias primero (para aprovechar cache)
COPY BasicAPI/pyproject.toml BasicAPI/poetry.lock* ./

# Instalar dependencias (sin crear entorno virtual)
RUN poetry install --no-root

# Copiar el resto de archivos del proyecto
COPY . .

# Exponer el puerto 8000 para la aplicación
EXPOSE 8000

# Comando para ejecutar la aplicación
CMD ["poetry", "run", "uvicorn", "BasicAPI.main:app", "--host", "0.0.0.0", "--port", "8000"]
