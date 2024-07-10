package controllers

import (
	"backend/internal/config"
	"backend/internal/models"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	log "github.com/sirupsen/logrus"
	"gorm.io/gorm"
)

func init() {
	config.SetupLogger()
}

// création de la table event
func MigrateEvent(db *gorm.DB) {
	db.AutoMigrate(&models.Event{})
}

// création de la table food
func MigrateFood(db *gorm.DB) {
	db.AutoMigrate(&models.FoodItem{})
}

func MigrateTransportation(db *gorm.DB) {
	db.AutoMigrate(&models.Transportation{})
}

// GetAllEvents retourne tous les événements
func GetAllEvents(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser la table Event si elle n'existe pas
		MigrateEvent(db)

		// migrate food
		MigrateFood(db)

		MigrateTransportation(db)

		MigrateParticipant(db)

		log.Info("Fetching all events")

		var events []models.Event
		result := db.Find(&events)
		if result.Error != nil {
			log.WithFields(log.Fields{
				"error": result.Error,
			}).Error("Error occurred while fetching events from the database")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		log.WithFields(log.Fields{
			"count": len(events),
		}).Info("Successfully fetched events from the database")

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(events); err != nil {
			log.WithFields(log.Fields{
				"error": err,
			}).Error("Error occurred while encoding events to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		log.Info("Successfully sent response with event data")
	}
}

// AddEvent gère l'ajout d'un nouvel événement
func AddEvent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser la table Event si elle n'existe pas
		MigrateEvent(db)

		//migrate food
		MigrateFood(db)

		MigrateTransportation(db)

		log.Info("Create event request received")

		var eventAdd models.EventAdd
		if err := json.NewDecoder(r.Body).Decode(&eventAdd); err != nil {
			log.WithFields(log.Fields{
				"error": err.Error,
			}).Error("Error while decoding the event data from the request")
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Find the user by email
		var user models.User
		if err := db.Where("email = ?", eventAdd.Email).First(&user).Error; err != nil {
			log.WithFields(log.Fields{
				"error": err.Error,
				"mail":  eventAdd.Email,
			}).Error("Unkown user")
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		context := log.WithFields(log.Fields{"eventName": eventAdd.Name, "email": eventAdd.Email})

		// Create the event
		event := models.Event{
			Name:            eventAdd.Name,
			Description:     eventAdd.Description,
			TransportActive: eventAdd.TransportActive,
		}
		result := db.Create(&event)
		if result.Error != nil {
			context.Error("Error occured while creating the event")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		// Create the participant using the retrieved user ID
		participant := models.Participant{
			UserID:   user.ID,
			EventID:  event.ID,
			Active:   true, // Set the participant as active by default
			Response: true,
		}
		if err := addParticipantEvent(db, participant); err != nil {
			context.Error("Error occured while creating and adding the participant to the event")
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		if err := json.NewEncoder(w).Encode(event); err != nil {
			context.Error("Error occurred while encoding event to JSONt")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		log.Info("Successfully creating event data")
	}
}

// FindEventByID récupère un événement par son ID
func FindEventByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser la table Event si elle n'existe pas
		MigrateEvent(db)

		log.Info("Fetching event by id")

		vars := mux.Vars(r)
		id, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			log.WithFields(log.Fields{
				"error": err.Error,
			}).Error("Invalid event ID")
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		context := log.WithFields(log.Fields{"eventId": id})

		var event models.Event
		result := db.First(&event, id)
		if result.Error != nil {
			context.Error("Unknown event")
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(event); err != nil {
			context.Error("Error occurred while encoding event to JSONt")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		log.Info("Successfully sent event data")
	}
}

// UpdateEventByID met à jour un événement par son ID
func UpdateEventByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser la table Event si elle n'existe pas
		MigrateEvent(db)

		log.Info("Update event request received")

		vars := mux.Vars(r)
		id, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			log.WithFields(log.Fields{
				"error": err.Error,
			}).Error("Invalid event ID")
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		context := log.WithFields(log.Fields{"eventId": id})

		var updatedEvent models.Event
		if err := json.NewDecoder(r.Body).Decode(&updatedEvent); err != nil {
			context.Error("Problem occured while decoding data request")
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Mise à jour de l'événement dans la base de données
		result := db.Model(&models.Event{}).Where("id = ?", id).Updates(&updatedEvent)
		if result.Error != nil {
			context.Error("Problem occured while updating event")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(updatedEvent); err != nil {
			context.Error("Error occurred while encoding event to JSONt")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		context.Info("Successfully updating event")
	}
}

// func AddUserToEvent(db *gorm.DB) http.HandlerFunc {
// 	return func(w http.ResponseWriter, r *http.Request) {
// 		vars := mux.Vars(r)

// 		eventIDInt, err := strconv.Atoi(vars["eventId"])
// 		if err != nil {
// 			http.Error(w, "ID d'événement invalide", http.StatusBadRequest)
// 			return
// 		}
// 		eventID := uint(eventIDInt) // Correction : utilisation de :=

// 		var request struct {
// 			Email string `json:"email"`
// 		}
// 		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
// 			http.Error(w, err.Error(), http.StatusBadRequest)
// 			return
// 		}

// 		var user models.User
// 		if err := db.Where("email = ?", request.Email).First(&user).Error; err != nil {
// 			http.Error(w, "Utilisateur introuvable", http.StatusNotFound)
// 			return
// 		}

// 		var event models.Event
// 		if err := db.First(&event, eventID).Error; err != nil {
// 			http.Error(w, "Événement introuvable", http.StatusNotFound)
// 			return
// 		}

// 		participant := models.Participant{
// 			UserID:  user.ID,
// 			EventID: uint(eventID),
// 			Active:  true,
// 		}

// 		if err := db.Create(&participant).Error; err != nil {
// 			http.Error(w, "Échec de l'ajout du participant", http.StatusInternalServerError)
// 			return
// 		}

// 		w.WriteHeader(http.StatusCreated)
// 		json.NewEncoder(w).Encode(participant)
// 	}
// }

// Fonctions handlers sécurisées avec AuthMiddleware
func AuthenticatedAddEvent(db *gorm.DB) http.HandlerFunc {
	return AuthMiddleware(AddEvent(db)).(http.HandlerFunc)
}

func AuthenticatedFindEventByID(db *gorm.DB) http.HandlerFunc {
	return AuthMiddleware(FindEventByID(db)).(http.HandlerFunc)
}

func AuthenticatedUpdateEventByID(db *gorm.DB) http.HandlerFunc {
	return AuthMiddleware(UpdateEventByID(db)).(http.HandlerFunc)
}

// func AuthenticatedAddUserToEvent(db *gorm.DB) http.HandlerFunc {
// 	return AuthMiddleware(AddUserToEvent(db)).(http.HandlerFunc)
// }

// AddFoodToEvent ajoute des informations sur la nourriture à un événement
func AddFoodToEvent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var eventID uint
		// Extraire l'ID de l'événement à partir des paramètres de la requête
		vars := mux.Vars(r)
		eventIDInt, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}
		eventID = uint(eventIDInt)

		var request struct {
			Food string `json:"food"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Enregistrer les informations sur la nourriture dans la base de données
		foodItem := models.FoodItem{
			EventID: eventID,
			Food:    request.Food,
		}
		if err := db.Create(&foodItem).Error; err != nil {
			http.Error(w, "Failed to add food to event", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(foodItem)
	}
}

// AddTransportationToEvent ajoute un véhicule et un nombre de places à un événement
func ActivateTransport(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)

		log.Info("Activate or deactivate transport")

		eventID := vars["id"]

		context := log.WithFields(log.Fields{"eventId": eventID})

		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			context.Error("Unknown event")
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		var transportUpdate models.EventTransportUpdate
		if err := json.NewDecoder(r.Body).Decode(&transportUpdate); err != nil {
			context.Error("Error while decoding transport request")
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		event.TransportActive = transportUpdate.TransportActive

		if err := db.Save(&event).Error; err != nil {
			context.Error("Error while updating transport for the event")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(event); err != nil {
			context.Error("Error occurred while encoding event to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		context.Info("Successfully updating event transport")
	}
}

func AddTransportationToEvent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		// Extraire l'ID de l'événement à partir des paramètres de la requête
		vars := mux.Vars(r)

		log.Info("Creation transportation for an event request received")

		eventIDInt, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			log.WithFields(log.Fields{
				"error": err.Error,
			}).Error("Invalid event ID")
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}
		eventID := uint(eventIDInt)

		context := log.WithFields(log.Fields{"eventId": eventID})

		// Check if transport is active for the event
		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			context.Error("Unknown event")
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}
		if !event.TransportActive {
			context.Error("Transportation is not active for this event")
			http.Error(w, "Transportation is not active for this event", http.StatusForbidden)
			return
		}

		var request models.TransportationAdd
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			context.Error("Error while decoding transporattion request")
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		context = log.WithFields(log.Fields{"eventId": eventID, "email": request.Email})

		// Trouver l'utilisateur par email
		var user models.User
		if err := db.Where("email = ?", request.Email).First(&user).Error; err != nil {
			context.Error("Unknown user")
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		log.Info("Check if the user has already a transportation")
		// Vérifier si l'utilisateur a déjà une réservation de transport pour cet événement
		var existingTransportation models.Transportation
		if err := db.Where("event_id = ? AND user_id = ?", eventID, user.ID).First(&existingTransportation).Error; err == nil {
			context.Warn("This user has already a trannsportation for that event")
			http.Error(w, "You already have a transportation reservation for this event", http.StatusConflict)
			return
		}

		// Enregistrer les informations sur le transport dans la base de données
		transportation := models.Transportation{
			EventID:    eventID,
			UserID:     user.ID,
			Vehicle:    request.Vehicle,
			SeatNumber: request.SeatNumber,
		}
		if err := db.Create(&transportation).Error; err != nil {
			context.Error("Error while creating transportation for the event")
			http.Error(w, "Failed to add transportation to event", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		if err := json.NewEncoder(w).Encode(transportation); err != nil {
			context.Error("Error occurred while encoding transportation to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		context.Info("Successfully creating transportation")
	}
}

// GetTransportationByEvent retourne tous les détails de transport pour un événement spécifique
func GetTransportationByEvent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)

		log.Info("Fetching transportations for an event")

		eventIDInt, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			log.WithFields(log.Fields{
				"error": err.Error,
			}).Error("Invalid event ID")
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}
		eventID := uint(eventIDInt)

		context := log.WithFields(log.Fields{"eventId": eventID})

		// Check if transport is active for the event
		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			context.Error("Unknown event")
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}
		if !event.TransportActive {
			context.Error("Transportation is not active for this event")
			http.Error(w, "Transportation is not active for this event", http.StatusForbidden)
			return
		}

		var transportation []models.Transportation
		result := db.Where("event_id = ?", eventID).Find(&transportation)
		if result.Error != nil {
			context.Error("Error while retrieving transportations for the event")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		if len(transportation) == 0 {
			context.Warn("Transportations not found for this event")
			http.Error(w, "No transportation found for this event", http.StatusNotFound)
			return
		}

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(transportation); err != nil {
			context.Error("Error occurred while encoding transportations to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		context.Info("Successfully fetching transportation data")
	}
}

// AddUtilitiesToEvent ajoute du matériel et son utilité à un événement
func AddUtilitiesToEvent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		eventIDInt, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "ID d'événement invalide", http.StatusBadRequest)
			return
		}
		eventID := uint(eventIDInt) // Correction : utilisation de :=

		var request struct {
			Material string `json:"material"`
			Utility  string `json:"utility"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Enregistrer les informations sur le matériel et son utilité dans la base de données
		utilities := models.Utilities{
			EventID:  eventID,
			Material: request.Material,
			Utility:  request.Utility,
		}
		if err := db.Create(&utilities).Error; err != nil {
			http.Error(w, "Échec de l'ajout des utilités à l'événement", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(utilities)
	}
}
