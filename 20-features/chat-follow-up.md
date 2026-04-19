# Chat Follow-up

**Status:** Not yet built  
**Phase:** 1 (Step 8)  
**API route:** `POST /api/wingman/chat`

## What it does

After Wingman generates a signal, the user can ask follow-up questions in a streaming chat. "Why did you pick that entry?" "What if I enter lower?" "Explain RSI to me."

## How it works

- Input: `{ signalId, message }`
- Server loads: original signal + market data snapshot + chat history for this signal
- Sends to Claude Opus 4.6 with streaming enabled
- Response streams to the UI in real-time (first token <400ms target)
- All messages saved to `chat_messages` table in Supabase

## Context sent to Claude

- The full original signal (action, entry, SL, TP, reasoning)
- The market data snapshot from signal generation
- User's portfolio state
- Full chat history for this signal session
- System prompt: "You are Wingman. The user is asking about a signal you generated. Be educational, explain concepts, answer directly."

## Cost per message

~$0.03-0.04 (shorter responses than full signal generation)

## Design decisions

- Chat is scoped to a single signal — starting a new signal starts a new chat
- Chat history is persisted for Phase 4 journal analysis (pattern detection)
- Streaming is mandatory — no waiting for full response

---

*Depends on [[wingman-signal-generation]] being built first.*
