'use client'

import { useState, useRef, useEffect, use } from 'react'
import { ArrowLeft, Send, Plus, Smile, Video, Phone } from 'lucide-react'
import { useRouter } from 'next/navigation'

interface ChatMessage {
  id: number
  text: string
  sender: 'user' | 'provider'
  time: string
  read?: boolean
}

const providerMap: Record<string, { name: string; avatar: string }> = {
  '1': {
    name: 'Dr. Samy',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBVw76b-xK2GTT9ISplmBv5eftTAFNu-mHokbHhzhYZPVRDKRKmQBD29VTpdxhHu0YHciSgfCtxX2AzPtMxehufs89slBK8RqHbwCK8mCfXaZREV3u47ywKELIstz7XL3lBOfaTuBUDuLJta9QngTuPyszkyk-Cy4Gl2PRmaumsXkDXtzy0bqy_MNv0cYHQVHsc-zN01yGiXZEkh6HAzBNTHsc2kVak8ovbhlLCZNAn9qfCwHPvIQ6D8hcWExN14xPir53aFm77Axk',
  },
  '2': {
    name: "Lina's Salon",
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBy8aHyOz3VGvlpTkfTHc_E39jVVhthnK6JS5uwm7VS446Zxn6CoMguXpNI_pKsnn2SYPUCucJT2x2ccMDDDRwwiz5w2MFOKn2vDlKP6Cf_asG36XrKIr4GmnGVFxqA6v48gOzKVEtxF7nU9YDtzO1tnp4alBoweVtlvLhLqouSlbbTJ-WN9Du9-_J4kb1Ng99MOdy5uF8GotDGNxaaKGyRBYFj9eXNWOwkPsL9OfXQJsUojxAoFdl5C87sqPh_ElFdwOEwRi8Y2us',
  },
  '3': {
    name: 'Fitness Pro',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCsZJNXglqe2TFBX2RItUFVEpYUn2FhMd1WvfwLcRpKeT7u8q25QVdgAs2T-jmm1OTWtqkydWhCiGsSPkUb7C9IRNHf_3eIUWQ8gh2rJH50qy0gr67M99amhaX9nmZ3pzHcv3YzghTcn_lvw7lJqRYqY2WL0tdtTRyA2DkW6QSfOc7mlPqwg15ImCODoPG0VHyLm5rmPikYrmGx7KODN2oDAH_AXExG-MY0_uuVMpC8hOiD2J-tPDPbCaYWveyCO_zyYPPoIVIJ4rU',
  },
  '4': {
    name: 'Chef Alex',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDo7Z9riGtAcHfFEZ2B4op56P2-iQoteU7N-qdxRPTLxqUhRB3SND2-t0ssSKbmxDzCa3rhIc0PODteXcCKpSrmcWDgq6K5AOuRu_BEAeQHuvtu-sISJamOzZ3T3W71aypRQQ--Ub5gMWQJ-kA8xT79ZtgW060IfmAokui7uO4aC7thj_pVvzNYpiOVPKoV5tjUY4bj12jt-S2TqcpnnFDYofuczRN6jHbj3lbgnvB-6fVQbPa1VDsjadfL64pp1ghe8EVcRcZNfj4',
  },
  '5': {
    name: 'Clean Masters',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCs-H8eZkUYCFJUBKsgZ7CN9flkqdIAur4T6JAXim9r1K-HT3n6OoIbjoPB4hVpxMgpAmOr_KaTwOIXdpDD3JogaJHVj1nhOj6C48Ja26h2Jr2zmxjSuvT9eDfzXrm12IOC3VSxOnPrdrHCdrDqEZpYnRJ8qTeRy_YdLZB4_-3UFS_lRYb4-sf8zB8rGP4t2X207KerL2rSz4Fnd4quUDr-5K6TjPjgK0TqGSVOwKXSooAegc06sHP7_6J6uL5roO2wfwcU8ejQcw0',
  },
}

const initialMessages: ChatMessage[] = [
  {
    id: 1,
    text: 'Hello! How are you feeling today after starting your new medication?',
    sender: 'provider',
    time: '10:30 AM',
  },
  {
    id: 2,
    text: "I'm feeling much better, thank you doctor. The headache has completely subsided.",
    sender: 'user',
    time: '10:32 AM',
    read: true,
  },
  {
    id: 3,
    text: "That's great to hear! Any side effects like nausea or dizziness?",
    sender: 'provider',
    time: '10:35 AM',
  },
  {
    id: 4,
    text: 'None at all. Should I continue the same dosage for the rest of the week?',
    sender: 'user',
    time: '10:38 AM',
    read: true,
  },
]

