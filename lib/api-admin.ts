// lib/api-admin.ts

const BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api';

export async function adminFetch(endpoint: string, options: RequestInit = {}) {
  // In a real scenario, we'd get the token from a cookie or secure store.
  // For integration purposes, we assume the admin is "logged in".
  const token = typeof window !== 'undefined' ? localStorage.getItem('admin-token') : '';

  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
    ...options.headers,
  };

  const response = await fetch(`${BASE_URL}${endpoint}`, {
    ...options,
    headers,
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.message || `API Error: ${response.status}`);
  }

  return response.json();
}
