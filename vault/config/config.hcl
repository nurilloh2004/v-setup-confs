# Full configuration options can be found at https://www.vaultproject.io/docs/configuration

ui = true

# Cluster address must be set if you use raft stoge
cluster_addr = "http://127.0.0.1:8201"

# Api address
api_addr = "http://127.0.0.1:8200"

#mlock = true
disable_mlock = true
disable_cache = true

# Storage type
storage "raft" {
        path = "/<path_to_storage_file>/"
        node_id = "node_id"
}

# HTTPS listener
listener "tcp" {
  address       = "127.0.0.1:8200"
  tls_disable   = 1
}



# Enterprise license_path
# This will be required for enterprise as of v1.8
#license_path = "/etc/vault.d/vault.hclic"



# Example AWS KMS auto unseal
#seal "awskms" {
#  region = "us-east-1"
#  kms_key_id = "REPLACE-ME"
#}

