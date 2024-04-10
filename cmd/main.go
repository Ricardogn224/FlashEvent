package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq" // Import PostgreSQL driver

	"flashEvent/pkg/db"
	"flashEvent/pkg/handlers"

	httpSwagger "github.com/swaggo/http-swagger"
)

// @title Article REST API
// @version 1.0
// @description API for managing articles
// @host localhost:8080
// @BasePath /
func main() {
	DB := db.Connect()
	db.CreateTable(DB)
	defer db.CloseConnection(DB)

	h := handlers.New(DB)

	myRouter := mux.NewRouter().StrictSlash(true)

	// Home page route
	// @Summary Home page
	// @Description Welcome page of the Article REST API
	// @Router / [get]
	myRouter.HandleFunc("/", homePage)

	// Get all articles route
	// @Summary Get all articles
	// @Description Retrieves a list of all articles
	// @Router /articles [get]
	myRouter.HandleFunc("/articles", h.GetAllArticles).Methods(http.MethodGet)

	// Get an article by ID route
	// @Summary Get an article by ID
	// @Description Retrieves a specific article by its ID
	// @Param id path int true "Article ID"
	// @Router /articles/{id} [get]
	myRouter.HandleFunc("/articles/{id}", h.GetArticle).Methods(http.MethodGet)

	// Add an article route
	// @Summary Add an article
	// @Description Adds a new article to the database
	// @Router /articles [post]
	myRouter.HandleFunc("/articles", h.AddArticle).Methods(http.MethodPost)

	// Update an article route
	// @Summary Update an existing article
	// @Description Updates an existing article by its ID
	// @Param id path int true "Article ID"
	// @Router /articles/{id} [put]
	myRouter.HandleFunc("/articles/{id}", h.UpdateArticle).Methods(http.MethodPut)

	// Delete an article route
	// @Summary Delete an article
	// @Description Deletes an existing article by its ID
	// @Param id path int true "Article ID"
	// @Router /articles/{id} [delete]
	myRouter.HandleFunc("/articles/{id}", h.DeleteArticle).Methods(http.MethodDelete)

	// Serve Swagger documentation
	myRouter.PathPrefix("/swagger/").Handler(httpSwagger.Handler(
		httpSwagger.URL("/swagger/doc.json"), // Specify the path to the Swagger JSON file
	))

	log.Fatal(http.ListenAndServe(":8080", myRouter))
	fmt.Println("Listening on port 8080")
}

func homePage(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Welcome to the Article REST API!")
	fmt.Println("Article REST API")
}
