# Utilise une image de base Go
FROM golang:latest

# Définit le répertoire de travail
WORKDIR /app

# Copie les fichiers du projet dans le conteneur
COPY ./backend .

# ouvrir le port 8080
EXPOSE 8080

RUN go mod tidy

#télécharge les dépendances
RUN go mod download

# Compile l'application Go
# RUN go run cmd/main.go     --> Supprimer cette ligne

# Compile l'application Go
RUN go build -o cmd/main .

# Définit la commande à exécuter lorsque le conteneur démarre
CMD ["./cmd/main"]
