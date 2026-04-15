import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Plus, Trash2, Tags } from 'lucide-react';
import adminClient from '../api/client';

interface Category {
  id: string;
  name: string;
  description: string | null;
  icon: string | null;
  isActive: boolean;
  createdAt: string;
}

export default function Categories() {
  const qc = useQueryClient();
  const [showAdd, setShowAdd] = useState(false);
  const [newName, setNewName] = useState('');
  const [newDesc, setNewDesc] = useState('');
  const [newIcon, setNewIcon] = useState('');

  const { data: categories = [], isLoading } = useQuery<Category[]>({
    queryKey: ['admin-categories'],
    queryFn: () => adminClient.get('/categories?all=true').then(r => r.data),
    refetchInterval: 30_000,
  });

  const addMutation = useMutation({
    mutationFn: ({ name, description, icon }: { name: string; description: string; icon: string }) =>
      adminClient.post('/categories', { name, description, icon }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['admin-categories'] });
      setNewName('');
      setNewDesc('');
      setNewIcon('');
      setShowAdd(false);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => adminClient.delete(`/categories/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin-categories'] }),
  });

  const toggleMutation = useMutation({
    mutationFn: ({ id, isActive }: { id: string; isActive: boolean }) =>
      adminClient.patch(`/categories/${id}`, { isActive }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['admin-categories'] }),
  });

  const handleAdd = () => {
    if (!newName.trim()) return;
    addMutation.mutate({ name: newName.trim(), description: newDesc.trim(), icon: newIcon.trim() });
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Categories</h1>
          <p className="text-sm text-gray-500 mt-1">{categories.length} service categories</p>
        </div>
        <button
          onClick={() => setShowAdd(v => !v)}
          className="flex items-center gap-2 bg-violet-600 text-white px-4 py-2.5 rounded-xl text-sm font-semibold hover:bg-violet-700 transition-colors shadow-sm"
        >
          <Plus className="w-4 h-4" />
          Add Category
        </button>
      </div>

      {/* Add category form */}
      {showAdd && (
        <div className="bg-white rounded-2xl border border-violet-100 shadow-sm p-5 space-y-4">
          <h3 className="font-semibold text-gray-800">New Category</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input
              value={newName}
              onChange={e => setNewName(e.target.value)}
              placeholder="Category name *"
              className="px-4 py-2.5 text-sm border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-violet-400/40"
            />
            <input
              value={newDesc}
              onChange={e => setNewDesc(e.target.value)}
              placeholder="Description (optional)"
              className="px-4 py-2.5 text-sm border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-violet-400/40"
            />
            <input
              value={newIcon}
              onChange={e => setNewIcon(e.target.value)}
              placeholder="Icon name (e.g. scissors, cut) (optional)"
              className="px-4 py-2.5 text-sm border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-violet-400/40 md:col-span-2"
            />
          </div>
          <div className="flex gap-3">
            <button
              onClick={handleAdd}
              disabled={!newName.trim() || addMutation.isPending}
              className="px-5 py-2.5 bg-violet-600 text-white text-sm font-semibold rounded-xl hover:bg-violet-700 disabled:opacity-50 transition-colors"
            >
              {addMutation.isPending ? 'Saving…' : 'Save Category'}
            </button>
            <button
              onClick={() => { setShowAdd(false); setNewName(''); setNewDesc(''); setNewIcon(''); }}
              className="px-5 py-2.5 bg-gray-100 text-gray-600 text-sm font-semibold rounded-xl hover:bg-gray-200 transition-colors"
            >
              Cancel
            </button>
          </div>
        </div>
      )}

      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          {isLoading ? (
            <div className="p-6 space-y-3">
              {Array.from({ length: 5 }).map((_, i) => (
                <div key={i} className="h-10 bg-gray-100 rounded-lg animate-pulse" />
              ))}
            </div>
          ) : (
            <table className="w-full text-left text-sm text-gray-600">
              <thead className="text-xs uppercase bg-gray-50 text-gray-500 border-b border-gray-100">
                <tr>
                  <th className="px-6 py-3">Name</th>
                  <th className="px-6 py-3">Description</th>
                  <th className="px-6 py-3 text-center">Status</th>
                  <th className="px-6 py-3 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {categories.map(c => (
                  <tr key={c.id} className="hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-4 font-semibold text-gray-800 flex items-center gap-2">
                      <Tags className="w-4 h-4 text-violet-400" />
                      {c.name}
                    </td>
                    <td className="px-6 py-4 text-gray-500">{c.description ?? '—'}</td>
                    <td className="px-6 py-4 text-center">
                      <button
                        onClick={() => toggleMutation.mutate({ id: c.id, isActive: !c.isActive })}
                        disabled={toggleMutation.isPending}
                        className={`text-xs font-semibold px-2.5 py-1 rounded-full transition-colors ${
                          c.isActive ? 'bg-emerald-100 text-emerald-700 hover:bg-emerald-200' : 'bg-gray-100 text-gray-500 hover:bg-gray-200'
                        }`}
                      >
                        {c.isActive ? 'Active' : 'Inactive'}
                      </button>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <button
                        onClick={() => {
                          if (!confirm(`Delete category "${c.name}"?`)) return;
                          deleteMutation.mutate(c.id);
                        }}
                        className="text-gray-400 hover:text-red-500 transition-colors p-2 rounded-lg hover:bg-red-50"
                        title="Delete Category"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
                {!categories.length && (
                  <tr><td colSpan={4} className="px-6 py-10 text-center text-gray-400">No categories yet</td></tr>
                )}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}
