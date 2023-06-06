# DevOps Practical 

This README shows how i went about solving the challenge. 

### Docker

I began by creating the docker file and building out the docker image. View Docker file in root of repo.

- Docker image was built utilizing

    ```
    docker buildx build --platform linux/amd64 -t infra_practice .
    ```
    *Docker image was built using platform flag to match the node environment in k8s*
&nbsp; 
- Tests were done locally alongside mongo image pulled from docker hub. Commands ran to ensure it worked were. 

    ```
    docker run -d --network=infra --name=mongo mongo
    ```
    *This was to startup the mongodb container*
    &nbsp;
    ```
    docker run -d --network=infra -e MONGODB_URL=mongodb://mongo:27017/database --name=app -p 8080:3000 infra_practice
    ```
    *This was to startup the app container and connect it to mongodb*
 &nbsp;    
- Image was pushed to docker registry. [View pushed image](https://hub.docker.com/r/1zyik/infra_practice)

### K8s Cluster 

I utilized Amazons EKS for my cluster. And the cluster was created utilizing EKSCTL. View cluster manifest in Kubernetes > create-cluster.yaml

* Created cluster using

```
eksctl create cluster -f create-cluster.yaml --profile Isaac
```
*Note: I utilized t2-micro for the nodes as well as enable KMS encrytion for secrets ensuring security.*

### Helm Charts

I utilized helm to create the app and database charts. 

* Created charts using
    ```
    helm create app
    helm create db
    ```
Charts for app  can be found in Kubernetes > helm-charts > app
&nbsp;
Charts for db can be found in Kubernetes > helm-charts > db
&nbsp;

* Made edits to the values.yaml file for both app and db. 
 &nbsp; 
* Sections changed for app were:
    ```
    image:
    repository: 1zyik/infra_practice
    pullPolicy: IfNotPresent
    # Overrides the image tag whose default is the chart appVersion.
    tag: "latest"
    ```
    ```
    service:
    type: LoadBalancer
    port: 80
    targetPort: 3000
    ```
    *Loadbalancer was used to expose the app for easy access from the web*
    &nbsp;
* Created config map to enable connection to db pod
    ```
    apiVersion: v1
    kind: ConfigMap
    data:
    MONGODB_URL: "mongodb://db:27017/database"
    metadata:
    name: app-env
    namespace: default
    ```
    **
    *Config map ensured connection to the k8s mongo deployment*
    &nbsp;
* Sections changed for db app were:
    ```
    image:
    repository: mongo
    pullPolicy: IfNotPresent
    # Overrides the image tag whose default is the chart appVersion.
    tag: "latest"
    ```
    ```
    service:
    type: ClusterIP
    port: 27017
    targetPort: 27017
    ```
 &nbsp;
 * Deployed charts

 ```
 helm install app ./app -f ./app/values.yaml 
 helm install db ./db -f ./db/values.yaml
 ```
### Images of working application
![alt text](screenshots/Shot%20-%201.png)
![alt text](screenshots/Shot%20-%202.png)
![alt text](screenshots/Shot%20-%203.png)
![alt text](screenshots/Shot%20-%204.png)
![alt text](screenshots/Shot%20-%205.png)
![alt text](screenshots/Shot%20-%206.png)