<script setup>
defineProps({ notices: Array, selectedId: Number, loading: Boolean, error: String })
defineEmits(['select', 'retry'])
function deadlineText(value) { return value ? value.replace('T', ' ').slice(0, 16) : '待老师通知' }
</script>

<template>
  <section class="notice-list" aria-label="通知列表" :aria-busy="loading">
    <p v-if="loading" role="status" class="muted">正在加载课程内容…</p>
    <div v-else-if="error" class="error" role="alert">
      <p>{{ error }}</p><button class="secondary" @click="$emit('retry')">重试加载</button>
    </div>
    <p v-else-if="!notices.length" class="empty">没有符合条件的内容。可以清空关键词或切换分类。</p>
    <button v-for="notice in loading || error ? [] : notices" :key="notice.id" class="notice-card"
      :class="{ selected: notice.id === selectedId }" @click="$emit('select', notice)">
      <span class="badge">{{ notice.type === 'MATERIAL' ? '学习资料' : '课程通知' }}</span>
      <strong>{{ notice.title }}</strong>
      <span class="muted small">截止时间：{{ deadlineText(notice.deadline) }}</span>
      <span class="muted small">来源：{{ notice.source }}</span>
    </button>
  </section>
</template>