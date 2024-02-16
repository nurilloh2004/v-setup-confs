auto_auth {
  method {
    type = "approle"
    mount_path = "auth/example"
    config = {
      role_id_file_path = "/vault-agent/credentials/role_id"
      secret_id_file_path = "/vault-agent/credentials/secret_id"
      remove_secret_id_file_after_reading = false
    } 
  }

sink {
  type = "file"
  config = { path = "/vault-agent/credentials/token" }
  } 
}

cache {
  use_auto_auth_token = true
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
}

vault {
  address = "https://vault.example.com"
}
template {
  source = "/vault-agent/templates/recruitment-bot-template.tpl"
  destination = "/secrets/recruitment-bot.env"
}

