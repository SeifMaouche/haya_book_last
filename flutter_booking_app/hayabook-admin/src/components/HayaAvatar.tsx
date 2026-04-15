import React from 'react';
import { User as UserIcon } from 'lucide-react';

interface HayaAvatarProps {
  src?: string | null;
  firstName?: string | null;
  lastName?: string | null;
  role: 'CLIENT' | 'PROVIDER' | string;
  size?: number;
  className?: string;
}

export default function HayaAvatar({
  src,
  firstName,
  lastName,
  role,
  size = 32,
  className = ""
}: HayaAvatarProps) {
  
  const isDefault = !src || src === 'default';
  const isProvider = role === 'PROVIDER';

  // ── Initials Logic ──────────────────────────────────────────────
  const getInitials = () => {
    const f = firstName?.trim() || '';
    const l = lastName?.trim() || '';
    if (!f && !l) return null;
    if (f && l) return (f[0] + l[0]).toUpperCase();
    return (f[0] || l[0]).toUpperCase();
  };

  const initials = getInitials();

  // ── Image URL Resolver ──────────────────────────────────────────
  const getFullUrl = (url: string) => {
    if (url.startsWith('http')) return url;
    const baseUrl = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000').replace(/\/$/, '');
    const imgPath = url.startsWith('/') ? url : `/${url}`;
    return `${baseUrl}${imgPath}`;
  };

  // ── Style Classes ───────────────────────────────────────────────
  const circleStyle = {
    width:  `${size}px`,
    height: `${size}px`,
    fontSize: `${size * 0.4}px`,
  };

  const gradientClass = isProvider
    ? "from-[#8B5CF6] to-[#6D28D9]" // Purple/Violet
    : "from-[#3B82F6] to-[#2563EB]"; // Blue

  return (
    <div 
      style={circleStyle}
      className={`relative inline-flex items-center justify-center rounded-full overflow-hidden shrink-0 shadow-sm ${className}`}
    >
      {isDefault ? (
        <div className={`w-full h-full bg-gradient-to-br ${gradientClass} flex items-center justify-center`}>
          <UserIcon size={size * 0.6} className="text-white/90" />
        </div>
      ) : (
        <img 
          src={getFullUrl(src!)} 
          alt="" 
          className="w-full h-full object-cover"
          onError={(e) => {
             // Fallback to silhouette if image fails to load
             (e.target as any).style.display = 'none';
             (e.target as any).nextSibling.style.display = 'flex';
          }}
        />
      )}
      
      {/* Hidden Fallback for Error cases */}
      {!isDefault && (
        <div className={`absolute inset-0 hidden items-center justify-center bg-gradient-to-br ${gradientClass}`}>
           <UserIcon size={size * 0.6} className="text-white/90" />
        </div>
      )}
    </div>
  );
}
