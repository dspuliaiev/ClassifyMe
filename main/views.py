from django.http import JsonResponse
from django.views.generic import TemplateView
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import os

from tensorflow.keras.models import load_model
import numpy as np
from tensorflow.keras.preprocessing import image
from functools import partial


# Определите функцию для загрузки модели
def load_tf_model():
    return load_model('model/cifar-10.keras')


# Используйте partial для ленивой загрузки модели
load_model_lazy = partial(load_tf_model)


def image_classification(img_path):
    img_path = img_path[1:]
    images_classes = ['airplane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck']

    # Загрузите модель лениво
    model = load_model_lazy()

    img = image.load_img(img_path, target_size=(32, 32))
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)

    img_array = img_array / 255.0

    predictions = model.predict(img_array)
    predicted_class = np.argmax(predictions, axis=-1)

    return images_classes[predicted_class[0]]


class IndexView(TemplateView):
    template_name = 'main/index.html'

    def post(self, request, *args, **kwargs):
        if request.FILES.get('image'):
            uploaded_file = request.FILES['image']
            file_name = default_storage.save(uploaded_file.name, ContentFile(uploaded_file.read()))
            file_url = default_storage.url(file_name)

            result = image_classification(file_url)

            return JsonResponse({'result': result, 'image_url': file_url})
        return JsonResponse({'result': None, 'image_url': None})
