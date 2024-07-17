// test/participant_controller_test.go
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

func getTokenForUser(user models.User) string {
	// Generate a JWT token for testing (you might need to use a real token generator)
	return "Bearer your_generated_token"
}

func TestAddParticipant(t *testing.T) {
	db := setupTestDB()

	adminUser := models.User{
		Email:    "admin@example.com",
		Password: "password123",
		Role:     "AdminPlatform",
	}
	db.Create(&adminUser)

	event := models.Event{
		Name:      "Test Event",
		CreatedBy: adminUser.ID,
	}
	db.Create(&event)

	participantAdd := models.ParticipantAdd{
		EventID: event.ID,
	}
	jsonParticipant, _ := json.Marshal(participantAdd)

	req, _ := http.NewRequest("POST", "/participants", bytes.NewBuffer(jsonParticipant))
	req.Header.Set("Authorization", getTokenForUser(adminUser))
	rr := httptest.NewRecorder()
	handler := controllers.AuthMiddleware(http.HandlerFunc(controllers.AddParticipant(db)))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusCreated, rr.Code)
}

func TestDeleteParticipant(t *testing.T) {
	db := setupTestDB()

	adminUser := models.User{
		Email:    "admin@example.com",
		Password: "password123",
		Role:     "AdminPlatform",
	}
	db.Create(&adminUser)

	user := models.User{
		Email:    "test@example.com",
		Password: "password123",
		Role:     "User",
	}
	db.Create(&user)

	event := models.Event{
		Name:      "Test Event",
		CreatedBy: adminUser.ID,
	}
	db.Create(&event)

	participant := models.Participant{
		UserID:  user.ID,
		EventID: event.ID,
	}
	db.Create(&participant)

	req, _ := http.NewRequest("DELETE", "/participants/"+strconv.Itoa(int(participant.ID)), nil)
	req.Header.Set("Authorization", getTokenForUser(adminUser))
	rr := httptest.NewRecorder()
	handler := controllers.AuthMiddleware(http.HandlerFunc(controllers.DeleteParticipantByID(db)))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusNoContent, rr.Code)
}

func TestUpdateParticipant(t *testing.T) {
	db := setupTestDB()

	adminUser := models.User{
		Email:    "admin@example.com",
		Password: "password123",
		Role:     "AdminPlatform",
	}
	db.Create(&adminUser)

	user := models.User{
		Email:    "test@example.com",
		Password: "password123",
		Role:     "User",
	}
	db.Create(&user)

	event := models.Event{
		Name:      "Test Event",
		CreatedBy: adminUser.ID,
	}
	db.Create(&event)

	participant := models.Participant{
		UserID:  user.ID,
		EventID: event.ID,
	}
	db.Create(&participant)

	updatedParticipant := models.Participant{
		Active: true,
	}
	jsonParticipant, _ := json.Marshal(updatedParticipant)

	req, _ := http.NewRequest("PATCH", "/participants/"+strconv.Itoa(int(participant.ID)), bytes.NewBuffer(jsonParticipant))
	req.Header.Set("Authorization", getTokenForUser(adminUser))
	rr := httptest.NewRecorder()
	handler := controllers.AuthMiddleware(http.HandlerFunc(controllers.UpdateParticipant(db)))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestGetParticipantByEventId(t *testing.T) {
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

	participant := models.Participant{
		UserID:  user.ID,
		EventID: event.ID,
	}
	db.Create(&participant)

	req, _ := http.NewRequest("GET", "/get-participant/"+strconv.Itoa(int(event.ID)), nil)
	req.Header.Set("Authorization", getTokenForUser(user))
	rr := httptest.NewRecorder()
	handler := controllers.AuthMiddleware(http.HandlerFunc(controllers.GetParticipantByEventId(db)))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestGetParticipantsByEventID(t *testing.T) {
	db := setupTestDB()

	event := models.Event{
		Name: "Test Event",
	}
	db.Create(&event)

	user1 := models.User{
		Email:    "user1@example.com",
		Password: "password123",
	}
	db.Create(&user1)

	user2 := models.User{
		Email:    "user2@example.com",
		Password: "password123",
	}
	db.Create(&user2)

	participant1 := models.Participant{
		UserID:  user1.ID,
		EventID: event.ID,
	}
	db.Create(&participant1)

	participant2 := models.Participant{
		UserID:  user2.ID,
		EventID: event.ID,
	}
	db.Create(&participant2)

	req, _ := http.NewRequest("GET", "/participants-event/"+strconv.Itoa(int(event.ID)), nil)
	rr := httptest.NewRecorder()
	handler := controllers.AuthMiddleware(http.HandlerFunc(controllers.GetParticipantsByEventID(db)))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	var participants []models.Participant
	json.Unmarshal(rr.Body.Bytes(), &participants)
	assert.Equal(t, 2, len(participants))
}
