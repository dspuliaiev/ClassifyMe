FROM python:3.12-slim AS builder

# Встановлюємо змінні оточення
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Встановлюємо необхідні пакети
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    libpq-dev \
    cmake \
    libhdf5-dev \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Встановлюємо робочий каталог
WORKDIR /app

# Копіюємо файли залежностей
COPY pyproject.toml poetry.lock /app/

# Встановлюємо Poetry
RUN pip install --upgrade pip \
    && pip install poetry

# Конфігуруємо Poetry для встановлення залежностей без створення віртуального оточення
RUN poetry config virtualenvs.create false

# Встановлюємо залежності
RUN poetry install --no-dev

# Stage 2: Final
FROM python:3.12-slim

# Встановлюємо змінні оточення
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Встановлюємо необхідні пакети
RUN apt-get update && \
    apt-get install -y \
    libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Встановлюємо робочий каталог
WORKDIR /app

# Копіюємо залежності з етапу зборки
COPY --from=builder /usr/local /usr/local

# Копіюємо весь вихідний код в контейнер
COPY . /app/

# Вказуємо порт
EXPOSE 8000

# Команда для запуску програми з параметром таймауту воркерів
CMD ["gunicorn", "--worker-class", "gevent", "root.wsgi:application", "--bind", "0.0.0.0:8001", "--timeout", "300"]
