import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Mail, MessageCircle, Reply, CheckCircle, Clock, Search, Filter, Link, User } from 'lucide-react';
import adminClient from '../api/client';
import HayaAvatar from '../components/HayaAvatar';

interface SupportMessage {
  id: string;
  userId: string;
  subject: string;
  message: string;
  status: 'OPEN' | 'RESOLVED';
  reply?: string;
  createdAt: string;
  user: {
    firstName: string;
    lastName: string;
    email: string;
    phone?: string;
    role: string;
  };
}

export default function Support() {
  const qc = useQueryClient();
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState<'ALL' | 'OPEN' | 'RESOLVED'>('ALL');
  const [activeMsg, setActiveMsg] = useState<SupportMessage | null>(null);
  const [replyText, setReplyText] = useState('');

  const { data: messages = [], isLoading } = useQuery<SupportMessage[]>({
    queryKey: ['admin-support'],
    queryFn: () => adminClient.get('/support').then(r => r.data),
  });

  const replyMutation = useMutation({
    mutationFn: (data: { id: string, reply: string }) => 
      adminClient.post(`/support/${data.id}/reply`, { reply: data.reply }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin-support'] });
      setActiveMsg(null);
      setReplyText('');
    }
  });

  const filtered = messages.filter(m => {
    const matchesSearch = 
      m.subject.toLowerCase().includes(searchTerm.toLowerCase()) ||
      m.user.firstName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      m.user.lastName.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesFilter = filterStatus === 'ALL' || m.status === filterStatus;
    
    return matchesSearch && matchesFilter;
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Support Tickets</h1>
          <p className="text-sm text-gray-500 mt-1">Manage in-app support requests and contact inquiries</p>
        </div>
        <div className="flex gap-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input 
              type="text" 
              placeholder="Search by subject or user..."
              className="pl-10 pr-4 py-2 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500/20 w-64"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <select 
            className="px-4 py-2 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500/20"
            value={filterStatus}
            onChange={(e) => setFilterStatus(e.target.value as any)}
          >
            <option value="ALL">All Status</option>
            <option value="OPEN">Pending (Open)</option>
            <option value="RESOLVED">Resolved</option>
          </select>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden text-sm">
        {isLoading ? (
          <div className="p-12 space-y-4">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="h-16 bg-gray-50 rounded-xl animate-pulse" />
            ))}
          </div>
        ) : filtered.length === 0 ? (
          <div className="py-20 text-center">
            <Mail className="w-12 h-12 text-gray-200 mx-auto mb-4" />
            <p className="text-gray-400 font-medium">No support messages found</p>
          </div>
        ) : (
          <table className="w-full text-left">
            <thead>
              <tr className="bg-gray-50 border-b border-gray-100">
                <th className="px-6 py-4 font-bold text-gray-600">User / Identity</th>
                <th className="px-6 py-4 font-bold text-gray-600">Subject</th>
                <th className="px-6 py-4 font-bold text-gray-600">Status</th>
                <th className="px-6 py-4 font-bold text-gray-600 text-center">Date</th>
                <th className="px-6 py-4 font-bold text-gray-600 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-50">
              {filtered.map(msg => (
                <tr key={msg.id} className="hover:bg-gray-50/50 transition-colors">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center gap-3">
                      <HayaAvatar firstName={msg.user.firstName} lastName={msg.user.lastName} role={msg.user.role as any} size={40} />
                      <div>
                        <div className="font-bold text-gray-900">{msg.user.firstName} {msg.user.lastName}</div>
                        <div className="text-[10px] uppercase font-bold text-violet-600 tracking-tighter">{msg.user.role}</div>
                        <div className="text-[10px] text-gray-400">{msg.user.email}</div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="font-medium text-gray-800 line-clamp-1">{msg.subject}</div>
                    <div className="text-xs text-gray-400 line-clamp-1 mt-0.5">{msg.message}</div>
                  </td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold ${
                      msg.status === 'RESOLVED' 
                        ? 'bg-emerald-50 text-emerald-600 box-shadow-none' 
                        : 'bg-amber-50 text-amber-600'
                    }`}>
                      {msg.status === 'RESOLVED' ? <CheckCircle className="w-3 h-3" /> : <Clock className="w-3 h-3" />}
                      {msg.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-center text-gray-400 text-xs">
                    {new Date(msg.createdAt).toLocaleDateString()}
                    <div className="text-[10px] opacity-70">{new Date(msg.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</div>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button 
                      onClick={() => setActiveMsg(msg)}
                      className="inline-flex items-center gap-2 px-3 py-1.5 bg-violet-50 text-violet-600 rounded-lg hover:bg-violet-100 font-bold transition-all"
                    >
                      <Reply className="w-3.5 h-3.5" />
                      {msg.status === 'RESOLVED' ? 'VIEW REPLY' : 'REPLY'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Reply / View Modal */}
      {activeMsg && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-xl overflow-hidden animate-in zoom-in-95 duration-200">
            <div className="p-6 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
              <div className="flex items-center gap-3">
                <div className="p-2.5 bg-violet-100 rounded-xl text-violet-600">
                  <Mail className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-bold text-gray-900">Support Request</h3>
                  <p className="text-[11px] text-gray-500 font-mono">TICKET: {activeMsg.id.substring(0, 8)}</p>
                </div>
              </div>
              <button 
                onClick={() => setActiveMsg(null)}
                className="p-2 hover:bg-gray-200 rounded-lg transition-colors text-gray-400"
              >
                <Clock className="w-5 h-5 rotate-45" />
              </button>
            </div>

            <div className="p-8 space-y-6">
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <label className="text-[10px] font-black uppercase text-gray-400 tracking-widest">Message from User</label>
                  <span className="text-[10px] text-gray-400 italic">Received on {new Date(activeMsg.createdAt).toLocaleString()}</span>
                </div>
                <div className="bg-gray-50 rounded-xl p-4 border border-gray-100">
                  <div className="font-bold text-gray-900 mb-1">{activeMsg.subject}</div>
                  <div className="text-gray-600 leading-relaxed text-[13px]">{activeMsg.message}</div>
                </div>
              </div>

              {activeMsg.status === 'RESOLVED' ? (
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase text-emerald-600 tracking-widest flex items-center gap-1.5">
                    <CheckCircle className="w-3 h-3" /> Admin Reply Sent
                  </label>
                  <div className="bg-emerald-50/30 rounded-xl p-4 border border-emerald-100 text-[13px] text-gray-700 leading-relaxed">
                    {activeMsg.reply}
                  </div>
                </div>
              ) : (
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase text-violet-600 tracking-widest">Your Reply</label>
                  <textarea 
                    autoFocus
                    className="w-full h-32 p-4 bg-white border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-violet-500/20 resize-none transition-all placeholder:text-gray-300"
                    placeholder="Type your response here... The user will receive this as an in-app notification."
                    value={replyText}
                    onChange={(e) => setReplyText(e.target.value)}
                  />
                  <div className="flex items-center justify-between pt-2">
                    <p className="text-[10px] text-gray-400 italic flex items-center gap-1">
                      <MessageCircle className="w-3 h-3" /> Will be sent as a push notification
                    </p>
                    <button 
                      disabled={!replyText.trim() || replyMutation.isPending}
                      onClick={() => replyMutation.mutate({ id: activeMsg.id, reply: replyText })}
                      className="px-6 py-2 bg-violet-600 text-white rounded-xl font-bold text-sm shadow-xl shadow-violet-500/20 hover:bg-violet-700 disabled:opacity-50 disabled:shadow-none transition-all flex items-center gap-2"
                    >
                      {replyMutation.isPending ? 'Sending...' : 'Send Reply'}
                      <Reply className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
