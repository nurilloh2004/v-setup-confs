# Dockerfile examples

How to dockerize our applications. 

### Fist step create Dockerfile and choose any image you want to use

```bash
# Image name from Dockerhub https://hub.docker.com
FROM python:latest  # or any version. python:3.10
```

### COPY files from your application root directory to container 

```bash

# Using COPY command
COPY ./example.txt /home/app # This command copy your exmaple.txt file inside of a docker continer's /home/app directory

# Copy all of them
COPY .  /home/app # `.` is a full of resource from your repository folder 
```

### Define working directory

```bash

# Working Directory
WORKDIR /home/app # This means - after this line, if your write commands or create something. It runs in this directory not root 
```

### Running commands inside of comtainer

```bash
RUN python manage.py migrate  # You can run any of commands 
```

### CMD 

```bash

# Run your application after  all steps
CMD ['python', 'manage.py', 'runserver']
```

### Entrypoint

```bash

ENTRYPOINT ['ScriptFileName.sh'] # Run multiple scritps end of steps
```



## Example provides instructions for writing a Dockerfile for a microservice written in the nodejs programming language.
```bash
# Step 1.
## Specify a base image. In this case, the node:14.17.1-alpine image is used as the base image for building the application:


FROM node:14.17.1-alpine
# Step 2.
## Create a working directory inside the container and set it as the working directory:
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Step 3.
## Copy the package.json and package-lock.json files (if any) inside the container:
COPY package*.json ./
# Step 4.
## Install dependencies:
RUN npm install
# Step 5.
## Copy all other project files inside the container:
COPY . .

# Step 6.
## Specify the port that will be open in the container:
EXPOSE 80
# Step 7.
## Specify the command that will be executed when the container starts:

CMD ["npm", "start"]

# The entire Dockerfile will look like this:

FROM node:14.17.1-alpine

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 80

CMD ["npm", "start"]