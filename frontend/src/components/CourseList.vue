<script setup>
defineProps({ courses: Array, selectedId: Number })
defineEmits(['select'])
</script>

<template>
  <nav class="course-nav" aria-label="课程列表">
    <h2>我的课程</h2>
    <p class="muted small">按课程整理通知与学习资料</p>
    <button v-for="course in courses" :key="course.id" class="course-button" :class="{ active: course.id === selectedId }"
      :aria-current="course.id === selectedId ? 'page' : undefined" @click="$emit('select', course)">
      {{ course.name }}
    </button>
    <p v-if="!courses.length" class="muted">暂无课程。</p>
  </nav>
</template>