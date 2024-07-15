// test/user_controller_test.go
package test

import (
	"backend/internal/controllers"
	"backend/internal/database"
	"backend/internal/models"
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func setupTestDB() *gorm.DB {
	db, err := gorm.Open(sqlite.Open("file::memory:?cache=shared"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	database.MigrateAll(db)
	return db
}

func TestRegisterUser(t *testing.T) {
	db := setupTestDB()

	user := models.User{
		Email:     "test@example.com",
		Firstname: "Test",
		Lastname:  "User",
		Password:  "password123",
	}
	jsonUser, _ := json.Marshal(user)

	req, _ := http.NewRequest("POST", "/register", bytes.NewBuffer(jsonUser))
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(controllers.RegisterUser(db))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusCreated, rr.Code)

	var createdUser models.User
	db.Where("email = ?", user.Email).First(&createdUser)
	assert.Equal(t, user.Email, createdUser.Email)
}

func TestLoginUser(t *testing.T) {
	db := setupTestDB()

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	user := models.User{
		Email:    "test@example.com",
		Password: string(hashedPassword),
	}
	db.Create(&user)

	loginDetails := models.User{
		Email:    "test@example.com",
		Password: "password123",
	}
	jsonLogin, _ := json.Marshal(loginDetails)

	req, _ := http.NewRequest("POST", "/login", bytes.NewBuffer(jsonLogin))
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(controllers.LoginUser(db))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestForgotPassword(t *testing.T) {
	db := setupTestDB()

	user := models.User{
		Email: "test@example.com",
	}
	db.Create(&user)

	reqBody := map[string]string{"email": "test@example.com"}
	jsonReq, _ := json.Marshal(reqBody)

	req, _ := http.NewRequest("POST", "/forgot-password", bytes.NewBuffer(jsonReq))
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(controllers.ForgotPassword(db))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestResetPassword(t *testing.T) {
	db := setupTestDB()

	user := models.User{
		Email: "test@example.com",
	}
	db.Create(&user)

	otp := "123456"
	controllers.OTPStore[user.Email] = otp

	reqBody := map[string]string{
		"email":        "test@example.com",
		"otp":          otp,
		"new_password": "newpassword123",
	}
	jsonReq, _ := json.Marshal(reqBody)

	req, _ := http.NewRequest("POST", "/reset-password", bytes.NewBuffer(jsonReq))
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(controllers.ResetPassword(db))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}
