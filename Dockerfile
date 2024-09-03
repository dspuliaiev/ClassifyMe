# Stage 1: Build
FROM python:3.12-bullseye AS builder

# Установка необходимых системных зависимостей
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    libhdf5-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN pip install poetry
RUN poetry config virtualenvs.create false
RUN poetry install --no-interaction --no-ansi --no-dev

# Stage 2: Final
FROM python:3.12-slim

WORKDIR /app
COPY --from=builder /app /app
COPY . .

RUN python manage.py collectstatic --noinput

CMD ["gunicorn", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000"]




