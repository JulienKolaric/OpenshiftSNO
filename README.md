# OpenShift Virtualization — GitOps Lab

Monorepo GitOps pour OpenShift Virtualization et workloads Kubernetes.

## Structure

```
gitops/
├── cluster/                        # Infra partagée (cluster-scoped)
│   └── operators/
│       ├── cnv/                    # OpenShift Virtualization
│       │   ├── base/
│       │   └── overlays/dev/
│       └── openshift-gitops/       # OpenShift GitOps (Argo CD)
│           ├── base/
│           └── overlays/dev/
│
└── namespaces/                     # 1 dossier = 1 namespace K8s
    ├── jko-dev/
    │   ├── base/
    │   │   ├── namespace.yaml
    │   │   └── workloads/
    │   │       ├── kustomization.yaml
    │   │       ├── vm/
    │   │       │   ├── kustomization.yaml
    │   │       │   └── test-fedora.yaml
    │   │       └── containers/
    │   └── overlays/dev/
    │
    └── jko-prod/
        ├── base/
        │   ├── namespace.yaml
        │   └── workloads/        # vm/ et containers/ (vide)
        └── overlays/prod/
```

| Couche | Rôle |
|--------|------|
| `cluster/` | Opérateurs et ressources cluster |
| `namespaces/<ns>/` | Namespace + workloads du tenant |
| `workloads/vm/` | VirtualMachines |
| `workloads/containers/` | Deployments, Services, etc. |

**Nommage :** `jko-dev` / `jko-prod` — suffixe `-dev` ou `-prod`.

## Dev → prod

| GitOps | Namespace | Contenu |
|--------|-----------|---------|
| `namespaces/jko-dev/` | `jko-dev` | Namespace + VM test |
| `namespaces/jko-prod/` | `jko-prod` | Namespace seul (workloads promus depuis dev) |

## Déploiement

```bash
eval $(crc oc-env)

oc apply -k gitops/cluster/operators/cnv/overlays/dev
oc apply -k gitops/cluster/operators/openshift-gitops/overlays/dev
oc apply -k gitops/namespaces/jko-dev/overlays/dev
oc apply -k gitops/namespaces/jko-prod/overlays/prod
```

Prévisualiser :

```bash
oc kustomize gitops/cluster/operators/cnv/overlays/dev
oc kustomize gitops/namespaces/jko-dev/overlays/dev
```

## Ajouter un workload

**VM** — créer `workloads/vm/<nom>.yaml`, puis l'ajouter dans `workloads/vm/kustomization.yaml` :

```yaml
resources:
  - test-fedora.yaml
  - <nouvelle-vm>.yaml
```

**Container** — créer `workloads/containers/<nom>.yaml`, ajouter un `workloads/containers/kustomization.yaml`, puis référencer `containers` dans `workloads/kustomization.yaml`.

## OpenShift GitOps

L'opérateur est installé via `cluster/operators/openshift-gitops/`. L'instance Argo CD par défaut est dans le namespace `openshift-gitops`.

```bash
oc get route openshift-gitops-server -n openshift-gitops
```

Dossiers `bootstrap/` et `argocd/` réservés pour les Applications Argo CD (non configurées).

## Hors GitOps

- `.cursor/` — skills Cursor / Lola
- `.lola/` — cache Lola (gitignored)
