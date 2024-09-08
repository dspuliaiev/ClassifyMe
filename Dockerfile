# Используем Python 3.11 slim
FROM python:3.11-slim

# Устанавливаем переменные окружения
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV TF_ENABLE_ONEDNN_OPTS=1

# Устанавливаем необходимые пакеты для сборки и работы
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev cmake zlib1g-dev libjpeg-dev libtiff-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем рабочий каталог
WORKDIR /app

# Копируем конфигурационные файлы Poetry
COPY pyproject.toml poetry.lock /app/

# Устанавливаем и обновляем pip, устанавливаем Poetry
RUN pip install --upgrade pip --no-cache-dir && pip install poetry

# Настраиваем Poetry и устанавливаем зависимости проекта
RUN poetry config virtualenvs.create false && poetry install --no-dev --no-interaction --no-ansi

# Копируем весь код проекта
COPY . /app/

# Собираем статические файлы
RUN python manage.py collectstatic --noinput


# Открываем порт 8000 для приложения
EXPOSE 8000

# Команда для запуска приложения
CMD ["gunicorn", "--worker-class", "gevent", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "150", "--workers", "1"]




