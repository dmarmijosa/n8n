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
Las credenciales están configuradas:
```bash
# Usuario: admin
# Password: 1225161930
```

#### Service (`k8s/service.yaml`)
- `nodePort`: Puerto 30678 (o cambia según tu preferencia)

#### Application (`argocd/application.yaml`)
- `repoURL`: Cambia por tu repositorio Git

### 2. Subir a Git Repository

```bash
git init
git add .
git commit -m "Initial n8n deployment configuration"
git remote add origin https://github.com/tu-usuario/n8n-k8s.git
git push -u origin main
```

### 3. Aplicar en ArgoCD

```bash
kubectl apply -f argocd/application.yaml
```

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

## Verificación del Despliegue

### 1. Verificar en ArgoCD
```bash
kubectl get applications -n argocd
kubectl describe application n8n -n argocd
```

### 2. Verificar recursos en Kubernetes
```bash
kubectl get all -n n8n
kubectl get pvc -n n8n
kubectl logs -f deployment/n8n -n n8n
```

### 3. Verificar NodePort
```bash
kubectl get svc n8n-service -n n8n
```

## Acceso a n8n

Una vez configurado nginx proxy manager:
- URL: `https://n8n.dmarmijosa.com`
- Usuario: `admin`
- Password: `1225161930`

## Solución de Problemas

### Logs de n8n
```bash
kubectl logs -f deployment/n8n -n n8n
```

### Estado de ArgoCD
```bash
kubectl get application n8n -n argocd -o yaml
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
