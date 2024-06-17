package controllers

import (
	"backend/internal/models"
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

// creation de la table user

func MigrateParticipant(db *gorm.DB) {
	db.AutoMigrate(&models.Participant{})
}

func addParticipantEvent(db *gorm.DB, participant models.Participant) error {
	// Initialiser la table Event si elle n'existe pas
	MigrateParticipant(db)
	// Valider que l'utilisateur et l'événement existent
	var user models.User
	if err := db.First(&user, participant.UserID).Error; err != nil {
		return err
	}
	var event models.Event
	if err := db.First(&event, participant.EventID).Error; err != nil {
		return err
	}

	// Créer le participant
	if err := db.Create(&participant).Error; err != nil {
		return err
	}

	return nil
}

// AddParticipant handles the addition of a new participant to an event
func AddParticipant(db *gorm.DB) http.HandlerFunc {
	MigrateParticipant(db)
	return func(w http.ResponseWriter, r *http.Request) {
		var participant models.Participant
		if err := json.NewDecoder(r.Body).Decode(&participant); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Validate that the user and event exist
		var user models.User
		if err := db.First(&user, participant.UserID).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}
		var event models.Event
		if err := db.First(&event, participant.EventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		result := db.Create(&participant)
		if result.Error != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(participant)
	}
}

// GetParticipantsByEventID retrieves all participants associated with the provided event ID
func GetParticipantsByEventID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)
		eventID := params["eventId"]

		// Fetch all participants with the given event ID
		var participants []models.Participant
		if err := db.Where("event_id = ?", eventID).Find(&participants).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		// Respond with the retrieved participants
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(participants)
	}
}
