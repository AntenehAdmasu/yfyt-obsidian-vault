# Decision: Model Locked to Claude Opus 4.6

**Date:** April 16, 2026  
**Decided by:** Anti

## Decision

All AI interactions in YFYT must use `claude-opus-4-6` — signals, chat, post-mortems, everything. Never default to Sonnet.

## Context

Anti: *"I don't know why you keep mentioning Claude Sonnet but I want to be using the best available model. I bought Opus 4.6 specifically for this purpose and will keep updating as they launch."*

## How to apply

- Model ID in all API calls: `claude-opus-4-6`
- Always upgrade to the latest best model when new versions launch
- Never use a cheaper model for cost savings — quality of signal reasoning is the product's core value
- Updated across: README, slides, product specs, context files, memory

---

*Non-negotiable. See [[tech-stack]] for full stack details.*
