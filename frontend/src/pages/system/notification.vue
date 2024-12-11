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
        </t-form-item>
      </t-form>
    </t-card>
  </div>
</template>

<script setup lang="ts">
import { FormProps, MessagePlugin } from 'tdesign-vue-next';
import { ref } from 'vue';

import RequestApi from '@/api/request';

const loading = ref(false);
const notificationData = ref({
  title: '',
  content: '',
});

const handleSubmit: FormProps['onSubmit'] = async ({ validateResult, firstError }) => {
  if (validateResult) {
    loading.value = true;
    try {
      const response = await RequestApi('/0x/config/notification-config/', 'POST', notificationData.value);
      const data = await response.json();
      if (response.ok) {
        MessagePlugin.success('通知配置成功');
        notificationData.value = { title: '', content: '' };
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
</script>

<style lang="less" scoped>
.list-card-container {
  padding: 20px;
}
</style>
