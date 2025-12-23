# Cloud Setup Summary - Security-Focused Approach

## ⚠️ CRITICAL SECURITY NOTICE

The original issue contained exposed credentials including API keys, passwords, and server access information. **These credentials must be rotated immediately** as they have been exposed in a public GitHub issue.

## What This Repository Provides

This repository (`local-nsfw`) is designed for **local, privacy-focused AI model execution**. It allows you to:

1. Run uncensored AI language models entirely on your device
2. Chat with customizable AI characters
3. Switch between different models easily
4. Maintain complete privacy (no data sent to external servers by default)

## What Was Requested vs. What Is Safe

### ❌ Unsafe Requests (Cannot Implement)

The issue requested:
- Hardcoding API keys and credentials in scripts
- Creating infrastructure with embedded secrets
- Direct SSH access commands with passwords in plain text
- Deployment scripts with real server IPs and credentials

**Why this is dangerous**:
- Exposed credentials can be used maliciously
- Hardcoded secrets in repositories are security vulnerabilities
- Public exposure violates security best practices
- Could lead to unauthorized access and data breaches

### ✅ Safe Alternatives (Implemented)

This PR provides:
1. **Secure deployment guides** without hardcoded secrets
2. **Docker containerization** with proper environment variables
3. **Multi-model routing** using LiteLLM (configuration examples only)
4. **Security advisory** with credential rotation steps
5. **Web deployment guide** with authentication and HTTPS
6. **Setup script** for local installation

## Architecture Overview

### Local Deployment (Recommended)
```
┌─────────────────────────────────────┐
│  Your Computer (100% Local)         │
│  ┌─────────────────────────────┐   │
│  │  Streamlit Web Interface     │   │
│  │  (localhost:8501)            │   │
│  └─────────────┬────────────────┘   │
│                │                     │
│  ┌─────────────▼────────────────┐   │
│  │  Nexa SDK                    │   │
│  │  - Model: llama3-uncensored  │   │
│  │  - Model: Mistral-Nemo       │   │
│  │  - Model: etc.               │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Hybrid Deployment (Optional - With Proper Security)
```
┌──────────────────────────────────────────────────┐
│  Your Server (Private)                           │
│  ┌────────────────────────────────────────────┐ │
│  │  Reverse Proxy (Nginx/Caddy)               │ │
│  │  - HTTPS/TLS                               │ │
│  │  - Authentication                          │ │
│  │  - Rate Limiting                           │ │
│  └────────────┬───────────────────────────────┘ │
│               │                                  │
│  ┌────────────▼───────────────────────────────┐ │
│  │  LiteLLM Proxy (Optional)                  │ │
│  │  - Routes requests to appropriate model    │ │
│  └────┬───────────────────────────────────────┘ │
│       │                                          │
│  ┌────▼─────────────┐  ┌─────────────────────┐ │
│  │  Local Models    │  │  Cloud APIs         │ │
│  │  (Nexa SDK)      │  │  (via env vars)     │ │
│  └──────────────────┘  └─────────────────────┘ │
└──────────────────────────────────────────────────┘
```

## Quick Start - Secure Local Setup

### One-Command Setup
```bash
# Clone the repository
git clone https://github.com/Thomas-carpuncle/local-nsfw.git
cd local-nsfw

# Run setup script
./setup.sh

# Start the application
streamlit run app.py
```

### Manual Setup
```bash
# 1. Create virtual environment
conda create --name nsfw_model_router python=3.12
conda activate nsfw_model_router

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure environment (optional - only if using cloud models)
cp .env.example .env
nano .env  # Add your API keys

# 4. Run the application
streamlit run app.py
```

## Cloud Integration (Secure Approach)

If you want to integrate cloud AI services:

### 1. Set Up Environment Variables

**Never commit these to Git!**

```bash
# .env file (add to .gitignore)
OPENAI_API_KEY=your_key_here
AZURE_OPENAI_API_KEY=your_key_here
AZURE_OPENAI_ENDPOINT=your_endpoint_here
XAI_API_KEY=your_key_here
```

### 2. Use Secret Management

For production:
- **HashiCorp Vault** for centralized secrets
- **Azure Key Vault** for Azure deployments
- **AWS Secrets Manager** for AWS
- **Docker Secrets** for Docker Swarm
- **Kubernetes Secrets** for K8s

### 3. Deploy with Docker (Recommended)

```bash
# Build and deploy
docker-compose up -d

