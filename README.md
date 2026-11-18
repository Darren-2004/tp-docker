# TP DevOps : Conteneurisation avec Docker et Vagrant

**Architecture cible :** VM Vagrant Ubuntu 22.04 (`192.168.56.10`) hébergeant une stack 3-tiers (`Nginx` -> `API Node.js` -> `PostgreSQL 16`)[cite: 3].

---

## 1. Comparaison des images Docker (Partie 2.3)

| Image | Stratégie | Taille disque (`DISK USAGE`) | Taille contenu (`CONTENT SIZE`) |
| :--- | :--- | :---: | :---: |
| `tp-api:1.0.0` | Multi-stage (`deps` + `runtime` sur `node:20-alpine`) | **200 MB** | **49.2 MB** |
| `tp-api:simple` | Mono-étape (`Dockerfile.simple`) | **212 MB** | **51.4 MB** |

---

## 2. Exécution et validation de la stack (Partie 4)

```bash
docker compose config
docker compose up -d --build
docker compose ps