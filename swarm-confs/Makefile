STACK=your_stack
prod-service-up:
	set -a &&. ./.env && set +a && docker stack deploy --with-registry-auth -c services/docker-compose.yml ${STACK}

prod-postgres-up:
	set -a &&. ./.env && set +a && docker stack deploy --with-registry-auth -c databases/mongodb-compose.yml ${STACK}