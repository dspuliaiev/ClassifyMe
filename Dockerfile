# Stage 1: Build
FROM python:3.11-slim AS builder

# Устанавливаем переменные окружения
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Устанавливаем необходимые пакеты для сборки
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev cmake zlib1g-dev libjpeg-dev libtiff-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем рабочий каталог
WORKDIR /app

# Копируем конфигурацию Poetry
COPY pyproject.toml poetry.lock /app/

# Устанавливаем и обновляем pip, устанавливаем Poetry
RUN pip install --upgrade pip --no-cache-dir && pip install poetry

# Настраиваем Poetry и устанавливаем зависимости проекта
RUN poetry config virtualenvs.create false && poetry install --no-dev --no-interaction --no-ansi

# Копируем весь код проекта в рабочий каталог
COPY . /app/

# Собираем статические файлы
RUN python manage.py collectstatic --noinput

# Stage 2: Final
FROM python:3.11-alpine

# Устанавливаем переменные окружения
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV TF_ENABLE_ONEDNN_OPTS=1

# Устанавливаем необходимые пакеты для запуска
RUN apk update && apk add --no-cache \
    libpq zlib libjpeg-turbo tiff freetype lcms2 libwebp harfbuzz fribidi \
    && rm -rf /var/cache/apk/*

# Устанавливаем рабочий каталог
WORKDIR /app

# Копируем установленные зависимости из стадии сборки
COPY --from=builder /usr/local /usr/local

# Копируем весь код проекта в рабочий каталог
COPY . /app/

# Устанавливаем TensorFlow с поддержкой AVX2 и FMA
RUN pip install --upgrade pip \
    && pip install tensorflow --no-cache-dir --extra-index-url https://google-cloud-tensorflow-wheels.storage.googleapis.com/cpu-avx2-wheels/

# Открываем порт 8000 для приложения
EXPOSE 8000

# Команда для запуска приложения
CMD ["gunicorn", "--worker-class", "gevent", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "150"]



