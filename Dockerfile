# Stage 1: Build
FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Устанавливаем необходимые пакеты для сборки
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev cmake zlib1g-dev libjpeg-dev libtiff-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Копируем только необходимые файлы для установки зависимостей
COPY pyproject.toml poetry.lock /app/

# Устанавливаем Poetry и зависимости
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create false \
    && poetry install --no-dev --no-interaction --no-ansi

# Копируем остальной код проекта
COPY . /app/

# Собираем статические файлы
RUN python manage.py collectstatic --noinput

# Stage 2: Final
FROM python:3.11-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TF_ENABLE_ONEDNN_OPTS=1

# Устанавливаем необходимые пакеты для запуска
RUN apk add --no-cache \
    libpq zlib libjpeg-turbo tiff freetype lcms2 libwebp harfbuzz fribidi

WORKDIR /app

# Копируем установленные зависимости из стадии сборки
COPY --from=builder /usr/local /usr/local

# Копируем весь код проекта в рабочий каталог
COPY . /app/


EXPOSE 8000

CMD ["gunicorn", "--worker-class", "gevent", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "150"]




