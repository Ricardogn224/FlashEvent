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

func AnswerInvitation(db *gorm.DB) http.HandlerFunc {
	MigrateParticipant(db)
	return func(w http.ResponseWriter, r *http.Request) {
		var invitationAnswer models.InvitationAnswer
		if err := json.NewDecoder(r.Body).Decode(&invitationAnswer); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Validate that the participant exists
		var participant models.Participant
		if err := db.Where("id = ?", invitationAnswer.ParticipantID).First(&participant).Error; err != nil {
			http.Error(w, "Participant not found", http.StatusNotFound)
			return
		}

		// Update the participant's response and active status
		participant.Response = true
		participant.Active = invitationAnswer.Active

		// Save the changes to the database
		if err := db.Save(&participant).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(participant)
	}
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

func AddParticipant(db *gorm.DB) http.HandlerFunc {
	MigrateParticipant(db)
	return func(w http.ResponseWriter, r *http.Request) {
		var participantAdd models.ParticipantAdd
		if err := json.NewDecoder(r.Body).Decode(&participantAdd); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Validate that the user exists
		var user models.User
		if err := db.Where("email = ?", participantAdd.Email).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Validate that the event exists
		var event models.Event
		if err := db.First(&event, participantAdd.EventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		// Create a new Participant instance
		participant := models.Participant{
			UserID:  user.ID,
			EventID: event.ID,
		}

		// Save the new Participant to the database
		if err := db.Create(&participant).Error; err != nil {
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
		if err := db.Where("event_id = ? AND active = ? AND response = ?", eventID, true, true).Find(&participants).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		// Respond with the retrieved participants
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(participants)
	}
}

// GetInvitationsByUser retrieves all participant items where the user ID matches the provided parameter and response is true
func GetInvitationsByUser(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)
		email := params["email"]

		var user models.User
		if err := db.Where("email = ?", email).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Fetch all participants with the given user ID and response is true
		var participants []models.Participant
		if err := db.Where("user_id = ? AND response = ?", user.ID, false).Find(&participants).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		// Create a slice to hold the invitations
		var invitations []models.Invitation
		// Iterate over the participants and create invitations
		for _, participant := range participants {
			var event models.Event
			if err := db.First(&event, participant.EventID).Error; err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				return
			}

			invitation := models.Invitation{
				ParticipantID: participant.ID,
				EventID:       participant.EventID,
				EventName:     event.Name,
				UserID:        participant.UserID,
			}
			invitations = append(invitations, invitation)
		}

		// Respond with the retrieved invitations
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(invitations)
	}
}
