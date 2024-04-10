package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq" // Import du pilote PostgreSQL

	"flashEvent/pkg/db"
	"flashEvent/pkg/handlers"

	httpSwagger "github.com/swaggo/http-swagger"
)

// @title Article REST API
// @version 1.0
// @description API de gestion des articles
// @host localhost:8080
// @BasePath /
func main() {
	DB := db.Connect()
	db.CreateTable(DB)
	defer db.CloseConnection(DB)

	h := handlers.New(DB)

	// Création d'un routeur mux
	myRouter := mux.NewRouter().StrictSlash(true)

	// Définition des endpoints de l'API avec les handlers correspondants
	myRouter.HandleFunc("/", homePage)
	myRouter.HandleFunc("/articles", h.GetAllArticles).Methods(http.MethodGet)
	myRouter.HandleFunc("/articles/{id}", h.GetArticle).Methods(http.MethodGet)
	myRouter.HandleFunc("/articles", h.AddArticle).Methods(http.MethodPost)
	myRouter.HandleFunc("/articles/{id}", h.UpdateArticle).Methods(http.MethodPut)
	myRouter.HandleFunc("/articles/{id}", h.DeleteArticle).Methods(http.MethodDelete)

	// Route pour servir la documentation Swagger
	myRouter.PathPrefix("/swagger/").Handler(httpSwagger.Handler(
		httpSwagger.URL("/swagger/doc.json"), // Spécifiez le chemin où se trouve le fichier JSON de Swagger
	))

	log.Fatal(http.ListenAndServe(":8080", myRouter))
	fmt.Println("Écoute sur le port 8080")
}

func homePage(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Bienvenue sur l'API REST d'Article!")
	fmt.Println("API REST d'Article")
}
