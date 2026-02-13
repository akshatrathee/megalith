# Quick Reference Card - Akshat's Model Mesh

## Naming Convention

```
FORMAT: SIZE-LOCATION-COST-MODEL_NAME

SIZE:
  XS  = <3B parameters     (ultra-fast, limited capability)
  S   = 3-8B parameters    (fast, good capability)
  M   = 8-20B parameters   (balanced speed/quality)
  L   = 20-40B parameters  (slower, high quality)
  XL  = 40B+ parameters    (slowest, best quality)

LOCATION:
  LOC = Local (your hardware)
  CLD = Cloud (paid APIs)

COST:
  FRE = Free (local models, no API cost)
  PAY = Paid (cloud APIs, per-token cost)

EXAMPLES:
  XL-LOC-FRE-qwen2.5-coder-32b    → 32B code model on local GPU
  S-CLD-PAY-gpt-4o-mini            → Small cloud model, costs money
  M-LOC-FRE-llama3.2-vision-11b    → 11B vision model on local GPU
```

## Access URLs

```bash
# Primary (Tailscale - anywhere)
https://pi5l.tailf49db2.ts.net/llm

# Alternate (Tailscale IP)
https://100.77.119.64/llm

# Local LAN only
http://10.0.0.111:4000

# Admin UI
https://pi5l.tailf49db2.ts.net/llm/ui
```

## Common Model Aliases

```python
"gpt-3.5-turbo"  → S-LOC-FRE-llama3.2-3b-ms01    # Fast local
"gpt-4"          → XL-CLD-PAY-gpt-4o              # Best cloud
"code"           → XL-LOC-FRE-qwen2.5-coder-32b   # Best code (local)
"vision"         → XL-LOC-FRE-llava-34b           # Best vision (local)
"fast"           → S-LOC-FRE-llama3.2-3b-ms01     # Ultra-fast
"best"           → XL-LOC-FRE-qwen2.5-coder-32b   # Best local
"best-cloud"     → XL-CLD-PAY-claude-opus-4.5     # Best overall
```

## Hardware Locations

### PRIMARY WORKSTATION
**Akshat-PC (RTX 5090, 192GB)**
- 100.111.115.92 / 10.0.0.5
- XL models (70B+)
- Image/Video generation
- Voice processing

### BACKUP GPU
**Old-Office-PC (RTX 2080 Super, 32GB)**
- [Configure Tailscale IP]
- XL models Q4
- M-L models
- Redundancy

### CPU POWERHOUSES (128GB RAM each)
**GTR9-Pro / EVO-X2 / MS-S1**
- [Configure Tailscale IPs]
- XL models Q4 (CPU)
- High-context tasks
- Embeddings

### NPU EXPERIMENTAL
**SER9 (AMD) / Atomman (Intel)**
- [Configure Tailscale IPs]
- NPU-optimized models
- S-M models
- Testing ground

### APPLE SILICON
**Mac Mini M4 Pro**
- [Configure Tailscale IP]
- Metal-optimized
- M models
- macOS tasks

### MID-RANGE
**MS01 / BorgCube / RetroMac**
- [Configure Tailscale IPs]
- S-M models
- General purpose

## Quick Test Commands

### Health Check
```bash
curl https://pi5l.tailf49db2.ts.net/llm/health
```

### List Models
```bash
curl https://pi5l.tailf49db2.ts.net/llm/models
```

### Test Chat (Fast Local)
```bash
curl https://pi5l.tailf49db2.ts.net/llm/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_KEY" \
  -d '{
    "model": "fast",
    "messages": [{"role": "user", "content": "Hi"}]
  }'
```

### Test Code Generation (Best Local)
```bash
curl https://pi5l.tailf49db2.ts.net/llm/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_KEY" \
  -d '{
    "model": "code",
    "messages": [{"role": "user", "content": "Write quicksort in Python"}]
  }'
```

### Test Vision
```bash
curl https://pi5l.tailf49db2.ts.net/llm/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_KEY" \
  -d '{
    "model": "vision",
    "messages": [{
      "role": "user",
      "content": [
        {"type": "text", "text": "What is in this image?"},
        {"type": "image_url", "image_url": {"url": "data:image/jpeg;base64,..."}}
      ]
    }]
  }'
```

## Python Client Setup

```python
from openai import OpenAI

# Configure client
client = OpenAI(
    api_key="YOUR_MASTER_KEY",
    base_url="https://pi5l.tailf49db2.ts.net/llm"
)

# Fast local chat
response = client.chat.completions.create(
    model="fast",
    messages=[{"role": "user", "content": "Hello!"}]
)

# Best code generation
response = client.chat.completions.create(
    model="code",
    messages=[{"role": "user", "content": "Write binary search in Rust"}]
)

# Best vision
response = client.chat.completions.create(
    model="vision",
    messages=[{
        "role": "user",
        "content": [
            {"type": "text", "text": "Describe this image"},
            {"type": "image_url", "image_url": {"url": "..."}}
        ]
    }]
)

# Cloud fallback (best quality, costs money)
response = client.chat.completions.create(
    model="best-cloud",
    messages=[{"role": "user", "content": "Complex reasoning task"}]
)

# Embeddings
response = client.embeddings.create(
    model="text-embedding-ada-002",
    input="Your text here"
)
```

