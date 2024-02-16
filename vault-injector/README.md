# Setup vault injector to K8s with helm

### Command running environment with zsh, Plugins (kubectl, .etc)

### Namespace in server = `vault`

```bash
kubectl create namespace vault
kubens vault
```

### Add hashicorp/vault repo with helm

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
```

## Save hashicorp/vault default values for latest configuring and edit values

```bash
helm show values hashicorp/vault > vault-values.yml
vim vault-values.yml or with vscode
```
## Edit default values, change some vars and 
	#### Set external vault-server address

```bash
externalVaultAddr: https://vault.example.com
```
### Set affinity suitable for cluster
```bash
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/vault
              operator: In
              values:
                - "true"
```

### Disable install vault server:
```bash
server:  enabled: false
```

### Save values file and install helm vault
```bash
helm install vault hashicorp/vault --values vault-values.yml
```

### Edit vault-agent-injector manifest
```bash
k edit deploy vault-agent-injector
```

```bash
        - name: AGENT_INJECT_CPU_REQUEST
          value: 25m
        - name: AGENT_INJECT_CPU_LIMIT
          value: 50m
        - name: AGENT_INJECT_MEM_REQUEST
          value: 32Mi
        - name: AGENT_INJECT_MEM_LIMIT
          value: 64Mi
```

### Move your ns for microservices and create service account

```bash
kubens test-namespace
kubectl create sa vault-auth
```

### On local: Login to vault server: Take token from vault server

```bash
export VAULT_ADDR=https://vault.example.com
vault login
```

## Check secrets in ns vault:

```bash
kubens vault 
kubectl get secret
```

### If there is not vault-token-* secret, than create it

```bash
cat > vault-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: vault-token-g955r
  annotations:
    kubernetes.io/service-account.name: vault
type: kubernetes.io/service-account-token
EOF
```

### Apply secret:

```bash
kubectl apply -f vault-secret.yaml
```

### Get nesessaty variables

```bash
KUBE_HOST=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')
VAULT_HELM_SECRET_NAME=$(kubectl get -n vault secrets --output=json | jq -r '.items[].metadata | select(.name|startswith("vault-token-")).name')
TOKEN_REVIEW_JWT=$(kubectl get -n vault secret $VAULT_HELM_SECRET_NAME --output='go-template={{ .data.token }}' | base64 --decode)
KUBE_CA_CERT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)

```

## You can review all variables with echo command
#### Create auth method in vault by Vault server API. We can see this methods in UI of vault: Access → Auth Methods. (An example has written for ucode project)

```bash
vault auth enable -path=kubernetes-ucode kubernetes
```

### Create config for just created auth method by Vault server API

```bash
vault write auth/kubernetes-udevs/config \
token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
kubernetes_host="$KUBE_HOST" \
kubernetes_ca_cert="$KUBE_CA_CERT" \
issuer="https://kubernetes.default.svc.cluster.local"
```

### Create Policy for Project under just created auth method by Vault server API

```bash
vault policy write udevs-test - <<EOF
path "secret/data/k8s/udevs-test/*" {
  capabilities = ["read"]
}
```

### Create Role for Project under just created auth method and bind Policy by Vault server API

```bash
vault write auth/kubernetes-udevs/role/udevs-test \
bound_service_account_names=vault-auth \
bound_service_account_namespaces=test \
policies=udevs-test \
ttl=24h
```
### You must add annotations to you project: Manifest:

```bash
apiVersion: v1
kind: Pod
metadata:
  name: devwebapp-with-annotations
  labels:
    app: devwebapp-with-annotations
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/auth-path: "auth/kubernetes-udevs"
    vault.hashicorp.com/agent-inject-secret-.env: "secret/data/k8s/invan-dev/invan-auth-service"
    vault.hashicorp.com/secret-volume-path-.env: "/app"
    vault.hashicorp.com/role: "invan-dev"
    vault.hashicorp.com/agent-inject-template-.env: |
      {{- with secret "secret/data/k8s/invan-dev/invan-auth-service" -}}
      {{- range $key, $value := .Data.data }}
      {{ $key }}: {{ $value }}
      {{- end }}
      {{ end -}}
      {{- with secret "secret/data/k8s/invan-dev/postgres" -}}
      {{- range $key, $value := .Data.data }}
      {{ $key }}: {{ $value }}
      {{- end }}
      {{ end -}}
spec:
  serviceAccountName: internal-app
  containers:
    - name: app
      image: burtlo/devwebapp-ruby:k8s
```

## Or you can use Helm:

```bash
serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Annotations to add to the service account
  annotations: {}
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: "vault-auth"

podAnnotations:
  vault.hashicorp.com/agent-inject: "true"
  vault.hashicorp.com/auth-path: "auth/kubernetes-udevs"
  vault.hashicorp.com/agent-inject-secret-.env: "secret/data/k8s/invan-dev/invan-auth-service"
  vault.hashicorp.com/secret-volume-path-.env: "/app"
  vault.hashicorp.com/role: "invan-dev"
  vault.hashicorp.com/agent-inject-template-.env: |
    {{- with secret "secret/data/k8s/invan-dev/invan-auth-service" -}}
    {{- range $key, $value := .Data.data }}
    {{ $key }}: {{ $value }}
    {{- end }}
    {{ end -}}
    {{- with secret "secret/data/k8s/invan-dev/postgres" -}}
    {{- range $key, $value := .Data.data }}
    {{ $key }}: {{ $value }}
    {{- end }}
    {{ end -}}
```

### Check with testing pods with secret that it is working or not

```bash
kubectl get pods -n test-namespace
kubectl get serviceaccount -n test-namespace
kubectl get secrets -n test-namespace
kubectl get pods test-example -o yaml
```

# This is a first type of vault integration with K8s, second type will be another branch of this repository