export default function ChatPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params)
  const router = useRouter()
  const [messages, setMessages] = useState<ChatMessage[]>(initialMessages)
  const [input, setInput] = useState('')
  const scrollRef = useRef<HTMLDivElement>(null)

  const info = providerMap[id] || providerMap['1']

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: 'smooth' })
  }, [messages])

  const handleSend = () => {
    if (!input.trim()) return
    const newMsg: ChatMessage = {
      id: messages.length + 1,
      text: input.trim(),
      sender: 'user',
      time: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
      read: false,
    }
    setMessages([...messages, newMsg])
    setInput('')

    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        {
          id: prev.length + 1,
          text: 'Thank you for your message! I will get back to you shortly.',
          sender: 'provider',
          time: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
        },
      ])
    }, 1200)
  }

  return (
    <div className="flex h-[100dvh] flex-col bg-background">
      {/* Header */}
      <header className="sticky top-0 z-10 flex items-center justify-between border-b border-border bg-card px-4 py-3">
        <div className="flex items-center gap-3">
          <button
            onClick={() => router.back()}
            className="flex h-10 w-10 items-center justify-center rounded-full text-muted-foreground transition-colors hover:bg-muted"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <div className="relative">
            <div className="h-10 w-10 overflow-hidden rounded-full">
              <img src={info.avatar} alt={info.name} className="h-full w-full object-cover" />
            </div>
            <span className="absolute bottom-0 right-0 h-3 w-3 rounded-full border-2 border-card bg-[#22c55e]" />
          </div>
          <div>
            <h2 className="text-base font-bold leading-tight text-foreground">{info.name}</h2>
            <span className="text-xs font-medium text-primary">Online</span>
          </div>
        </div>
        <div className="flex items-center gap-1">
          <button className="flex h-10 w-10 items-center justify-center rounded-full text-muted-foreground hover:bg-muted">
            <Video className="h-5 w-5" />
          </button>
          <button className="flex h-10 w-10 items-center justify-center rounded-full text-muted-foreground hover:bg-muted">
            <Phone className="h-5 w-5" />
          </button>
        </div>
      </header>

      {/* Chat Area */}
      <div ref={scrollRef} className="flex-1 overflow-y-auto bg-background px-4 py-6">
        <div className="mx-auto flex w-full max-w-2xl flex-col gap-6">
          {/* Date Separator */}
          <div className="flex justify-center">
            <span className="rounded-full bg-muted px-3 py-1 text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
              Today
            </span>
          </div>

          {messages.map((msg) => {
            if (msg.sender === 'provider') {
              return (
                <div key={msg.id} className="flex max-w-[85%] items-end gap-2">
                  <div className="h-8 w-8 shrink-0 overflow-hidden rounded-full">
                    <img src={info.avatar} alt={info.name} className="h-full w-full object-cover" />
                  </div>
                  <div className="flex flex-col gap-1.5">
                    <div className="rounded-lg rounded-bl-none bg-card p-4 text-sm leading-relaxed text-foreground shadow-sm">
                      {msg.text}
                    </div>
                    <span className="ml-1 text-[10px] text-muted-foreground">{msg.time}</span>
                  </div>
                </div>
              )
            }
            return (
              <div key={msg.id} className="flex max-w-[85%] flex-col items-end gap-1.5 self-end">
                <div className="rounded-lg rounded-br-none bg-primary p-4 text-sm leading-relaxed text-primary-foreground shadow-sm">
                  {msg.text}
                </div>
                <div className="mr-1 flex items-center gap-1">
                  <span className="text-[10px] text-muted-foreground">{msg.time}</span>
                  {msg.read && (
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="text-primary">
                      <path d="M18 6L7 17l-5-5" />
                      <path d="M22 6L11 17" />
                    </svg>
                  )}
                </div>
              </div>
            )
          })}
        </div>
      </div>

      {/* Bottom Input */}
      <footer className="border-t border-border bg-card p-4">
        <div className="mx-auto flex w-full max-w-2xl items-center gap-3">
          <button className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full text-muted-foreground hover:text-primary">
            <Plus className="h-5 w-5" />
          </button>
          <div className="relative flex flex-1 items-center">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSend()}
              placeholder="Type a message..."
              className="w-full rounded-xl border-none bg-muted py-3 pl-4 pr-12 text-sm text-foreground placeholder:text-muted-foreground focus:ring-2 focus:ring-primary/20 focus:outline-none"
            />
            <button className="absolute right-2 flex h-8 w-8 items-center justify-center rounded-lg text-muted-foreground hover:text-primary">
              <Smile className="h-5 w-5" />
            </button>
          </div>
          <button
            onClick={handleSend}
            disabled={!input.trim()}
            className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg shadow-primary/20 transition-colors hover:bg-primary/90 disabled:opacity-50"
          >
            <Send className="h-4 w-4" />
          </button>
        </div>
      </footer>
    </div>
  )
}
