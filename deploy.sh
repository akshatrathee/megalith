#!/bin/bash

# Megalith - LiteLLM Model Mesh Deployment Script
# GitHub: https://github.com/akshatrathee/megalith
# Run this on your Raspberry Pi 5 or Mini PC

set -e

echo "======================================"
echo "   Megalith - Deployment"
echo "======================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Installing..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo "✅ Docker installed. Please log out and back in, then run this script again."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
fi

echo "✅ Docker and Docker Compose found"
echo ""

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p litellm_data
mkdir -p grafana/dashboards
mkdir -p grafana/datasources

# Setup environment file
if [ ! -f .env ]; then
    echo "🔑 Setting up environment variables..."
    cp .env.example .env
    
    echo ""
    echo "⚠️  IMPORTANT: Edit .env and add your API keys:"
    echo "   - ANTHROPIC_API_KEY"
    echo "   - OPENAI_API_KEY"
    echo "   - GEMINI_API_KEY"
    echo "   - PERPLEXITY_API_KEY"
    echo ""
    read -p "Press Enter after you've edited .env..."
else
    echo "✅ .env file already exists"
fi

# Validate required files
echo "📋 Checking configuration files..."
if [ ! -f litellm_config.yaml ]; then
    echo "❌ litellm_config.yaml not found!"
    exit 1
fi
echo "✅ Configuration files found"
echo ""

# Choose deployment mode
echo "Select deployment mode:"
echo "1) Basic (LiteLLM + PostgreSQL + Redis)"
echo "2) Full (Basic + Monitoring with Grafana/Prometheus)"
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        PROFILE=""
        ;;
    2)
        PROFILE="--profile monitoring"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Pull images
echo ""
echo "📥 Pulling Docker images..."
docker-compose $PROFILE pull

# Start services
echo ""
echo "🚀 Starting Megalith Model Mesh..."
docker-compose $PROFILE up -d

# Wait for services to be ready
echo ""
echo "⏳ Waiting for services to start..."
sleep 10

# Check health
echo ""
echo "🏥 Checking service health..."
docker-compose ps

# Get IP address
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "======================================"
echo ""
echo "🌐 Configuring Tailscale Serve..."
echo ""

# Check if Tailscale is installed
if command -v tailscale &> /dev/null; then
    read -p "Configure Tailscale serve for remote access? (y/n): " configure_ts
    
    if [ "$configure_ts" == "y" ]; then
        echo "Setting up Tailscale serve at /llm path..."
        sudo tailscale serve --bg --https=443 /llm http://localhost:4000
        
        echo "✅ Tailscale serve configured!"
        echo ""
        echo "🌐 Remote access URLs:"
        echo "   https://pi5l.tailf49db2.ts.net/llm"
        echo "   https://100.77.119.64/llm"
        echo ""
    fi
else
    echo "⚠️  Tailscale not found. Skipping remote access setup."
    echo "   Install: curl -fsSL https://tailscale.com/install.sh | sh"
fi

echo ""
echo "======================================"
echo "✅ Deployment Complete!"
echo "======================================"
echo ""
echo "🌐 LiteLLM API: http://$IP:4000"
echo "🔑 API Key: (check your .env file for LITELLM_MASTER_KEY)"
echo ""
echo "📊 Admin UI: http://$IP:4000/ui"
echo "   Username: admin"
echo "   Password: admin"
echo ""

if [ "$choice" == "2" ]; then
    echo "📈 Grafana: http://$IP:3000"
    echo "   Username: admin"
    echo "   Password: admin"
    echo ""
    echo "📊 Prometheus: http://$IP:9090"
    echo ""
fi

echo "📖 Test your setup:"
echo "   curl http://$IP:4000/health"
echo ""
echo "💬 Example request:"
echo "   curl http://$IP:4000/v1/chat/completions \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -H 'Authorization: Bearer YOUR_MASTER_KEY' \\"
echo "     -d '{"
echo "       \"model\": \"gpt-3.5-turbo\","
echo "       \"messages\": [{\"role\": \"user\", \"content\": \"Hello!\"}]"
echo "     }'"
echo ""
echo "📝 View logs:"
echo "   docker-compose logs -f litellm"
echo ""
echo "🛑 Stop services:"
echo "   docker-compose $PROFILE down"
echo ""
echo "======================================"
