# Secure Deployment Guide for Local AI Platform

This guide provides a secure approach to deploying a private AI platform similar to the existing Local NSFW Model Router, with optional cloud integration capabilities.

## Overview

This guide covers:
1. Local deployment (existing functionality)
2. Secure cloud integration (optional)
3. Multi-model routing
4. Privacy-focused architecture

## Prerequisites

- Python 3.12+
- Docker (optional, for containerization)
- Git
- Sufficient RAM/GPU for models (see model requirements)

## Part 1: Local Setup (Current Functionality)

### 1.1 Installation

```bash
# Clone the repository
git clone https://github.com/Thomas-carpuncle/local-nsfw.git
cd local-nsfw

# Create virtual environment
conda create --name nsfw_model_router python=3.12
conda activate nsfw_model_router

# Install dependencies
pip install -r requirements.txt
```

### 1.2 Run the Application

```bash
# Start the Streamlit app
streamlit run app.py
```

The application runs entirely locally with no external API calls by default.

## Part 2: Optional Cloud Integration (Secure)

If you want to add cloud-based model capabilities, follow these secure practices:

### 2.1 Environment Setup

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your credentials (NEVER commit this file)
nano .env
```

### 2.2 Environment Variables (.env)

```bash
# OpenAI API (optional)
OPENAI_API_KEY=your_key_here

# Azure OpenAI (optional)
AZURE_OPENAI_API_KEY=your_key_here
AZURE_OPENAI_ENDPOINT=your_endpoint_here

# xAI Grok (optional)
XAI_API_KEY=your_key_here

# MongoDB (for conversation memory)
MONGO_URI=mongodb://localhost:27017/

# Other services as needed
```

### 2.3 Update .gitignore

Ensure your `.gitignore` includes:
```
.env
*.key
*.pem
secrets/
credentials/
```

## Part 3: Multi-Model Router Setup

### 3.1 Architecture

```
User Interface (Streamlit)
    ↓
Model Router (litellm or custom)
    ↓
├── Local Models (Nexa SDK)
│   ├── llama3-uncensored
│   ├── Mistral-Nemo
│   └── Other GGUF models
│
└── Cloud APIs (optional)
    ├── OpenAI GPT-4
    ├── Azure OpenAI
    └── xAI Grok
```

### 3.2 Installing LiteLLM (Optional)

```bash
# Install LiteLLM for multi-model routing
pip install litellm

# Create configuration file
nano litellm_config.yaml
```

### 3.3 LiteLLM Configuration (litellm_config.yaml)

```yaml
model_list:
  # Local models via Nexa SDK
  - model_name: llama3-local
    litellm_params:
      model: local/llama3-uncensored
      api_base: http://localhost:8080
  
  # Cloud models (optional - requires API keys in .env)
  - model_name: gpt-4-cloud
    litellm_params:
      model: azure/gpt-4
      api_key: os.environ/AZURE_OPENAI_API_KEY
      api_base: os.environ/AZURE_OPENAI_ENDPOINT

router_settings:
  routing_strategy: simple-shuffle
  enable_fallbacks: true
```

### 3.4 Running LiteLLM Proxy (Optional)

```bash
# Start LiteLLM proxy
litellm --config litellm_config.yaml --port 4000

# Or use Docker
docker run -p 4000:4000 \
  -v $(pwd)/litellm_config.yaml:/app/config.yaml \
  -e AZURE_OPENAI_API_KEY=$AZURE_OPENAI_API_KEY \
  ghcr.io/berriai/litellm:main-latest \
  --config /app/config.yaml
```

## Part 4: Docker Deployment (Recommended)

### 4.1 Dockerfile for Local Deployment

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app.py .
COPY utils/ ./utils/
COPY *.png .

# Expose Streamlit port
EXPOSE 8501

# Run the application
CMD ["streamlit", "run", "app.py", "--server.address", "0.0.0.0"]
```

### 4.2 Docker Compose

```yaml
version: '3.8'

services:
  nsfw-router:
    build: .
    ports:
      - "8501:8501"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - AZURE_OPENAI_API_KEY=${AZURE_OPENAI_API_KEY}
    volumes:
      - ./models:/app/models
      - ./.env:/app/.env
    restart: unless-stopped

  mongodb:
    image: mongo:7
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db
    restart: unless-stopped

volumes:
  mongo-data:
```

### 4.3 Build and Run

```bash
# Build the image
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Part 5: Security Considerations

### 5.1 Network Security

```bash
# For local-only access
streamlit run app.py --server.address localhost

# For network access with authentication
streamlit run app.py --server.address 0.0.0.0 --server.enableCORS false
```

### 5.2 Firewall Configuration

```bash
# Allow only specific IPs (example for ufw)
sudo ufw default deny incoming
sudo ufw allow from 192.168.1.0/24 to any port 8501
sudo ufw enable
```

### 5.3 HTTPS/TLS (Production)

Use a reverse proxy like Nginx or Traefik:

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:8501;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## Part 6: Model Management

### 6.1 Downloading Models

```bash
# Using Nexa SDK
nexa pull llama3-uncensored
nexa pull Mistral-Nemo-Instruct-2407:q4_K_M

# Check downloaded models
nexa list
```

### 6.2 Storage Requirements

| Model | Size | RAM Required | GPU VRAM (Optional) |
|-------|------|--------------|---------------------|
| Llama-3.2-3B | ~2GB | 4GB | 4GB |
| Llama-3-8B | ~5GB | 8GB | 8GB |
| Mistral-Nemo-12B | ~7GB | 12GB | 12GB |
| Rocinante-12B | ~7GB | 12GB | 12GB |

## Part 7: Monitoring and Maintenance

### 7.1 Basic Monitoring

```bash
# Check application logs
docker-compose logs -f nsfw-router

# Monitor resource usage
docker stats

# Check model loading status
nexa status
```

### 7.2 Backup Strategy

```bash
# Backup MongoDB data
docker exec mongodb mongodump --out /backup

# Backup environment configuration (without secrets)
cp .env.example .env.backup
```

## Part 8: Troubleshooting

### Common Issues

1. **Out of Memory**
   - Use smaller quantization (e.g., q4_K_M instead of q8_0)
   - Reduce context length in settings
   - Use CPU offloading

2. **Slow Response**
   - Enable GPU acceleration (Metal/CUDA)
   - Use smaller models
   - Adjust temperature and sampling parameters

3. **Model Not Loading**
   - Check model path is correct
   - Verify sufficient disk space
   - Review terminal logs for errors

## Resources

- [Nexa SDK Documentation](https://github.com/NexaAI/nexa-sdk)
- [Streamlit Documentation](https://docs.streamlit.io)
- [LiteLLM Documentation](https://docs.litellm.ai)
- [Docker Documentation](https://docs.docker.com)

## Legal and Ethical Considerations

- This software is for adult users only
- Use responsibly and in accordance with local laws
- Respect privacy and consent
- Do not use for illegal activities
- Follow AI model licenses and terms of service

---

**Note**: This deployment guide focuses on secure, privacy-respecting implementations. Always keep credentials secure and never commit secrets to version control.
