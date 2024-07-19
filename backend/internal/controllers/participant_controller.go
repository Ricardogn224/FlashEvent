package controllers

import (
	"backend/internal/database"
	"backend/internal/models"
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

// AddParticipant ajoute un participant à un événement
func AddParticipant(db *gorm.DB) http.HandlerFunc {
	database.MigrateParticipant(db)
	return func(w http.ResponseWriter, r *http.Request) {
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		if user.Role == "AdminEvent" {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		var participantAdd models.ParticipantAdd
		if err := json.NewDecoder(r.Body).Decode(&participantAdd); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Validate that the user exists
		var newUser models.User
		if err := db.Where("email = ?", participantAdd.Email).First(&newUser).Error; err != nil {
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
			UserID:  newUser.ID,
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

func GetParticipantByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateParticipant(db)

		vars := mux.Vars(r)
		id, err := strconv.Atoi(vars["participantId"])
		if err != nil {
			http.Error(w, "Invalid participant ID", http.StatusBadRequest)
			return
		}

		var participant models.Participant
		if err := db.First(&participant, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Participant not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(participant)
	}
}

// DeleteParticipantByID deletes a participant by their ID
func DeleteParticipantByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateParticipant(db)

		vars := mux.Vars(r)
		id, err := strconv.Atoi(vars["participantId"])
		if err != nil {
			http.Error(w, "Invalid participant ID", http.StatusBadRequest)
			return
		}

		// Vérifier les rôles de l'utilisateur
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		var participant models.Participant
		if err := db.First(&participant, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Participant not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		// Only AdminPlatform, AdminEvent, or the participant themselves can delete the participant
		if user.Role == "AdminEvent" {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		if err := db.Delete(&participant).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusNoContent)
	}
}

func UpdateParticipant(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		params := mux.Vars(r)
		participantID := params["participantId"]

		var updatedParticipant models.Participant
		if err := json.NewDecoder(r.Body).Decode(&updatedParticipant); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Find the participant by ID
		var participant models.Participant
		if err := db.First(&participant, participantID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Participant not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		// Only AdminPlatform, AdminEvent, or the participant themselves can update the participant details
		if user.Role == "AdminEvent" {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		// Update the participant fields
		participant.TransportationID = updatedParticipant.TransportationID

		if updatedParticipant.TransportationID == 0 {
			participant.TransportationID = 0
		}

		// Save the updated participant to the database
		if err := db.Save(&participant).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(participant)
	}
}

// UpdateParticipant updates a participant's details
func UpdateParticipantPresent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		params := mux.Vars(r)
		participantID := params["participantId"]

		var updatedParticipant models.Participant
		if err := json.NewDecoder(r.Body).Decode(&updatedParticipant); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Find the participant by ID
		var participant models.Participant
		if err := db.First(&participant, participantID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Participant not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		// Only AdminPlatform, AdminEvent, or the participant themselves can update the participant details
		if user.Role == "AdminEvent" {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		log.Printf("Participant present successfully: %+v", participant.Present)

		// Update the participant fields
		participant.Present = updatedParticipant.Present

		log.Printf("Participant present successfully: %+v", participant.Present)

		// Save the updated participant to the database
		if err := db.Save(&participant).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(participant)
	}
}

// UpdateParticipantContribution updates a participant's details
func UpdateParticipantContribution(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		params := mux.Vars(r)
		participantID := params["participantId"]

		var updatedParticipant models.Participant
		if err := json.NewDecoder(r.Body).Decode(&updatedParticipant); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Find the participant by ID
		var participant models.Participant
		if err := db.First(&participant, participantID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Participant not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		// Only AdminPlatform, AdminEvent, or the participant themselves can update the participant details
		if user.Role == "AdminEvent" {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		// Retrieve the event associated with the participant
		var event models.Event
		if err := db.First(&event, participant.EventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		// Update the cagnotte based on the participant's contribution
		if participant.Contribution != 0 {
			event.Cagnotte = event.Cagnotte - participant.Contribution + updatedParticipant.Contribution
		} else {
			event.Cagnotte = event.Cagnotte + updatedParticipant.Contribution
		}

		log.Printf("Event cagnotte updated successfully: %+v", event.Cagnotte)

		// Update the participant fields
		participant.Contribution = updatedParticipant.Contribution

		// Save the updated participant and event to the database
		if err := db.Save(&participant).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}
		if err := db.Save(&event).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(participant)
	}
}

// GetParticipantByEventId récupère un participant par ID d'événement
func GetParticipantByEventId(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, err.Error(), http.StatusUnauthorized)
			return
		}

		params := mux.Vars(r)
		eventID := params["eventId"]

		// Logging user and eventID
		log.Printf("Fetching participant for user ID: %d and event ID: %s", user.ID, eventID)

		var participant models.Participant
		if err := db.Where("user_id = ? AND event_id = ? AND active = ? AND response = ?", user.ID, eventID, true, true).First(&participant).Error; err != nil {
			// More detailed error logging
			if errors.Is(err, gorm.ErrRecordNotFound) {
				log.Printf("Participant not found for user ID: %d and event ID: %s", user.ID, eventID)
				w.WriteHeader(http.StatusOK)
				json.NewEncoder(w).Encode(models.Participant{})
				return
			} else {
				log.Printf("Database error: %v", err)
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				return
			}
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(participant)
	}
}

// GetParticipantsByEventID retrieves all participants associated with the provided event ID
func GetParticipantsByEventID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)
		eventIDStr := params["eventId"]

		// Convert eventID to uint
		eventIDInt, err := strconv.Atoi(eventIDStr)
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}
		eventID := uint(eventIDInt)

		// Fetch all participants with the given event ID and where active and response are true
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

func GetParticipantsByEventIDWithContribution(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)
		eventID := params["eventId"]

		// Fetch all participants with the given event ID, who are active, have responded, and have a contribution greater than 0
		var participants []models.Participant
		if err := db.Where("event_id = ? AND active = ? AND response = ? AND contribution > ?", eventID, true, true, 0).Find(&participants).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		// Respond with the retrieved participants
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(participants)
	}
}

