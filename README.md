# Megalith - Private Multi-Node AI Utility Provider

## Heterogeneous Model Mesh for High-Performance AI

Megalith transforms a cluster of isolated hardware—from RTX 5090s to Raspberry Pis—into a specialized utility farm. By assigning **Personas** based on hardware strengths, it achieves zero-latency serving (TTFT < 100ms) and intelligent routing across specialized tiers.

🌐 **OpenWebUI Frontend** • 🚀 **Persona-Based Routing** • ⚡ **Zero-Latency Pinning** • 🛡️ **Failover Resilience**

---

## 🏗️ The Architecture (Persona Strategy)

Rather than one machine doing everything, Megalith fragments tasks across specialized nodes:

### 🟢 1. The "Cruncher" (RTX 5090 Nodes)

**Priority:** Ultra-Low Latency Reasoning & Coding.

#### Environment Tuning

DeepSeek-R1, Qwen2.5-Coder

### 🔵 2. The "Fat Brains" (AMD Halo Strix)

**Priority:** High-Context Analysis & RAG.

#### Environment Tuning

Llama-3-70B, Mixtral

### 🟠 3. The "Media Lab" (3080Ti / 2080 / Corals)

**Priority:** Vision & Voice Processing.

#### Environment Tuning

Llava, Whisper, Frigate

### ⚪ 4. The "Micro-Logic Swarm" (Pi 5s)

**Priority:** Function Calling & Tool Routing.

#### Environment Tuning

Llama-3.2-3B, MCP Agents

---

## ⚡ Quick Start (Controller Deployment)

On your **Mac Studio M4 (Controller Node)**:

```bash
# 1. Clone & Configure
git clone https://github.com/akshatrathee/megalith.git megalith
cd megalith
cp .env.example .env # Add your keys

# 2. Deploy Infrastructure
docker-compose up -d
```

**Access Points:**

- **OpenWebUI:** `http://localhost:3000`
- **LiteLLM Router:** `http://localhost:4000`
- **Netdata Monitoring:** `http://localhost:19999`

---

## 📚 Specialized Guides

- **[PERSONAS.md](PERSONAS.md)**: Hardware tuning & environment variables for each tier.
- **[STORAGE.md](STORAGE.md)**: Master-Slave sync logic for NAS and local NVMe.
- **[test_client.py](test_client.py)**: Verify routing across the persona mesh.

---

## 🎯 Core Principles

1. **Zero-Latency Priority**: All models are pinned in VRAM/RAM (`KEEP_ALIVE=-1`) on high-performance nodes to ensure instant TTFT.
2. **Specialized Mesh**: LiteLLM routes "Code" to GPUs and "Context" to High-RAM CPU nodes.
3. **Resilient Failover**: If a GPU node hits a limit, traffic cascades to the "Fat Brain" CPU cluster.
4. **Master-Slave Storage**: NAS stores the library; local NVMe serves the active models to avoid network bottlenecks.

---

## 🎮 Consumption ecosystem

Megalith is designed to serve:
Agent0 • OpenLLM • Frigate • Immich • ComfyUI • n8n • Home Assistant

---

## 📄 License

MIT License - Built for the future of private AI utility.
