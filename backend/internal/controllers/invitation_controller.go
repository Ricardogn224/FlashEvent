package controllers

import (
	"backend/internal/database"
	"backend/internal/models"
	"encoding/json"
	"net/http"

	"gorm.io/gorm"
)

// GetInvitationsByUser retrieves all participant items where the user ID matches the provided parameter and response is true
func GetInvitationsByUser(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
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

// AnswerInvitation permet de répondre à une invitation
func AnswerInvitation(db *gorm.DB) http.HandlerFunc {
	database.MigrateParticipant(db)
	return func(w http.ResponseWriter, r *http.Request) {
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

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

		// Ensure that only the participant or an admin can respond to the invitation
		if user.ID != participant.UserID && user.Role != "AdminPlatform" && user.Role != "AdminEvent" {
			http.Error(w, "Forbidden", http.StatusForbidden)
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
