from django.http import JsonResponse
from django.views.generic import TemplateView
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import os

class IndexView(TemplateView):
    template_name = 'main/index.html'

    def post(self, request, *args, **kwargs):
        if request.FILES.get('image'):
            uploaded_file = request.FILES['image']
            file_name = default_storage.save(uploaded_file.name, ContentFile(uploaded_file.read()))
            file_url = default_storage.url(file_name)

            # Тут викликається модель для класифікації зображення
            # result = your_model_classification_function(file_url)

            result = "Example Classification Result"  # Замініть реальний результат

            return JsonResponse({'result': result, 'image_url': file_url})
        return JsonResponse({'result': None, 'image_url': None})
