#!/bin/bash

MINIKUBE_IP=$(minikube ip)
echo $MINIKUBE_IP

echo "$MINIKUBE_IP wallos.local" | sudo tee -a /etc/hosts