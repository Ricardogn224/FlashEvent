// test/chat_controller_test.go
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
	"time"

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

func getTokenForUser(user models.User) string {
	// Generate a JWT token for testing (you might need to use a real token generator)
	return "Bearer your_generated_token"
}

func TestSendMessage(t *testing.T) {
	db := setupTestDB()

	user := models.User{
		Email:    "test@example.com",
		Password: "password123",
		Role:     "User",
	}
	db.Create(&user)

	chatRoom := models.ChatRoom{
		Name:    "Test Chat Room",
		EventID: 1,
	}
	db.Create(&chatRoom)

	message := models.MessageAdd{
		Email:   "test@example.com",
		Content: "Hello, this is a test message",
	}
	jsonMessage, _ := json.Marshal(message)

	req, _ := http.NewRequest("POST", "/chatrooms/1/messages", bytes.NewBuffer(jsonMessage))
	req.Header.Set("Authorization", getTokenForUser(user))
	rr := httptest.NewRecorder()
	handler := controllers.AuthMiddleware(http.HandlerFunc(controllers.SendMessage(db)))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusCreated, rr.Code)
}

func TestGetMessagesByChatRoom(t *testing.T) {
	db := setupTestDB()

	user := models.User{
		Email:    "test@example.com",
		Password: "password123",
		Role:     "User",
	}
	db.Create(&user)

	chatRoom := models.ChatRoom{
		Name:    "Test Chat Room",
		EventID: 1,
	}
	db.Create(&chatRoom)

	message := models.Message{
		UserID:     user.ID,
		ChatRoomID: chatRoom.ID,
		Content:    "Hello, this is a test message",
		Timestamp:  time.Now(),
	}
	db.Create(&message)

	req, _ := http.NewRequest("GET", "/chatrooms/1/messages", nil)
	req.Header.Set("Authorization", getTokenForUser(user))
	rr := httptest.NewRecorder()
	handler := controllers.AuthMiddleware(http.HandlerFunc(controllers.GetMessagesByChatRoom(db)))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestAddMessageToChat(t *testing.T) {
	db := setupTestDB()

	user := models.User{
		Email:    "test@example.com",
		Password: "password123",
		Role:     "User",
	}
	db.Create(&user)

	event := models.Event{
		Name: "Test Event",
	}
	db.Create(&event)

	message := models.MessageAdd{
		Email:   "test@example.com",
		Content: "Hello, this is a test message",
	}
	jsonMessage, _ := json.Marshal(message)

	req, _ := http.NewRequest("POST", "/event/1/chat", bytes.NewBuffer(jsonMessage))
	req.Header.Set("Authorization", getTokenForUser(user))
	rr := httptest.NewRecorder()
	handler := controllers.AuthMiddleware(http.HandlerFunc(controllers.AddMessageToChat(db)))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusCreated, rr.Code)
}
