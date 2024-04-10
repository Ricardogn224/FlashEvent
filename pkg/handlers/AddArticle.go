package handlers

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"

	"github.com/janirefdez/ArticleRestApi/pkg/models"

	"github.com/google/uuid"
)

// AddArticle adds a new article to the database.
// @Summary Add a new article
// @Description Add a new article to the database
// @Tags articles
// @Accept json
// @Produce json
// @Param request body ArticleRequest true "Article data to be added"
// @Success 201 {string} string "Created"
// @Failure 400 {string} string "Bad Request"
// @Failure 500 {string} string "Internal Server Error"
// @Router /articles [post]
func (h handler) AddArticle(w http.ResponseWriter, r *http.Request) {
	// Read to request body
	defer r.Body.Close()
	body, err := ioutil.ReadAll(r.Body)

	if err != nil {
		log.Fatalln(err)
		w.WriteHeader(500)
		return
	}
	var article models.Article
	json.Unmarshal(body, &article)

	article.Id = (uuid.New()).String()
	queryStmt := `INSERT INTO articles (id,title,description,content) VALUES ($1, $2, $3, $4) RETURNING id;`
	err = h.DB.QueryRow(queryStmt, &article.Id, &article.Title, &article.Desc, &article.Content).Scan(&article.Id)
	if err != nil {
		log.Println("failed to execute query", err)
		w.WriteHeader(500)
		return
	}

	w.Header().Add("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode("Created")

}
