# Stage 1: Build
FROM python:3.11-alpine AS builder

# Устанавливаем переменные окружения
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Устанавливаем необходимые пакеты для сборки
RUN apk update && apk add --no-cache \
    build-base libpq cmake zlib-dev jpeg-dev tiff-dev freetype-dev \
    lcms2-dev libwebp-dev harfbuzz-dev fribidi-dev \
    hdf5-dev \
    && rm -rf /var/cache/apk/*

# Устанавливаем рабочий каталог
WORKDIR /app

# Копируем конфигурацию Poetry
COPY pyproject.toml poetry.lock /app/

# Устанавливаем и обновляем pip, устанавливаем Poetry
RUN pip install --upgrade pip && pip install poetry

# Настраиваем Poetry и устанавливаем зависимости проекта
RUN poetry config virtualenvs.create false && poetry install --no-dev --no-interaction --no-ansi --without ml-dtypes

# Устанавливаем ml-dtypes и numpy вручную для избежания конфликта
RUN pip install numpy==1.21 ml-dtypes

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
    hdf5 \
    && rm -rf /var/cache/apk/*

# Устанавливаем рабочий каталог
WORKDIR /app

# Копируем установленные зависимости из стадии сборки
COPY --from=builder /usr/local /usr/local

# Копируем только код проекта
COPY . /app/

# Устанавливаем TensorFlow с поддержкой AVX2 и FMA
RUN pip install --no-cache-dir tensorflow-cpu==2.17.0 tensorflow-io-gcs-filesystem==0.31.0

# Открываем порт 8000 для приложения
EXPOSE 8000

# Команда для запуска приложения
CMD ["gunicorn", "--worker-class", "gevent", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "150"]





