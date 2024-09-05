# Stage 1: Build
FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev cmake zlib1g-dev libjpeg-dev libtiff-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml poetry.lock /app/

RUN pip install --upgrade pip --no-cache-dir && pip install poetry

RUN poetry config virtualenvs.create false && poetry install --no-dev --no-interaction --no-ansi

COPY . /app/

RUN python manage.py collectstatic --noinput

# Stage 2: Final
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV TF_ENABLE_ONEDNN_OPTS=1  # Оптимизация для TensorFlow на CPU

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev zlib1g libjpeg62-turbo-dev libtiff6 libfreetype6 \
    liblcms2-2 libwebp7 libharfbuzz0b libfribidi0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /usr/local /usr/local
COPY . /app/

# Установка TensorFlow с поддержкой AVX2 и FMA
RUN pip install --upgrade pip \
    && pip install tensorflow --no-cache-dir --extra-index-url https://google-cloud-tensorflow-wheels.storage.googleapis.com/cpu-avx2-wheels/

EXPOSE 8000

CMD ["gunicorn", "--worker-class", "gevent", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "150", "--workers", "1"]



