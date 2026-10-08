<script setup>
import { onBeforeUnmount, ref } from 'vue'
import { api } from '../api'
const emit = defineEmits(['authenticated'])
const username = ref('')
const password = ref('')
const pending = ref(false)
const error = ref('')
const controller = new AbortController()
let active = true
onBeforeUnmount(() => { active = false; controller.abort(); password.value = '' })
async function login() {
  if (pending.value) return
  pending.value = true
  error.value = ''
  try {
    const response = await api.post('/api/auth/login', { username: username.value.trim(), password: password.value }, { signal: controller.signal })
    if (!active) return
    password.value = ''
    emit('authenticated', response.data)
  } catch (failure) {
    if (!active) return
    error.value = failure.response?.status === 401 ? '用户名或密码错误。' : '登录失败，请确认后端已启动后重试。'
  } finally {
    if (active) pending.value = false
  }
}
</script>

<template>
  <form class="login-panel" @submit.prevent="login">
    <h2>登录课程通知平台</h2>
    <p class="muted">学生查看课程内容，任课教师发布和维护自己的课程通知。</p>
    <label for="login-username">用户名</label><input id="login-username" v-model="username" autocomplete="username" required maxlength="50" :disabled="pending" />
    <label for="login-password">密码</label><input id="login-password" v-model="password" type="password" autocomplete="current-password" required maxlength="72" :disabled="pending" />
    <p v-if="error" class="error" role="alert">{{ error }}</p>
    <button type="submit" :disabled="pending">{{ pending ? '正在登录…' : '登录' }}</button>
    <p class="muted small">演示账号见项目根目录“演示账号.txt”。刷新页面后需重新登录。</p>
  </form>
</template>
