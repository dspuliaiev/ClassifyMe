# Stage 1: Build
FROM python:3.11-slim AS builder

# Встановлюємо змінні оточення
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Встановлюємо необхідні пакети
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    cmake \
    zlib1g-dev \
    libjpeg-dev \
    libtiff-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    libharfbuzz-dev \
    libfribidi-dev && \
    rm -rf /var/lib/apt/lists/*

# Встановлюємо робочий каталог
WORKDIR /app

# Copy poetry configuration
COPY pyproject.toml poetry.lock /app/

# Install poetry and project dependencies
RUN pip install --upgrade pip \
    && pip install poetry

RUN poetry config virtualenvs.create false \
    && poetry install --no-dev --no-interaction --no-ansi

# Stage 2: Final
FROM python:3.11-slim

# Встановлюємо змінні оточення
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Встановлюємо необхідні пакети
RUN apt-get update && apt-get install -y \
    libpq-dev \
    zlib1g \
    libjpeg62-turbo-dev \
    libtiff5 \
    libfreetype6 \
    liblcms2-2 \
    libwebp6 \
    libharfbuzz0b \
    libfribidi0 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy application code from builder stage
COPY --from=builder /usr/local /usr/local
COPY . /app/

# Collect static files
RUN python manage.py collectstatic --noinput

EXPOSE 8000

# Command to start the application
CMD ["gunicorn", "--worker-class", "gevent", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "300", "--workers", "5"]

