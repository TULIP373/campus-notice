<script setup>
import { computed, ref } from 'vue'
import { api, onUnauthorized, setAuthToken } from './api'
import CourseList from './components/CourseList.vue'
import NoticeList from './components/NoticeList.vue'
import NoticeDetail from './components/NoticeDetail.vue'
import NoticeForm from './components/NoticeForm.vue'
import LoginForm from './components/LoginForm.vue'
import AskPanel from './components/AskPanel.vue'

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
const user = ref(null)
const teacherMode = computed(() => user.value?.role === 'TEACHER')
const authMessage = ref('')
let sessionEpoch = 0
let coursesRequest = 0
const editorOpen = ref(false)
const editorInitial = ref(null)
const editorVersion = ref(0)
const savePending = ref(false)
const saveError = ref('')
const feedback = ref('')
const deleteConfirm = ref(false)
const deletePending = ref(false)
const deleteError = ref('')
let listRequest = 0
let detailRequest = 0

const visibleNotices = computed(() => notices.value.filter(item => item.type === category.value))
function message(error) { return error.response?.status === 403 ? '当前账号没有此操作权限。' : error.response?.data?.message || '请求失败，请确认后端已启动后重试。' }
function clearDetail() {
  deleteConfirm.value = false
  deleteError.value = ''
  detailRequest++
  selectedNoticeId.value = null
  detail.value = null
  detailError.value = ''
  detailLoading.value = false
}
async function loadCourses() {
  if (!user.value) return
  const epoch = sessionEpoch
  const request = ++coursesRequest
  coursesLoading.value = true
  coursesError.value = ''
  try {
    const response = await api.get('/api/courses')
    if (epoch !== sessionEpoch || request !== coursesRequest) return
    courses.value = response.data
    if (courses.value.length) selectCourse(courses.value[0])
    else { selectedCourse.value = null; notices.value = []; clearDetail() }
  } catch (error) {
    if (epoch === sessionEpoch && request === coursesRequest) coursesError.value = message(error)
  } finally {
    if (epoch === sessionEpoch && request === coursesRequest) coursesLoading.value = false
  }
}
function selectCourse(course) {
  if (!user.value) return
  cancelEditor()
  feedback.value = ''
  selectedCourse.value = course
  keyword.value = ''
  category.value = 'NOTICE'
  loadNotices()
}
async function loadNotices() {
  const epoch = sessionEpoch
  const currentRequest = ++listRequest
  clearDetail()
  notices.value = []
  noticesError.value = ''
  if (!user.value || !selectedCourse.value) return
  noticesLoading.value = true
  try {
    const response = await api.get('/api/notices', { params: { courseId: selectedCourse.value.id, q: keyword.value.trim() } })
    if (epoch === sessionEpoch && currentRequest === listRequest) notices.value = response.data
  } catch (error) {
    if (epoch === sessionEpoch && currentRequest === listRequest) noticesError.value = message(error)
  } finally {
    if (epoch === sessionEpoch && currentRequest === listRequest) noticesLoading.value = false
  }
}
function selectCategory(value) { category.value = value; clearDetail() }
async function loadDetail(notice) {
  if (!user.value) return
  const epoch = sessionEpoch
  deleteConfirm.value = false
  deleteError.value = ''
  const currentRequest = ++detailRequest
  selectedNoticeId.value = notice.id
  detail.value = null
  detailError.value = ''
  detailLoading.value = true
  try {
    const response = await api.get(`/api/notices/${notice.id}`)
    if (epoch === sessionEpoch && currentRequest === detailRequest) detail.value = response.data
  } catch (error) {
    if (epoch === sessionEpoch && currentRequest === detailRequest) detailError.value = message(error)
  } finally {
    if (epoch === sessionEpoch && currentRequest === detailRequest) detailLoading.value = false
  }
}
function retryDetail() {
  if (selectedNoticeId.value) loadDetail({ id: selectedNoticeId.value })
}
function cancelEditor() {
  editorVersion.value++
  editorOpen.value = false
  editorInitial.value = null
  savePending.value = false
  saveError.value = ''
}
function openEditor(notice = null) {
  if (!teacherMode.value || savePending.value) return
  cancelEditor()
  editorInitial.value = notice
  editorOpen.value = true
  feedback.value = ''
}
async function saveNotice(values) {
  if (!teacherMode.value || savePending.value || !selectedCourse.value) return
  const epoch = sessionEpoch
  const version = editorVersion.value
  const courseId = selectedCourse.value.id
  const noticeId = editorInitial.value?.id
  savePending.value = true
  saveError.value = ''
  try {
    const payload = { ...values, courseId }
    const response = noticeId ? await api.put(`/api/notices/${noticeId}`, payload) : await api.post('/api/notices', payload)
    if (epoch !== sessionEpoch || version !== editorVersion.value || selectedCourse.value?.id !== courseId) return
    const savedNotice = response.data
    cancelEditor()
    keyword.value = ''
    category.value = savedNotice.type
    feedback.value = noticeId ? '内容已更新。' : '内容已保存。'
    const refresh = loadNotices()
    const expectedListRequest = listRequest
    const expectedDetailRequest = detailRequest
    await refresh
    if (epoch === sessionEpoch && selectedCourse.value?.id === courseId && listRequest === expectedListRequest && detailRequest === expectedDetailRequest) await loadDetail(savedNotice)
  } catch (error) {
    if (epoch === sessionEpoch && version === editorVersion.value) saveError.value = message(error)
  } finally {
    if (epoch === sessionEpoch && version === editorVersion.value) savePending.value = false
  }
}
async function deleteNotice() {
  if (!teacherMode.value || deletePending.value || !detail.value) return
  const epoch = sessionEpoch
  const noticeId = detail.value.id
  const courseId = selectedCourse.value.id
  deletePending.value = true
  deleteError.value = ''
  try {
    await api.delete(`/api/notices/${noticeId}`)
    if (epoch !== sessionEpoch || selectedCourse.value?.id !== courseId) return
    if (editorInitial.value?.id === noticeId) cancelEditor()
    feedback.value = '内容已删除。'
    await loadNotices()
  } catch (error) {
    if (epoch === sessionEpoch && selectedCourse.value?.id === courseId && detail.value?.id === noticeId) deleteError.value = message(error)
  } finally {
    if (epoch === sessionEpoch) deletePending.value = false
  }
}
function logout(reason = '') {
  sessionEpoch++
  coursesRequest++
  listRequest++
  setAuthToken('')
  user.value = null
  courses.value = []
  selectedCourse.value = null
  coursesLoading.value = false
  coursesError.value = ''
  notices.value = []
  noticesLoading.value = false
  noticesError.value = ''
  keyword.value = ''
  category.value = 'NOTICE'
  feedback.value = ''
  deletePending.value = false
  cancelEditor()
  clearDetail()
  authMessage.value = reason
}
function authenticated(result) {
  logout()
  setAuthToken(result.token)
  user.value = result.user
  loadCourses()
}
onUnauthorized(() => logout('登录状态已失效，请重新登录。'))
</script>

