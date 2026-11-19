<#
.SYNOPSIS
    Automates configuration of passwordless OpenID Connect (OIDC) between GitHub Actions and Microsoft Azure.

.DESCRIPTION
    Creates an Entra ID Application, Service Principal, Federated Identity Credential,
    and assigns Contributor RBAC role at the target Subscription scope.

.EXAMPLE
    .\setup-azure-oidc-federation.ps1 -GitHubOrg "farazahmedy" -GitHubRepo "azure-terraform-production-infrastructure" -SubscriptionId "00000000-0000-0000-0000-000000000000"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$GitHubOrg,

    [Parameter(Mandatory = $true)]
    [string]$GitHubRepo,

    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId
)

Write-Host "==> Ensuring Azure CLI is logged in..." -ForegroundColor Cyan
az account set --subscription $SubscriptionId
$tenantId = (az account show --query tenantId -o tsv)

$appName = "github-actions-$GitHubRepo"
Write-Host "==> Creating Azure AD Application: $appName" -ForegroundColor Cyan
$appId = (az ad app create --display-name $appName --query appId -o tsv)

Write-Host "==> Creating Service Principal for App ID: $appId" -ForegroundColor Cyan
$spId = (az ad sp create --id $appId --query id -o tsv)

Write-Host "==> Creating Federated Credential for branch 'main'..." -ForegroundColor Cyan
$credentialParams = @{
    name      = "github-actions-main-branch"
    issuer    = "https://token.actions.githubusercontent.com"
    subject   = "repo:${GitHubOrg}/${GitHubRepo}:ref:refs/heads/main"
    audiences = @("api://AzureADTokenExchange")
} | ConvertTo-Json -Compress

az ad app federated-credential create --id $appId --parameters $credentialParams

Write-Host "==> Assigning 'Contributor' role at Subscription scope..." -ForegroundColor Cyan
az role assignment create `
    --role "Contributor" `
    --assignee $appId `
    --scope "/subscriptions/$SubscriptionId"

Write-Host "`n=======================================================" -ForegroundColor Green
Write-Host "✅ Azure OIDC Federation Configured Successfully!" -ForegroundColor Green
Write-Host "Add the following GitHub Secrets to your repository:" -ForegroundColor Yellow
Write-Host "  AZURE_CLIENT_ID       : $appId" -ForegroundColor White
Write-Host "  AZURE_TENANT_ID       : $tenantId" -ForegroundColor White
Write-Host "  AZURE_SUBSCRIPTION_ID : $SubscriptionId" -ForegroundColor White
Write-Host "=======================================================" -ForegroundColor Green
