# 🚀 Azure DevOps & GitHub Actions Enterprise CI/CD Pipelines

[![Azure Pipelines](https://img.shields.io/badge/Azure_Pipelines-0078D4?style=for-the-badge&logo=azure-devops&logoColor=white)](https://azure.microsoft.com/en-us/products/devops/pipelines/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Production-ready, battle-tested CI/CD blueprints for **Azure DevOps** and **GitHub Actions**. Designed with modern **DevSecOps**, **Azure Workload Identity Federation (OIDC - passwordless)**, container vulnerability scanning, and multi-stage approval gates.

---

## 📁 Repository Structure

```
azure-devops-and-github-actions-pipelines/
├── .github/workflows/
│   ├── terraform-ci-cd.yml       # IaC validation, tfsec, PR plan & apply
│   ├── docker-build-push-acr.yml # Container build, Trivy scan & ACR push
│   └── deploy-aks-helm.yml       # Helm deployment to AKS cluster
├── azure-pipelines/
│   ├── azure-pipelines-terraform.yml # Multi-stage Azure DevOps pipeline with approval gates
│   └── azure-pipelines-appservice.yml# Build, test & deploy to App Service with slots
├── scripts/
│   └── setup-azure-oidc-federation.ps1 # Automation to configure Azure OIDC trust
└── README.md
```

---

## 🔐 Zero-Trust Authentication: Passwordless Azure OIDC

Traditional CI/CD pipelines store long-lived Client Secrets that expire and risk leakage. These pipelines use **OpenID Connect (OIDC)**:
1. GitHub Actions / Azure DevOps requests a short-lived token.
2. Microsoft Entra ID validates the token against a configured Federated Credential.
3. Azure issues a short-lived access token scoped strictly to the workflow run.

👉 Run `./scripts/setup-azure-oidc-federation.ps1` to configure this in seconds!

---

## 🛠️ Included Pipelines

### 1. GitHub Actions: Terraform CI/CD (`terraform-ci-cd.yml`)
- **Pull Request Trigger**: Runs `terraform fmt -check`, `terraform validate`, security scan with `tfsec`, and posts the `terraform plan` output directly as a comment on the Pull Request.
- **Main Branch Merge Trigger**: Executes `terraform apply -auto-approve` using short-lived Azure OIDC credentials.

### 2. GitHub Actions: Docker Build, Scan & ACR (`docker-build-push-acr.yml`)
- Builds Docker image with multi-stage caching.
- Scans container image for vulnerabilities with Aqua Security **Trivy**. Fails pipeline on `CRITICAL` CVEs.
- Pushes authenticated container image to **Azure Container Registry (ACR)**.

### 3. GitHub Actions: Helm Deployment to AKS (`deploy-aks-helm.yml`)
- Obtains AKS credentials via Azure OIDC.
- Deploys application Helm chart.
- Runs `kubectl rollout status` to verify pod readiness before finalizing release.

### 4. Azure DevOps Multi-Stage Pipeline (`azure-pipelines-terraform.yml`)
- **Stage 1 (Validate)**: Syntax checks and formatting validation.
- **Stage 2 (Plan)**: Generates Terraform execution plan and publishes plan artifact.
- **Stage 3 (Apply - Production)**: Protected by Environment Manual Approval Check and business hour restrictions.

---

## 👤 Author

Maintained by **Faraz Ahmed** ([@farazahmedy](https://github.com/farazahmedy)).
Feel free to open an issue or fork this repository!
