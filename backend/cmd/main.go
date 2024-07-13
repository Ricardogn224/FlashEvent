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
		option.Description("API documentation for the Event API"),
		option.Version("1.0.0"),
		option.Schemes("http", "https"),
		option.Security("BearerAuth", "read:events"),
		option.SecurityScheme("BearerAuth",
			option.APIKeySecurity("token", "header"),
		),
	)

	// Création du routeur
	router := mux.NewRouter()

	// Enregistrement des routes
	routes.RegisterRoutes(router, api, db)

	// Servir la documentation Swagger
	router.PathPrefix("/swagger/").Handler(http.StripPrefix("/swagger/", api.Handler()))

	// Démarrage du serveur HTTP
	log.Fatal(http.ListenAndServe(":8080", router))
}
