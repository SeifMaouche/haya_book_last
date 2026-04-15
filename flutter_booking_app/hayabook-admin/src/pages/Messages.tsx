import { useEffect, useRef, useState } from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { MessageSquare, Zap, Eye, X, User } from 'lucide-react';
import adminClient from '../api/client';
import { io } from 'socket.io-client';

interface Message {
  id: string;
  conversationId: string;
  content: string;
  isRead: boolean;
  createdAt: string;
  sender: { firstName: string; lastName: string; role: string };
  receiver?: { firstName: string; lastName: string; role: string };
}

const SOCKET_URL = import.meta.env.VITE_SOCKET_URL || 'http://localhost:5000';

export default function Messages() {
  const qc      = useQueryClient();
  const socketRef = useRef<ReturnType<typeof io> | null>(null);
  
  // ── Thread Monitor State ──────────────────────────────────────
  const [activeThreadId, setActiveThreadId] = useState<string | null>(null);
  const [threadParticipants, setThreadParticipants] = useState<string>('');

  const { data: conversations = [], isLoading } = useQuery<Message[]>({
    queryKey: ['admin-messages'],
    queryFn:  () => adminClient.get('/messages').then(r => r.data),
    refetchInterval: 15_000,
  });

  const { data: threadMessages = [], isLoading: loadingThread } = useQuery<Message[]>({
    queryKey:  ['admin-thread', activeThreadId],
    queryFn:   () => adminClient.get(`/messages/conversation/${activeThreadId}`).then(r => r.data),
    enabled:   !!activeThreadId,
    refetchInterval: activeThreadId ? 5000 : false,
  });

  // ── Connect to Socket.io and listen for ANY new message ──────────
  useEffect(() => {
    const socket = io(SOCKET_URL, { transports: ['websocket'] });
    socketRef.current = socket;

    socket.on('new_message', () => {
      qc.invalidateQueries({ queryKey: ['admin-messages'] });
      if (activeThreadId) qc.invalidateQueries({ queryKey: ['admin-thread', activeThreadId] });
    });

    return () => { socket.disconnect(); };
  }, [qc, activeThreadId]);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Conversations Monitor</h1>
          <p className="text-sm text-gray-500 mt-1 flex items-center gap-1.5">
            <Zap className="w-3.5 h-3.5 text-emerald-500" />
            Live Oversight — monitoring all client-provider interactions
          </p>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          {isLoading ? (
            <div className="p-6 space-y-3">
              {Array.from({ length: 6 }).map((_, i) => <div key={i} className="h-14 bg-gray-100 rounded-lg animate-pulse" />)}
            </div>
          ) : conversations.length === 0 ? (
            <div className="py-20 text-center">
              <MessageSquare className="w-10 h-10 text-gray-200 mx-auto mb-3" />
              <p className="text-gray-400">No active conversations yet</p>
            </div>
          ) : (
            <table className="w-full text-sm text-left text-gray-600">
              <thead className="text-xs uppercase bg-gray-50 text-gray-500 border-b border-gray-100">
                <tr>
                  <th className="px-6 py-3">Participants</th>
                  <th className="px-6 py-3">Last Content</th>
                  <th className="px-6 py-3 text-center">Status</th>
                  <th className="px-6 py-3">Last Activity</th>
                  <th className="px-6 py-3 text-center">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {conversations.map(m => (
                  <tr key={m.id} className={`hover:bg-gray-50/50 transition-colors ${!m.isRead ? 'bg-violet-50/10' : ''}`}>
                    <td className="px-6 py-4 font-medium text-gray-800">
                      <div className="flex flex-col">
                        <span>{m.sender.firstName} {m.sender.lastName}</span>
                        <span className="text-[10px] text-gray-400 uppercase tracking-tight font-bold">{m.sender.role}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-gray-500 max-w-xs truncate">{m.content}</td>
                    <td className="px-6 py-4 text-center">
                      <span className={`inline-block w-2 h-2 rounded-full ${m.isRead ? 'bg-gray-300' : 'bg-violet-500 animate-pulse'}`} />
                    </td>
                    <td className="px-6 py-4 text-gray-400 whitespace-nowrap">
                      {new Date(m.createdAt).toLocaleString()}
                    </td>
                    <td className="px-6 py-4 text-center">
                      <button 
                        onClick={() => {
                          setActiveThreadId(m.conversationId);
                          setThreadParticipants(`${m.sender.firstName} & Target`);
                        }}
                        className="inline-flex items-center gap-1.5 text-xs font-bold text-violet-600 hover:text-violet-700 bg-violet-50 hover:bg-violet-100 px-3 py-1.5 rounded-lg transition-colors"
                      >
                        <Eye className="w-3.5 h-3.5" />
                        INSPECT THREAD
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {/* ── Conversation Thread Drawer ────────────────────────────── */}
      {activeThreadId && (
        <div className="fixed inset-0 z-50 flex justify-end bg-black/40 backdrop-blur-sm">
          <div className="bg-gray-50 h-full w-full max-w-2xl shadow-2xl flex flex-col animate-in slide-in-from-right duration-300">
            {/* Header */}
            <div className="bg-white border-b border-gray-200 p-5 flex items-center justify-between">
              <div>
                <h3 className="text-lg font-bold text-gray-900">Thread Inspection</h3>
                <p className="text-xs text-gray-500 font-mono">ID: {activeThreadId}</p>
              </div>
              <button 
                onClick={() => setActiveThreadId(null)}
                className="p-2 hover:bg-gray-100 rounded-xl transition-colors"
              >
                <X className="w-5 h-5 text-gray-400" />
              </button>
            </div>

            {/* Chat History */}
            <div className="flex-1 overflow-y-auto p-6 space-y-4">
              {loadingThread ? (
                <div className="flex items-center justify-center h-full text-gray-400 text-sm italic">Loading full history...</div>
              ) : (
                threadMessages.map((msg, i) => (
                  <div key={msg.id} className={`flex flex-col ${msg.sender.role === 'PROVIDER' ? 'items-end' : 'items-start'}`}>
                    <div className="flex items-center gap-2 mb-1 px-1">
                      <span className="text-[10px] font-bold text-gray-400 uppercase">{msg.sender.firstName} ({msg.sender.role})</span>
                    </div>
                    <div className={`max-w-[85%] px-4 py-3 rounded-2xl text-sm shadow-sm ${
                      msg.sender.role === 'PROVIDER' 
                        ? 'bg-violet-600 text-white rounded-tr-none' 
                        : 'bg-white text-gray-800 rounded-tl-none border border-gray-100'
                    }`}>
                      {msg.content}
                    </div>
                    <span className="text-[9px] text-gray-400 mt-1 uppercase tracking-widest">{new Date(msg.createdAt).toLocaleTimeString()}</span>
                  </div>
                ))
              )}
            </div>

            <div className="p-4 bg-white border-t border-gray-200">
              <p className="text-[10px] text-center text-gray-400 italic">
                This is a read-only oversight view. Admins cannot participate in conversations.
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
