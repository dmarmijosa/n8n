#!/bin/bash

# Script para ejecutar en el servidor via SSH
# Despliegue de n8n en ArgoCD

set -e

echo "🚀 Iniciando despliegue de n8n en ArgoCD..."

# Verificar que estemos en el directorio correcto
if [ ! -f "argocd/application.yaml" ]; then
    echo "❌ No se encuentra argocd/application.yaml"
    echo "Asegúrate de estar en el directorio del repositorio n8n"
    exit 1
fi

# Verificar conexión a Kubernetes
echo "🔍 Verificando conexión a Kubernetes..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ No se puede conectar al cluster de Kubernetes"
    exit 1
fi

echo "✅ Conexión al cluster verificada"

# Verificar que ArgoCD esté instalado
echo "🔍 Verificando instalación de ArgoCD..."
if ! kubectl get namespace argocd &> /dev/null; then
    echo "❌ Namespace argocd no encontrado. ¿Está ArgoCD instalado?"
    exit 1
fi

echo "✅ ArgoCD detectado"

# Aplicar la aplicación
echo "📦 Aplicando aplicación de n8n en ArgoCD..."
kubectl apply -f argocd/application.yaml

if [ $? -eq 0 ]; then
    echo "✅ Aplicación de ArgoCD creada exitosamente!"
else
    echo "❌ Error al crear la aplicación"
    exit 1
fi

# Esperar un momento y verificar el estado
echo "⏳ Esperando sincronización inicial..."
sleep 10

echo "📊 Estado actual de la aplicación:"
kubectl get application n8n -n argocd

echo ""
echo "🎉 ¡Despliegue iniciado exitosamente!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Verifica el estado en ArgoCD UI o con: kubectl get application n8n -n argocd"
echo "2. Una vez sincronizado, verifica los pods: kubectl get pods -n n8n"
echo "3. Configura nginx proxy manager apuntando al NodePort 30678"
echo "4. Accede a n8n en: https://n8n.dmarmijosa.com"
echo ""
echo "🔧 Comandos útiles:"
echo "   kubectl get all -n n8n"
echo "   kubectl logs -f deployment/n8n -n n8n"
echo "   kubectl describe application n8n -n argocd"
