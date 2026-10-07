<script setup>
import { computed, onMounted, ref } from 'vue'
import { api } from './api'
import CourseList from './components/CourseList.vue'
import NoticeList from './components/NoticeList.vue'
import NoticeDetail from './components/NoticeDetail.vue'

const courses = ref([])
const selectedCourse = ref(null)
const coursesLoading = ref(false)
const coursesError = ref('')
const notices = ref([])
const noticesLoading = ref(false)
const noticesError = ref('')
const keyword = ref('')
const category = ref('NOTICE')
const selectedNoticeId = ref(null)
const detail = ref(null)
const detailLoading = ref(false)
const detailError = ref('')
let listRequest = 0
let detailRequest = 0

const visibleNotices = computed(() => notices.value.filter(item => item.type === category.value))
function message(error) { return error.response?.data?.message || '请求失败，请确认后端已启动后重试。' }
function clearDetail() {
  detailRequest++
  selectedNoticeId.value = null
  detail.value = null
  detailError.value = ''
  detailLoading.value = false
}
async function loadCourses() {
  coursesLoading.value = true
  coursesError.value = ''
  try {
    courses.value = (await api.get('/api/courses')).data
    if (courses.value.length) selectCourse(courses.value[0])
    else { selectedCourse.value = null; notices.value = []; clearDetail() }
  } catch (error) {
    coursesError.value = message(error)
  } finally {
    coursesLoading.value = false
  }
}
function selectCourse(course) {
  selectedCourse.value = course
  keyword.value = ''
  category.value = 'NOTICE'
  loadNotices()
}
async function loadNotices() {
  const currentRequest = ++listRequest
  clearDetail()
  notices.value = []
  noticesError.value = ''
  if (!selectedCourse.value) return
  noticesLoading.value = true
  try {
    const response = await api.get('/api/notices', { params: { courseId: selectedCourse.value.id, q: keyword.value.trim() } })
    if (currentRequest === listRequest) notices.value = response.data
  } catch (error) {
    if (currentRequest === listRequest) noticesError.value = message(error)
  } finally {
    if (currentRequest === listRequest) noticesLoading.value = false
  }
}
function selectCategory(value) { category.value = value; clearDetail() }
async function loadDetail(notice) {
  const currentRequest = ++detailRequest
  selectedNoticeId.value = notice.id
  detail.value = null
  detailError.value = ''
  detailLoading.value = true
  try {
    const response = await api.get(`/api/notices/${notice.id}`)
    if (currentRequest === detailRequest) detail.value = response.data
  } catch (error) {
    if (currentRequest === detailRequest) detailError.value = message(error)
  } finally {
    if (currentRequest === detailRequest) detailLoading.value = false
  }
}
function retryDetail() {
  if (selectedNoticeId.value) loadDetail({ id: selectedNoticeId.value })
}
onMounted(loadCourses)
</script>

<template>
  <div class="app-shell">
    <header class="page-header">
      <div><p class="eyebrow">个人项目 · 课程信息集中整理</p><h1>课程通知平台</h1></div>
      <span class="student-label">学生浏览</span>
    </header>
    <p class="demo-banner">本机演示课程：软件项目实训的截止时间待老师通知；其他课程日期为演示示例，请以老师实际发布的信息为准。</p>
    <p v-if="coursesLoading" role="status" class="state-panel">正在加载课程…</p>
    <div v-else-if="coursesError" class="state-panel error" role="alert">
      <p>{{ coursesError }}</p><button @click="loadCourses">重新加载课程</button>
    </div>
    <main v-else class="workspace">
      <CourseList :courses="courses" :selected-id="selectedCourse?.id" @select="selectCourse" />
      <section class="course-content">
        <header class="course-heading"><h2>{{ selectedCourse?.name || '暂无课程' }}</h2><p class="muted">{{ selectedCourse?.description }}</p></header>
        <template v-if="selectedCourse">
          <div class="content-tools">
            <div class="tabs" aria-label="内容分类">
              <button :class="{ active: category === 'NOTICE' }" :aria-pressed="category === 'NOTICE'" @click="selectCategory('NOTICE')">课程通知</button>
              <button :class="{ active: category === 'MATERIAL' }" :aria-pressed="category === 'MATERIAL'" @click="selectCategory('MATERIAL')">学习资料</button>
            </div>
            <form class="search-form" role="search" @submit.prevent="loadNotices">
              <label class="sr-only" for="keyword">搜索标题或正文</label>
              <input id="keyword" v-model="keyword" maxlength="200" placeholder="搜索标题或正文" />
              <button type="submit" :disabled="noticesLoading">搜索</button>
            </form>
          </div>
          <div class="reading-area">
            <NoticeList :notices="visibleNotices" :selected-id="selectedNoticeId" :loading="noticesLoading" :error="noticesError" @select="loadDetail" @retry="loadNotices" />
            <NoticeDetail :notice="detail" :loading="detailLoading" :error="detailError" @retry="retryDetail" />
          </div>
        </template>
      </section>
    </main>
  </div>
</template>