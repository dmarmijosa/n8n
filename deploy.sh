#!/bin/bash

# Script de despliegue de n8n en ArgoCD
set -e

echo "🚀 Desplegando n8n en ArgoCD..."

# Verificar que kubectl esté disponible
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl no está instalado o no está en el PATH"
    exit 1
fi

# Verificar conexión a cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ No se puede conectar al cluster de Kubernetes"
    exit 1
fi

echo "✅ Conexión al cluster verificada"

# Aplicar la aplicación de ArgoCD
echo "📦 Aplicando aplicación de ArgoCD..."
kubectl apply -f argocd/application.yaml

echo "⏳ Esperando que ArgoCD sincronice la aplicación..."
sleep 10

# Verificar el estado de la aplicación
echo "🔍 Verificando estado de la aplicación..."
kubectl get application n8n -n argocd

echo "📊 Estado de los recursos en el namespace n8n:"
kubectl get all -n n8n 2>/dev/null || echo "Namespace n8n aún no creado, ArgoCD lo creará automáticamente"

echo ""
echo "✅ Despliegue iniciado!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Verifica el estado en ArgoCD UI"
echo "2. Configura nginx proxy manager apuntando al NodePort 30678"
echo "3. Accede a n8n a través de tu dominio configurado"
echo ""
echo "🔧 Comandos útiles:"
echo "   kubectl get application n8n -n argocd"
echo "   kubectl get all -n n8n"
echo "   kubectl logs -f deployment/n8n -n n8n"
