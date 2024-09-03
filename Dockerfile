
# Stage 1: Build
FROM python:3.12-slim AS builder

# Install required dependencies for Pillow and other packages
RUN apt-get update && apt-get install -y \
    build-essential \
    zlib1g-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Copy and install poetry
COPY pyproject.toml poetry.lock /app/
RUN pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi --no-dev

# Stage 2: Run
FROM python:3.12-slim

# Set work directory
WORKDIR /app

# Copy installed dependencies from builder stage
COPY --from=builder /app /app

# Copy source code
COPY . /app/

# Command to run the Django server using Gunicorn
CMD ["gunicorn", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000"]

# Open port 8000
EXPOSE 8000