func GetParticipantsByPresence(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)
		eventID := params["eventId"]

		// Fetch all participants with the given event ID
		var participants []models.Participant
		if err := db.Where("event_id = ? AND active = ? AND response = ? AND present = ?", eventID, true, true, true).Find(&participants).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		// Respond with the retrieved participants
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(participants)
	}
}

// GetParticipantsByTransportationID retrieves all participants associated with the provided transportation ID
func GetParticipantsByTransportationID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)
		transportationId := params["transportationId"]

		// Fetch all participants with the given transportation ID
		var participants []models.Participant
		if err := db.Where("transportation_id = ?", transportationId).Find(&participants).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		// Respond with the retrieved participants
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(participants)
	}
}

// GetParticipantsWithUserByTransportationID retrieves participants with user info linked to a specific transportation ID
func GetParticipantsWithUserByTransportationID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)
		transportationId := params["transportationId"]

		var transportation models.Transportation
		if err := db.First(&transportation, "id = ?", transportationId).Error; err != nil {
			http.Error(w, "Transportation not found", http.StatusNotFound)
			return
		}

		var event models.Event
		if err := db.First(&event, "id = ?", transportation.EventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}
		if !event.TransportActive {
			http.Error(w, "Transportation is not active for this event", http.StatusForbidden)
			return
		}

		// Define a structure to hold the response data
		var results []models.ParticipantWithUser

		// Fetch participants with their user information
		if err := db.Table("participants").
			Select("participants.user_id, participants.event_id, users.email, users.firstname, users.lastname, participants.id as participant_id, participants.transportation_id").
			Joins("JOIN users ON users.id = participants.user_id").
			Where("participants.transportation_id = ?", transportationId).
			Find(&results).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		// Respond with the retrieved participants
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(results)
	}
}
