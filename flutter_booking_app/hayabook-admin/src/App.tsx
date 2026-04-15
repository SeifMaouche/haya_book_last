import React from 'react';
import { Routes, Route, Navigate, useLocation } from 'react-router-dom';
import DashboardLayout from './layouts/DashboardLayout';
import Dashboard   from './pages/Dashboard';
import Users       from './pages/Users';
import Providers   from './pages/Providers';
import Bookings    from './pages/Bookings';
import Reviews     from './pages/Reviews';
import Messages    from './pages/Messages';
import Categories  from './pages/Categories';
import Support     from './pages/Support';
import Admins      from './pages/Admins';
import Login       from './pages/Login';

// ── Auth guard ───────────────────────────────────────────────────────
function RequireAuth({ children }: { children: React.ReactElement }) {
  const token    = localStorage.getItem('admin_token');
  const location = useLocation();
  if (!token) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }
  return children;
}

function App() {
  return (
    <Routes>
      {/* Public */}
      <Route path="/login" element={<Login />} />

      {/* Protected */}
      <Route
        path="/"
        element={
          <RequireAuth>
            <DashboardLayout />
          </RequireAuth>
        }
      >
        <Route index           element={<Dashboard  />} />
        <Route path="users"      element={<Users      />} />
        <Route path="providers"  element={<Providers  />} />
        <Route path="bookings"   element={<Bookings   />} />
        <Route path="reviews"    element={<Reviews    />} />
        <Route path="messages"   element={<Messages   />} />
        <Route path="categories" element={<Categories />} />
        <Route path="support"    element={<Support    />} />
        <Route path="admins"     element={<Admins     />} />
        <Route path="*"          element={<div className="p-8 text-gray-500">Page under construction</div>} />
      </Route>
    </Routes>
  );
}

export default App;
