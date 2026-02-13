# Tailscale Serve Setup - Pi5L LiteLLM Orchestrator

## Network Configuration

**Pi5L Details:**
- **Local IP:** 10.0.0.111
- **Tailscale IP:** 100.77.119.64
- **Tailnet Hostname:** pi5l.tailf49db2.ts.net
- **Service Port:** 4000 (LiteLLM)
- **Tailscale Path:** /llm (keeps root free)

## Tailscale Serve Command

After deploying LiteLLM with Docker Compose, configure Tailscale serve:

```bash
# SSH to Pi5L
ssh pi@10.0.0.111

# Ensure Tailscale is installed and authenticated
sudo tailscale status

# Configure Tailscale serve to expose LiteLLM at /llm path
sudo tailscale serve --bg --https=443 /llm http://localhost:4000

# Verify configuration
sudo tailscale serve status
```

## Access URLs

Once configured, LiteLLM will be accessible at:

### 1. Tailnet URL (Recommended for remote access)
```
https://pi5l.tailf49db2.ts.net/llm
```

### 2. Tailscale IP
```
https://100.77.119.64/llm
```

### 3. Local LAN (Pi5L network only)
```
http://10.0.0.111:4000
```

## Testing Access

### From Tailscale Network
```bash
# Health check
curl https://pi5l.tailf49db2.ts.net/llm/health

# List models
curl https://pi5l.tailf49db2.ts.net/llm/models

# Test completion
curl https://pi5l.tailf49db2.ts.net/llm/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_MASTER_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### From Local LAN
```bash
# Health check
curl http://10.0.0.111:4000/health

# Test completion
curl http://10.0.0.111:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_MASTER_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## Python Client Configuration

### Using Tailscale (Remote Access)
```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_MASTER_KEY",
    base_url="https://pi5l.tailf49db2.ts.net/llm"
)

response = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=[{"role": "user", "content": "Hello!"}]
)
```

### Using Local LAN
```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_MASTER_KEY",
    base_url="http://10.0.0.111:4000"
)

response = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=[{"role": "user", "content": "Hello!"}]
)
```

## Admin UI Access

### Tailscale
```
https://pi5l.tailf49db2.ts.net/llm/ui
```

### Local LAN
```
http://10.0.0.111:4000/ui
```

**Credentials:**
- Username: `admin`
- Password: `admin` (change in litellm_config.yaml)

## Firewall Configuration

### On Pi5L
```bash
# Allow local LAN access to port 4000
sudo ufw allow from 10.0.0.0/24 to any port 4000 proto tcp

# Allow Tailscale
sudo ufw allow in on tailscale0
```

## Tailscale Serve Advanced Options

### Check Current Configuration
```bash
sudo tailscale serve status
```

### Remove Serve Configuration
```bash
sudo tailscale serve --https=443 off
```

### Serve on Different Path
```bash
# If you want /api instead of /llm
sudo tailscale serve --bg --https=443 /api http://localhost:4000
```

### Serve with TLS on Custom Port
```bash
# Expose on port 8443 instead of 443
sudo tailscale serve --bg --https=8443 http://localhost:4000
# Access at: https://pi5l.tailf49db2.ts.net:8443
```

## Monitoring Access

### Grafana (if monitoring enabled)

**Tailscale:**
```
https://pi5l.tailf49db2.ts.net:3000
```

**Local LAN:**
```
http://10.0.0.111:3000
```

**Note:** Grafana runs on separate port (3000), not under /llm path.

To expose Grafana via Tailscale:
```bash
sudo tailscale serve --bg --https=443 /grafana http://localhost:3000
# Access at: https://pi5l.tailf49db2.ts.net/grafana
```

### Prometheus (if monitoring enabled)

**Local LAN only:**
```
http://10.0.0.111:9090
```

## Troubleshooting

### Tailscale serve not working
```bash
# Check Tailscale status
sudo tailscale status

# Check if serve is configured
sudo tailscale serve status

# View Tailscale logs
sudo journalctl -u tailscaled -f

# Restart Tailscale
sudo systemctl restart tailscaled

# Reconfigure serve
sudo tailscale serve --https=443 off
sudo tailscale serve --bg --https=443 /llm http://localhost:4000
```

### LiteLLM not responding
```bash
# Check Docker containers
docker ps

# Check LiteLLM logs
docker logs litellm-proxy

# Restart LiteLLM
docker restart litellm-proxy

# Check if port 4000 is listening
sudo netstat -tlnp | grep 4000
```

### Certificate Issues (Tailscale HTTPS)
Tailscale automatically provides HTTPS certificates. If you see certificate warnings:

1. Ensure you're using the full tailnet hostname: `pi5l.tailf49db2.ts.net`
2. Check Tailscale is authenticated: `sudo tailscale status`
3. Verify MagicDNS is enabled in Tailscale admin console

## Security Notes

1. **Tailscale Access:** Anyone on your Tailnet can access the API
2. **Master Key Required:** All API requests need `Authorization: Bearer <master_key>`
3. **Change Default Passwords:** Update `master_key` and `ui_password` in config
4. **Local LAN:** Only devices on 10.0.0.0/24 network can access locally

## Environment Variable Configuration

Add to your shell profile (`.bashrc`, `.zshrc`, etc.):

```bash
# LiteLLM via Tailscale
export LITELLM_API_KEY="YOUR_MASTER_KEY"
export LITELLM_BASE_URL="https://pi5l.tailf49db2.ts.net/llm"

# Or for local access
export LITELLM_BASE_URL="http://10.0.0.111:4000"
```

## Integration Examples

### N8N Workflow
```json
{
  "credentials": {
    "httpHeaderAuth": {
      "name": "LiteLLM Auth",
      "data": {
        "name": "Authorization",
        "value": "Bearer YOUR_MASTER_KEY"
      }
    }
  },
  "url": "https://pi5l.tailf49db2.ts.net/llm/v1/chat/completions"
}
```

### Continue.dev (VSCode)
```json
{
  "models": [{
    "title": "Homelab Models",
    "provider": "openai",
    "apiBase": "https://pi5l.tailf49db2.ts.net/llm",
    "apiKey": "YOUR_MASTER_KEY"
  }]
}
```

### Cursor AI
```json
{
  "openaiBaseURL": "https://pi5l.tailf49db2.ts.net/llm",
  "openaiKey": "YOUR_MASTER_KEY"
}
```

## Complete Deployment Command

```bash
# 1. Deploy LiteLLM
cd ~/litellm-mesh
./deploy.sh

# 2. Wait for services to start (30 seconds)
sleep 30

# 3. Configure Tailscale serve
sudo tailscale serve --bg --https=443 /llm http://localhost:4000

# 4. Verify
curl http://localhost:4000/health
curl https://pi5l.tailf49db2.ts.net/llm/health

# 5. Test from another machine on Tailnet
curl https://pi5l.tailf49db2.ts.net/llm/models
```

---

**Summary:**
- **Production URL:** `https://pi5l.tailf49db2.ts.net/llm`
- **Local Development:** `http://10.0.0.111:4000`
- **Admin UI:** `https://pi5l.tailf49db2.ts.net/llm/ui`
- **Path Prefix:** `/llm` (root remains free)
