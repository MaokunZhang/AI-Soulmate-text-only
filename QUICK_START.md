# Quick Start Guide

Get up and running with Local NSFW Model Router in minutes!

## 🚀 Fastest Start (Local Only - 100% Private)

```bash
# 1. Clone and enter directory
git clone https://github.com/Thomas-carpuncle/local-nsfw.git
cd local-nsfw

# 2. Run automated setup
./setup.sh

# 3. Start the application
streamlit run app.py
```

Your browser will open at `http://localhost:8501`

**That's it!** You're now running a completely private, local AI chatbot.

## 📦 Docker Quick Start

```bash
# 1. Clone repository
git clone https://github.com/Thomas-carpuncle/local-nsfw.git
cd local-nsfw

# 2. Start with Docker Compose
docker-compose up -d

# 3. Open browser
# Navigate to http://localhost:8501
```

## 🎯 What You Get (Default Setup)

- ✅ **Privacy**: Everything runs on your device, no data sent to cloud
- ✅ **Uncensored Models**: Access to various uncensored AI models
- ✅ **Easy Switching**: Change models with a dropdown
- ✅ **Customization**: Create and customize AI characters
- ✅ **Free**: No API costs, no subscriptions

## 🌐 Optional: Add Cloud Models

Want to add GPT-4, Claude, or other cloud models?

```bash
# 1. Copy environment example
cp .env.example .env

# 2. Edit and add your API keys
nano .env

# Add:
# OPENAI_API_KEY=sk-your-key-here
# AZURE_OPENAI_API_KEY=your-key-here
# XAI_API_KEY=your-key-here

# 3. Restart the application
# Local: Ctrl+C then `streamlit run app.py`
# Docker: `docker-compose restart`
```

⚠️ **Never commit .env to Git!** (It's already in .gitignore)

## 📱 Available Models (Local)

Built-in models you can use right away:

| Model | Size | RAM Required | Best For |
|-------|------|--------------|----------|
| llama3-uncensored | ~5GB | 8GB | General chat, roleplay |
| Mistral-Nemo | ~7GB | 12GB | Advanced conversations |
| Llama-3.2-3B | ~2GB | 4GB | Lightweight, fast responses |
| Rocinante-12B | ~7GB | 12GB | Creative writing |

More models available at [Nexa Model Hub](https://nexaai.com/models)

## 🎨 Customization

Click the "Customize" button in the UI to:
- Change AI personality
- Upload custom avatar
- Modify character traits
- Set conversation style

## ⚙️ Configuration Options

In the sidebar, adjust:
- **Temperature**: Higher = more creative (0.0-1.0)
- **Max New Tokens**: Response length (1-1000)
- **Top K**: Vocabulary diversity (1-100)
- **Top P**: Probability threshold (0.0-1.0)
- **Context Length**: Memory of conversation (1000-9999)

## 🆘 Troubleshooting

### "Out of Memory" Error
```bash
# Use a smaller model
# Select "Llama-3.2-3B-Instruct-uncensored" instead of 12B models
```

### Model Loading Slow
```bash
# First time downloads the model
# Check terminal for download progress
# Models cache in ~/.cache/nexa/ for future use
```

### Can't Connect
```bash
# Make sure Streamlit is running
# Check terminal for errors
# Default URL: http://localhost:8501
```

### Docker Issues
```bash
# Restart services
docker-compose restart

# View logs
docker-compose logs -f

# Full reset
docker-compose down
docker-compose up -d
```

## 🔒 Security Checklist

- [x] .env file is in .gitignore ✅
- [x] No API keys in code ✅
- [ ] Rotate any accidentally exposed keys 🔴 **DO THIS NOW!**
- [ ] Use HTTPS if deploying to web
- [ ] Enable authentication for web deployment
- [ ] Regular backups of conversations (if using MongoDB)

## 📚 Learn More

- **Full Setup**: See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **Web Deployment**: See [WEB_DEPLOYMENT.md](WEB_DEPLOYMENT.md)
- **Security**: See [SECURITY_ADVISORY.md](SECURITY_ADVISORY.md)
- **Cloud Integration**: See [CLOUD_SETUP_SUMMARY.md](CLOUD_SETUP_SUMMARY.md)

## 💡 Tips

1. **Save Resources**: Close unused models by selecting a different one
2. **Better Responses**: Adjust temperature (0.7-0.9 works well for roleplay)
3. **Longer Memory**: Increase context length for longer conversations
4. **Faster Loading**: Smaller quantizations (q4_K_M) load faster than larger ones

## 🌟 Popular Use Cases

- **Roleplay**: Create custom characters and scenarios
- **Creative Writing**: Generate stories, dialogues, scripts
- **Personal Assistant**: Uncensored help with any topic
- **Learning**: Ask questions without content filtering
- **Entertainment**: Casual conversation with AI personalities

## 🔄 Updating

```bash
# Pull latest changes
cd local-nsfw
git pull

# Update dependencies
pip install -r requirements.txt --upgrade

# Or with Docker
docker-compose pull
docker-compose up -d
```

## 🎉 Next Steps

Once you're comfortable with the basics:

1. Try different models and compare responses
2. Create custom characters for specific scenarios
3. Explore advanced deployment options (Docker, cloud)
4. Join the community and share your experiences

## ⚖️ Legal Notice

- 18+ only
- For personal use
- Respect local laws
- Use responsibly
- Keep private conversations private

---

**Enjoy your privacy-focused AI companion! 🚀**

Need help? Check the documentation or create an issue on GitHub (without exposing credentials!).
