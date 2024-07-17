# FlashEvent

FlashEvent est une plateforme d'événements qui permet aux utilisateurs de créer et de participer à divers événements. Ce projet est divisé en deux parties principales : le frontend et le backend.

## Table des matières

- [Installation](#installation)
- [Configuration](#configuration)
- [Utilisation](#utilisation)
- [Déploiement](#déploiement)
- [Contribuer](#contribuer)
- [Licence](#licence)

## Installation

### Frontend

1. Clonez le dépôt :

    ```bash
    git clone https://github.com/Ricardogn224/FlashEvent.git
    cd FlashEvent/client
    ```


### Backend

1. Clonez le dépôt (si ce n'est pas déjà fait) :

    ```bash
    git clone https://github.com/Ricardogn224/FlashEvent.git
    cd FlashEvent/backend
    ```


## Configuration

### Fichiers de configuration

- `client/.env.local` : Variables d'environnement pour le frontend
- `backend/.env.local` : Variables d'environnement pour le backend

Assurez-vous de configurer ces fichiers avec les valeurs correctes pour votre environnement.

## Utilisation

### Accéder à l'application

- Backend : `http://localhost:8000/swagger/ui`

### API Endpoints



### Tests

Pour exécuter les tests, utilisez la commande suivante :

```bash
go test ./... -v