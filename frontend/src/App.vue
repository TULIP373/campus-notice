<script setup>
import { onMounted, ref } from 'vue'
import { api } from './api'

const status = ref('正在连接后端…')
const loading = ref(false)

async function checkConnection() {
  loading.value = true
  status.value = '正在连接后端…'
  try {
    const response = await api.get('/api/health')
    status.value = response.data.status === 'UP' ? '前后端已连通' : '后端返回了未知状态'
  } catch (error) {
    status.value = `连接失败：${error.response?.data?.message || error.message}`
  } finally {
    loading.value = false
  }
}

onMounted(checkConnection)
</script>

<template>
  <main class="connection-panel">
    <p class="eyebrow">实验二 · 前后端连接</p>
    <h1>课程通知平台</h1>
    <p role="status" aria-live="polite">{{ status }}</p>
    <button :disabled="loading" @click="checkConnection">重新检查连接</button>
  </main>
</template>