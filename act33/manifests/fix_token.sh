#!/bin/bash
# Script para renovar el token de acceso vencido en AWS Lab
TOKEN_CLEAN=$(aws eks get-token --cluster-name iny1105-ea3-cluster --region us-east-1 --output json | jq -r '.status.token')
kubectl config set-credentials arn:aws:eks:us-east-1:224331140327:cluster/iny1105-ea3-cluster --token=$TOKEN_CLEAN