# Environment variables are loaded from .env (not committed)
# Secrets are passed as environment variables, never hardcoded
```

## What About the Server Setup Mentioned?

The issue mentioned specific servers (Netcup RS 12000 G12, VPS 3000 G11, etc.) with exposed IPs and credentials. 

### Immediate Actions Required:

1. **Change all passwords** mentioned in the issue
2. **Rotate all API keys** (Azure, OpenAI, xAI, Netcup, etc.)
3. **Review access logs** for unauthorized access
4. **Enable 2FA** on all services
5. **Use SSH keys** instead of passwords
6. **Implement firewall rules** to restrict access

### For Server Deployment:

Instead of providing scripts with hardcoded credentials, use:

```bash
# SSH with key-based authentication (secure)
ssh -i ~/.ssh/id_ed25519 user@your-server-ip

# Deploy with environment variables
export AZURE_API_KEY="your-key"
docker-compose up -d

# Or use a secrets management solution
vault kv put secret/nsfw-router \
  azure_key="your-key" \
  openai_key="your-key"
```

## Comparison to Replika

You mentioned wanting something "similar to Replika". Here's how this project compares:

| Feature | Replika | This Project |
|---------|---------|--------------|
| Privacy | Cloud-based, data stored remotely | Local, data stays on your device |
| Customization | Limited | Fully customizable characters |
| Models | Proprietary | Open-source uncensored models |
| NSFW Content | Restricted (paid tiers) | Unrestricted (local models) |
| Cost | Subscription-based | Free (local) or pay-per-use (cloud APIs) |
| Control | Limited | Complete control |

## Features Available

### Current Features:
- ✅ Local model execution (complete privacy)
- ✅ Multiple uncensored models available
- ✅ Character customization
- ✅ Chat history
- ✅ Model switching
- ✅ Streamlit web interface
- ✅ Docker support

### Optional Features (Require Setup):
- 🔧 Cloud model integration (OpenAI, Azure, xAI)
- 🔧 MongoDB conversation storage
- 🔧 Text-to-speech
- 🔧 Multi-model routing with LiteLLM
- 🔧 Web deployment with HTTPS

## Cost Analysis

### Local Deployment (Free)
- Hardware: Your existing computer
- Storage: 50GB+ for models
- RAM: 8GB+ recommended
- Cost: $0/month (electricity only)

### Hybrid Deployment (Local + Cloud)
- Local models: Free
- Cloud API calls (optional):
  - OpenAI GPT-4: ~$0.03 per 1K tokens
  - Azure OpenAI: Similar pricing
  - xAI Grok: Varies by plan
- Typical usage: $5-50/month depending on volume

### Cloud-Only Deployment
- VPS hosting: $20-100/month
- GPU server (if needed): $100-300/month
- Cloud APIs: $10-100/month
- Total: $30-400/month

**Recommendation**: Start with local deployment (free), add cloud features only if needed.

## Documentation Structure

This repository now includes:

1. **README.md** - Basic project overview and local usage
2. **SECURITY_ADVISORY.md** - ⚠️ Critical security information
3. **DEPLOYMENT_GUIDE.md** - Secure deployment options
4. **WEB_DEPLOYMENT.md** - Web service deployment with security
5. **AI_GIRLFRIEND_README.md** - AI girlfriend chatbot specific docs
6. **CLOUD_SETUP_SUMMARY.md** - This file
7. **setup.sh** - Automated setup script

## Resources and Further Reading

### Model Resources:
- [Nexa Model Hub](https://nexaai.com/models) - Browse available models
- [Hugging Face](https://huggingface.co/models) - Additional models

### Deployment Resources:
- [Docker Documentation](https://docs.docker.com/)
- [Streamlit Cloud](https://streamlit.io/cloud) - Free hosting option
- [LiteLLM Docs](https://docs.litellm.ai/) - Multi-model routing

### Security Resources:
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)

## Support

For issues or questions:
1. Check the documentation files in this repository
2. Review the [GitHub Issues](https://github.com/Thomas-carpuncle/local-nsfw/issues)
3. Create a new issue (without exposing credentials!)

## Legal and Ethical Considerations

- ✅ This software is for personal, adult use only
- ✅ Use responsibly and in accordance with local laws
- ✅ Respect privacy and consent
- ✅ Follow AI model licenses and terms of service
- ❌ Do not use for illegal activities
- ❌ Do not expose credentials publicly
- ❌ Do not share or distribute generated content without proper consideration

---

**Remember**: Security first! Never commit secrets to version control, always use environment variables and proper secret management.

If you need help with a specific deployment scenario, create a new issue with:
- Your deployment goal (without sensitive information)
- Your current setup
- Specific questions

We'll help you deploy securely!
