# Model Distribution Strategy - Akshat's Homelab
# Max Performance with Redundancy + Multi-Modal (Code/Vision/Voice/Image/Video)

## Hardware Inventory & Assignments

### TIER 1: GPU POWERHOUSES (Primary Performance)

#### Akshat-PC (RTX 5090, 192GB RAM, i9-12900K) - PRIMARY WORKHORSE
**Role:** All heavy lifting - XL models, video gen, image gen
**Tailscale:** 100.111.115.92
**Local:** 10.0.0.5
**Hostname:** akshat-pc.tailf49db2.ts.net

**Models to Install:**
```bash
# XL Code Models
ollama pull qwen2.5-coder:32b          # → XL-LOC-FRE-qwen2.5-coder-32b
ollama pull deepseek-coder-v2:236b     # → XL-LOC-FRE-deepseek-coder-236b

# XL Vision Models  
ollama pull qwen2.5:72b                # → XL-LOC-FRE-qwen2.5-72b
ollama pull llava:34b                  # → XL-LOC-FRE-llava-34b

# L Reasoning Models
ollama pull deepseek-r1:14b            # → L-LOC-FRE-deepseek-r1-14b
ollama pull qwen2.5:32b                # → L-LOC-FRE-qwen2.5-32b

# L Vision
ollama pull llama3.2-vision:90b        # → XL-LOC-FRE-llama3.2-vision-90b (if released)
ollama pull llama3.2-vision:11b        # → M-LOC-FRE-llama3.2-vision-11b

# M Code
ollama pull codestral:22b              # → L-LOC-FRE-codestral-22b

# Image Generation
ollama pull stable-diffusion-xl        # → XL-LOC-FRE-sdxl
ollama pull flux-schnell               # → XL-LOC-FRE-flux-schnell

# Video Generation (when available)
# ollama pull <video-model>            # → XL-LOC-FRE-video-gen

# Voice (Whisper)
ollama pull whisper:large-v3           # → L-LOC-FRE-whisper-large-v3

# Keep loaded: 3 models max (per your OLLAMA_MAX_LOADED_MODELS)
```

**Expected Performance:**
- 70B+ models: ~20-30 tokens/sec
- Image gen: ~2-5 sec/image
- Video gen: TBD

---

#### Old-Office-PC (RTX 2080 Super, 32GB RAM, i7-6700K) - BACKUP + MID-TIER
**Role:** Redundancy for critical models + mid-tier workload
**Tailscale:** [TO BE CONFIGURED]
**Local:** [TO BE CONFIGURED]

**Models to Install:**
```bash
# Redundant Heavy Models (Q4 quantization for 32GB)
ollama pull qwen2.5-coder:32b-q4       # → XL-LOC-FRE-qwen2.5-coder-32b-q4 (backup)
ollama pull llama3.1:70b-q4            # → XL-LOC-FRE-llama3.1-70b-q4

# Mid-tier models
ollama pull llama3.2-vision:11b        # → M-LOC-FRE-llama3.2-vision-11b (backup)
ollama pull mistral-nemo:12b           # → M-LOC-FRE-mistral-nemo-12b
ollama pull qwen2.5:14b                # → M-LOC-FRE-qwen2.5-14b

# Small fast models
ollama pull llama3.2:3b                # → S-LOC-FRE-llama3.2-3b
ollama pull deepseek-r1:8b             # → S-LOC-FRE-deepseek-r1-8b

# Image generation
ollama pull stable-diffusion-2.1       # → L-LOC-FRE-sd-2.1

# Embeddings
ollama pull nomic-embed-text           # → S-LOC-FRE-nomic-embed-text
```

---

### TIER 2: HIGH-RAM CPU MONSTERS (Large Context, CPU Inference)

#### GTR9-Pro (AI Max+ 395, 128GB RAM) - LARGE MODEL CPU
**Role:** XL models via CPU, high-context tasks
**Tailscale:** [TO BE CONFIGURED]
**Local:** [TO BE CONFIGURED]

**Models to Install:**
```bash
# XL models with Q4 quantization (CPU optimized)
ollama pull qwen2.5:72b-q4             # → XL-LOC-FRE-qwen2.5-72b-q4-cpu
ollama pull llama3.1:70b-q4            # → XL-LOC-FRE-llama3.1-70b-q4-cpu
ollama pull mixtral:8x22b-q4           # → XL-LOC-FRE-mixtral-8x22b-q4

# Embeddings for parallel processing
ollama pull mxbai-embed-large          # → M-LOC-FRE-mxbai-embed-large
ollama pull bge-m3                     # → M-LOC-FRE-bge-m3
```

**Environment Variables:**
```bash
OLLAMA_NUM_PARALLEL=4                  # Parallel requests
OLLAMA_CTX=131072                      # 128k context
```

---

#### EVO-X2 (AI Max+ 395, 128GB RAM) - LARGE MODEL CPU #2
**Role:** More XL CPU models, redundancy
**Tailscale:** [TO BE CONFIGURED]
**Local:** [TO BE CONFIGURED]

