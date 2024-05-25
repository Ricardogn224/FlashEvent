package controllers

import (
	"backend/internal/models"
	"encoding/json"
	"net/http"

	"gorm.io/gorm"
)

// creation de la table user

func MigrateParticipant(db *gorm.DB) {
	db.AutoMigrate(&User{})
}

// AddParticipant handles the addition of a new participant to an event
func AddParticipant(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var participant models.Participant
		if err := json.NewDecoder(r.Body).Decode(&participant); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Validate that the user and event exist
		var user User
		if err := db.First(&user, participant.UserID).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}
		var event Event
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
