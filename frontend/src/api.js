import axios from 'axios'

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8080',
  timeout: 10000,
})

// 令牌仅存在当前页面的内存中，刷新页面即清空。
let token = ''
let authEpoch = 0
let unauthorizedHandler = () => {}
export function setAuthToken(value) { token = value || ''; authEpoch++ }
export function onUnauthorized(handler) { unauthorizedHandler = handler }
api.interceptors.request.use(config => {
  config.authEpoch = authEpoch
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})
api.interceptors.response.use(response => response, error => {
  if (error.response?.status === 401 && token && error.config?.authEpoch === authEpoch) unauthorizedHandler()
  return Promise.reject(error)
})