**Models to Install:**
```bash
# Different XL models to spread workload
ollama pull deepseek-coder-v2:236b-q4  # → XL-LOC-FRE-deepseek-coder-236b-q4-cpu
ollama pull qwen2.5:72b-q4             # → XL-LOC-FRE-qwen2.5-72b-q4-cpu (redundant)

# Embeddings
ollama pull snowflake-arctic-embed:335m # → S-LOC-FRE-arctic-embed
ollama pull nomic-embed-text           # → S-LOC-FRE-nomic-embed-text
```

---

#### MS-S1 (AI Max+ 395, 128GB RAM) - LARGE MODEL CPU #3
**Role:** Third XL CPU node for load distribution
**Tailscale:** [TO BE CONFIGURED]
**Local:** [TO BE CONFIGURED]

**Models to Install:**
```bash
# Redundant large models
ollama pull qwen2.5:72b-q4             # → XL-LOC-FRE-qwen2.5-72b-q4-cpu
ollama pull llama3.1:70b-q4            # → XL-LOC-FRE-llama3.1-70b-q4-cpu

# Specialized embeddings
ollama pull granite-embedding          # → S-LOC-FRE-granite-embed
```

---

### TIER 3: NPU-CAPABLE (Experimental NPU Acceleration)

#### SER9 (AMD XDNA 2 NPU, 32GB, Ryzen AI 9 HX 370) - NPU EXPERIMENTAL
**Role:** NPU-optimized models, testing ground
**Tailscale:** [TO BE CONFIGURED]
**Local:** [TO BE CONFIGURED]

**Models to Install:**
```bash
# NPU-optimized models (if available for AMD XDNA 2)
# Note: Check ollama/DirectML for NPU support
ollama pull phi3.5:3.8b                # → S-LOC-FRE-phi3.5-3.8b-npu
ollama pull llama3.2:3b                # → S-LOC-FRE-llama3.2-3b-npu

# CPU fallback models
ollama pull qwen2.5:14b                # → M-LOC-FRE-qwen2.5-14b
ollama pull mistral:7b                 # → S-LOC-FRE-mistral-7b
```

**NPU Setup (when available):**
```bash
# AMD ROCm for XDNA 2 (experimental)
# Follow AMD NPU SDK documentation
```

---

#### Atomman-X7-Ti (Intel Meteor Lake NPU, 32GB, Ultra 9 185H) - NPU EXPERIMENTAL
**Role:** Intel NPU testing, mid-tier models
**Tailscale:** [TO BE CONFIGURED]
**Local:** [TO BE CONFIGURED]

**Models to Install:**
```bash
# Intel NPU optimized (OpenVINO)
ollama pull phi3.5:3.8b                # → S-LOC-FRE-phi3.5-3.8b-intel-npu
ollama pull llama3.2:3b                # → S-LOC-FRE-llama3.2-3b-intel-npu

# CPU models
ollama pull qwen2.5:14b                # → M-LOC-FRE-qwen2.5-14b
ollama pull codellama:13b              # → M-LOC-FRE-codellama-13b

# Embeddings
ollama pull nomic-embed-text           # → S-LOC-FRE-nomic-embed-text
```

**NPU Setup:**
```bash
# Intel OpenVINO for Meteor Lake NPU
# Requires OpenVINO 2024.0+
```

---

### TIER 4: APPLE SILICON (Metal Optimization)

#### Mac-Mini-M4-Pro (M4 Pro 12-core, 24GB) - APPLE METAL
**Role:** Metal-optimized models, macOS-specific tasks
**Tailscale:** [TO BE CONFIGURED]
**Local:** [TO BE CONFIGURED]

**Models to Install:**
```bash
# Metal-optimized models
ollama pull qwen2.5:14b                # → M-LOC-FRE-qwen2.5-14b-metal
ollama pull llama3.2:3b                # → S-LOC-FRE-llama3.2-3b-metal
ollama pull phi3.5:3.8b                # → S-LOC-FRE-phi3.5-metal

# Image gen (CoreML)
ollama pull stable-diffusion           # → M-LOC-FRE-sd-coreml

# Embeddings
ollama pull nomic-embed-text           # → S-LOC-FRE-nomic-embed-text
```

---

### TIER 5: MID-RANGE CPU

#### MS01 (i9-12900H, RAM TBD - assume 32-64GB) - MID-RANGE
**Role:** Mid-tier models, general purpose
**Tailscale:** [TO BE CONFIGURED]
**Local:** [TO BE CONFIGURED]

**Models to Install:**
```bash
# Mid-tier models
ollama pull qwen2.5:14b                # → M-LOC-FRE-qwen2.5-14b
ollama pull codellama:13b              # → M-LOC-FRE-codellama-13b
ollama pull mistral-nemo:12b           # → M-LOC-FRE-mistral-nemo-12b

# Small models
ollama pull llama3.2:3b                # → S-LOC-FRE-llama3.2-3b
ollama pull deepseek-r1:8b             # → S-LOC-FRE-deepseek-r1-8b
```

