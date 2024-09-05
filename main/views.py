from django.http import JsonResponse
from django.views.generic import TemplateView
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import os
import numpy as np
from PIL import Image
from tensorflow import keras
import tensorflow as tf
from tensorflow.keras import backend as K
import logging

# Настройка логирования
logger = logging.getLogger(__name__)

# Оптимизация использования CPU для TensorFlow
config = tf.compat.v1.ConfigProto()
config.intra_op_parallelism_threads = 1
config.inter_op_parallelism_threads = 1
config.allow_soft_placement = True

# Устанавливаем количество устройств (CPU)
config.device_count['CPU'] = 1

session = tf.compat.v1.Session(config=config)
K.set_session(session)

# Загрузите модель один раз при старте приложения
MODEL_PATH = 'model/cifar-10.keras'
if not os.path.exists(MODEL_PATH):
    raise FileNotFoundError(f"Model file not found: {MODEL_PATH}")
model = keras.models.load_model(MODEL_PATH)

# Классы изображений
images_classes = ['airplane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck']

# Определите функцию классификации изображений
def image_classification(image_path):
    try:
        # Открываем изображение и преобразуем в массив NumPy
        img = Image.open(image_path)
        img = img.resize((32, 32))  # Изменяем размер до 32x32
        img_array = np.expand_dims(np.array(img) / 255.0, axis=0)  # Добавляем измерение для батча и нормализуем
        img.close()  # Закрываем изображение после его использования

        # Предсказание класса изображения
        predictions = model.predict(img_array)
        predicted_class = np.argmax(predictions, axis=-1)

        return images_classes[predicted_class[0]]
    except Exception as e:
        logger.error(f"Ошибка при классификации изображения: {e}")
        return str(e)

# Определите класс IndexView
class IndexView(TemplateView):
    template_name = 'main/index.html'

    def post(self, request, *args, **kwargs):
        if request.FILES.get('image'):
            try:
                # Получаем загруженный файл
                uploaded_file = request.FILES['image']
                # Сохраняем файл и получаем путь
                file_name = default_storage.save(uploaded_file.name, ContentFile(uploaded_file.read()))
                file_path = default_storage.path(file_name)

                # Классификация изображения
                result = image_classification(file_path)

                # Возвращаем результат
                return JsonResponse({'result': result, 'image_url': default_storage.url(file_name)})
            except Exception as e:
                # Логируем и возвращаем ошибку в формате JSON
                logger.error(f"Ошибка загрузки или обработки файла: {e}")
                return JsonResponse({'error': str(e)}, status=500)
        # Если изображение не загружено
        return JsonResponse({'result': None, 'image_url': None})


