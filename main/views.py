from django.http import JsonResponse
from django.views.generic import TemplateView
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import os
import numpy as np
from PIL import Image
from tensorflow.keras.models import load_model
from functools import partial

# Define the function to load the model
def load_tf_model():
    model_path = 'model/cifar-10.keras'
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Model file not found: {model_path}")
    return load_model(model_path)

# Use partial for lazy loading the model
load_model_lazy = partial(load_tf_model)

# Define the image classification function
def image_classification(img_path):
    img_path = img_path[1:]
    images_classes = ['airplane', 'automobile', 'bird', 'cat', 'deer', 'dog', 'frog', 'horse', 'ship', 'truck']

    # Load the model lazily
    model = load_model_lazy()

    try:
        img = Image.open(img_path)
        img = img.resize((32, 32))
        img_array = np.array(img)
        img_array = np.expand_dims(img_array, axis=0)
        img_array = img_array / 255.0

        predictions = model.predict(img_array)
        predicted_class = np.argmax(predictions, axis=-1)

        return images_classes[predicted_class[0]]
    except Exception as e:
        return str(e)

# Define the IndexView class
class IndexView(TemplateView):
    template_name = 'main/index.html'

    def post(self, request, *args, **kwargs):
        if request.FILES.get('image'):
            try:
                uploaded_file = request.FILES['image']
                file_name = default_storage.save(uploaded_file.name, ContentFile(uploaded_file.read()))
                file_url = default_storage.url(file_name)

                result = image_classification(file_url)

                return JsonResponse({'result': result, 'image_url': file_url})
            except Exception as e:
                return JsonResponse({'error': str(e)}, status=500)
        return JsonResponse({'result': None, 'image_url': None})
