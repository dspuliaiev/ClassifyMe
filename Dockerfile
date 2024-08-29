
# Stage 1: Build
FROM python:3.12 AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN python manage.py migrate && \
    python manage.py collectstatic --noinput

# Stage 2: Production
FROM nginx:alpine

COPY --from=builder /app/staticfiles /usr/share/nginx/html/static
COPY --from=builder /app/media /usr/share/nginx/html/media

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8000

CMD ["nginx", "-g", "daemon off;"]
