# Setup Docker swarm 

```bash
# Initialize swarm mode in server
docker swarm init
```

### Commands run with Makefile

```bash
# Up database service in swarm mode 
make example-db-up

# Up your application service in swarm mode
make application-service-up
```

## This commands run with Makefile which you have write all of them one by one

```bash

# Example of Makefile
STACK=your_stack
prod-service-up:
	set -a &&. ./.env && set +a && docker stack deploy --with-registry-auth -c services/docker-compose.yml ${STACK}

prod-postgres-up:
	set -a &&. ./.env && set +a && docker stack deploy --with-registry-auth -c databases/mongodb-compose.yml ${STACK}
```

