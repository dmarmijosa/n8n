# N8N Deployment en Kubernetes con ArgoCD

Este proyecto despliega n8n en Kubernetes usando ArgoCD con NodePort para integración con nginx proxy manager.

## Estructura del Proyecto

```
n8n/
├── k8s/
│   ├── namespace.yaml      # Namespace de n8n
│   ├── pvc.yaml           # PersistentVolumeClaim para datos
│   ├── configmap.yaml     # Configuración de n8n
│   ├── secret.yaml        # Credenciales y datos sensibles
│   ├── deployment.yaml    # Deployment de n8n
│   ├── service.yaml       # Service con NodePort
│   └── kustomization.yaml # Kustomization para organizar recursos
└── argocd/
    └── application.yaml   # Aplicación de ArgoCD
```

## Pasos para el Despliegue

### 1. Configuración Previa

Antes de desplegar, asegúrate de modificar los siguientes archivos:

#### ConfigMap (`k8s/configmap.yaml`)
- `N8N_HOST`: n8n.dmarmijosa.com
- `WEBHOOK_URL`: https://n8n.dmarmijosa.com/
- `GENERIC_TIMEZONE`: Ajusta tu zona horaria
- `N8N_ENCRYPTION_KEY`: Genera una clave segura

#### Secret (`k8s/secret.yaml`)
Las credenciales están configuradas en el archivo secret.yaml

#### Service (`k8s/service.yaml`)
- `nodePort`: Puerto 30678 (o cambia según tu preferencia)

#### Application (`argocd/application.yaml`)
- `repoURL`: Ya configurado con https://github.com/dmarmijosa/n8n.git

### 2. Subir a Git Repository

Este paso ya está completado. El repositorio está en:
```
https://github.com/dmarmijosa/n8n
```

### 3. Aplicar en ArgoCD (SSH Remoto)

**Conectado via SSH al servidor (MicroK8s):**
```bash
# Clonar el repositorio en el servidor
git clone https://github.com/dmarmijosa/n8n.git
cd n8n

# Hacer ejecutable el script y ejecutar
chmod +x deploy-remote.sh
./deploy-remote.sh
```

**Manualmente:**
```bash
# Aplicar la aplicación de ArgoCD
microk8s kubectl apply -f argocd/application.yaml
```

**Opción alternativa: Através de la UI de ArgoCD**
1. Accede a la interfaz web de ArgoCD en tu servidor
2. Crea una nueva aplicación con estos datos:
   - **Application Name**: `n8n`
   - **Project**: `default`
   - **Repository URL**: `https://github.com/dmarmijosa/n8n.git`
   - **Path**: `k8s`
   - **Cluster URL**: `https://kubernetes.default.svc`
   - **Namespace**: `n8n`

### 4. Configurar nginx proxy manager

En nginx proxy manager, crea un nuevo proxy host:
- **Domain Names**: `n8n.dmarmijosa.com`
- **Scheme**: `http`
- **Forward Hostname/IP**: `IP-de-tu-nodo-k8s`
- **Forward Port**: `30678`
- **Block Common Exploits**: ✓
- **Websockets Support**: ✓

En la pestaña SSL:
- **SSL Certificate**: Selecciona o crea un certificado
- **Force SSL**: ✓
- **HTTP/2 Support**: ✓

## Verificación del Despliegue (Remoto)

### 1. Verificar en ArgoCD UI
- Accede a tu interfaz de ArgoCD
- Busca la aplicación `n8n`
- Verifica que esté sincronizada y sin errores

### 2. Verificar recursos en Kubernetes (si tienes acceso kubectl)
```bash
microk8s kubectl get all -n n8n
microk8s kubectl get pvc -n n8n
microk8s kubectl logs -f deployment/n8n -n n8n
```

### 3. Verificar NodePort
```bash
microk8s kubectl get svc n8n-service -n n8n
```

## Acceso a n8n

Una vez configurado nginx proxy manager:
- URL: `https://n8n.dmarmijosa.com`
- Las credenciales están configuradas en el secret de Kubernetes

## Solución de Problemas

### Logs de n8n
```bash
microk8s kubectl logs -f deployment/n8n -n n8n
```

### Estado de ArgoCD
```bash
microk8s kubectl get application n8n -n argocd -o yaml
```

### Verificar conectividad NodePort
```bash
curl http://IP-NODO:30678/healthz
```

## Personalización

### Cambiar puerto NodePort
Edita `k8s/service.yaml` y cambia el valor de `nodePort`.

### Agregar variables de entorno
Edita `k8s/configmap.yaml` para agregar nuevas configuraciones.

### Configurar base de datos externa
Modifica `k8s/deployment.yaml` para agregar variables de conexión a BD.

## Notas Importantes

1. **Seguridad**: Cambia todas las credenciales por defecto antes del despliegue
2. **Persistencia**: Los datos se almacenan en PVC, asegúrate de tener un storageClass configurado
3. **Backup**: Considera implementar backups regulares del PVC
4. **Monitoreo**: n8n expone métricas en `/metrics` si `N8N_METRICS=true`
