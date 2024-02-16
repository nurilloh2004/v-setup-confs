# Setup vault injector to K8s with helm

# Command running environment with zsh, Plugins (kubectl, .etc)

# Namespace in server = `vault`

```bash
kubectl create namespace vault
kubens vault
```

# Add hashicorp/vault repo with helm

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
```

# Save hashicorp/vault default values for latest configuring and edit values

```bash
helm show values hashicorp/vault > vault-values.yml
vim vault-values.yml or with vscode
```


