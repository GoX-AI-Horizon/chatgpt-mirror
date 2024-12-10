from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import NotificationConfig
from .serializers import NotificationConfigSerializer

class NotificationConfigView(APIView):
    """
    处理通知的配置和获取
    """

    def get(self, request):
        """获取通知配置"""
        config = NotificationConfig.objects.first()
        if not config:
            return Response({"detail": "No notification configuration found."}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = NotificationConfigSerializer(config)
        return Response(serializer.data)

    def post(self, request):
        """设置通知配置"""
        config = NotificationConfig.objects.first()
        if config:
            serializer = NotificationConfigSerializer(config, data=request.data)
        else:
            serializer = NotificationConfigSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
