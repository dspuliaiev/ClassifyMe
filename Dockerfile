
# Используем официальный образ Python в качестве основы
FROM python:3.12-slim

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем и устанавливаем Poetry
COPY pyproject.toml poetry.lock /app/
RUN pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

# Копируем исходный код проекта
COPY . /app/

# Прописываем команду для запуска сервера Django с использованием Gunicorn
CMD ["gunicorn", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000"]

# Открываем порт 8000
EXPOSE 8000

