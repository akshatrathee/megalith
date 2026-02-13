# LiteLLM Model Mesh - Complete Deployment Guide
## Akshat's Distributed AI Infrastructure

**Status:** Production-Ready  
**Orchestrator:** Pi5L (100.77.119.64 / 10.0.0.111)  
**Access:** https://pi5l.tailf49db2.ts.net/llm

---

## 📁 File Structure

```
deployment-package/
├── README.md                          ← This file
├── MODEL_DISTRIBUTION.md              ← Hardware assignments & model list
├── litellm_config_production.yaml    ← Main config (with templates)
├── docker-compose.yml                 ← Docker stack definition
├── .env.example                       ← API keys template
├── deploy.sh                          ← One-command deployment
├── TAILSCALE_SETUP.md                ← Remote access setup
├── QUICK_REFERENCE.md                ← Cheat sheet
└── test_client.py                     ← Testing script
```

---

## 🎯 What You're Building

A **single API endpoint** that intelligently routes requests across:
- **Your local Ollama machines** (currently Akshat-PC with RTX 5090)
- **Future machines** (11 mini PCs, 1 Mac Mini, 12 Raspberry Pis)
- **Cloud APIs** (Claude, GPT, Gemini, Perplexity)

**Key Features:**
- ✅ OpenAI-compatible API (drop-in replacement)
- ✅ Smart weighted routing (speed 40%, quality 35%, cost 25%)
- ✅ Automatic redundancy and failover
- ✅ Response caching (save API costs)
- ✅ Works locally AND remotely via Tailscale
- ✅ Template-based config for easy machine additions

**Model Naming Convention:**
```
FORMAT: SIZE-LOCATION-COST-MODEL_NAME

Examples:
  XL-LOC-FRE-qwen2.5-coder-32b    → Large local free model
  S-CLD-PAY-gpt-4o-mini            → Small cloud paid model
  M-LOC-FRE-llama3.2-vision-11b    → Medium local free vision model
```

---

## 🚀 Quick Start (30 Minutes)

### Step 1: Deploy Orchestrator on Pi5L

```bash
# 1. Copy files to Pi5L
scp -r deployment-package/* pi@10.0.0.111:~/litellm-mesh/

# 2. SSH to Pi5L
ssh pi@10.0.0.111

# 3. Go to directory
cd ~/litellm-mesh

# 4. Setup API keys
cp .env.example .env
nano .env
# Add your cloud API keys (Claude, GPT, Gemini, Perplexity)

# 5. Run deployment
chmod +x deploy.sh
./deploy.sh

# Choose:
# - Option 1: Basic (recommended for Pi5)
# - Configure Tailscale serve: Yes

# 6. Verify
curl http://localhost:4000/health
curl https://pi5l.tailf49db2.ts.net/llm/health
```

**That's it!** Your orchestrator is running. ✅

### Step 2: Your Existing Ollama Machine (Already Done)

Your Akshat-PC (RTX 5090) at `100.111.115.92:11434` is already configured and will work immediately!

The config file already includes all your existing models with proper naming:
- `XL-LOC-FRE-qwen2.5-coder-32b`
- `XL-LOC-FRE-deepseek-coder-236b`
- `M-LOC-FRE-llama3.2-vision-11b`
- `L-LOC-FRE-whisper-large-v3`
- And 50+ more!

### Step 3: Add More Machines (Optional, When Ready)

See **MODEL_DISTRIBUTION.md** for which models to install on which machines.

For each new machine:
```bash
# 1. Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# 2. Configure for network access
export OLLAMA_HOST=0.0.0.0:11434
sudo systemctl restart ollama

# 3. Pull assigned models (see MODEL_DISTRIBUTION.md)
ollama pull <model-name>

# 4. Update litellm_config_production.yaml
# Uncomment the machine's section
# Add Tailscale IP
# Restart LiteLLM: docker restart litellm-proxy
```

---

## 📖 Documentation Guide

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **README.md** (this file) | Overview & quick start | Start here |
| **QUICK_REFERENCE.md** | Cheat sheet, common commands | Daily use |
| **MODEL_DISTRIBUTION.md** | Hardware specs & model assignments | When adding machines |
| **TAILSCALE_SETUP.md** | Remote access configuration | For Tailscale setup |
| **litellm_config_production.yaml** | Full config with templates | When customizing |

---

## 🎮 Using Your Model Mesh

### Python (OpenAI SDK)