---

#### BorgCube (i5-12400, 32GB DDR5) - LIGHT-MID
**Role:** Small to mid models
**Tailscale:** [TO BE CONFIGURED]
**Local:** [TO BE CONFIGURED]

**Models to Install:**
```bash
# Small-mid models
ollama pull qwen2.5:7b                 # → S-LOC-FRE-qwen2.5-7b
ollama pull mistral:7b                 # → S-LOC-FRE-mistral-7b
ollama pull phi3.5:3.8b                # → S-LOC-FRE-phi3.5-3.8b

# Embeddings
ollama pull nomic-embed-text           # → S-LOC-FRE-nomic-embed-text
```

---

#### RetroMac (Ryzen 3 3200U, 16GB) - LIGHTWEIGHT ONLY
**Role:** Tiny models only, edge case testing
**Tailscale:** [TO BE CONFIGURED]
**Local:** [TO BE CONFIGURED]

**Models to Install:**
```bash
# Tiny models only (16GB limit)
ollama pull tinyllama:1.1b             # → XS-LOC-FRE-tinyllama-1.1b
ollama pull phi-2:2.7b                 # → S-LOC-FRE-phi-2-2.7b
ollama pull llama3.2:1b                # → XS-LOC-FRE-llama3.2-1b

# Light embeddings
ollama pull nomic-embed-text           # → S-LOC-FRE-nomic-embed-text
```

---

### TIER 6: INFRASTRUCTURE (No Inference)

#### Pi5 Fleet (12 units) - MONITORING & ORCHESTRATION ONLY
**Role:** Infrastructure, monitoring, no model inference
**Pi5L (Orchestrator):**
- **Tailscale:** 100.77.119.64
- **Local:** 10.0.0.111
- **Hostname:** pi5l.tailf49db2.ts.net
- **Runs:** LiteLLM Proxy + PostgreSQL + Redis + Prometheus + Grafana

**Other 11 Pis:**
- Prometheus node exporters
- Log aggregation
- Health monitoring
- Backup services

**NO OLLAMA MODELS - Just infrastructure**

---

## Redundancy Map

| Model Category | Primary | Backup 1 | Backup 2 |
|----------------|---------|----------|----------|
| XL Code (70B+) | Akshat-PC | GTR9-Pro (CPU) | EVO-X2 (CPU) |
| XL Vision (32B+) | Akshat-PC | Old-Office-PC (Q4) | - |
| L Code (20-40B) | Akshat-PC | Old-Office-PC | MS01 |
| M Vision (11B) | Akshat-PC | Old-Office-PC | Mac-Mini |
| S Fast (3-8B) | Multiple | Multiple | Multiple |
| Embeddings | All except Pis | All except Pis | All except Pis |

---

## Cloud APIs (Fallback/Premium)

All cloud models accessed via LiteLLM when local insufficient:

- **XL-CLD-PAY-claude-opus-4.5** - Best reasoning
- **XL-CLD-PAY-gpt-4o** - Best vision + general
- **XL-CLD-PAY-o1** - Best math/reasoning
- **M-CLD-PAY-claude-sonnet-4.5** - Balanced
- **M-CLD-PAY-gemini-flash-2.0** - Fast vision
- **S-CLD-PAY-gpt-4o-mini** - Fast cheap
- **S-CLD-PAY-claude-haiku-4.5** - Fast cheap

---

## Installation Commands by Machine

See individual machine sections above for exact `ollama pull` commands.

**General pattern:**
```bash
# SSH to each machine
ssh user@machine-ip

# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Configure for network access
export OLLAMA_HOST=0.0.0.0:11434
sudo systemctl restart ollama

# Pull assigned models (see machine-specific lists above)
ollama pull <model-name>

# Verify
ollama list
```

---

## Performance Expectations

| Tier | Hardware | Model Size | Tokens/sec | Use Case |
|------|----------|-----------|------------|----------|
| 1 | RTX 5090 | 70B+ | 20-30 | Best quality |
| 1 | RTX 2080S | 30B Q4 | 10-15 | Backup quality |
| 2 | AI Max+ CPU | 70B Q4 | 5-10 | High context |
| 3 | NPU | 3-14B | 20-40 | Experimental fast |
| 4 | M4 Pro | 3-14B | 15-25 | Metal optimized |
| 5 | Intel CPU | 7-14B | 8-12 | General purpose |

---

## Next Steps

1. ✅ Review this distribution
2. ⏭ Install models on each machine
3. ⏭ Configure LiteLLM with all endpoints
4. ⏭ Set up Tailscale serve on Pi5L
5. ⏭ Test routing and redundancy
6. ⏭ Monitor performance and adjust

**Estimated Total Storage:** ~2-3TB across all machines
**Estimated Setup Time:** 2-3 hours (parallel downloads)
