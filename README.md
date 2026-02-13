# Kheti AI - Distributed Model Mesh

**Single API endpoint for all your AI models** - local and cloud.

Smart orchestration across your homelab GPUs, CPUs, NPUs, and cloud APIs with intelligent routing, redundancy, and cost optimization.

🌐 **OpenAI-compatible API** • 🚀 **Auto-routing** • 💰 **Cost-optimized** • 🔒 **Tailscale-secured**

---

## ⚡ Quick Start (5 Minutes)

### On Pi5L (or any orchestrator machine):

```bash
# Clone the repository
git clone https://github.com/akshatrathee/kheti-ai.git
cd kheti-ai

# Initial setup (interactive - configures API keys)
chmod +x setup.sh
./setup.sh

# That's it! Your orchestrator is running.
```

**Access your API at:** `https://pi5l.tailf49db2.ts.net/llm`

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[MASTER_README.md](MASTER_README.md)** | Complete guide & architecture |
| **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** | Daily cheat sheet |
| **[MODEL_DISTRIBUTION.md](MODEL_DISTRIBUTION.md)** | Hardware specs & model assignments |
| **[TAILSCALE_SETUP.md](TAILSCALE_SETUP.md)** | Remote access configuration |

---

## 🏗️ Architecture

```
Your Apps (VSCode, Python, etc.)
         ↓
LiteLLM Orchestrator (Pi5L)
    ↓           ↓            ↓
Local Ollama   Cloud APIs   NPU/Metal
(RTX 5090)     (Claude/GPT) (Experimental)
```

**Naming Convention:** `SIZE-LOCATION-COST-MODEL_NAME`
- `XL-LOC-FRE-qwen2.5-coder-32b` = 32B code model on local GPU
- `S-CLD-PAY-gpt-4o-mini` = Small cloud model (paid)

---

## 🎯 Features

✅ **Single API** - One endpoint for all models  
✅ **Smart Routing** - Weighted by speed (40%), quality (35%), cost (25%)  
✅ **Auto-failover** - Redundancy across machines  
✅ **Response Caching** - Save API costs  
✅ **Multi-modal** - Code, vision, voice, image generation  
✅ **OpenAI Compatible** - Drop-in replacement  

---

## 📦 What's Included

- **LiteLLM Orchestrator** - Smart routing proxy
- **PostgreSQL** - Request logging & model configs
- **Redis** - Response caching
- **Grafana + Prometheus** - Monitoring (optional)
- **Tailscale Integration** - Secure remote access
- **Model Templates** - Ready for 19+ machines

---

## 🎮 Usage

### Python

```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_MASTER_KEY",
    base_url="https://pi5l.tailf49db2.ts.net/llm"
)

# Auto-routes to best local model
response = client.chat.completions.create(
    model="code",
    messages=[{"role": "user", "content": "Write Rust code"}]
)
```

### cURL

```bash
curl https://pi5l.tailf49db2.ts.net/llm/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_KEY" \
  -d '{
    "model": "fast",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### VSCode (Continue.dev)

```json
{
  "models": [{
    "provider": "openai",
    "model": "code",
    "apiBase": "https://pi5l.tailf49db2.ts.net/llm",
    "apiKey": "YOUR_MASTER_KEY"
  }]
}
```

---

## 🔄 Updates

Pull latest changes and redeploy:

```bash
cd kheti-ai
git pull
docker-compose down
docker-compose up -d
```

---

## 🛠️ Current Setup

### ✅ Configured & Ready
- **Akshat-PC (RTX 5090):** 54 models mapped
- **Cloud APIs:** Templates ready
- **Pi5L:** Orchestrator deployment ready

### ⏭ Add When Ready
- **11 Mini PCs:** Templates in config (commented)
- **1 Mac Mini:** Template ready
- **11 Raspberry Pis:** For monitoring

See [MODEL_DISTRIBUTION.md](MODEL_DISTRIBUTION.md) for details.

---

## 🔧 Common Commands

```bash
# Check status
docker ps
docker logs -f litellm-proxy

# Restart
docker restart litellm-proxy

# Update config
nano litellm_config_production.yaml
docker restart litellm-proxy

# View costs
# Open: https://pi5l.tailf49db2.ts.net/llm/ui
```

---

## 📍 Hardware Requirements

**Orchestrator (Pi5L):**
- Raspberry Pi 5 (4GB+) OR
- Mini PC (4GB+ RAM)
- Docker installed
- Tailscale configured

**Ollama Machines:**
- Any machine with Ollama installed
- Network accessible (Tailscale recommended)

---

## 🔐 Security

- API key required for all requests
- Tailscale for secure remote access
- Cloud API keys stored in `.env` (not committed)
- Change default passwords before production

---

## 💰 Cost

- **Local models:** Free (electricity only)
- **Cloud APIs:** Pay per token
- **Budget limit:** Configurable (default $100/month)
- **Monitoring:** Track costs in admin UI

---

## 📄 License

MIT License - See LICENSE file

---

## 🙏 Credits

Built with:
- [LiteLLM](https://github.com/BerriAI/litellm) - Model orchestration
- [Ollama](https://ollama.ai) - Local model serving
- [Tailscale](https://tailscale.com) - Secure networking

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/akshatrathee/kheti-ai/issues)
- **Docs:** See [MASTER_README.md](MASTER_README.md)
- **Quick Help:** See [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

---

## 🚀 Next Steps

1. ✅ Clone repo
2. ✅ Run `./setup.sh`
3. ⏭ Add more Ollama machines (see [MODEL_DISTRIBUTION.md](MODEL_DISTRIBUTION.md))
4. ⏭ Enable monitoring (run `./deploy.sh` → option 2)
5. ⏭ Integrate with your apps

---

**Your homelab, your models, your API.** 🎯
