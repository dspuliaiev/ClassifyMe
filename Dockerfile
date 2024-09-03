
# Stage 1: Build
FROM python:3.12-bullseye AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    zlib1g-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml poetry.lock /app/
RUN pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi --no-dev

# Stage 2: Run
FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /app /app
COPY . /app/

CMD ["gunicorn", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000"]

EXPOSE 8000


