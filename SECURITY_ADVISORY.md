# Security Advisory

## Critical Security Issue Detected

**Date**: 2025-12-16  
**Severity**: CRITICAL  
**Status**: Immediate Action Required

### Issue Summary

The GitHub issue contains exposed credentials, API keys, and sensitive infrastructure information that should never be shared publicly. This includes:

- API keys for Azure OpenAI, xAI Grok, OpenAI
- Server credentials and IP addresses
- Database passwords and connection strings
- Netcup API credentials

### Immediate Actions Required

**If you are the repository owner, you MUST immediately**:

1. **Rotate ALL exposed credentials**:
   - Azure OpenAI API keys
   - xAI Grok API keys  
   - OpenAI service account keys
   - Ollama API keys
   - Netcup API credentials
   - Database passwords
   - Any other API keys or secrets mentioned in the issue

2. **Review access logs** for all affected services to check for unauthorized access

3. **Update the GitHub issue** to remove all sensitive information

4. **Never commit secrets** to version control - use environment variables and secret management tools instead

### Proper Secrets Management

For legitimate cloud-based AI deployments, use:

#### Environment Variables
```bash
# .env (add to .gitignore)
AZURE_OPENAI_API_KEY=your_key_here
XAI_API_KEY=your_key_here
OPENAI_API_KEY=your_key_here
```

#### Secret Management Tools
- **HashiCorp Vault**: For centralized secrets management
- **Azure Key Vault**: For Azure-based deployments
- **Docker Secrets**: For Docker Swarm deployments
- **Kubernetes Secrets**: For Kubernetes deployments

#### Example: Using Environment Variables
```python
import os
from dotenv import load_dotenv

load_dotenv()

AZURE_API_KEY = os.getenv('AZURE_OPENAI_API_KEY')
# Never hardcode: AZURE_API_KEY = "9CszOf9Ebcd..."
```

### Security Best Practices

1. **Never commit**:
   - API keys or credentials
   - Server passwords or IP addresses
   - Database connection strings with credentials
   - Private SSH keys

2. **Always use**:
   - Environment variables for secrets
   - `.gitignore` to exclude `.env` files
   - Secret management services for production
   - Principle of least privilege for API keys

3. **Repository security**:
   - Enable GitHub secret scanning
   - Use `.env.example` with placeholder values
   - Document required environment variables
   - Regular security audits

### Resources

- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning)
- [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [Azure Key Vault Best Practices](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)

### Responsible Disclosure

If you discover exposed credentials in this repository:
1. Do not use or share them
2. Report immediately to the repository owner
3. Allow time for remediation before public disclosure

---

**Note**: This repository is designed for LOCAL model execution with privacy in mind. For cloud deployments, consult with security professionals and follow industry best practices.
