#!/bin/bash
services=$(yq '.project.services | keys' /home/nurilloh/devops/vault/scripts/services.yml | sed 's/- //g')


if [[ "$1" == "main" ]]; then
    PROJECT_NAME=$(yq '.project.name-main' /home/nurilloh/devops/vault/scripts/services.yml)
else
    echo "Invalid argument"
    exit 1
fi

rm -rf /home/nurilloh/devops/vault/templates/*.tpl
echo "auto_auth {
  method {
    type = \"approle\"
    mount_path = \"auth/$PROJECT_NAME\"
    config = {
      role_id_file_path = \"/vault-agent/credentials/role_id\"
      secret_id_file_path = \"/vault-agent/credentials/secret_id\"
      remove_secret_id_file_after_reading = false
    } 
  }

sink {
  type = \"file\"
  config = { path = \"/vault-agent/credentials/token\" }
  } 
}

cache {
  use_auto_auth_token = true
}

listener \"tcp\" {
  address = \"0.0.0.0:8200\"
  tls_disable = true
}

vault {
  address = \"https://vault.example.com\"
}" > /etc/vault-agent/config/vault-agent.hcl
for service in ${services[@]}
do

options=$(yq '.project.services.'$service'.options' /home/nurilloh/devops/vault/scripts/services.yml | sed 's/- //g')

echo "{{- with secret \"secret/data/$PROJECT_NAME/$service\" -}}                                                                              
{{- range \$key, \$value := .Data.data }}                                                                                                            
{{ \$key }}: {{ \$value }}                                                                                                                           
{{- end }}                                                                                                                                         
{{ end -}} " >> /home/nurilloh/devops/vault/templates/$service-template.tpl

  for option in ${options[@]}
  do

echo "{{- with secret \"secret/data/$PROJECT_NAME/$option\" -}}                                                                              
{{- range \$key, \$value := .Data.data }}                                                                                                            
{{ \$key }}: {{ \$value }}                                                                                                                           
{{- end }}                                                                                                                                         
{{ end -}} " >> /home/nurilloh/devops/vault/templates/$service-template.tpl

  done

echo "template {
  source = \"/vault-agent/templates/$service-template.tpl\"
  destination = \"/secrets/$service.env\"
}" >> /home/nurilloh/devops/vault/config/vault-agent.hcl

done
