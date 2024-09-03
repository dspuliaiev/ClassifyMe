
# Use official python image
FROM python:3.12-slim

# Set work directory
WORKDIR /app

# Copy and install poetry
COPY pyproject.toml poetry.lock /app/
RUN pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

# Copy source code
COPY . /app/

# Command to run the Django server using Gunicorn
CMD ["gunicorn", "image_web_classifier.wsgi:application", "--bind", "0.0.0.0:8000"]

# Open port 8000
EXPOSE 8000


