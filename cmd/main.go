package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"flashEvent/db"
	"github.com/janirefdez/ArticleRestApi/pkg/db"
	"github.com/janirefdez/ArticleRestApi/pkg/handlers"


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

	r := gin.Default()

	r.GET("/", homePage)

	h := handlers.New(DB)

	// Articles endpoints
	// @Summary Get all articles
	// @Description Get all articles from the database
	// @Tags articles
	// @Produce json
	// @Success 200 {array} models.Article
	// @Router /articles [get]
	r.GET("/articles", h.GetAllArticles)

	// @Summary Get an article by ID
	// @Description Get an article from the database by its ID
	// @Tags articles
	// @Produce json
	// @Param id path string true "Article ID"
	// @Success 200 {object} models.Article
	// @Failure 404 {string} string "Article not found"
	// @Router /articles/{id} [get]
	r.GET("/articles/{id}", h.GetArticle)

	// @Summary Add a new article
	// @Description Add a new article to the database
	// @Tags articles
	// @Accept json
	// @Produce json
	// @Param request body models.Article true "Article data to be added"
	// @Success 201 {string} string "Created"
	// @Failure 400 {string} string "Bad Request"
	// @Router /articles [post]
	r.POST("/articles", h.AddArticle)

	// @Summary Update an existing article
	// @Description Update an existing article in the database
	// @Tags articles
	// @Accept json
	// @Produce json
	// @Param id path string true "Article ID"
	// @Param request body models.Article true "Updated article data"
	// @Success 200 {string} string "OK"
	// @Failure 400 {string} string "Bad Request"
	// @Failure 404 {string} string "Article not found"
	// @Router /articles/{id} [put]
	r.PUT("/articles/{id}", h.UpdateArticle)

	// @Summary Delete an article
	// @Description Delete an article from the database
	// @Tags articles
	// @Produce json
	// @Param id path string true "Article ID"
	// @Success 200 {string} string "OK"
	// @Failure 404 {string} string "Article not found"
	// @Router /articles/{id} [delete]
	r.DELETE("/articles/{id}", h.DeleteArticle)

	// Swagger UI route
	url := ginSwagger.URL("http://localhost:8080/swagger/doc.json")
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler, url))

	log.Fatal(r.Run(":8080"))
	fmt.Println("Listening on port 8080")
}

// @Summary Home page
// @Description Welcome message for the Article REST API
// @Produce plain
// @Success 200 {string} string "Welcome to the Article REST API!"
// @Router / [get]
func homePage(c *gin.Context) {
	c.String(http.StatusOK, "Welcome to the Article REST API!")
}
