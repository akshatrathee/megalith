# Git-Based Deployment Workflow

This guide explains how to deploy and maintain Kheti AI using git.

---

## Initial Deployment

### 1. Clone Repository on Pi5L (or orchestrator machine)

```bash
# SSH to your orchestrator machine
ssh pi@10.0.0.111  # or your Pi5L IP

# Clone the repository
cd ~
git clone https://github.com/akshatrathee/kheti-ai.git
cd kheti-ai
```

### 2. Run Initial Setup

```bash
# Make setup script executable
chmod +x setup.sh

# Run interactive setup
./setup.sh
```

This will:
- Create `.env` file with your API keys
- Generate secure master key
- Create necessary directories
- Optionally start deployment

### 3. Access Your API

```bash
# Test health
curl http://localhost:4000/health

# Or via Tailscale (if configured)
curl https://pi5l.tailf49db2.ts.net/llm/health
```

**Done!** Your orchestrator is running.

---

## Updating Your Deployment

### Pull Latest Changes

```bash
cd ~/kheti-ai
git pull
```

### Review Changes

```bash
# See what changed
git log -5 --oneline

# Check for config updates
git diff HEAD~1 litellm_config_production.yaml
```

### Apply Updates

#### Option 1: Full Restart (Safe)
```bash
docker-compose down
docker-compose up -d
```

#### Option 2: Restart Only LiteLLM (Faster)
```bash
docker restart litellm-proxy
```

#### Option 3: Reload Config Without Restart
```bash
# If only config changed
docker exec litellm-proxy kill -HUP 1
```

---

## Customizing for Your Setup

### Update Machine IPs

```bash
# Edit config with your machine IPs
nano litellm_config_production.yaml

# Find commented sections like:
# # Tailscale: [TO_BE_CONFIGURED]

# Replace with actual IPs:
# # Tailscale: 100.x.x.x
# api_base: http://100.x.x.x:11434

# Restart to apply
docker restart litellm-proxy
```

### Add Your API Keys

```bash
# Edit environment file
nano .env

# Add your keys:
ANTHROPIC_API_KEY=sk-ant-xxxxx
OPENAI_API_KEY=sk-xxxxx
GEMINI_API_KEY=xxxxx
PERPLEXITY_API_KEY=pplx-xxxxx

# Restart to apply
docker-compose restart litellm
```

### Save Your Changes Locally (Optional)

```bash
# Create a local branch for your customizations
git checkout -b my-setup

# Commit your IP updates
git add litellm_config_production.yaml
git commit -m "Updated machine IPs for my setup"

# When pulling updates:
git fetch origin
git merge origin/main
```

**Note:** Don't commit `.env` - it's in `.gitignore`

---

## Backing Up Your Configuration

### Automated Backup Script

Create `~/backup-kheti.sh`:

```bash
#!/bin/bash
BACKUP_DIR=~/kheti-backups
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

cd ~/kheti-ai
tar -czf $BACKUP_DIR/kheti-backup-$DATE.tar.gz \
  .env \
  litellm_config_production.yaml \
  litellm_data/

echo "Backup saved to $BACKUP_DIR/kheti-backup-$DATE.tar.gz"
```

Run before major updates:
```bash
chmod +x ~/backup-kheti.sh
~/backup-kheti.sh
```

### Restore from Backup

```bash
cd ~/kheti-ai
tar -xzf ~/kheti-backups/kheti-backup-YYYYMMDD_HHMMSS.tar.gz
docker-compose restart
```

---

## Adding New Machines

### 1. Install Ollama on New Machine

```bash
# SSH to new machine
ssh user@new-machine

# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Configure for network access
export OLLAMA_HOST=0.0.0.0:11434
echo 'OLLAMA_HOST=0.0.0.0:11434' | sudo tee -a /etc/environment

# Restart
sudo systemctl restart ollama
```

### 2. Pull Models

See [MODEL_DISTRIBUTION.md](MODEL_DISTRIBUTION.md) for which models to pull.

```bash
# Example for a mid-range machine
ollama pull qwen2.5:14b
ollama pull codellama:13b
ollama pull mistral-nemo:12b

# Verify
ollama list
```

### 3. Update Configuration

