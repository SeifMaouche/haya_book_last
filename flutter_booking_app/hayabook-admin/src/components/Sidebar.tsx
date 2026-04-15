import { NavLink } from 'react-router-dom';
import { 
  LayoutDashboard, 
  Users, 
  Briefcase, 
  CalendarCheck, 
  Star, 
  MessageSquare, 
  Tags, 
  ShieldAlert,
  LifeBuoy
} from 'lucide-react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

const navItems = [
  { path: '/', label: 'Dashboard', icon: LayoutDashboard },
  { path: '/users', label: 'Users', icon: Users },
  { path: '/providers', label: 'Providers', icon: Briefcase },
  { path: '/bookings', label: 'Bookings', icon: CalendarCheck },
  { path: '/reviews', label: 'Reviews', icon: Star },
  { path: '/messages', label: 'Messages', icon: MessageSquare },
  { path: '/categories', label: 'Categories', icon: Tags },
  { path: '/support', label: 'Support', icon: LifeBuoy },
  { path: '/admins', label: 'Admins', icon: ShieldAlert },
];

export default function Sidebar() {
  return (
    <div className="w-64 bg-dark min-h-screen text-gray-300 flex flex-col">
      <div className="p-6">
        <h1 className="text-2xl font-bold text-white flex items-center gap-2">
          <span className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center text-sm">H</span>
          HayaBook
        </h1>
        <p className="text-xs text-gray-400 mt-1 uppercase tracking-wider font-semibold">Admin Portal</p>
      </div>
      
      <nav className="flex-1 px-4 py-4 space-y-1">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) => twMerge(
                clsx(
                  "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors",
                  isActive 
                    ? "bg-primary text-white" 
                    : "hover:bg-white/10 hover:text-white"
                )
              )}
            >
              <Icon size={18} />
              {item.label}
            </NavLink>
          );
        })}
      </nav>
      
      <div className="p-4 border-t border-white/10 text-xs text-center text-gray-500">
        &copy; 2026 HayaBook
      </div>
    </div>
  );
}
