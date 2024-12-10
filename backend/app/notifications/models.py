from django.db import models

class NotificationConfig(models.Model):
    title = models.CharField(max_length=200)  # 通知标题
    content = models.TextField()             # 通知内容

    def __str__(self):
        return self.title
