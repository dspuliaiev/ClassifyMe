
# Stage 1: Build
FROM python:3.12 AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN python manage.py migrate && \
    python manage.py collectstatic --noinput

# Stage 2: Production
FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /app /app

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "image_web_classifier.wsgi:application"]
