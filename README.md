# PostgreSQL Deployment Toolkit

Production-ready PostgreSQL deployment with SSL/TLS, automated certificate management, and hardware-optimized configuration.

This specific deployment covers this use case:
- you have access to Azure cloud
- you have access to Azure Keyvault where TLS certificate and key are deployed
- you have access to remote Ubuntu machine over ssh (with passwordless sudo) where postgres container should be deployed

## Features

- 🔒 **SSL/TLS Encryption** - Automatic certificate fetching from Azure Key Vault
- ⚡ **Hardware Auto-Tuning** - Dynamic PostgreSQL config based on CPU/RAM
- 🐳 **Docker Deployment** - Containerized for consistency
- 🤖 **Ansible Automation** - Idempotent remote deployment
- 📊 **Production Monitoring** - pg_stat_statements, query logging

## Quick Start

### Configure environment

```bash
cp .devcontainer/.env.example .devcontainer/.env.prod
# ... update values in .env.prod
# ... update "postStartCommand" in devcontainer.json
# ... Reopen in Container in VS Code
```

### Deploy

```bash
./deploy-postgres.sh
```
