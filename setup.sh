#!/bin/bash

# Kheti AI - Initial Setup Script
# Run this once after cloning the repository

set -e

echo "======================================"
echo "   Kheti AI - Initial Setup"
echo "======================================"
echo ""

# Check if already configured
if [ -f .env ]; then
    echo "⚠️  .env file already exists!"
    read -p "Do you want to reconfigure? (y/n): " reconfig
    if [ "$reconfig" != "y" ]; then
        echo "Skipping configuration. Run ./deploy.sh to deploy."
        exit 0
    fi
fi

echo "📋 This script will help you configure Kheti AI for first deployment."
echo ""

# Create .env from template
echo "🔑 Setting up environment variables..."
cp .env.example .env

echo ""
echo "Please enter your API keys (press Enter to skip if you don't have them yet):"
echo ""

# Anthropic API Key
read -p "Anthropic API Key (for Claude): " anthropic_key
if [ ! -z "$anthropic_key" ]; then
    sed -i "s|ANTHROPIC_API_KEY=.*|ANTHROPIC_API_KEY=$anthropic_key|g" .env
fi

# OpenAI API Key
read -p "OpenAI API Key (for GPT): " openai_key
if [ ! -z "$openai_key" ]; then
    sed -i "s|OPENAI_API_KEY=.*|OPENAI_API_KEY=$openai_key|g" .env
fi

# Gemini API Key
read -p "Gemini API Key (for Google): " gemini_key
if [ ! -z "$gemini_key" ]; then
    sed -i "s|GEMINI_API_KEY=.*|GEMINI_API_KEY=$gemini_key|g" .env
fi

# Perplexity API Key
read -p "Perplexity API Key: " perplexity_key
if [ ! -z "$perplexity_key" ]; then
    sed -i "s|PERPLEXITY_API_KEY=.*|PERPLEXITY_API_KEY=$perplexity_key|g" .env
fi

# Generate secure master key
echo ""
echo "🔐 Generating secure LiteLLM master key..."
MASTER_KEY="sk-kheti-$(openssl rand -hex 32)"
sed -i "s|LITELLM_MASTER_KEY=.*|LITELLM_MASTER_KEY=$MASTER_KEY|g" .env

# Generate secure PostgreSQL password
PG_PASSWORD="kheti_pg_$(openssl rand -hex 16)"
sed -i "s|POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$PG_PASSWORD|g" .env

echo "✅ Environment variables configured!"
echo ""

# Ask about machine configuration
echo "📍 Current configuration is for Pi5L:"
echo "   Tailscale: 100.77.119.64"
echo "   Local: 10.0.0.111"
echo "   Hostname: pi5l.tailf49db2.ts.net"
echo ""
read -p "Are you deploying on Pi5L? (y/n): " is_pi5l

if [ "$is_pi5l" != "y" ]; then
    echo ""
    echo "⚠️  You're deploying on a different machine."
    echo "   You'll need to update TAILSCALE_SETUP.md with your machine's IPs."
    echo "   Press Enter to continue..."
    read
fi

# Create necessary directories
echo ""
echo "📁 Creating directory structure..."
mkdir -p litellm_data
mkdir -p grafana/dashboards
mkdir -p grafana/datasources

echo "✅ Directories created!"
echo ""

# Summary
echo "======================================"
echo "   ✅ Setup Complete!"
echo "======================================"
echo ""
echo "Your LiteLLM master key (save this!):"
echo "   $MASTER_KEY"
echo ""
echo "Next steps:"
echo "   1. Review and customize litellm_config_production.yaml"
echo "   2. Run: ./deploy.sh"
echo "   3. Configure Tailscale serve (deploy.sh will prompt)"
echo ""
echo "For help, see MASTER_README.md"
echo ""

# Ask if they want to deploy now
read -p "Deploy now? (y/n): " deploy_now
if [ "$deploy_now" == "y" ]; then
    echo ""
    echo "Starting deployment..."
    ./deploy.sh
else
    echo ""
    echo "Run ./deploy.sh when ready to deploy."
fi
