import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";

interface StatusBadgeProps {
  status: string;
}

export default function StatusBadge({ status }: StatusBadgeProps) {
  const styles: Record<string, string> = {
    // Bookings
    confirmed: "bg-blue-100 text-blue-800",
    completed: "bg-green-100 text-green-800",
    cancelled: "bg-red-100 text-red-800",
    no_show: "bg-orange-100 text-orange-800",
    // Providers & Users
    active: "bg-emerald-100 text-emerald-800",
    pending_review: "bg-amber-100 text-amber-800",
    suspended: "bg-rose-100 text-rose-800",
    vacation: "bg-purple-100 text-purple-800",
  };

  const currentStyle = styles[status] || "bg-gray-100 text-gray-800";
  const formattedStatus = status.replace('_', ' ');

  return (
    <span className={twMerge(clsx("px-2.5 py-1 rounded-full text-xs font-semibold capitalize", currentStyle))}>
      {formattedStatus}
    </span>
  );
}
