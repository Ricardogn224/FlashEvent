package main

import (
	"backend/internal/controllers"
	"backend/internal/database"
	"backend/internal/routes"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
	"github.com/zc2638/swag"
	"github.com/zc2638/swag/option"
)

func main() {
	// Charger les variables d'environnement
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

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

	// Ajout du middleware CORS
	router.Use(corsMiddleware)

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

// corsMiddleware ajoute les en-têtes CORS aux réponses HTTP
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.Header().Set("Access-Control-Allow-Credentials", "true")

		// Si la méthode est OPTIONS, on retourne 200 sans aller plus loin
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

