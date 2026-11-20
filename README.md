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


Reponses aux questions de validation (Partie 8)

1) Que deviennent les donnees apres docker compose down suivi de up ? Et avec down -v ?
Avec docker compose down suivi de docker compose up -d, les conteneurs sont supprimes et recrees, mais les donnees sont gardees grace au volume pgdata. Dans mon test, le compteur /visits etait a 6 avant l'arret, et il est passe a 7 juste apres le redemarrage.
Avec docker compose down -v, l'option -v supprime aussi le volume. Toutes les donnees sont effacees et le compteur /visits repart a 1.

2) Pourquoi l'API joint-elle la base avec DB_HOST=db et non localhost ? Quel mecanisme le permet ?
Dans un conteneur, localhost designe le conteneur de l'API lui-meme, et pas celui de la base de donnees. Docker Compose utilise un systeme DNS interne sur son reseau prive : quand l'API demande l'adresse "db", Docker traduit automatiquement ce nom vers l'adresse IP du conteneur PostgreSQL.

3) Difference entre vagrant halt, vagrant suspend et vagrant destroy ?
- vagrant halt : eteint la machine virtuelle proprement, comme quand on eteint un PC. On peut la rallumer plus tard avec vagrant up sans rien perdre.
- vagrant suspend : met la VM en pause en sauvegardant son etat en memoire sur le disque. Elle redemarre tres vite avec vagrant resume, mais ca prend de la place sur le disque.
- vagrant destroy : supprime completement la machine virtuelle et son disque. Si on refait vagrant up apres, il faut tout reinstaller depuis zero.

4) A quoi sert un healthcheck combine a depends_on ? Que se passerait-il sans lui ?
Sans healthcheck, depends_on attend juste que le conteneur soit lance, meme si le logiciel a l'interieur n'est pas encore pret. Comme PostgreSQL met quelques secondes a demarrer, l'API essaierait de se connecter trop tot et planterait avec une erreur de connexion. Le healthcheck permet d'attendre que la base soit vraiment prete avant de lancer l'API (et pareil entre l'API et Nginx).

5) Pourquoi USER node et pas root ? Quel risque evite-t-on ?
Par defaut, un conteneur tourne en root (administrateur). En mettant USER node, on limite les droits du programme. Si quelqu'un trouve une faille dans l'API pour executer des commandes, il n'aura pas les droits administrateur dans le conteneur, ce qui limite les degats.

6) Pourquoi copier package*.json avant le reste du code ?
Docker fonctionne par couches et garde en memoire les etapes qui n'ont pas change. En copiant package.json et en lancant npm install avant de copier server.js, Docker n'a pas besoin de retelecharger tous les modules a chaque fois qu'on modifie juste une ligne dans server.js. Ca rend la construction de l'image beaucoup plus rapide.

7) Volume nomme, bind mount, tmpfs : differences ? Lequel pour pgdata et lequel pour nginx.conf ?
- Volume nomme : c'est un espace de stockage gere directement par Docker sur la machine. On l'utilise pour pgdata parce que c'est fait pour garder les donnees de la base de maniere sure et performante.
- Bind mount : ca relie directement un fichier de notre dossier local vers le conteneur. On l'utilise pour nginx.conf parce que ca permet de modifier facilement le fichier de configuration sur notre machine et de le partager au conteneur.
- tmpfs : c'est un stockage temporaire uniquement en memoire RAM, tout disparait des que le conteneur s'arrete.

8) Pourquoi ne pas publier le port 5432 ? Quel est le role des deux reseaux et de l'option internal ?
On ne publie pas le port 5432 pour eviter que n'importe qui depuis l'exterieur puisse tenter de se connecter directement a la base de donnees. Les deux reseaux servent a isoler les services : Nginx est seulement sur le reseau frontend et ne peut pas voir la base de donnees (quand j'ai teste un ping db depuis Nginx, ca a echoue). L'API fait le lien entre les deux. L'option internal: true sur le reseau backend empeche aussi la base de donnees d'acceder a Internet.

9) Comparez les tailles des deux images (Partie 2). Pourquoi l'ecart est-il faible ici ? Dans quel cas le multi-stage devient-il indispensable (exemple : Angular) ?
L'image multi-stage (tp-api:1.0.0) fait 200 MB (49.2 MB de contenu) et l'image simple fait 212 MB (51.4 MB de contenu). L'ecart est petit ici parce que l'API est tres simple et n'a pas besoin d'etre compilee, on gagne juste la place du cache de npm.
Pour un projet Angular, le multi-stage est indispensable parce qu'il faut installer plein d'outils lourds (Angular CLI, TypeScript, etc.) juste pour compiler le site. Avec le multi-stage, on compile dans une premiere etape lourde, puis on copie uniquement les fichiers finaux (le dossier dist) dans un petit serveur Nginx. On passe ainsi d'une image de plusieurs centaines de Mo a une image finale tres legere sans code source ni outils de compilation.

10) Pourquoi ne jamais versionner .env ? Que contient .env.example ? Quelles sont les limites des variables d'environnement pour transmettre des secrets ?
On ne met jamais .env sur Git parce qu'il contient les vrais mots de passe : si on le pousse, tout le monde peut les voir dans l'historique du projet. Le fichier .env.example sert juste de modele avec de faux mots de passe pour montrer aux autres quelles variables il faut configurer.
La limite des variables d'environnement, c'est qu'elles restent lisibles en clair si quelqu'un fait un docker inspect sur le conteneur, ou elles peuvent apparaitre dans des logs en cas de plantage.

11) Difference entre une image et un conteneur ? Entre docker compose stop, down et restart ?
- Image vs Conteneur : une image est comme un modele ou un installeur fige (en lecture seule), alors qu'un conteneur est l'application en train de tourner a partir de cette image. On peut lancer plusieurs conteneurs a partir d'une meme image.
- docker compose stop : met les conteneurs en pause (les arrete), mais ils existent toujours et on peut les relancer avec start.
- docker compose down : arrete et supprime completement les conteneurs et les reseaux crees (mais garde les volumes sauf si on ajoute -v).
- docker compose restart : redemarre directement les conteneurs existants sans les supprimer ni relire les changements du fichier .env.