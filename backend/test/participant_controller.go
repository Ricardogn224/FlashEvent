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

func TestAnswerInvitation(t *testing.T) {
	db := setupTestDB()

	user := models.User{
		Email:    "test@example.com",
		Password: "password123",
		Role:     "user",
	}
	db.Create(&user)

	participant := models.Participant{
		UserID:  user.ID,
		EventID: 1,
	}
	db.Create(&participant)

	invitationAnswer := models.InvitationAnswer{
		ParticipantID: participant.ID,
		Active:        true,
	}
	jsonInvitation, _ := json.Marshal(invitationAnswer)

	req, _ := http.NewRequest("POST", "/answer-invitation", bytes.NewBuffer(jsonInvitation))
	req.Header.Set("Authorization", getTokenForUser(user))
	rr := httptest.NewRecorder()
	handler := controllers.AuthMiddleware(http.HandlerFunc(controllers.AnswerInvitation(db)))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestAddParticipant(t *testing.T) {
	db := setupTestDB()

	admin := models.User{
		Email:    "admin@example.com",
		Password: "password123",
		Role:     "AdminEvent",
	}
	db.Create(&admin)

	event := models.Event{
		Name: "Test Event",
	}
	db.Create(&event)

	participantAdd := models.ParticipantAdd{
		Email:   "test@example.com",
		EventID: event.ID,
	}
	jsonParticipant, _ := json.Marshal(participantAdd)

	req, _ := http.NewRequest("POST", "/participant", bytes.NewBuffer(jsonParticipant))
	req.Header.Set("Authorization", getTokenForUser(admin))
	rr := httptest.NewRecorder()
	handler := controllers.AuthMiddleware(http.HandlerFunc(controllers.AddParticipant(db)))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusCreated, rr.Code)
}

func TestGetParticipantByID(t *testing.T) {
	db := setupTestDB()

	participant := models.Participant{
		UserID:  1,
		EventID: 1,
	}
	db.Create(&participant)

	req, _ := http.NewRequest("GET", "/participant/1", nil)
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(controllers.GetParticipantByID(db))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestDeleteParticipantByID(t *testing.T) {
	db := setupTestDB()

	admin := models.User{
		Email:    "admin@example.com",
		Password: "password123",
		Role:     "AdminEvent",
	}
	db.Create(&admin)

	participant := models.Participant{
		UserID:  admin.ID,
		EventID: 1,
	}
	db.Create(&participant)

	req, _ := http.NewRequest("DELETE", "/participant/1", nil)
	req.Header.Set("Authorization", getTokenForUser(admin))
	rr := httptest.NewRecorder()
	handler := controllers.AuthMiddleware(http.HandlerFunc(controllers.DeleteParticipantByID(db)))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusNoContent, rr.Code)
}

func TestUpdateParticipant(t *testing.T) {
	db := setupTestDB()

	admin := models.User{
		Email:    "admin@example.com",
		Password: "password123",
		Role:     "AdminEvent",
	}
	db.Create(&admin)

	participant := models.Participant{
		UserID:  admin.ID,
		EventID: 1,
	}
	db.Create(&participant)

	updateData := models.Participant{
		TransportationID: 2,
		Active:           true,
	}
	jsonUpdate, _ := json.Marshal(updateData)

	req, _ := http.NewRequest("PATCH", "/participants/1", bytes.NewBuffer(jsonUpdate))
	req.Header.Set("Authorization", getTokenForUser(admin))
	rr := httptest.NewRecorder()
	handler := controllers.AuthMiddleware(http.HandlerFunc(controllers.UpdateParticipant(db)))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestGetParticipantsByEventID(t *testing.T) {
	db := setupTestDB()

	participant := models.Participant{
		UserID:   1,
		EventID:  1,
		Active:   true,
		Response: true,
	}
	db.Create(&participant)

	req, _ := http.NewRequest("GET", "/participants-event/1", nil)
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(controllers.GetParticipantsByEventID(db))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestGetParticipantsByTransportationID(t *testing.T) {
	db := setupTestDB()

	participant := models.Participant{
		UserID:           1,
		TransportationID: 1,
	}
	db.Create(&participant)

	req, _ := http.NewRequest("GET", "/participants-transportation/1", nil)
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(controllers.GetParticipantsByTransportationID(db))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestGetParticipantsWithUserByTransportationID(t *testing.T) {
	db := setupTestDB()

	user := models.User{
		Email:    "test@example.com",
		Password: "password123",
		Role:     "user",
	}
	db.Create(&user)

	event := models.Event{
		Name:            "Test Event",
		TransportActive: true,
	}
	db.Create(&event)

	transportation := models.Transportation{
		EventID: event.ID,
		UserID:  user.ID,
	}
	db.Create(&transportation)

	participant := models.Participant{
		UserID:           user.ID,
		EventID:          event.ID,
		TransportationID: transportation.ID,
	}
	db.Create(&participant)

	req, _ := http.NewRequest("GET", "/participants-transportation-user/1", nil)
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(controllers.GetParticipantsWithUserByTransportationID(db))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}

func TestGetInvitationsByUser(t *testing.T) {
	db := setupTestDB()

	user := models.User{
		Email:    "test@example.com",
		Password: "password123",
		Role:     "user",
	}
	db.Create(&user)

	event := models.Event{
		Name: "Test Event",
	}
	db.Create(&event)

	participant := models.Participant{
		UserID:   user.ID,
		EventID:  event.ID,
		Response: false,
	}
	db.Create(&participant)

	req, _ := http.NewRequest("GET", "/invitations/test@example.com", nil)
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(controllers.GetInvitationsByUser(db))
	handler.ServeHTTP(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
}
