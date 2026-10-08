<script setup>
import { onBeforeUnmount, ref } from 'vue'
import { api } from '../api'

const props = defineProps({ course: Object, sessionKey: Number })
const question = ref('')
const result = ref(null)
const pending = ref(false)
const error = ref('')
const controller = new AbortController()
let active = true
onBeforeUnmount(() => {
  active = false
  controller.abort()
  question.value = ''
  result.value = null
})
async function ask() {
  if (pending.value) return
  const text = question.value.trim()
  if (!text || text.length > 1000) { error.value = '请输入1至1000字的问题。'; return }
  const courseId = props.course.id
  const epoch = props.sessionKey
  pending.value = true
  error.value = ''
  result.value = null
  try {
    const response = await api.post('/api/ask', { courseId, question: text }, { timeout: 150000, signal: controller.signal })
    if (!active || props.course.id !== courseId || props.sessionKey !== epoch) return
    if (response.data.courseId !== courseId) { error.value = '问答返回的课程不一致，请重新提问。'; return }
    result.value = response.data
  } catch (failure) {
    if (!active || props.course.id !== courseId || props.sessionKey !== epoch) return
    error.value = failure.response?.status === 403 ? '当前账号没有问答权限。' : failure.code === 'ECONNABORTED' ? '问答等待超时，请稍后重试。' : failure.response?.data?.message || '问答服务请求失败，请确认后端与模型服务可用后重试。'
  } finally {
    if (active && props.course.id === courseId && props.sessionKey === epoch) pending.value = false
  }
}
</script>

<template>
  <section class="ask-panel" aria-label="课程资料问答">
    <h2>课程资料问答</h2>
    <p class="muted small">当前课程：{{ course.name }}。根据本课程已录入的通知与资料回答，并提供原文出处；请结合原文核对。</p>
    <form @submit.prevent="ask">
      <label for="course-question">你的问题（1至1000字）</label>
      <textarea id="course-question" v-model="question" required maxlength="1000" rows="3" placeholder="例如：个人项目需要提交哪些文件？" :disabled="pending"></textarea>
      <button type="submit" :disabled="pending">{{ pending ? '正在检索资料并生成回答…' : '根据课程资料回答' }}</button>
    </form>
    <p v-if="pending" class="muted small" role="status">正在等待模型响应，请稍候。</p>
    <p v-if="error" class="error" role="alert">{{ error }}</p>
    <div v-if="result" class="ask-result" aria-live="polite">
      <h3>回答</h3><p class="paragraph">{{ result.answer }}</p>
      <h3>原文出处</h3>
      <p v-if="!result.sources.length" class="muted small">没有检索到可引用的相关资料，请按上述提示补充课程资料或调整问题。</p>
      <details v-for="(source, index) in result.sources" :key="`${source.noticeId}-${source.chunkIndex}`" class="source-detail">
        <summary>[{{ index + 1 }}] {{ source.title }}</summary>
        <p class="muted small">来源：{{ source.source }} · 内容编号：{{ source.noticeId }}</p>
        <p class="paragraph">{{ source.text }}</p>
      </details>
    </div>
  </section>
</template>