```python
from openai import OpenAI

# Connect to your homelab
client = OpenAI(
    api_key="YOUR_MASTER_KEY",
    base_url="https://pi5l.tailf49db2.ts.net/llm"
)

# Fast local chat
response = client.chat.completions.create(
    model="gpt-3.5-turbo",  # Routes to fast local model
    messages=[{"role": "user", "content": "Hello!"}]
)

# Best code generation
response = client.chat.completions.create(
    model="code",  # Routes to XL-LOC-FRE-qwen2.5-coder-32b
    messages=[{"role": "user", "content": "Write binary search in Rust"}]
)

# Vision task
response = client.chat.completions.create(
    model="vision",  # Routes to XL-LOC-FRE-llava-34b
    messages=[{
        "role": "user",
        "content": [
            {"type": "text", "text": "What's in this image?"},
            {"type": "image_url", "image_url": {"url": "data:image/jpeg;base64,..."}}
        ]
    }]
)

# Embeddings
response = client.embeddings.create(
    model="text-embedding-ada-002",
    input="Your text here"
)
```

### cURL

```bash
curl https://pi5l.tailf49db2.ts.net/llm/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_KEY" \
  -d '{
    "model": "code",
    "messages": [{"role": "user", "content": "Write quicksort"}]
  }'
```

### Continue.dev (VSCode)

```json
{
  "models": [{
    "title": "Homelab XL Code",
    "provider": "openai",
    "model": "code",
    "apiBase": "https://pi5l.tailf49db2.ts.net/llm",
    "apiKey": "YOUR_MASTER_KEY"
  }]
}
```

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│  Your Applications                                       │
│  (VSCode, Python scripts, N8N, etc.)                    │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│  LiteLLM Orchestrator (Pi5L)                            │
│  - Smart routing based on prompt analysis               │
│  - Weighted scoring (speed, quality, cost)              │
│  - Response caching                                      │
│  - Request logging                                       │
│  https://pi5l.tailf49db2.ts.net/llm                     │
└────────┬────────────────────────────────────────────────┘
         │
         ├──────────┬──────────┬──────────┬──────────┐
         ▼          ▼          ▼          ▼          ▼
┌────────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│ Akshat-PC  │ │ GTR9   │ │ SER9   │ │Mac Mini│ │ Cloud  │
│ RTX 5090   │ │ CPU    │ │ NPU    │ │ Metal  │ │ APIs   │
│ XL models  │ │128GB   │ │ Fast   │ │ M4 Pro │ │Premium │
└────────────┘ └────────┘ └────────┘ └────────┘ └────────┘
```

---

## 📊 Current Status

### ✅ Already Configured & Working
- **Akshat-PC (RTX 5090):** 54 models, fully integrated
- **Cloud APIs:** Ready (just add keys to .env)
- **Pi5L Orchestrator:** Ready to deploy

### ⏭ Ready to Add (When You Want)
- **11 Mini PCs:** Templates ready in config
- **1 Mac Mini:** Template ready
- **11 Raspberry Pis:** Can use for monitoring

---

## 🔧 Common Tasks

### Check Status
```bash
# On Pi5L
docker ps
docker logs litellm-proxy

# Test health
curl https://pi5l.tailf49db2.ts.net/llm/health
```

### Add New Machine
```bash
# 1. See MODEL_DISTRIBUTION.md for model assignments
# 2. Install Ollama and pull models on new machine
# 3. Edit litellm_config_production.yaml
#    - Find machine section (commented)
#    - Uncomment it
#    - Replace [TO_BE_CONFIGURED] with Tailscale IP
# 4. Restart: docker restart litellm-proxy
```

### View Logs
```bash
# LiteLLM
docker logs -f litellm-proxy

# PostgreSQL
docker logs -f litellm-postgres

# All services
docker-compose logs -f
```

### Update Configuration
```bash
# Edit config
nano litellm_config_production.yaml

# Restart to apply
docker restart litellm-proxy
```

### Backup Everything
```bash
tar -czf litellm-backup-$(date +%F).tar.gz \
  litellm_config_production.yaml \
  .env \
  docker-compose.yml \
  litellm_data/
