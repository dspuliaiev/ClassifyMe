# Stage 1: Build
FROM python:3.12-slim AS builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    cmake \
    zlib1g-dev \
    libjpeg-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml poetry.lock /app/

RUN pip install --upgrade pip \
    && pip install poetry

RUN poetry config virtualenvs.create false \
    && poetry install --no-dev

# Stage 2: Final
FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /usr/local /usr/local

COPY . /app/

EXPOSE 8000

CMD ["gunicorn", "--worker-class", "gevent", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "300"]