<template>
  <div class="app-shell">
    <header class="page-header">
      <div><p class="eyebrow">通知、资料与课程问答</p><h1>课程通知平台</h1></div>
      <div v-if="user" class="account-bar"><span class="student-label">{{ user.name }} · {{ teacherMode ? '教师' : '学生' }}</span><button class="secondary" @click="logout()">退出登录</button></div>
    </header>
    <p class="demo-banner">演示数据：课程通知及附件用于模拟课堂使用；软件项目实训的实际截止时间待老师通知。</p>
    <p v-if="authMessage" class="error" role="alert">{{ authMessage }}</p>
    <LoginForm v-if="!user" @authenticated="authenticated" />
    <p v-else-if="coursesLoading" role="status" class="state-panel">正在加载课程…</p>
    <div v-else-if="coursesError" class="state-panel error" role="alert">
      <p>{{ coursesError }}</p><button @click="loadCourses">重新加载课程</button>
    </div>
    <main v-else class="workspace">
      <CourseList :courses="courses" :selected-id="selectedCourse?.id" :teacher-mode="teacherMode" @select="selectCourse" />
      <section class="course-content">
        <header class="course-heading"><h2>{{ selectedCourse?.name || '暂无课程' }}</h2><p class="muted">{{ selectedCourse?.description }}</p></header>
        <template v-if="selectedCourse">
          <div v-if="teacherMode" class="maintenance-bar"><p class="muted small">任教课程：{{ selectedCourse.name }} · 发布和维护本课程的通知、资料</p><button :disabled="savePending" @click="openEditor()">发布通知或资料</button></div>
          <p v-if="feedback" class="success" role="status">{{ feedback }}</p>
          <NoticeForm v-if="editorOpen && teacherMode" :key="editorVersion" :initial="editorInitial" :pending="savePending" :error="saveError" @save="saveNotice" @cancel="cancelEditor" />
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
            <div class="detail-column">
              <NoticeDetail :notice="detail" :loading="detailLoading" :error="detailError" @retry="retryDetail" />
              <div v-if="teacherMode && detail && !detailLoading" class="maintenance-actions">
                <button class="secondary" :disabled="deletePending || savePending" @click="openEditor(detail)">编辑当前内容</button>
                <button class="danger" :disabled="deletePending" @click="deleteConfirm = true">删除当前内容</button>
                <div v-if="deleteConfirm" class="delete-confirm"><p>确认删除“{{ detail.title }}”？删除后无法从页面恢复。</p><button class="danger" :disabled="deletePending" @click="deleteNotice">{{ deletePending ? '正在删除…' : '确认删除' }}</button><button class="secondary" :disabled="deletePending" @click="deleteConfirm = false">取消删除</button></div>
                <p v-if="deleteError" class="error" role="alert">{{ deleteError }}</p>
              </div>
            </div>
          </div>
          <AskPanel v-if="!detailLoading" :key="`${user.id}:${selectedCourse.id}:${detail?.id || 'course'}:${sessionEpoch}`" :course="selectedCourse" :notice="detail" :session-key="sessionEpoch" />
        </template>
      </section>
    </main>
  </div>
</template>
