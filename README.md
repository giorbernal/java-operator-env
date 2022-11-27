# Kubernetes Java Operator Environment (java-operator-env)
This is a sample test to handle a k8s operator with JOSDK and Quarkus

This project is based in the official documentation of [Java Operator SDK](https://javaoperatorsdk.io). Basically we are building a docker container to create and evaluate the whole development process described in this [series of articles](https://developers.redhat.com/articles/2022/02/15/write-kubernetes-java-java-operator-sdk) to write a kubernetes operator by using the Java Operator SDK, from now on JOSDK.

## Minikube

You will need to use a kubernetes instance to test the example. We are using [Minikube](https://minikube.sigs.k8s.io/docs/start/) initiated in a different machine. To connect with Minikube in a different machine it is neccessary in install a reverse proxy in the remote machine. The attached script:
```bash
remote/createReverseProxy.sh
```
allows to do just that. You just need to tune the proper minikube IP. With this proxy you could connect without configuring security in your kubectl config file. So you could use it in local minikube deployment if you wish this purpose.


## Setting the environment

To run this sample code we will need install next:

* Docker
* Java 11 at least
* maven 3.8

We can use next Makefile commands to build and start the environment to run the example.

First, you need to build the image
```bash
make build
```

Then, you will need to create the conteiner, after editing Makefile and setting the vars LOCAL_PATH, for the base projects (operators) folder and KUBE_IP to connect with your kube instance by the reverse proxy (the docker image build a kubectl config without security). Now you can create the image:
```bash
make create
```

From now on you could use *make start*, *make stop*, *make enter* .... , to handle the container.


NOTE: Keep in mind that, since is not possible to run docker in docker in this example, you will need to set the Java and Maven version in your machine as well to run the project

## Sample Operator

We have download the sample proyect described in the indicated series of articles, [exposedapp-rhdblog](https://github.com/halkyonio/exposedapp-rhdblog/tree/part-3) from github and we have included a k8s folder to included next files:

* **kubernetes.yml**: a completed version of the operator .yml, including permissions and image proper location for the test
* **example.yml**: a .yml example to install in the cluster an [hello world example nginx](https://hub.docker.com/r/nginxdemos/hello/) application

To run the operator and the test application we need to follow next steps:

* get into the work operator exposedapp-rhdblog work folder
* compile the code: *mvn clean install* (this will build a docker image as well)
* build container for test: *make docker-build*
* take the image to our minikube instance: *make docker-take*
* install the CRD: *make install* (and *make uninstall* to remove it)
* tune the target operator .yaml with the provided in "k8s" folder
* Deploy the operator: *make deploy* (and *make undeploy* to remove it)
