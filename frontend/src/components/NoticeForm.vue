<script setup>
import { reactive } from 'vue'
const props = defineProps({ initial: Object, pending: Boolean, error: String })
const emit = defineEmits(['save', 'cancel'])
const form = reactive({
  title: props.initial?.title || '',
  content: props.initial?.content || '',
  submissionRequirements: props.initial?.submissionRequirements || '',
  reportFormat: props.initial?.reportFormat || '',
  deadline: props.initial?.deadline?.slice(0, 16) || '',
  source: props.initial?.source || '本地演示：教师手动录入',
  type: props.initial?.type || 'NOTICE',
})
function submit() {
  if (props.pending) return
  emit('save', { ...form, deadline: form.deadline ? `${form.deadline}:00` : null })
}
</script>

<template>
  <form class="notice-form" @submit.prevent="submit">
    <h2>{{ initial?.id ? '编辑内容' : '新增内容' }}</h2>
    <fieldset :disabled="pending">
      <label>内容类型<select v-model="form.type"><option value="NOTICE">课程通知</option><option value="MATERIAL">学习资料</option></select></label>
      <label>标题（必填，最多200字）<input v-model="form.title" required maxlength="200" /></label>
      <label>正文（必填，最多10000字）<textarea v-model="form.content" required maxlength="10000" rows="5"></textarea></label>
      <label>提交要求（最多2000字）<textarea v-model="form.submissionRequirements" maxlength="2000" rows="3"></textarea></label>
      <label>报告格式（最多1000字）<textarea v-model="form.reportFormat" maxlength="1000" rows="2"></textarea></label>
      <label>截止时间（可留空，按本地时间填写）<input v-model="form.deadline" type="datetime-local" /></label>
      <label>信息来源（必填，最多255字）<input v-model="form.source" required maxlength="255" /></label>
    </fieldset>
    <p v-if="error" class="error" role="alert">{{ error }}</p>
    <div class="form-actions"><button type="submit" :disabled="pending">{{ pending ? '正在保存…' : '保存内容' }}</button><button type="button" class="secondary" :disabled="pending" @click="emit('cancel')">取消编辑</button></div>
  </form>
</template>