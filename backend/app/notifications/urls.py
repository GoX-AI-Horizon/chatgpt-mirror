from django.urls import path
from .views import NotificationConfigView

urlpatterns = [
    path('notification-config/', NotificationConfigView.as_view(), name='notification-config'),
]