```bash
# On Pi5L (orchestrator)
cd ~/kheti-ai
nano litellm_config_production.yaml

# Find machine section (e.g., MS01, BorgCube, etc.)
# Uncomment it
# Replace [TO_BE_CONFIGURED] with Tailscale IP

# Example:
# Before:
# # Tailscale: [TO_BE_CONFIGURED]

# After:
# Tailscale: 100.x.x.x
# api_base: http://100.x.x.x:11434
```

### 4. Apply Changes

```bash
docker restart litellm-proxy
```

### 5. Test New Machine

```bash
# Check if reachable
curl http://NEW_MACHINE_IP:11434/api/tags

# Test via LiteLLM
curl https://pi5l.tailf49db2.ts.net/llm/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_KEY" \
  -d '{
    "model": "M-LOC-FRE-qwen2.5-14b-ms01",
    "messages": [{"role": "user", "content": "Test"}]
  }'
```

---

## Development Workflow

### Testing Changes Before Deployment

```bash
# Create test branch
git checkout -b test-new-models

# Make changes
nano litellm_config_production.yaml

# Test locally
docker-compose -f docker-compose.yml -p kheti-test up -d

# Test
curl http://localhost:4000/health

# If good, apply to production
git checkout main
git merge test-new-models
docker-compose restart

# Cleanup test stack
docker-compose -p kheti-test down
```

---

## Monitoring Updates

### Check for New Commits

```bash
cd ~/kheti-ai
git fetch origin

# See if updates available
git log HEAD..origin/main --oneline

# Or set up email notifications (GitHub)
# Settings → Notifications → Watch repository
```

### Auto-update (Optional, Advanced)

Create a cron job to auto-pull and restart daily:

```bash
# Edit crontab
crontab -e

# Add (runs daily at 3 AM):
0 3 * * * cd ~/kheti-ai && git pull && docker-compose restart
```

**⚠️ Warning:** Only use auto-update if you trust all commits!

---

## Rollback

### To Previous Version

```bash
# View recent commits
git log --oneline -10

# Rollback to specific commit
git reset --hard COMMIT_HASH

# Or rollback one commit
git reset --hard HEAD~1

# Restart services
docker-compose down
docker-compose up -d
```

### Restore Specific File

```bash
# Restore config from previous commit
git checkout HEAD~1 -- litellm_config_production.yaml

# Apply
docker restart litellm-proxy
```

---

## Troubleshooting Git Deployment

### "Your local changes would be overwritten"

```bash
# Option 1: Stash changes
git stash
git pull
git stash pop

# Option 2: Commit changes to local branch
git checkout -b my-changes
git add .
git commit -m "My local changes"
git checkout main
git pull
```

### Lost .env file

```bash
# Recreate from example
cp .env.example .env
nano .env  # Add your keys

# Restart
docker-compose restart
```

### Docker containers not starting

```bash
# Check logs
docker-compose logs

# Full cleanup and restart
docker-compose down -v
docker-compose up -d
```

---

## Best Practices

1. **Before pulling updates:**
   - Backup your `.env` and config
   - Check changelog/commit messages
   - Test in development if major changes

2. **After pulling updates:**
   - Review changes: `git diff HEAD~1`
   - Restart services
   - Test health endpoint
   - Monitor logs for errors

3. **Keep `.env` secure:**
   - Never commit it
   - Back it up separately
   - Use strong master keys

4. **Document your changes:**
   - Comment your IP changes in config
   - Keep notes on custom modifications
   - Use git branches for experiments

---

## CI/CD Integration (Advanced)

### GitHub Actions Example

Create `.github/workflows/update-pi5l.yml`:

```yaml
name: Update Pi5L

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Pi5L
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.PI5L_HOST }}
          username: ${{ secrets.PI5L_USER }}
          key: ${{ secrets.PI5L_SSH_KEY }}
          script: |
            cd ~/kheti-ai
            git pull
            docker-compose restart
```

**Setup:**
1. Add secrets in GitHub repo settings
2. Generate SSH key for GitHub Actions
3. Commits to main auto-deploy

---

## Summary

**Normal workflow:**
```bash
cd ~/kheti-ai
git pull
docker-compose restart
```

**Adding machines:**
```bash
# Install Ollama on machine
# Pull models
# Edit config, uncomment section
# docker restart litellm-proxy
```

**Emergency rollback:**
```bash
git reset --hard HEAD~1
docker-compose restart
```

That's it! Git-based deployment makes updates simple and rollbacks easy.
