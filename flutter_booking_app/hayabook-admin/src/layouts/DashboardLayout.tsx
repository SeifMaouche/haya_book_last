import { Outlet } from 'react-router-dom';
import Sidebar from '../components/Sidebar';
import { LogOut, Bell } from 'lucide-react';

export default function DashboardLayout() {
  return (
    <div className="flex min-h-screen bg-gray-50 font-sans">
      <Sidebar />
      
      <div className="flex-1 flex flex-col h-screen overflow-hidden">
        {/* Topbar */}
        <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-8 shrink-0">
          <h2 className="text-xl font-bold text-gray-800">Overview</h2>
          
          <div className="flex items-center gap-6">
            <button className="text-gray-400 hover:text-primary transition">
              <Bell size={20} />
            </button>
            <div className="flex items-center gap-3 pl-6 border-l border-gray-200">
              <div className="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold text-sm">
                A
              </div>
              <div>
                <p className="text-sm font-semibold text-gray-700 leading-tight">Admin User</p>
                <p className="text-xs text-gray-500">Super Admin</p>
              </div>
              <button className="ml-2 text-gray-400 hover:text-red-500 transition">
                <LogOut size={18} />
              </button>
            </div>
          </div>
        </header>

        {/* Main Content Area */}
        <main className="flex-1 overflow-auto p-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
