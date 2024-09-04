from django.http import JsonResponse
from django.views.generic import TemplateView
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import os
import numpy as np
from PIL import Image
from tensorflow import keras

# Загрузите модель один раз при старте приложения
MODEL_PATH = 'model/cifar-10.keras'
if not os.path.exists(MODEL_PATH):
    raise FileNotFoundError(f"Model file not found: {MODEL_PATH}")
model = keras.models.load_model(MODEL_PATH)

# Определите функцию классификации изображений
def image_classification(image_path):
    images_classes = ['airplane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck']

    try:
        # Откройте изображение и преобразуйте его в массив NumPy
        img = Image.open(image_path)
        img = img.resize((32, 32))  # Убедитесь, что размер соответствует ожиданиям модели
        img_array = np.array(img)
        img_array = np.expand_dims(img_array, axis=0)  # Добавьте размерность для партии
        img_array = img_array / 255.0  # Нормализуйте изображение

        # Получите предсказания от модели
        predictions = model.predict(img_array)
        predicted_class = np.argmax(predictions, axis=-1)

        return images_classes[predicted_class[0]]
    except Exception as e:
        return str(e)

# Определите класс IndexView
class IndexView(TemplateView):
    template_name = 'main/index.html'

    def post(self, request, *args, **kwargs):
        if request.FILES.get('image'):
            try:
                uploaded_file = request.FILES['image']
                file_name = default_storage.save(uploaded_file.name, ContentFile(uploaded_file.read()))
                file_path = default_storage.path(file_name)  # Получите путь к файлу на сервере

                # Передайте путь к файлу функции классификации
                result = image_classification(file_path)

                return JsonResponse({'result': result, 'image_url': default_storage.url(file_name)})
            except Exception as e:
                return JsonResponse({'error': str(e)}, status=500)
        return JsonResponse({'result': None, 'image_url': None})

