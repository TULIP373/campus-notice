<script setup>
defineProps({ courses: Array, selectedId: Number, teacherMode: Boolean })
defineEmits(['select'])
</script>

<template>
  <nav class="course-nav" aria-label="课程列表">
    <h2>{{ teacherMode ? '任教课程' : '我的课程' }}</h2>
    <p class="muted small">本学期 · {{ courses.length }} 门课程</p>
    <button v-for="course in courses" :key="course.id" class="course-button" :class="{ active: course.id === selectedId }"
      :aria-current="course.id === selectedId ? 'page' : undefined" @click="$emit('select', course)">
      {{ course.name }}
    </button>
    <p v-if="!courses.length" class="muted">暂无课程。</p>
  </nav>
</template>
