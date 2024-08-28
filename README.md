
# ClassifyMe - Image Classification Web Service

## Introduction
ClassifyMe is a web-based image classification service built on the Django web platform, utilizing TensorFlow and other dependencies. The primary goal of this project is to classify images into one of the following categories: airplane, automobile, bird, cat, deer, dog, frog, horse, ship, and truck. This classification assists clients in labeling their unlabeled images, aiding their model in learning to generate new images. The project is fully configured to operate within a Docker container environment.

## The data used to train the model
[CIFAR-10](https://www.kaggle.com/competitions/cifar-10)

## Technologies
Project is mainly based on:
- **Web framework:** Django  
- **Frontend:** HTML/CSS, framework Bootstrap, JavaScript  
- **Backend:** Python  

## System Requirements
- Docker
- Docker Compose
- Python 3.12

## Installation
1. **Clone the repository:**
   ```
   git clone https://github.com/alenaporoskun/Group_4_Image_Classification_Web_Service.git
   ```

3. **Create a Docker image:**
   ```
   docker-compose build
   ```

5. **Run the Docker container:**
   ```
   docker-compose up
   ```
   or
   ```
   docker-compose up -d 
   ```
## Settings

1. **Install dependencies with Poetry:**  
   **Make sure Poetry is installed on your system. If not, install it using:**  
   ```
   pip install poetry
   ```

3. **Install dependencies:**  
   ```
   poetry install
   ```

5. **Set environment variables:**  
   Create an ```.env``` file in the root of the project and add the necessary environment variables if needed.

## Using

1. **Start the server:**  
   **If you run the project locally without Docker:**  
   ```
   poetry run python manage.py runserver
   ```
  
   **If you run the project in a Docker container:**  
   ```
   docker-compose up
   ```
   or
   ```
   docker-compose up -d 
   ```

3. **Access to the service:**
   Open your browser and follow the link
   ```
   http://127.0.0.1:8000/
   ```

   You should see the main page.

![Screenshot of the ClassifyMe application](images/screenshot.png)


   Examples of Image Classification.
   
![Screenshot2 of the ClassifyMe application](images/screenshot2.png)

![Screenshot3 of the ClassifyMe application](images/screenshot3.png)

![Screenshot4 of the ClassifyMe application](images/screenshot4.png)

   
