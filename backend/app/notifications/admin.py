from django.contrib import admin

from app.notifications.models import NotificationConfig

@admin.register(NotificationConfig)
class NotificationConfigAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "title",
        "content",
    )