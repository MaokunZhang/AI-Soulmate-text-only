#!/bin/bash

# Local NSFW Model Router - Setup Script
# This script helps you set up the application securely

set -e

echo "=========================================="
echo "Local NSFW Model Router - Setup Script"
echo "=========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running in a virtual environment
if [ -z "$VIRTUAL_ENV" ] && [ -z "$CONDA_DEFAULT_ENV" ]; then
    echo -e "${YELLOW}Warning: You are not in a virtual environment!${NC}"
    echo "It's recommended to use a virtual environment."
    echo "Would you like to continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Exiting. Please create a virtual environment first:"
        echo "  conda create --name nsfw_model_router python=3.12"
        echo "  conda activate nsfw_model_router"
        exit 1
    fi
fi

echo "Step 1: Checking prerequisites..."
echo ""

# Check for Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d ' ' -f 2)
    echo -e "${GREEN}✓ Python found: $PYTHON_VERSION${NC}"
else
    echo -e "${RED}✗ Python 3 not found. Please install Python 3.12 or higher.${NC}"
    exit 1
fi

# Check for pip
if command -v pip &> /dev/null || command -v pip3 &> /dev/null; then
    echo -e "${GREEN}✓ pip found${NC}"
else
    echo -e "${RED}✗ pip not found. Please install pip.${NC}"
    exit 1
fi

echo ""
echo "Step 2: Installing Python dependencies..."
echo ""

# Install requirements
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${RED}✗ requirements.txt not found${NC}"
    exit 1
fi

echo ""
echo "Step 3: Setting up environment configuration..."
echo ""

# Setup .env file
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✓ Created .env file from .env.example${NC}"
        echo -e "${YELLOW}⚠ Please edit .env and add your API keys if you plan to use cloud models${NC}"
        echo ""
        echo "Do you want to edit .env now? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            # Use safe default editor
            if command -v nano &> /dev/null; then
                nano .env
            elif command -v vim &> /dev/null; then
                vim .env
            elif command -v vi &> /dev/null; then
                vi .env
            else
                echo "No suitable editor found. Please edit .env manually."
            fi
        fi
    else
        echo -e "${YELLOW}⚠ .env.example not found, creating basic .env${NC}"
        cat > .env << EOF
# OpenAI API key for cloud models (optional)
OPENAI_API_KEY=

# Azure OpenAI (optional)
AZURE_OPENAI_API_KEY=
AZURE_OPENAI_ENDPOINT=

# xAI Grok (optional)
XAI_API_KEY=

# MongoDB connection (for AI Girlfriend chatbot)
MONGO_URI=mongodb://localhost:27017/
EOF
        echo -e "${GREEN}✓ Created basic .env file${NC}"
    fi
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

echo ""
echo "Step 4: Creating necessary directories..."
echo ""

# Create models directory
mkdir -p models
echo -e "${GREEN}✓ Created models directory${NC}"

echo ""
echo "=========================================="
echo "Setup complete!"
echo "=========================================="
echo ""
echo -e "${GREEN}✓ All dependencies installed${NC}"
echo -e "${GREEN}✓ Environment configured${NC}"
echo -e "${GREEN}✓ Directories created${NC}"
echo ""
echo "Next steps:"
echo "  1. Review and update .env with your API keys (if using cloud models)"
echo "  2. Run the application:"
echo "     ${GREEN}streamlit run app.py${NC}"
echo ""
echo "For Docker deployment:"
echo "     ${GREEN}docker-compose up -d${NC}"
echo ""
echo "For more information, see:"
echo "  - README.md - Basic usage"
echo "  - DEPLOYMENT_GUIDE.md - Deployment options"
echo "  - WEB_DEPLOYMENT.md - Web deployment"
echo "  - SECURITY_ADVISORY.md - Security best practices"
echo ""
echo "Enjoy your local NSFW model router!"
echo ""
