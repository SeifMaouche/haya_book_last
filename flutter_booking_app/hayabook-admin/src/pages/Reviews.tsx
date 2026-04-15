import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Star, Trash2 } from 'lucide-react';
import adminClient from '../api/client';

interface Review {
  id: string;
  rating: number;
  comment: string | null;
  createdAt: string;
  client: { firstName: string; lastName: string };
  providerProfile: { businessName: string };
}

function StarRating({ rating }: { rating: number }) {
  return (
    <div className="flex items-center gap-0.5">
      {Array.from({ length: 5 }).map((_, i) => (
        <Star key={i} className={`w-3.5 h-3.5 ${i < rating ? 'text-amber-400 fill-amber-400' : 'text-gray-200 fill-gray-200'}`} />
      ))}
    </div>
  );
}

export default function Reviews() {
  const qc = useQueryClient();

  const { data: reviews = [], isLoading } = useQuery<Review[]>({
    queryKey: ['admin-reviews'],
    queryFn:  () => adminClient.get('/reviews').then(r => r.data),
    refetchInterval: 30_000,
  });

  // ── Delete review mutation ────────────────────────────────────
  const deleteMutation = useMutation({
    mutationFn: (id: string) => adminClient.delete(`/reviews/${id}`),
    onSuccess:  () => qc.invalidateQueries({ queryKey: ['admin-reviews'] }),
  });

  const avgRating = reviews.length
    ? (reviews.reduce((s, r) => s + r.rating, 0) / reviews.length).toFixed(1)
    : '—';

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Reviews</h1>
          <p className="text-sm text-gray-500 mt-1">
            {reviews.length} reviews • Platform avg&nbsp;
            <span className="font-semibold text-amber-500">★ {avgRating}</span>
          </p>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          {isLoading ? (
            <div className="p-6 space-y-3">
              {Array.from({ length: 5 }).map((_, i) => <div key={i} className="h-16 bg-gray-100 rounded-lg animate-pulse" />)}
            </div>
          ) : (
            <table className="w-full text-sm text-left text-gray-600">
              <thead className="text-xs uppercase bg-gray-50 text-gray-500 border-b border-gray-100">
                <tr>
                  <th className="px-6 py-3">Reviewer</th>
                  <th className="px-6 py-3">Provider</th>
                  <th className="px-6 py-3">Rating</th>
                  <th className="px-6 py-3">Comment</th>
                  <th className="px-6 py-3">Date</th>
                  <th className="px-6 py-3 text-center">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {reviews.map(r => (
                  <tr key={r.id} className="hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-4 font-medium text-gray-800">{r.client.firstName} {r.client.lastName}</td>
                    <td className="px-6 py-4">{r.providerProfile.businessName}</td>
                    <td className="px-6 py-4"><StarRating rating={r.rating} /></td>
                    <td className="px-6 py-4 text-gray-500 max-w-xs truncate">{r.comment ?? <em className="text-gray-300">No comment</em>}</td>
                    <td className="px-6 py-4 text-gray-400 whitespace-nowrap">{new Date(r.createdAt).toLocaleDateString()}</td>
                    {/* ── Delete button ── */}
                    <td className="px-6 py-4 text-center">
                      <button
                        onClick={() => {
                          if (!confirm('Delete this review? This will recalculate the provider rating.')) return;
                          deleteMutation.mutate(r.id);
                        }}
                        disabled={deleteMutation.isPending}
                        className="inline-flex items-center gap-1.5 text-xs font-medium px-3 py-1.5 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
                        title="Delete Review"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                        Delete
                      </button>
                    </td>
                  </tr>
                ))}
                {!reviews.length && (
                  <tr><td colSpan={6} className="px-6 py-10 text-center text-gray-400">No reviews yet</td></tr>
                )}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}
