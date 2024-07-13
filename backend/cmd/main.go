package main

import (
	"backend/internal/controllers"
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
			option.APIKeySecurity("Authorization", "header"),
		),
	)

	// Création du routeur
	router := mux.NewRouter()

	// Enregistrement des routes publiques
	routes.RegisterPublicRoutes(router, api, db)

	// Middleware d'authentification
	authRouter := router.PathPrefix("/").Subrouter()
	authRouter.Use(controllers.AuthMiddleware)

	// Enregistrement des routes authentifiées
	routes.RegisterAuthRoutes(authRouter, api, db)

	// Enregistrement des routes Swagger
	routes.RegisterSwaggerRoutes(router, api)

	// Démarrage du serveur HTTP
	log.Fatal(http.ListenAndServe(":8080", router))
}
