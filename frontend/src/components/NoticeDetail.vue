<script setup>
import { ref, watch, onBeforeUnmount } from 'vue'
import { api } from '../api'
const props = defineProps({ notice: Object, loading: Boolean, error: String })
const filePending = ref(null)
const fileError = ref('')
let fileEpoch = 0
watch(() => props.notice?.id, () => { fileEpoch++; filePending.value = null; fileError.value = '' })
onBeforeUnmount(() => { fileEpoch++ })
async function download(attachment) {
  if (filePending.value) return
  const id = props.notice.id
  const epoch = fileEpoch
  filePending.value = attachment.id
  fileError.value = ''
  try {
    const response = await api.get(`/api/notices/${id}/attachments/${attachment.id}`, { responseType: 'blob' })
    if (epoch !== fileEpoch) return
    const url = URL.createObjectURL(response.data)
    const link = document.createElement('a')
    link.href = url
    link.download = attachment.filename
    document.body.appendChild(link)
    link.click()
    link.remove()
    setTimeout(() => URL.revokeObjectURL(url), 1000)
  } catch {
    if (epoch === fileEpoch) fileError.value = '附件下载失败，请重试。'
  } finally {
    if (epoch === fileEpoch) filePending.value = null
  }
}
defineEmits(['retry'])
function deadlineText(value) { return value ? value.replace('T', ' ').slice(0, 16) : '待老师通知' }
</script>

<template>
  <article class="detail-panel" aria-label="内容详情" :aria-busy="loading">
    <p v-if="loading" class="muted" role="status">正在加载详情…</p>
    <div v-else-if="error" class="error" role="alert">
      <p>{{ error }}</p><button class="secondary" @click="$emit('retry')">重试查看</button>
    </div>
    <template v-else-if="notice">
      <p class="eyebrow">{{ notice.type === 'MATERIAL' ? '学习资料' : '课程通知' }}</p>
      <h2>{{ notice.title }}</h2>
      <dl class="metadata">
        <div><dt>截止时间</dt><dd>{{ deadlineText(notice.deadline) }}</dd></div>
        <div><dt>信息来源</dt><dd>{{ notice.source }}</dd></div>
      </dl>
      <section><h3>通知原文</h3><p class="paragraph original-content">{{ notice.content }}</p></section>
      <section v-if="notice.submissionRequirements"><h3>要点整理</h3><p class="paragraph">{{ notice.submissionRequirements }}</p></section>
      <section v-if="notice.reportFormat"><h3>文件与格式要求</h3><p class="paragraph">{{ notice.reportFormat }}</p></section>
      <section class="attachments">
        <h3>参考附件</h3>
        <p v-if="!notice.attachments?.length" class="muted small">这条通知没有附带文件。</p>
        <div v-for="attachment in notice.attachments" :key="attachment.id" class="attachment-item">
          <div class="attachment-heading"><div><strong>{{ attachment.filename }}</strong><p class="muted small">PDF · 老师通知随附的参考文件（模拟）</p></div><button class="secondary" :disabled="!!filePending" @click="download(attachment)">{{ filePending === attachment.id ? '正在下载…' : '下载原文件' }}</button></div>
          <details><summary>查看附件原文</summary><p class="paragraph">{{ attachment.content }}</p></details>
        </div>
        <p v-if="fileError" class="error" role="alert">{{ fileError }}</p>
      </section>
    </template>
    <div v-else class="empty detail-empty"><h2>选择一张卡片查看原文</h2><p>查看老师发布的完整通知、参考附件，也可以针对这条内容向 AI 提问。</p></div>
  </article>
</template>
