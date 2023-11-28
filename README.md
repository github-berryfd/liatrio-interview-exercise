# Liatrio Interview Exercise

## Goals
The goal of this project is to cover a few key pillars.
1. Create webservice that exposes a REST endpoint.
2. The endpoint should respond with a JSON payload with a static message and timestamp.
3. A Single command to run
4. Testing
5. The application must be deployed on a Kubernetes cluster


## Resources
Project Structure
https://github.com/golang-standards/project-layout

Project 
https://travisjeffery.com/b/2019/11/i-ll-take-pkg-over-internal/
## Deployment Instructions
docker build -t liatrio-exercise -f .\deployment\docker\Dockerfile .

docker push berryfd/liatrio-webservice:0.1.0

docker tag liatrio-webservice berryfd/liatrio-webserivce:0.1.0

kubectl apply -f .\deployment\kube\deployment.yaml
/health