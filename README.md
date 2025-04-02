# Wallos Helm Repository

This repository hosts the Helm chart for [Wallos](https://wallosapp.com/), a subscription management application.

## Repository URL

```
https://kayaman.github.io/wallos
```

## Getting Started

### Add the Helm Repository

```bash
helm repo add wallos https://kayaman.github.io/wallos
helm repo update
```

### Install the Chart

```bash
# Create a namespace for Wallos
kubectl create namespace wallos

# Install the chart with the release name "wallos"
helm install wallos wallos/wallos -n wallos
```

### Upgrading

```bash
helm repo update
helm upgrade wallos wallos/wallos -n wallos
```

### Uninstalling

```bash
helm uninstall wallos -n wallos
```

## Configuration

The following table lists the configurable parameters of the Wallos chart and their default values.

| Parameter                            | Description                  | Default           |
| ------------------------------------ | ---------------------------- | ----------------- |
| `replicaCount`                       | Number of replicas to deploy | `1`               |
| `image.repository`                   | Wallos image repository      | `bellamy/wallos`  |
| `image.tag`                          | Wallos image tag             | `latest`          |
| `image.pullPolicy`                   | Image pull policy            | `IfNotPresent`    |
| `service.type`                       | Service type                 | `ClusterIP`       |
| `service.port`                       | Service port                 | `80`              |
| `service.targetPort`                 | Target port                  | `80`              |
| `env.TZ`                             | Timezone setting             | `America/Toronto` |
| `persistence.enabled`                | Enable persistence using PVC | `true`            |
| `persistence.db.size`                | Database PVC size            | `1Gi`             |
| `persistence.db.storageClassName`    | Database storage class name  | `standard`        |
| `persistence.logos.size`             | Logos PVC size               | `1Gi`             |
| `persistence.logos.storageClassName` | Logos storage class name     | `standard`        |
| `resources.limits.cpu`               | CPU resource limits          | `500m`            |
| `resources.limits.memory`            | Memory resource limits       | `512Mi`           |
| `resources.requests.cpu`             | CPU resource requests        | `100m`            |
| `resources.requests.memory`          | Memory resource requests     | `128Mi`           |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Example:

```bash
helm install wallos wallos/wallos -n wallos \
  --set replicaCount=2 \
  --set persistence.db.size=2Gi
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart:

```bash
helm install wallos wallos/wallos -n wallos -f values.yaml
```

## Accessing Wallos

By default, the application is not exposed externally. To access it, you can use port forwarding:

```bash
kubectl port-forward svc/wallos 8282:80 -n wallos
```

Then access Wallos at http://localhost:8282

For production deployments, you may want to set up an Ingress. Example values for enabling Ingress:

```yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - host: wallos.example.com
      paths:
        - path: /
          pathType: Prefix
```

## Deploying with ArgoCD

If you're using ArgoCD, you can deploy Wallos using the following Application resource:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wallos
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://kayaman.github.io/wallos
    chart: wallos
    targetRevision: 0.1.0
    helm:
      values: |
        replicaCount: 1
        persistence:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: wallos
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

## Persistent Storage

The chart creates two Persistent Volume Claims:

- One for the database (`/var/www/html/db`)
- One for the logos (`/var/www/html/images/uploads/logos`)

Make sure your Kubernetes cluster has a storage provisioner that can handle the `standard` storage class, or specify a different storage class using the `persistence.*.storageClassName` parameters.

## Minikube Notes

When using Minikube, you might need to enable the storage addon:

```bash
minikube addons enable storage-provisioner
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
