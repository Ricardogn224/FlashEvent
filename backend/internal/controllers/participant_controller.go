package controllers

import (
	"backend/internal/config"
	"backend/internal/models"
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
	log "github.com/sirupsen/logrus"
	"gorm.io/gorm"
)

func init() {
	config.SetupLogger()
}

// creation de la table user

func MigrateParticipant(db *gorm.DB) {
	db.AutoMigrate(&models.Participant{})
}

func AnswerInvitation(db *gorm.DB) http.HandlerFunc {
	MigrateParticipant(db)
	return func(w http.ResponseWriter, r *http.Request) {

		log.Info("Answer to invitation request received")

		var invitationAnswer models.InvitationAnswer
		if err := json.NewDecoder(r.Body).Decode(&invitationAnswer); err != nil {
			log.WithFields(log.Fields{
				"error": err,
			}).Error("Error while decoding request data")
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		context := log.WithFields(log.Fields{"participant_id": invitationAnswer.ParticipantID})

		// Validate that the participant exists
		var participant models.Participant
		if err := db.Where("id = ?", invitationAnswer.ParticipantID).First(&participant).Error; err != nil {
			context.Error("Unknown Participant")
			http.Error(w, "Participant not found", http.StatusNotFound)
			return
		}

		// Update the participant's response and active status
		participant.Response = true
		participant.Active = invitationAnswer.Active

		// Save the changes to the database
		if err := db.Save(&participant).Error; err != nil {
			context.Error("Error while updating the invitation iin participant")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(participant); err != nil {
			context.Error("Error occurred while encoding participant to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		context.Info("Successfully responding to invitation with participant data")
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

		log.Info("Add participant request received")

		var participantAdd models.ParticipantAdd
		if err := json.NewDecoder(r.Body).Decode(&participantAdd); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		context := log.WithFields(log.Fields{"event_id": participantAdd.EventID, "email": participantAdd.Email})

		// Validate that the user exists
		var user models.User
		if err := db.Where("email = ?", participantAdd.Email).First(&user).Error; err != nil {
			context.Error("Unknown user")
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Validate that the event exists
		var event models.Event
		if err := db.First(&event, participantAdd.EventID).Error; err != nil {
			context.Error("Unknown event")
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
			context.Error("Error while creating the participant")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		if err := json.NewEncoder(w).Encode(participant); err != nil {
			context.Error("Error occurred while encoding participant to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		context.Info("Successfully adding the participant to event")
	}
}

func GetParticipantByUserId(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		log.Info("Fetching participant by user id")

		params := mux.Vars(r)
		userID := params["userId"]

		context := log.WithFields(log.Fields{"user_id": userID})

		// Fetch all participants with the given event ID
		var participant models.Participant
		if err := db.Where("user_id = ?", userID).First(&participant).Error; err != nil {
			context.Error("Error while retrieving participant")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(participant); err != nil {
			context.Error("Error occurred while encoding participant to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		context.Info("Successfully sent response with participant data")
	}
}

// GetParticipantsByEventID retrieves all participants associated with the provided event ID
func GetParticipantsByEventID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		log.Info("Fetching participants by event id")

		params := mux.Vars(r)
		eventID := params["eventId"]

		context := log.WithFields(log.Fields{"event_id": eventID})

		// Fetch all participants with the given event ID
		var participants []models.Participant
		if err := db.Where("event_id = ? AND active = ? AND response = ?", eventID, true, true).Find(&participants).Error; err != nil {
			context.Error("Probllem occured while retrieving the participants by event")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		log.WithFields(log.Fields{
			"count": len(participants),
		}).Info("Successfully fetched participants from the database")

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(participants); err != nil {
			context.Error("Error occurred while encoding participants to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		context.Info("Successfully sent response with participants data")
	}
}

// GetParticipantsByEventID retrieves all participants associated with the provided event ID
func GetParticipantsByTransportationID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		log.Info("Fetching participants by transportation id")

		params := mux.Vars(r)
		transportationId := params["transportationId"]

		context := log.WithFields(log.Fields{"transportation_id": transportationId})

		// Fetch all participants with the given event ID
		var participants []models.Participant
		if err := db.Where("transportation_id = ?", transportationId).Find(&participants).Error; err != nil {
			context.Error("Error while fetching participants by transportation")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		log.WithFields(log.Fields{
			"count": len(participants),
		}).Info("Successfully fetched participants from the database")

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(participants); err != nil {
			context.Error("Error occurred while encoding participants to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		context.Info("Successfully sent response with participants data")
	}
}

// GetParticipantsWithUserByTransportationID retrieves participants with user info linked to a specific transportation ID
func GetParticipantsWithUserByTransportationID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		log.Info("Fetching participants with user informations by transportation id")

		params := mux.Vars(r)
		transportationId := params["transportationId"]

		context := log.WithFields(log.Fields{"transportation_id": transportationId})

		var transportation models.Transportation
		if err := db.First(&transportation, "id = ?", transportationId).Error; err != nil {
			context.Error("Unknown transportation")
			http.Error(w, "Transportation not found", http.StatusNotFound)
			return
		}

		var event models.Event
		if err := db.First(&event, "id = ?", transportation.EventID).Error; err != nil {
			context.Error("Unknown event")
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}
		if !event.TransportActive {
			context.Error("Transportation not active")
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

		log.WithFields(log.Fields{
			"count": len(results),
		}).Info("Successfully fetched participants from the database")

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(results); err != nil {
			context.Error("Error occurred while encoding participants to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		context.Info("Successfully sent response with participants data")
	}
}

// GetInvitationsByUser retrieves all participant items where the user ID matches the provided parameter and response is true
func GetInvitationsByUser(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		log.Info("Fetching the invitations by transportation id")

		params := mux.Vars(r)
		email := params["email"]

		context := log.WithFields(log.Fields{"email": email})

		var user models.User
		if err := db.Where("email = ?", email).First(&user).Error; err != nil {
			context.Error("Unknown user")
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Fetch all participants with the given user ID and response is true
		var participants []models.Participant
		if err := db.Where("user_id = ? AND response = ?", user.ID, false).Find(&participants).Error; err != nil {
			context.Error("Error while retrieving the invitation from partifipants data")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		// Create a slice to hold the invitations
		var invitations []models.Invitation
		// Iterate over the participants and create invitations
		for _, participant := range participants {
			var event models.Event
			if err := db.First(&event, participant.EventID).Error; err != nil {
				context.Error("Error while retrieving the event from the participant")
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

		log.WithFields(log.Fields{
			"count": len(invitations),
		}).Info("Successfully fetched invitations from the database")

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(invitations); err != nil {
			context.Error("Error occurred while encoding invitatations to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		context.Info("Successfully sent response with invitations data")
	}
}

// UpdateParticipant updates a participant's details
func UpdateParticipant(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		log.Info("Attempting to update the particpant")

		params := mux.Vars(r)
		participantID := params["participantId"]

		context := log.WithFields(log.Fields{"participant_id": participantID})

		var updatedParticipant models.Participant
		if err := json.NewDecoder(r.Body).Decode(&updatedParticipant); err != nil {
			context.Error("Error while decoding the updated reqquest")
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Find the participant by ID
		var participant models.Participant
		if err := db.First(&participant, participantID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				context.Error("Unknown participant")
				http.Error(w, "Participant not found", http.StatusNotFound)
			} else {
				context.Error("Error while fetching the participant")
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		// Update the participant fields
		participant.TransportationID = updatedParticipant.TransportationID
		participant.Active = updatedParticipant.Active

		if updatedParticipant.TransportationID == 0 {
			participant.TransportationID = 0
		}

		// Save the updated participant to the database
		if err := db.Save(&participant).Error; err != nil {
			context.Error("Problem occured while updating the participant")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(participant); err != nil {
			context.Error("Error occurred while encoding participant to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		context.Info("Successfully updating the participant")
	}
}
