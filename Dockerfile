# Stage 1: Build
FROM python:3.11-alpine AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Устанавливаем необходимые пакеты для сборки
RUN apk add --no-cache \
    build-base postgresql-dev cmake zlib-dev jpeg-dev tiff-dev \
    freetype-dev lcms2-dev libwebp-dev harfbuzz-dev fribidi-dev

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
    libpq zlib libjpeg tiff freetype lcms2 libwebp harfbuzz fribidi

WORKDIR /app

# Копируем только необходимые файлы из стадии сборки
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app /app

# Устанавливаем TensorFlow с поддержкой AVX2 и FMA
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir tensorflow --extra-index-url https://google-cloud-tensorflow-wheels.storage.googleapis.com/cpu-avx2-wheels/

EXPOSE 8000

CMD ["gunicorn", "--worker-class", "gevent", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "150"]




