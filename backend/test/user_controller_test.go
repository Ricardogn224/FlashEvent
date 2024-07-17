package test

import (
	"backend/internal/controllers"
	"backend/internal/database"
	"backend/internal/models"
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"golang.org/x/crypto/bcrypt"
)

func TestRegisterUser(t *testing.T) {
	db := SetupTestDB()
	// Ajout du setup de la base de données
	database.MigrateAll(db)

	user := models.User{
		Email:     "test@example.com",
		Password:  "password123",
		Firstname: "John",
		Lastname:  "Doe",
	}
	jsonUser, _ := json.Marshal(user)

	req, _ := http.NewRequest("POST", "/register", bytes.NewBuffer(jsonUser))
	rr := httptest.NewRecorder()
	handler := controllers.RegisterUser(db)
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusCreated, rr.Code)
}

func TestLoginUser(t *testing.T) {
	db := SetupTestDB()
	// Ajout du setup de la base de données
	database.MigrateAll(db)

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	user := models.User{
		Email:     "test@example.com",
		Password:  string(hashedPassword),
		Firstname: "John",
		Lastname:  "Doe",
	}
	db.Create(&user)

	loginUser := models.User{
		Email:    "test@example.com",
		Password: "password123",
	}
	jsonLoginUser, _ := json.Marshal(loginUser)

	req, _ := http.NewRequest("POST", "/login", bytes.NewBuffer(jsonLoginUser))
	rr := httptest.NewRecorder()
	handler := controllers.LoginUser(db)
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}
