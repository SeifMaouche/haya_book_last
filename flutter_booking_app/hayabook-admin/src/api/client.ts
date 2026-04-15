import axios from 'axios';

// Base URL — use environment variable with a safe fallback for local development
const BASE_URL = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000') + '/api';

// Attach JWT to every request
const authInterceptor = (config: any) => {
  const token = localStorage.getItem('admin_token');
  if (token && config.headers) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
};

// ✅ FIX A1: Handle 401 responses — clear token and redirect to /login
const responseErrorInterceptor = (error: any) => {
  if (error.response?.status === 401) {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
    // Use replace so the user can't navigate back to a protected page
    window.location.replace('/login');
  }
  return Promise.reject(error);
};

// ── General API client (for auth endpoints, etc.) ────────────────────
export const apiClient = axios.create({ baseURL: BASE_URL });
apiClient.interceptors.request.use(authInterceptor);
apiClient.interceptors.response.use(undefined, responseErrorInterceptor);

// ── Admin-prefixed client (all /api/admin/* routes) ──────────────────
const adminClient = axios.create({ baseURL: `${BASE_URL}/admin` });
adminClient.interceptors.request.use(authInterceptor);
adminClient.interceptors.response.use(undefined, responseErrorInterceptor);

export default adminClient;
