import { useQuery } from '@tanstack/react-query';
import { X, ShoppingBag, Landmark, Star, Calendar, Mail, Phone, MapPin } from 'lucide-react';
import adminClient from '../api/client';
import HayaAvatar from './HayaAvatar';

interface UserDetailsModalProps {
  userId: string;
  onClose: () => void;
}

export default function UserDetailsModal({ userId, onClose }: UserDetailsModalProps) {
  const { data: user, isLoading } = useQuery({
    queryKey: ['admin-user-detail', userId],
    queryFn: () => adminClient.get(`/users/${userId}`).then(r => r.data),
  });

  if (isLoading) {
    return (
      <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/40 backdrop-blur-sm p-4">
        <div className="bg-white rounded-2xl shadow-2xl p-8 animate-pulse text-gray-400">Loading profile data...</div>
      </div>
    );
  }

  if (!user) return null;

  const isProvider = user.role === 'PROVIDER';
  const stats = user.stats || { totalSpent: 0, totalEarned: 0 };

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 overflow-y-auto">
      <div className="bg-white rounded-3xl shadow-2xl w-full max-w-4xl p-0 overflow-hidden animate-in fade-in zoom-in duration-200 my-8">
        
        {/* Header / Banner */}
        <div className="relative h-32 bg-gradient-to-r from-violet-600 to-indigo-600">
          <button 
            onClick={onClose}
            className="absolute top-4 right-4 p-2 bg-white/20 hover:bg-white/30 rounded-full text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
          
          <div className="absolute -bottom-12 left-8 flex items-end gap-5">
            <div className="w-24 h-24 rounded-2xl bg-white p-1.5 shadow-xl">
              <HayaAvatar 
                src={user.profileImage}
                firstName={user.firstName}
                lastName={user.lastName}
                role={user.role}
                size={96}
                className="rounded-xl"
              />
            </div>
            <div className="mb-2">
              <h2 className="text-2xl font-bold text-white drop-shadow-sm">{user.firstName} {user.lastName}</h2>
              <span className={`inline-block px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider text-white border border-white/30 ${
                isProvider ? 'bg-violet-500' : 'bg-blue-500'
              }`}>
                {user.role}
              </span>
            </div>
          </div>
        </div>

        <div className="pt-16 px-8 pb-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            
            {/* Left Column: Basic Info */}
            <div className="space-y-6">
              <section>
                <h4 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4">Contact Information</h4>
                <div className="space-y-3">
                  <div className="flex items-center gap-3 text-sm text-gray-600">
                    <Mail className="w-4 h-4 text-gray-400" />
                    <span>{user.email || 'No email'}</span>
                  </div>
                  <div className="flex items-center gap-3 text-sm text-gray-600">
                    <Phone className="w-4 h-4 text-gray-400" />
                    <span>{user.phone || 'No phone'}</span>
                  </div>
                  <div className="flex items-center gap-3 text-sm text-gray-600">
                    <Calendar className="w-4 h-4 text-gray-400" />
                    <span>Joined {new Date(user.createdAt).toLocaleDateString()}</span>
                  </div>
                </div>
              </section>

              {isProvider && user.providerProfile && (
                <section>
                  <h4 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4">Business Location</h4>
                  <div className="flex gap-3 text-sm text-gray-600 bg-gray-50 p-3 rounded-xl">
                    <MapPin className="w-4 h-4 text-gray-400 shrink-0 mt-0.5" />
                    <span>{user.providerProfile.address || 'Address not listed'}</span>
                  </div>
                </section>
              )}
            </div>

            {/* Middle Column: Stats Cards */}
            <div className="md:col-span-2 space-y-6">
              <div className="grid grid-cols-2 gap-4">
                <div className="bg-emerald-50 p-5 rounded-2xl border border-emerald-100/50">
                  <ShoppingBag className="w-5 h-5 text-emerald-600 mb-3" />
                  <div className="text-2xl font-bold text-emerald-900">${stats.totalSpent.toFixed(2)}</div>
                  <div className="text-xs font-medium text-emerald-600/70 uppercase">Total Lifetime Spend</div>
                </div>
                {isProvider && (
                  <div className="bg-violet-50 p-5 rounded-2xl border border-violet-100/50">
                    <Landmark className="w-5 h-5 text-violet-600 mb-3" />
                    <div className="text-2xl font-bold text-violet-900">${stats.totalEarned.toFixed(2)}</div>
                    <div className="text-xs font-medium text-violet-600/70 uppercase">Total Provider Revenue</div>
                  </div>
                )}
              </div>

              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="bg-gray-50 p-4 rounded-xl text-center">
                  <div className="text-lg font-bold text-gray-900">{user._count.clientBookings}</div>
                  <div className="text-[10px] font-bold text-gray-400 uppercase">Bookings</div>
                </div>
                <div className="bg-gray-50 p-4 rounded-xl text-center">
                  <div className="text-lg font-bold text-gray-900">{isProvider ? user.providerProfile?._count.reviewsReceived : user._count.reviewsGiven}</div>
                  <div className="text-[10px] font-bold text-gray-400 uppercase">Reviews</div>
                </div>
                <div className="bg-gray-50 p-4 rounded-xl text-center">
                  <div className="text-lg font-bold text-gray-900">{user._count.notifications}</div>
                  <div className="text-[10px] font-bold text-gray-400 uppercase">Alerts</div>
                </div>
                {isProvider && (
                  <div className="bg-gray-50 p-4 rounded-xl text-center">
                    <div className="text-lg font-bold text-gray-900">{user.providerProfile?._count.services}</div>
                    <div className="text-[10px] font-bold text-gray-400 uppercase">Services</div>
                  </div>
                )}
              </div>

              {/* Bio / Bio Bio */}
              <section className="bg-gray-50/50 p-6 rounded-2xl border border-dashed border-gray-200">
                <h4 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-3">User Biography</h4>
                <p className="text-sm text-gray-600 leading-relaxed italic">
                  {user.bio || "No biography provided by user."}
                </p>
              </section>
            </div>

          </div>
        </div>
      </div>
    </div>
  );
}
