Write-Host "=== Initialisation Vault ===" -ForegroundColor Cyan

# 1. Activer le moteur kv-v2
Write-Host "Activation moteur kv-v2..." -ForegroundColor Yellow
kubectl exec vault-0 -n vault-system -- sh -c "export VAULT_ADDR=http://127.0.0.1:8200 && vault login root-token-banking-2026 > /dev/null && vault secrets enable -path=banking kv-v2 2>/dev/null; echo ok"

# 2. Stocker les secrets
Write-Host "Stockage des secrets..." -ForegroundColor Yellow
kubectl exec vault-0 -n vault-system -- sh -c "export VAULT_ADDR=http://127.0.0.1:8200 && vault login root-token-banking-2026 > /dev/null && vault kv put banking/mysql password=root"
kubectl exec vault-0 -n vault-system -- sh -c "export VAULT_ADDR=http://127.0.0.1:8200 && vault login root-token-banking-2026 > /dev/null && vault kv put banking/gmail host=smtp.gmail.com port=587 username=basmaboulli2003@gmail.com password=zlgziogttpxnxouk"
kubectl exec vault-0 -n vault-system -- sh -c "export VAULT_ADDR=http://127.0.0.1:8200 && vault login root-token-banking-2026 > /dev/null && vault kv put banking/cloudinary cloud-name=none api-key=none api-secret=none"
kubectl exec vault-0 -n vault-system -- sh -c "export VAULT_ADDR=http://127.0.0.1:8200 && vault login root-token-banking-2026 > /dev/null && vault kv put banking/jwt secret=ThisIsTheBankingJwtSecretKey2026"

# 3. Activer auth Kubernetes
Write-Host "Configuration auth Kubernetes..." -ForegroundColor Yellow
kubectl exec vault-0 -n vault-system -- sh -c "export VAULT_ADDR=http://127.0.0.1:8200 && vault login root-token-banking-2026 > /dev/null && vault auth enable kubernetes 2>/dev/null; echo ok"

# 4. *** ETAPE MANQUANTE *** - Configurer avec token_reviewer_jwt
Write-Host "Configuration token reviewer JWT..." -ForegroundColor Red
$TOKEN = kubectl get secret vault-auth-token -n vault-system -o jsonpath='{.data.token}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
kubectl exec vault-0 -n vault-system -- sh -c "export VAULT_ADDR=http://127.0.0.1:8200 && vault login root-token-banking-2026 > /dev/null && vault write auth/kubernetes/config kubernetes_host=https://kubernetes.default.svc:443 token_reviewer_jwt=$TOKEN"

# 5. Créer la policy
Write-Host "Creation policy eso-banking-reader..." -ForegroundColor Yellow
$policy = @"
path "banking/data/*" {
  capabilities = ["read"]
}
path "banking/metadata/*" {
  capabilities = ["read", "list"]
}
"@
$policy | kubectl exec -i vault-0 -n vault-system -- sh -c "cat > /tmp/policy.hcl"
kubectl exec vault-0 -n vault-system -- sh -c "export VAULT_ADDR=http://127.0.0.1:8200 && vault login root-token-banking-2026 > /dev/null && vault policy write eso-banking-reader /tmp/policy.hcl"

# 6. Créer le role
Write-Host "Creation role eso-role..." -ForegroundColor Yellow
kubectl exec vault-0 -n vault-system -- sh -c "export VAULT_ADDR=http://127.0.0.1:8200 && vault login root-token-banking-2026 > /dev/null && vault write auth/kubernetes/role/eso-role bound_service_account_names=eso-vault-sa bound_service_account_namespaces=microservices policies=eso-banking-reader ttl=1h"

Write-Host "`n=== Vault reinitialise avec succes ===" -ForegroundColor Green

# Verification finale
Write-Host "`nVerification token_reviewer_jwt_set :" -ForegroundColor Cyan
kubectl exec vault-0 -n vault-system -- sh -c "export VAULT_ADDR=http://127.0.0.1:8200 && vault login root-token-banking-2026 > /dev/null && vault read auth/kubernetes/config" | findstr token_reviewer_jwt_set

Write-Host "`nSecrets dans Vault :" -ForegroundColor Cyan
kubectl exec vault-0 -n vault-system -- sh -c "export VAULT_ADDR=http://127.0.0.1:8200 && vault login root-token-banking-2026 > /dev/null && vault kv list banking"