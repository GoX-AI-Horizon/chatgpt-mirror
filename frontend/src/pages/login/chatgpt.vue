<template>
  <div>
    <t-dialog
      :visible="tableVisible"
      header="请选择 ChatGPT 账号"
      :cancel-btn="null"
      :confirm-btn="null"
      :on-close="onClose"
      width="930px"
    >
      <t-loading :loading="tableLoading">
        <t-space break-line>
          <div
            v-for="item in tableData"
            :key="item.id"
            style="width: 160px; cursor: pointer"
            :class="{ 'is-disabled': !item.auth_status }"
            @click="onSelect(item.id)"
          >
            <div style="background: #f2f4f7; padding: 8px; border-radius: 5px">
              <t-space direction="vertical" style="width: 100%" :size="8">
                <div>
                  <div style="display: flex; justify-content: space-between">
                    <t-tag
                      size="small"
                      theme="primary"
                      variant="outline"
                      style="width: 35px"
                      :class="{ 'shiny-blue': item.plan_type !== 'free' }"
                      >{{ item.plan_type }}</t-tag
                    >
                    <span>{{ item.chatgpt_flag }} </span>
                  </div>
                </div>

                <div style="font-size: 12px; display: flex; justify-content: space-between">
                  <div>实时状态</div>
                  <div>
                    <span v-if="item.auth_status === false"> 已过期 </span>
                    <span v-else-if="getGPTUsePercent(item) < 40"> 空闲 </span>
                    <span v-else-if="getGPTUsePercent(item) < 80"> 忙碌 </span>
                    <span v-else> 繁忙 | 可用 </span>
                  </div>
                </div>

                <div>
                  <t-progress
                    v-if="getGPTUsePercent(item) < 40"
                    :percentage="getGPTUsePercent(item)"
                    status="success"
                    :label="false"
                  />
                  <t-progress
                    v-else-if="getGPTUsePercent(item) < 80"
                    :percentage="getGPTUsePercent(item)"
                    status="warning"
                    :label="false"
                  />
                  <t-progress v-else :percentage="getGPTUsePercent(item)" status="error" :label="false" />
                </div>

                <div></div>
              </t-space>
            </div>
          </div>
        </t-space>
      </t-loading>
    </t-dialog>

    <!-- 新增的通知对话框 -->
    <t-dialog
      v-model:visible="visible1"
      theme="warning"
      placement="center"
      :header="notificationMessage.title"
      :body="notificationMessage.content"
      :on-close="close1"
      :cancel-btn="null"
      :close-on-esc-keydown="false"
      :close-on-overlay-click="false"
      @confirm="onConfirm"
    />
  </div>
</template>

<script setup lang="ts">
import Cookies from 'js-cookie';
import { MessagePlugin } from 'tdesign-vue-next';
import { onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';

import RequestApi from '@/api/request';

const tableLoading = ref(false);
const router = useRouter();
const tableVisible = ref(false);

interface TableData {
  id: number;
  chatgpt_flag: string;
  plan_type: string;
  auth_status: boolean;
  use_count: any;
}
const tableData = ref<TableData[]>([]);

const notificationMessage = ref({ title: '', content: '' }); // 新增的状态变量，用于存储通知信息
const visible1 = ref(false); // 控制对话框的显示状态

onMounted(async () => {
  await getUserChatGPTAccountList();
  await fetchNotificationConfig(); // 新增的函数调用
});

const getGPTUsePercent = (item: any) => {
  const MaxLimitCount: number = item.plan_type === 'free' ? 20 : 80;
  return Math.min((item.use_count / MaxLimitCount) * 100 + 1, 99);
};
const getUserChatGPTAccountList = async () => {
  // 获取 用户 ChatGPT 账号列表
  tableLoading.value = true;
  const response = await RequestApi('/0x/user/chatgpt-list');

  const data = await response.json();
  tableLoading.value = false;
  if (data.results.length === 1 && data.results[0].auth_status) {
    onSelect(data.results[0].id);
  } else {
    tableVisible.value = true;
    tableData.value = data.results;
  }
};

// 新增的函数，用于获取通知配置
const fetchNotificationConfig = async () => {
  try {
    const response = await fetch('/0x/config/notification-config');
    if (response.ok) {
      const data = await response.json();
      if (data.title) {
        notificationMessage.value = {
          title: data.title,
          content: data.content,
        };
        visible1.value = true; // 显示对话框
      }
    }
  } catch (error) {
    console.error('Failed to fetch notification config:', error);
  }
};

const onClose = () => {
  router.push({ name: 'login' });
};
const onSelect = async (chatgptId: number) => {
  console.log(chatgptId);
  tableLoading.value = true;
  const response = await RequestApi('/0x/chatgpt/login', 'POST', { chatgpt_id: chatgptId });
  tableLoading.value = false;

  const data = await response.json();
  if (response.status !== 200) {
    MessagePlugin.error(JSON.stringify(Object.values(data)[0]));
  } else {
    Cookies.set('user-gateway-token', data['user-gateway-token'], { expires: 7 });
    MessagePlugin.success('登录成功');
    window.location.href = '/'; // 跳转到首页
  }
};

// 新增的函数，用于处理对话框确认操作
const onConfirm = () => {
  visible1.value = false;
};

// 新增的函数，用于处理对话框关闭操作
const close1 = () => {
  visible1.value = false;
};
</script>

<style lang="less" scoped>
.is-disabled {
  pointer-events: none;
  /* Prevent interaction */
  opacity: 0.5;
  /* Optional: Make the item look visually disabled */
}

.shiny-blue {
  box-shadow:
    0 0 1px rgba(0, 123, 255, 0.5),
    0 0 20px rgba(0, 123, 255, 0.3);
}
</style>
