
# Stage 1: Build
FROM python:3.12 AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN python manage.py migrate

RUN python manage.py collectstatic --noinput

CMD ["gunicorn", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000"]

EXPOSE 8000
