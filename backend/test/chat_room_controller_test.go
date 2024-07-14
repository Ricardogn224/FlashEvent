// test/chat_room_controller_test.go
package test

import (
	"backend/internal/controllers"
	"backend/internal/database"
	"backend/internal/models"
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
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

func TestAddChatRoom(t *testing.T) {
	db := setupTestDB()

	// Créer un événement pour associer à la salle de chat
	event := models.Event{
		Name: "Test Event",
	}
	db.Create(&event)

	chatRoom := models.ChatRoom{
		EventID: event.ID,
		Name:    "Test Chat Room",
	}
	jsonChatRoom, _ := json.Marshal(chatRoom)

	req, _ := http.NewRequest("POST", "/chatrooms", bytes.NewBuffer(jsonChatRoom))
	rr := httptest.NewRecorder()
	handler := controllers.AddChatRoom(db)
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusCreated, rr.Code)
}

func TestAddChatRoomInvalidPayload(t *testing.T) {
	db := setupTestDB()

	invalidPayload := []byte(`{"invalid": "data"}`)

	req, _ := http.NewRequest("POST", "/chatrooms", bytes.NewBuffer(invalidPayload))
	rr := httptest.NewRecorder()
	handler := controllers.AddChatRoom(db)
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

func TestGetChatRooms(t *testing.T) {
	db := setupTestDB()

	// Créer un événement pour associer à la salle de chat
	event := models.Event{
		Name: "Test Event",
	}
	db.Create(&event)

	// Créer des salles de chat pour cet événement
	chatRoom1 := models.ChatRoom{
		EventID: event.ID,
		Name:    "Test Chat Room 1",
	}
	chatRoom2 := models.ChatRoom{
		EventID: event.ID,
		Name:    "Test Chat Room 2",
	}
	db.Create(&chatRoom1)
	db.Create(&chatRoom2)

	req, _ := http.NewRequest("GET", "/events/"+strconv.Itoa(int(event.ID))+"/chatrooms", nil)
	rr := httptest.NewRecorder()
	handler := controllers.GetChatRooms(db)
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)

	var chatRooms []models.ChatRoom
	if err := json.Unmarshal(rr.Body.Bytes(), &chatRooms); err != nil {
		t.Fatalf("Failed to unmarshal response: %v", err)
	}

	assert.Equal(t, 2, len(chatRooms))
	assert.Equal(t, "Test Chat Room 1", chatRooms[0].Name)
	assert.Equal(t, "Test Chat Room 2", chatRooms[1].Name)
}

func TestGetChatRoomsInvalidEventID(t *testing.T) {
	db := setupTestDB()

	req, _ := http.NewRequest("GET", "/events/invalid/chatrooms", nil)
	rr := httptest.NewRecorder()
	handler := controllers.GetChatRooms(db)
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
}
