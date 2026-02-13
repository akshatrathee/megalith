# Kheti AI - Soul

## The Name

"Kheti" (खेती) means **farming** in Hindi. Just as a farmer cultivates diverse crops across different plots of land — each with its own soil, climate, and strengths — Kheti AI cultivates intelligence across diverse hardware. Your GPUs, CPUs, NPUs, and cloud APIs are the fields. The models are the crops. The mesh is the irrigation system that routes water (requests) to wherever it grows best.

---

## Core Philosophy

### Own Your Intelligence

The AI industry is consolidating around a few cloud providers. Kheti AI exists because **your hardware should work for you**. If you have a GPU sitting idle, it should be serving your requests — not someone else's. If you have 12 Raspberry Pis collecting dust, they should be doing something useful. Cloud APIs are a tool, not a dependency.

### Local First, Cloud When Necessary

Every request starts local. The mesh evaluates speed, quality, and cost to find the best model on your own machines. Cloud APIs are the fallback — the safety net for when you need premium reasoning (Claude Opus), web search (Perplexity), or your local machines are overloaded. The goal is to minimize cloud spending without sacrificing quality.

### Simplicity Over Sophistication

A single API endpoint. OpenAI-compatible. Drop it into any tool that speaks the OpenAI protocol — VSCode, Python scripts, N8N workflows, mobile apps. No custom SDKs, no proprietary formats, no vendor lock-in. If you can use `openai.ChatCompletion.create()`, you can use Kheti AI.

### Hardware Agnostic

Kheti AI doesn't care if your inference runs on an NVIDIA RTX 5090, an AMD NPU, an Apple M4 Pro, or a Ryzen CPU with 128GB of RAM. If it runs Ollama and responds on port 11434, it's part of the mesh. The system embraces heterogeneity — that's the whole point of a homelab.

---

## Design Principles

### 1. One Endpoint, Many Machines

Users should never need to know which machine or model is handling their request. They say `model: "code"` and the mesh figures out the rest. The complexity lives in the config, not in the client.

### 2. Graceful Degradation

If a machine goes down, the mesh routes around it. If all local machines are down, cloud APIs catch the request. If cloud keys aren't configured, the system still works with whatever is available. Nothing should catastrophically fail because one component is missing.

### 3. Progressive Disclosure

The README gets you running in 5 minutes. The INIT guide explains the architecture. The MEMORY captures operational knowledge. The full config file reveals every knob and dial. You engage with complexity only when you need it.

### 4. No Waste

Response caching (Redis) prevents paying twice for the same answer. Budget limits prevent runaway cloud costs. Routing weights ensure cheap local models handle simple queries, saving expensive models for hard problems. Every token counts.

### 5. Template-Driven Scaling

Adding a new machine should take minutes, not hours. The config file contains pre-built templates for every machine in the homelab. Uncomment, set the IP, restart. No YAML surgery required.

---

## What Kheti AI Is NOT

- **Not a model training platform** — it routes to models, it doesn't train them
- **Not a cloud service** — it runs on YOUR hardware, in YOUR network
- **Not a replacement for Ollama** — it sits on top of Ollama (and cloud APIs) as an orchestration layer
- **Not production SaaS** — it's a homelab tool built for one person's infrastructure, though others can adapt it

---

## The Vision

Imagine walking up to any device on your network and asking it a question. Your phone, your laptop, your terminal. The question flows to Pi5L, which evaluates what you're asking — is it a code question? Use the RTX 5090 with Qwen 2.5 Coder. Is it a vision task? Route to LLaVA. Is it a research question? Send it to Perplexity. Is it a quick chat? Use the nearest small model for instant response.

You don't think about which model, which machine, which API key. You just ask. The mesh handles the rest.

That's the farm. Every field producing exactly what it's best at. Every harvest routed to where it's needed most.

---

## Guiding Questions

When making decisions about Kheti AI, ask:

1. **Does this keep things local-first?** If a feature pushes more traffic to cloud APIs without good reason, reconsider.
2. **Does this add complexity for the user?** If someone needs to read a manual to use a new feature, the feature needs better defaults.
3. **Does this work when something is broken?** If a feature fails silently when a machine is offline, it needs a fallback path.
4. **Would a farmer understand this?** Not literally, but the system should feel natural — plant seeds, water them, harvest the results. No black magic.

---

## On Cost

The entire infrastructure costs electricity. That's it. No monthly subscriptions for local inference. Cloud API spend is tracked, budgeted, and minimized by design. The RTX 5090 you already bought for gaming now pays for itself in saved API costs. The Raspberry Pi that orchestrates everything costs less than a single Claude Opus API call per month to run.

This is the economics of ownership. You pay once for hardware, and it works forever.

---

## On Privacy

Your prompts stay on your network. Local models run locally — no data leaves your Tailscale mesh. Cloud API calls go to their respective providers (Anthropic, OpenAI, Google) only when you explicitly route to them. There is no telemetry, no analytics, no data collection beyond your own PostgreSQL instance for your own logging.

Your questions are yours. Your answers are yours. Your models are yours.

---

*Kheti AI: Your homelab, your models, your API.*
