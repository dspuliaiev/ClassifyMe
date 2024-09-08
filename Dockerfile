# Используем Python 3.11 на базе Alpine
FROM python:3.11-alpine

# Устанавливаем переменные окружения
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV TF_ENABLE_ONEDNN_OPTS=1

# Устанавливаем необходимые пакеты для сборки и работы
RUN apk update && apk add --no-cache \
    gcc g++ make cmake libpq-dev zlib-dev jpeg-dev tiff-dev \
    freetype-dev lcms2-dev libwebp-dev harfbuzz-dev fribidi-dev bash

# Устанавливаем рабочий каталог
WORKDIR /app

# Копируем конфигурационные файлы Poetry
COPY pyproject.toml poetry.lock /app/

# Устанавливаем и обновляем pip, устанавливаем Poetry
RUN pip install --upgrade pip && pip install poetry

# Настраиваем Poetry и устанавливаем зависимости проекта
RUN poetry config virtualenvs.create false && \
    pip install grpcio && \
    poetry install --no-dev --no-interaction --no-ansi

# Копируем весь код проекта
COPY . /app/

# Собираем статические файлы
RUN python manage.py collectstatic --noinput

# Открываем порт 8000 для приложения
EXPOSE 8000

# Команда для запуска приложения
CMD ["gunicorn", "--worker-class", "gevent", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "150", "--workers", "1"]





