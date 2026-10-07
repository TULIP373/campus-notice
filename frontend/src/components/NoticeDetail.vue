<script setup>
defineProps({ notice: Object, loading: Boolean, error: String })
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
      <section><h3>正文</h3><p class="paragraph">{{ notice.content }}</p></section>
      <section><h3>提交要求</h3><p class="paragraph">{{ notice.submissionRequirements || '本条内容未填写提交要求。' }}</p></section>
      <section><h3>报告格式</h3><p class="paragraph">{{ notice.reportFormat || '本条内容未填写报告格式。' }}</p></section>
    </template>
    <div v-else class="empty detail-empty"><h2>选择一条内容查看详情</h2><p>提交要求、报告格式、截止时间和出处集中展示在这里。</p></div>
  </article>
</template>