```

---

## 🎯 Model Selection Strategy

| Use Case | Start With | Escalate To | Final Fallback |
|----------|-----------|-------------|----------------|
| Quick chat | `fast` (S-LOC) | `balanced` (M-LOC) | `gpt-3.5-turbo` (Cloud) |
| Code generation | `code` (XL-LOC) | `code` (XL-LOC) | `gpt-4` (Cloud) |
| Vision/images | `vision` (XL-LOC) | `vision` (XL-LOC) | `gpt-4o` (Cloud) |
| Complex reasoning | `best` (XL-LOC) | `best-cloud` (Cloud) | `claude-opus` (Cloud) |
| Research/web | N/A | N/A | `research` (Cloud) |

---

## 🔐 Security Notes

1. **Change default passwords** in `litellm_config_production.yaml`:
   - `master_key`
   - `ui_password`

2. **Tailscale access:** Anyone on your Tailnet can reach the API

3. **API key required:** All requests need `Authorization: Bearer <key>`

4. **Environment variables:** Never commit `.env` to git

---

## 💰 Cost Tracking

- **Local models:** Free (just electricity)
- **Cloud models:** Pay per token
- **Monthly budget:** Set in config (default $100/month)
- **View costs:** Admin UI → https://pi5l.tailf49db2.ts.net/llm/ui

---

## 🎓 Next Steps

### Immediate (Day 1)
1. ✅ Deploy orchestrator on Pi5L
2. ✅ Test with existing Akshat-PC models
3. ✅ Set up Python client in your projects

### Short-term (Week 1)
1. ⏭ Add one more GPU machine (Old Office PC)
2. ⏭ Set up monitoring (Grafana)
3. ⏭ Fine-tune routing weights based on usage

### Long-term (Month 1)
1. ⏭ Add high-RAM CPU machines (GTR9, EVO-X2, MS-S1)
2. ⏭ Experiment with NPU machines (SER9, Atomman)
3. ⏭ Add Mac Mini for Metal optimization
4. ⏭ Set up automated model updates

---

## 📞 Troubleshooting

### "Model not found"
```bash
# Check if model exists in config
grep "MODEL_NAME" litellm_config_production.yaml

# Check if Ollama machine is reachable
curl http://MACHINE_IP:11434/api/tags
```

### Slow responses
```bash
# Check which models are loaded
ssh user@ollama-machine
ollama ps

# Preload model
ollama run MODEL_NAME
```

### Can't access via Tailscale
```bash
# Check Tailscale status
sudo tailscale status

# Check serve configuration
sudo tailscale serve status

# Reconfigure if needed
sudo tailscale serve --bg --https=443 /llm http://localhost:4000
```

---

## 📚 Advanced Configuration

### Custom Routing Rules

Edit `litellm_config_production.yaml`:

```yaml
router_settings:
  routing_strategy_args:
    ttft_weight: 0.5      # Prioritize speed more
    quality_weight: 0.3
    cost_weight: 0.2
```

### Add Custom Model Alias

```yaml
router_settings:
  model_group_alias:
    my-custom-name: XL-LOC-FRE-qwen2.5-coder-32b
```

### Enable Monitoring

```bash
# Redeploy with monitoring
./deploy.sh
# Choose option 2: Full (with monitoring)

# Access Grafana
https://pi5l.tailf49db2.ts.net:3000
```

---

## 🎉 Success Criteria

You'll know it's working when:

✅ Health check returns `{"status": "healthy"}`  
✅ Admin UI loads at `/ui`  
✅ Test chat completes in <5 seconds  
✅ Models list shows your Ollama models  
✅ Can access via both Tailscale and local LAN  
✅ Python client connects successfully  

---

## 📦 Package Contents Summary

| File | Size | Purpose |
|------|------|---------|
| docker-compose.yml | 3 KB | Service definitions |
| litellm_config_production.yaml | 25 KB | Complete routing config |
| MODEL_DISTRIBUTION.md | 15 KB | Hardware & model guide |
| QUICK_REFERENCE.md | 12 KB | Daily cheat sheet |
| TAILSCALE_SETUP.md | 8 KB | Remote access guide |
| deploy.sh | 4 KB | Deployment automation |
| test_client.py | 5 KB | Testing script |
| .env.example | 1 KB | API keys template |

**Total:** Ready-to-deploy production infrastructure

---

## 🏆 What You Get

A **production-grade AI infrastructure** with:

- 🚀 **Single API** for all your models
- 🎯 **Smart routing** based on task requirements  
- 💪 **Redundancy** across multiple machines
- 💰 **Cost optimization** (local-first, cloud-fallback)
- 🔒 **Secure** Tailscale access
- 📊 **Monitoring** (optional)
- 🔧 **Easy scaling** (just uncomment templates)

**No vendor lock-in.** OpenAI-compatible API. Your hardware, your control.

---

**Questions?** Check QUICK_REFERENCE.md for common commands and patterns.

**Ready to deploy?** Run `./deploy.sh` on Pi5L! 🚀
