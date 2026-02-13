# Kheti AI - Project Context

> This file is the AI assistant init file for Google Gemini (Android Studio / IDX). Canonical source: `INIT.md`. See also: `MEMORY.md` (knowledge base), `SOUL.md` (philosophy).

## What Is This?

Kheti AI is a **distributed AI model mesh** — a single OpenAI-compatible API endpoint that intelligently routes requests across your local hardware (GPUs, CPUs, NPUs, Apple Silicon) and cloud APIs (Claude, GPT, Gemini, Perplexity). It uses LiteLLM as the orchestration layer, running on a Raspberry Pi 5 with PostgreSQL, Redis, and optional Grafana/Prometheus monitoring.

---

## Prerequisites

Before you begin, ensure you have:

- **Orchestrator machine** (Pi5L recommended): Raspberry Pi 5 (4GB+) or any mini PC with Docker
- **At least one Ollama machine**: Any machine with a GPU or CPU capable of running Ollama
- **Tailscale account**: For secure remote access across your network
- **Cloud API keys** (optional): Anthropic, OpenAI, Google, Perplexity

---

## First-Time Setup

### 1. Clone and Configure

```bash
git clone https://github.com/akshatrathee/kheti-ai.git
cd kheti-ai
chmod +x setup.sh
./setup.sh
```

The setup script will:
- Create `.env` from the template
- Prompt for your cloud API keys
- Generate a secure master key and database password
- Create required directories (`litellm_data/`, `grafana/`)

### 2. Deploy

```bash
./deploy.sh
# Choose: 1) Basic  or  2) Full (with monitoring)
```

This pulls Docker images and starts: LiteLLM proxy (port 4000), PostgreSQL, Redis, and optionally Grafana + Prometheus.

### 3. Verify

```bash
curl http://localhost:4000/health
# Should return: {"status": "healthy"}
```

### 4. Configure Tailscale (Remote Access)

The deploy script will prompt you. If you skip it, run manually:

```bash
sudo tailscale serve --bg --https=443 /llm http://localhost:4000
```

---

## Key Files

| File | Purpose |
|------|---------|
| `litellm_config_production.yaml` | Model routing configuration — all models, weights, aliases |
| `docker-compose.yml` | Service definitions (LiteLLM, Postgres, Redis, Grafana) |
| `.env` | Your API keys and secrets (never committed) |
| `.env.example` | Template for `.env` |
| `setup.sh` | Interactive first-time setup |
| `deploy.sh` | Docker deployment script |
| `test_client.py` | Python test suite for verifying routing |

---

## Model Naming Convention

```
FORMAT: SIZE-LOCATION-COST-MODEL_NAME

SIZE:     XS (<3B) | S (3-8B) | M (8-20B) | L (20-40B) | XL (40B+)
LOCATION: LOC (local/self-hosted) | CLD (cloud API)
COST:     FRE (free/local) | PAY (paid/cloud)

Examples:
  XL-LOC-FRE-qwen2.5-coder-32b    Large local free model
  S-CLD-PAY-gpt-4o-mini            Small cloud paid model
```

---

## Routing Aliases

Quick shortcuts instead of full model names:

| Alias | Routes To | Use Case |
|-------|-----------|----------|
| `fast` | S-LOC-FRE-llama3.2-3b | Quick responses |
| `balanced` | M-LOC-FRE-qwen2.5-14b | General purpose |
| `best` | XL-LOC-FRE-qwen2.5-coder-32b | Best local quality |
| `code` | XL-LOC-FRE-qwen2.5-coder-32b | Code generation |
| `vision` | XL-LOC-FRE-llava-34b | Image understanding |
| `reasoning` | L-LOC-FRE-deepseek-r1-14b | Chain-of-thought |
| `research` | L-CLD-PAY-perplexity-online | Web-connected queries |
| `image-gen` | XL-LOC-FRE-flux-schnell | Image generation |
| `voice` | L-LOC-FRE-whisper-large-v3 | Audio transcription |
| `gpt-3.5-turbo` | Fast local model | OpenAI compatibility |
| `claude-opus` | XL-CLD-PAY-claude-opus-4.5 | Premium cloud |

---

## Hardware Tiers

| Tier | Machine | Role | Status |
|------|---------|------|--------|
| 1 - GPU | Akshat-PC (RTX 5090) | Primary XL models, image/video gen | Active |
| 1 - GPU | Old-Office-PC (RTX 2080S) | Backup, mid-tier | Template |
| 2 - CPU | GTR9-Pro / EVO-X2 / MS-S1 (128GB) | XL models via CPU, high context | Template |
| 3 - NPU | SER9 (AMD XDNA 2) / Atomman (Intel) | Experimental NPU acceleration | Template |
| 4 - Apple | Mac Mini M4 Pro | Metal-optimized models | Template |
| 5 - Mid | MS01 / BorgCube / RetroMac | Small-mid models | Template |
| 6 - Infra | Pi5 Fleet (12 units) | Orchestration, monitoring only | Pi5L Active |

---

## Adding a New Machine

1. Install Ollama on the machine:
   ```bash
   curl -fsSL https://ollama.ai/install.sh | sh
   export OLLAMA_HOST=0.0.0.0:11434
   sudo systemctl restart ollama
   ```

2. Pull the assigned models (see `MODEL_DISTRIBUTION.md`)

3. Edit `litellm_config_production.yaml`:
   - Find the machine's commented-out section
   - Uncomment it
   - Replace `[TO_BE_CONFIGURED]` with the machine's Tailscale IP

4. Restart:
   ```bash
   docker restart litellm-proxy
   ```

---

## Common Operations

```bash
# Check status
docker ps && docker logs -f litellm-proxy

# Restart after config change
docker restart litellm-proxy

# Update from git
git pull && docker-compose down && docker-compose up -d

# View admin UI
# Open: http://localhost:4000/ui  (admin/admin)

# Test with Python
python test_client.py

# Backup
tar -czf backup-$(date +%F).tar.gz litellm_config_production.yaml .env docker-compose.yml litellm_data/
```

---

## Routing Strategy

Requests are scored using weighted criteria:
- **Speed (40%)**: Time to first token
- **Quality (35%)**: Model capability for the task
- **Cost (25%)**: Local (free) vs cloud (paid)

Local models are always preferred. Cloud APIs serve as fallback for premium quality or when local machines are unavailable.

---

## Security Checklist

- [ ] Change `master_key` in config (or use setup.sh to auto-generate)
- [ ] Change `ui_password` from default `admin`
- [ ] Never commit `.env` to git
- [ ] Use Tailscale for remote access (no open ports)
- [ ] Set monthly budget limit (default: $100)
