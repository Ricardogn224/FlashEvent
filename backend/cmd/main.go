package main

import (
	"backend/internal/database"
	"backend/internal/routes"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/zc2638/swag"
	"github.com/zc2638/swag/option"
)

func main() {
	// Connexion à la base de données
	db, err := database.ConnectDB()
	if err != nil {
		log.Fatalf("Error connecting to database: %v", err)
	} else {
		log.Println("Connected to database")
	}

	// Initialisation de l'API Swagger
	api := swag.New(
		option.Title("Swagger Event API"),
	)

	// Création du routeur
	router := mux.NewRouter()

	// Enregistrement des routes
	routes.RegisterRoutes(router, api, db)

	// Démarrage du serveur HTTP
	log.Fatal(http.ListenAndServe(":8080", router))
}
