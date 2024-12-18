<template>
  <div>
    <t-card class="list-card-container">
      <t-form
        ref="notificationFormRef"
        v-loading="loading"
        :data="notificationData"
        :label-width="120"
        @submit="handleSubmit"
      >
        <t-form-item label="通知标题" name="title">
          <t-input v-model="notificationData.title" placeholder="请输入通知标题"></t-input>
        </t-form-item>

        <t-form-item label="通知内容" name="content">
          <t-textarea v-model="notificationData.content" placeholder="请输入通知内容"></t-textarea>
        </t-form-item>

        <t-form-item>
          <t-button theme="primary" type="submit">提交</t-button>
          <t-button theme="danger" @click="handleDeleteAll">删除全部</t-button>
        </t-form-item>
      </t-form>
    </t-card>
  </div>
</template>

<script setup lang="ts">
import { FormProps, MessagePlugin } from 'tdesign-vue-next';
import { onMounted, ref } from 'vue';

const loading = ref(false);
const notificationData = ref({
  title: '',
  content: '',
});

// 新增的函数，用于获取通知配置
const fetchNotificationConfig = async () => {
  try {
    const response = await fetch('/0x/config/notification-config');
    if (response.ok) {
      const data = await response.json();
      if (data.title) {
        notificationData.value = {
          title: data.title,
          content: data.content,
        };
      }
    }
  } catch (error) {
    console.error('Failed to fetch notification config:', error);
  }
};

// 在组件挂载时获取通知配置
onMounted(async () => {
  await fetchNotificationConfig();
});

const handleSubmit: FormProps['onSubmit'] = async ({ validateResult, firstError }) => {
  if (validateResult) {
    loading.value = true;
    try {
      const response = await fetch('/0x/config/notification-config/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(notificationData.value),
      });
      const data = await response.json();
      if (response.ok) {
        MessagePlugin.success('通知配置成功');
      } else {
        MessagePlugin.error(JSON.stringify(Object.values(data)[0]));
      }
    } catch (error) {
      MessagePlugin.error('请求失败，请稍后重试');
      console.error('请求错误:', error);
    } finally {
      loading.value = false;
    }
  } else {
    console.error('表单验证失败', firstError);
  }
};

const handleDeleteAll = async () => {
  loading.value = true;
  try {
    const response = await fetch('/0x/config/notification-config/', {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    if (response.ok) {
      MessagePlugin.success('所有通知已删除');
      notificationData.value = { title: '', content: '' };
    } else {
      const data = await response.json();
      MessagePlugin.error(JSON.stringify(Object.values(data)[0]));
    }
  } catch (error) {
    MessagePlugin.error('删除请求失败，请稍后重试');
    console.error('删除请求错误:', error);
  } finally {
    loading.value = false;
  }
};
</script>
