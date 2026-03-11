'use client'

import Link from 'next/link'
import BottomNav from '@/components/bottom-nav'

const conversations = [
  {
    id: 1,
    name: 'Dr. Samy',
    lastMessage: 'Your appointment is confirmed for to...',
    time: '2h ago',
    unread: 1,
    online: true,
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBVw76b-xK2GTT9ISplmBv5eftTAFNu-mHokbHhzhYZPVRDKRKmQBD29VTpdxhHu0YHciSgfCtxX2AzPtMxehufs89slBK8RqHbwCK8mCfXaZREV3u47ywKELIstz7XL3lBOfaTuBUDuLJta9QngTuPyszkyk-Cy4Gl2PRmaumsXkDXtzy0bqy_MNv0cYHQVHsc-zN01yGiXZEkh6HAzBNTHsc2kVak8ovbhlLCZNAn9qfCwHPvIQ6D8hcWExN14xPir53aFm77Axk',
  },
  {
    id: 2,
    name: "Lina's Salon",
    lastMessage: "See you at 3 PM today! Don't forget...",
    time: '5h ago',
    unread: 0,
    online: false,
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBy8aHyOz3VGvlpTkfTHc_E39jVVhthnK6JS5uwm7VS446Zxn6CoMguXpNI_pKsnn2SYPUCucJT2x2ccMDDDRwwiz5w2MFOKn2vDlKP6Cf_asG36XrKIr4GmnGVFxqA6v48gOzKVEtxF7nU9YDtzO1tnp4alBoweVtlvLhLqouSlbbTJ-WN9Du9-_J4kb1Ng99MOdy5uF8GotDGNxaaKGyRBYFj9eXNWOwkPsL9OfXQJsUojxAoFdl5C87sqPh_ElFdwOEwRi8Y2us',
  },
  {
    id: 3,
    name: 'Fitness Pro',
    lastMessage: 'Can we reschedule our personal ses...',
    time: 'Yesterday',
    unread: 3,
    online: false,
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCsZJNXglqe2TFBX2RItUFVEpYUn2FhMd1WvfwLcRpKeT7u8q25QVdgAs2T-jmm1OTWtqkydWhCiGsSPkUb7C9IRNHf_3eIUWQ8gh2rJH50qy0gr67M99amhaX9nmZ3pzHcv3YzghTcn_lvw7lJqRYqY2WL0tdtTRyA2DkW6QSfOc7mlPqwg15ImCODoPG0VHyLm5rmPikYrmGx7KODN2oDAH_AXExG-MY0_uuVMpC8hOiD2J-tPDPbCaYWveyCO_zyYPPoIVIJ4rU',
  },
  {
    id: 4,
    name: 'Chef Alex',
    lastMessage: "I've sent the menu options for your e...",
    time: 'Tue',
    unread: 0,
    online: false,
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDo7Z9riGtAcHfFEZ2B4op56P2-iQoteU7N-qdxRPTLxqUhRB3SND2-t0ssSKbmxDzCa3rhIc0PODteXcCKpSrmcWDgq6K5AOuRu_BEAeQHuvtu-sISJamOzZ3T3W71aypRQQ--Ub5gMWQJ-kA8xT79ZtgW060IfmAokui7uO4aC7thj_pVvzNYpiOVPKoV5tjUY4bj12jt-S2TqcpnnFDYofuczRN6jHbj3lbgnvB-6fVQbPa1VDsjadfL64pp1ghe8EVcRcZNfj4',
  },
  {
    id: 5,
    name: 'Clean Masters',
    lastMessage: "Thanks for your feedback! We're gla...",
    time: 'Mon',
    unread: 0,
    online: false,
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCs-H8eZkUYCFJUBKsgZ7CN9flkqdIAur4T6JAXim9r1K-HT3n6OoIbjoPB4hVpxMgpAmOr_KaTwOIXdpDD3JogaJHVj1nhOj6C48Ja26h2Jr2zmxjSuvT9eDfzXrm12IOC3VSxOnPrdrHCdrDqEZpYnRJ8qTeRy_YdLZB4_-3UFS_lRYb4-sf8zB8rGP4t2X207KerL2rSz4Fnd4quUDr-5K6TjPjgK0TqGSVOwKXSooAegc06sHP7_6J6uL5roO2wfwcU8ejQcw0',
  },
]

export default function MessagesPage() {
  return (
    <div className="flex min-h-[100dvh] flex-col bg-background pb-24">
      {/* Top Bar */}
      <nav className="sticky top-0 z-50 w-full border-b border-border bg-card/80 backdrop-blur-md">
        <div className="mx-auto flex h-14 max-w-md items-center justify-between px-4">
          <div className="flex items-center gap-2">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary text-primary-foreground">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"/>
              </svg>
            </div>
            <span className="text-lg font-bold text-primary">BookApp</span>
          </div>
          <div className="flex items-center gap-1.5 rounded-full bg-primary/10 px-3 py-1.5">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" className="text-primary">
              <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
            </svg>
            <span className="text-xs font-semibold text-primary">Algiers, Algeria</span>
          </div>
        </div>
      </nav>

      <main className="mx-auto w-full max-w-md">
        {/* Title */}
        <div className="px-4 pt-6 pb-4">
          <h1 className="text-[28px] font-bold leading-tight text-foreground">Messages</h1>
        </div>

        {/* Conversations */}
        <div className="flex flex-col">
          {conversations.map((conv) => (
            <Link
              key={conv.id}
              href={`/messages/${conv.id}`}
              className="flex items-center gap-4 px-4 py-4 transition-colors hover:bg-card"
            >
              {/* Avatar */}
              <div className="relative shrink-0">
                <div className={`h-[50px] w-[50px] overflow-hidden rounded-full ${conv.unread > 0 ? 'border-2 border-primary/20' : ''}`}>
                  <img
                    src={conv.avatar}
                    alt={conv.name}
                    className="h-full w-full object-cover"
                  />
                </div>
                {conv.online && (
                  <span className="absolute bottom-0 right-0 h-3 w-3 rounded-full border-2 border-background bg-[#22c55e]" />
                )}
              </div>

              {/* Content */}
              <div className="min-w-0 flex-1">
                <div className="mb-0.5 flex items-baseline justify-between">
                  <h3 className="truncate font-bold text-foreground">{conv.name}</h3>
                  <span className={`shrink-0 text-xs font-medium ${conv.unread > 0 ? 'text-primary' : 'text-muted-foreground'}`}>
                    {conv.time}
                  </span>
                </div>
                <p className={`truncate text-sm ${conv.unread > 0 ? 'font-medium text-muted-foreground' : 'text-muted-foreground/70'}`}>
                  {conv.lastMessage}
                </p>
              </div>

              {/* Badge */}
              {conv.unread > 0 && (
                <span className="flex h-5 min-w-5 shrink-0 items-center justify-center rounded-full bg-[#ef4444] px-1.5 text-[10px] font-bold text-[#ffffff]">
                  {conv.unread}
                </span>
              )}
            </Link>
          ))}
        </div>
      </main>

      <BottomNav />
    </div>
  )
}
