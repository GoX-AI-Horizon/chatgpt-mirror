from rest_framework import serializers
from .models import NotificationConfig

class NotificationConfigSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationConfig
        fields = '__all__'