## Model Selection Guide

| Task | Recommended Model | Tier | Location |
|------|------------------|------|----------|
| Quick chat | `fast` | S | Local |
| Code generation | `code` | XL | Local |
| Image understanding | `vision` | XL | Local |
| Complex reasoning | `best-cloud` | XL | Cloud |
| Embeddings | `text-embedding-ada-002` | S | Local |
| Web search | `research` | L | Cloud |
| Image generation | `image-gen` | XL | Local |
| Voice transcription | `voice` | L | Local |

## Escalation Pattern

```python
def query_with_escalation(prompt):
    """Start fast, escalate if needed"""
    
    # Try fast local first
    response = client.chat.completions.create(
        model="fast",
        messages=[{"role": "user", "content": prompt}]
    )
    
    print(response.choices[0].message.content)
    satisfied = input("Satisfied? (y/n): ")
    
    if satisfied == 'n':
        # Escalate to best local
        print("Trying best local model...")
        response = client.chat.completions.create(
            model="best",
            messages=[{"role": "user", "content": prompt}]
        )
        
        print(response.choices[0].message.content)
        satisfied = input("Satisfied now? (y/n): ")
        
        if satisfied == 'n':
            # Final escalation to cloud
            print("Escalating to best cloud model...")
            response = client.chat.completions.create(
                model="best-cloud",
                messages=[{"role": "user", "content": prompt}]
            )
    
    return response
```

## Deployment Checklist

### One-Time Setup (Pi5L)
- [ ] Install Docker & Docker Compose
- [ ] Copy deployment files
- [ ] Configure `.env` with API keys
- [ ] Run `./deploy.sh`
- [ ] Configure Tailscale serve
- [ ] Test access from Tailnet
- [ ] Test access from local LAN

### Per Machine (Other Machines)
- [ ] Install Ollama
- [ ] Configure `OLLAMA_HOST=0.0.0.0:11434`
- [ ] Pull assigned models
- [ ] Verify with `ollama list`
- [ ] Test access: `curl http://IP:11434/api/tags`
- [ ] Update `litellm_config_production.yaml`
- [ ] Uncomment machine section
- [ ] Add Tailscale IP
- [ ] Restart LiteLLM: `docker restart litellm-proxy`

## Monitoring

### Docker Logs
```bash
# Real-time logs
docker logs -f litellm-proxy

# Last 100 lines
docker logs --tail 100 litellm-proxy
```

### Health Checks
```bash
# LiteLLM health
curl http://10.0.0.111:4000/health

# Ollama machine health
curl http://100.111.115.92:11434/api/tags
```

### Admin Dashboard
```
https://pi5l.tailf49db2.ts.net/llm/ui
Username: admin
Password: admin (CHANGE THIS)
```

### Grafana (if enabled)
```
https://pi5l.tailf49db2.ts.net/grafana
Username: admin
Password: admin (CHANGE THIS)
```

## Troubleshooting

### Model not found
```bash
# Check if model is in config
grep "MODEL_NAME" litellm_config_production.yaml

# Check if machine is accessible
curl http://MACHINE_IP:11434/api/tags

# Check if model is loaded on machine
ssh user@machine
ollama list
```

### Slow responses
```bash
# Check which models are loaded
ssh user@ollama-machine
ollama ps

# Preload frequently used models
ollama run MODEL_NAME <<< "test"
```

### Connection errors
```bash
# Check Tailscale connectivity
tailscale ping MACHINE_HOSTNAME

# Check firewall
sudo ufw status

# Check Docker network
docker network ls
docker network inspect litellm-network
```

## Security

### Change Default Credentials
```bash
# Edit litellm_config_production.yaml
nano litellm_config_production.yaml

# Change these:
master_key: sk-YOUR-SECURE-KEY
ui_password: YOUR-SECURE-PASSWORD

# Restart
docker restart litellm-proxy
```

### API Key Security
```bash
# Store in .env, never commit
echo "LITELLM_API_KEY=sk-YOUR-KEY" >> .env
echo ".env" >> .gitignore
```

### Tailscale ACLs
```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["group:homelab"],
      "dst": ["tag:pi5l:443", "tag:ollama:11434"]
    }
  ]
}
```

## Performance Tips

1. **Preload models:** Run `ollama run MODEL` to keep in memory
2. **Increase workers:** Edit `docker-compose.yml` → `--num_workers 8`
3. **Adjust cache TTL:** Edit config → `cache_kwargs.ttl: 7200`
4. **Enable monitoring:** Run `./deploy.sh` → Choose option 2
5. **Load balance:** Add multiple machines with same model

## Cost Tracking

### View in UI
```
https://pi5l.tailf49db2.ts.net/llm/ui → Budget tab
```

### Monthly Limit
Edit `litellm_config_production.yaml`:
```yaml
litellm_settings:
  max_budget: 100  # $100/month
```

---

**Quick Start:**
```bash
# Deploy
cd ~/litellm-mesh && ./deploy.sh

# Configure Tailscale
sudo tailscale serve --bg --https=443 /llm http://localhost:4000

# Test
curl https://pi5l.tailf49db2.ts.net/llm/health
```

**Production URL:**
`https://pi5l.tailf49db2.ts.net/llm`
