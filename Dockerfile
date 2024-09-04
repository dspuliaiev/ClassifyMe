# Stage 1: Build
FROM python:3.12-bullseye AS builder

# Установка необходимых системных зависимостей
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    libhdf5-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN pip install poetry
RUN poetry config virtualenvs.create false
RUN poetry install --no-interaction --no-ansi --no-dev

# Stage 2: Final
FROM python:3.12-slim

WORKDIR /app

# Установка переменных окружения
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Установка необходимых системных зависимостей
RUN apt-get update && apt-get install -y \
    libssl1.1 \
    && rm -rf /var/lib/apt/lists/*

# Копируем зависимости из этапа сборки
COPY --from=builder /usr/local /usr/local

COPY . /app/

RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["gunicorn", "--worker-class", "gevent", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "300"]
