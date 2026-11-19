# 🚀 Azure DevOps & GitHub Actions Enterprise CI/CD Pipelines

[![Azure Pipelines](https://img.shields.io/badge/Azure_Pipelines-0078D4?style=for-the-badge&logo=azure-devops&logoColor=white)](https://azure.microsoft.com/en-us/products/devops/pipelines/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Azure Key Vault](https://img.shields.io/badge/Azure_Key_Vault-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/en-us/products/key-vault/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Enterprise-grade, modular CI/CD blueprints for **Azure DevOps** and **GitHub Actions**. Designed with modern **DevSecOps**, **Azure Key Vault Secrets Injection**, **Reusable Variable & Stage Templates**, and **Multi-Stage Approval Gates**.

---

## 🏛️ Pipeline Architecture & Directory Structure

```
azure-devops-and-github-actions-pipelines/
├── sample-app/                               # Production Node.js Microservice
│   ├── src/index.js                          # /healthz, /ready, /metrics endpoints & SIGTERM handling
│   ├── Dockerfile                            # Multi-stage non-root hardened container build
│   └── package.json
│
├── charts/app/                               # Production Helm Chart
│   ├── Chart.yaml
│   ├── values.yaml                           # Resource limits, HPA, and securityContext
│   └── templates/                            # deployment.yaml, service.yaml, hpa.yaml
│
├── azure-pipelines/                          # Enterprise Azure DevOps Architecture
│   ├── azure-pipelines-enterprise-app.yml    # Master multi-stage pipeline orchestrator
│   ├── azure-pipelines-terraform.yml         # Multi-stage Terraform pipeline with plan gates
│   ├── azure-pipelines-appservice.yml        # WebApp build and blue/green slot swap
│   ├── variables/
│   │   ├── vars-common.yml                   # Common reusable pipeline variables
│   │   ├── vars-dev.yml                      # Dev environment variables & KV target
│   │   └── vars-prod.yml                     # Prod environment variables & KV target
│   └── templates/
│       ├── keyvault-secrets-step.yml         # AzureKeyVault@2 task template (auto-masked secrets)
│       ├── stages-build-test.yml             # Build, unit test & container scan stage
│       ├── stages-deploy.yml                 # Deployment stage with Key Vault & health checks
│       └── security-scan.yml                 # Gitleaks & Trivy security scanning
│
├── .github/workflows/                        # GitHub Actions CI/CD Workflows
│   ├── deploy-with-keyvault.yml              # Azure OIDC + Key Vault secret retrieval
│   ├── terraform-ci-cd.yml                   # Lint, tfsec, PR plan comments & auto-apply
│   ├── docker-build-push-acr.yml             # Docker buildx, Trivy scan & ACR push
│   └── deploy-aks-helm.yml                   # Helm deployment with rollout status check
│
├── scripts/
│   └── setup-azure-oidc-federation.ps1       # Automated passwordless OIDC trust setup
└── README.md
```

---

## 🔐 1. Azure Key Vault Integration

Never store database connection strings, API tokens, or certificates in Git repositories or plaintext variables!

### Azure DevOps (`AzureKeyVault@2`):
```yaml
- task: AzureKeyVault@2
  displayName: 'Download Secrets from Key Vault'
  inputs:
    azureSubscription: '$(azureServiceConnection)'
    KeyVaultName: '$(keyVaultName)'
    SecretsFilter: 'DbConnectionString, ApiKey, TlsCertificate'
```
*All retrieved secrets are automatically masked by the agent and cannot be leaked into build logs.*

### GitHub Actions (`azure/get-keyvault-secrets@v1`):
```yaml
- name: Fetch Secrets from Azure Key Vault
  uses: azure/get-keyvault-secrets@v1
  with:
    keyvault: "kv-cloud-prod-eastus"
    secrets: 'DbConnectionString, ApiKey'
  id: keyvault-secrets
```

---

## 📋 2. Variable Templates Architecture

Separate environment configurations cleanly into reusable YAML templates:
- **`vars-common.yml`**: Shared configuration across all pipelines.
- **`vars-dev.yml`**: Points to dev resource groups, dev Key Vault, and dev AKS cluster.
- **`vars-prod.yml`**: Points to production resources protected by manual approval gates.

---

## 🚀 3. Multi-Stage Approval Release Gates

The master pipeline (`azure-pipelines-enterprise-app.yml`) implements true enterprise release governance:
1. **Stage 1 (Build & Scan)**: Tests code, scans for secrets with Gitleaks, scans container vulnerabilities with Trivy, pushes image to ACR.
2. **Stage 2 (Deploy Dev)**: Ingests dev Key Vault secrets and deploys to `development` namespace.
3. **Stage 3 (Deploy Prod)**: Requires designated approver sign-off, checks business hours, retrieves prod Key Vault secrets, and performs atomic rollout.

---

## 👤 Author

Crafted by **Faraz Ahmed** ([@farazahmedy](https://github.com/farazahmedy)).
Contributions and PRs are welcome!
