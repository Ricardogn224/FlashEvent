package controllers

import (
	"backend/internal/models"
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

// Migrate les différentes tables
func MigrateEvent(db *gorm.DB) {
	db.AutoMigrate(&models.Event{})
}

func MigrateFood(db *gorm.DB) {
	db.AutoMigrate(&models.FoodItem{})
}

func MigrateTransportation(db *gorm.DB) {
	db.AutoMigrate(&models.Transportation{})
}

func MigrateParticipant(db *gorm.DB) {
	db.AutoMigrate(&models.Participant{})
}

func GetAllEvents(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser les tables si elles n'existent pas
		MigrateEvent(db)
		MigrateFood(db)
		MigrateTransportation(db)
		MigrateParticipant(db)

		var events []models.Event
		result := db.Find(&events)
		if result.Error != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(events)
	}
}

// AddEvent gère l'ajout d'un nouvel événement
func AddEvent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser les tables si elles n'existent pas
		log.Println("Initializing tables if they do not exist...")
		MigrateEvent(db)
		MigrateFood(db)
		MigrateTransportation(db)

		// Décoder la requête
		var eventAdd models.EventAdd
		if err := json.NewDecoder(r.Body).Decode(&eventAdd); err != nil {
			log.Printf("Error decoding request body: %v", err)
			http.Error(w, "Invalid request payload", http.StatusBadRequest)
			return
		}
		log.Printf("Received eventAdd: %+v", eventAdd)

		// Vérifier les rôles de l'utilisateur
		log.Println("Verifying user role...")
		user, err := GetUserFromToken(r, db)
		if err != nil {
			log.Printf("Error getting user from token: %v", err)
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		if user.Role != "AdminPlatform" && user.Role != "AdminEvent"  && user.Role != "user" {
			log.Println("User is not authorized to create an event.")
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}
		log.Printf("User %d is authorized to create an event.", user.ID)

		// Créer l'événement
		event := models.Event{
			Name:            eventAdd.Name,
			Description:     eventAdd.Description,
			Place:           eventAdd.Place,
			DateStart:       eventAdd.DateStart,
			DateEnd:         eventAdd.DateEnd,
			TransportActive: eventAdd.TransportActive,
			CreatedBy:       user.ID, // Enregistrer l'ID du créateur
		}
		log.Println("Creating event...")
		result := db.Create(&event)
		if result.Error != nil {
			log.Printf("Error creating event: %v", result.Error)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}
		log.Printf("Event created successfully: %+v", event)

		// Créer le participant avec l'ID de l'utilisateur récupéré
		participant := models.Participant{
			UserID:   user.ID,
			EventID:  event.ID,
			Active:   true, // Set the participant as active by default
			Response: true,
		}
		log.Println("Creating participant...")
		if err := db.Create(&participant).Error; err != nil {
			log.Printf("Error creating participant: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}
		log.Printf("Participant created successfully: %+v", participant)

		// Répondre avec succès
		w.WriteHeader(http.StatusCreated)
		if err := json.NewEncoder(w).Encode(event); err != nil {
			log.Printf("Error encoding response: %v", err)
		}
		log.Println("Event creation response sent.")
	}
}


// FindEventByID récupère un événement par son ID
func FindEventByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser la table Event si elle n'existe pas
		MigrateEvent(db)

		vars := mux.Vars(r)
		id, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		var event models.Event
		result := db.First(&event, id)
		if result.Error != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(event)
	}
}

// UpdateEventByID met à jour un événement par son ID
func UpdateEventByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser la table Event si elle n'existe pas
		MigrateEvent(db)

		vars := mux.Vars(r)
		id, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		var updates map[string]interface{}
		if err := json.NewDecoder(r.Body).Decode(&updates); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Vérifier les rôles de l'utilisateur
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		// Vérifier que l'utilisateur a le droit de modifier cet événement
		var event models.Event
		if err := db.First(&event, id).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		if user.Role != "AdminPlatform" && (user.Role != "AdminEvent" || event.CreatedBy != user.ID) {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		// Mise à jour partielle de l'événement dans la base de données
		result := db.Model(&event).Updates(updates)
		if result.Error != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(event)
	}
}

// DeleteEventByID supprime un événement par son ID
func DeleteEventByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser la table Event si elle n'existe pas
		MigrateEvent(db)

		vars := mux.Vars(r)
		id, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		// Vérifier les rôles de l'utilisateur
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		// Vérifier que l'utilisateur a le droit de supprimer cet événement
		var event models.Event
		if err := db.First(&event, id).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		if user.Role != "AdminPlatform" && (user.Role != "AdminEvent" || event.CreatedBy != user.ID) {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		// Suppression de l'événement dans la base de données
		if err := db.Delete(&event).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusNoContent)
	}
}

func AddUserToEvent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		eventIDInt, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "ID d'événement invalide", http.StatusBadRequest)
			return
		}
		eventID := uint(eventIDInt)

		var request struct {
			Email string `json:"email"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Vérifier les rôles de l'utilisateur
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		// Vérifier que l'utilisateur a le droit d'ajouter un participant à cet événement
		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		if user.Role != "AdminPlatform" && (user.Role != "AdminEvent" || event.CreatedBy != user.ID) {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		var newUser models.User
		if err := db.Where("email = ?", request.Email).First(&newUser).Error; err != nil {
			http.Error(w, "Utilisateur introuvable", http.StatusNotFound)
			return
		}

		participant := models.Participant{
			UserID:  newUser.ID,
			EventID: eventID,
			Active:  true,
		}

		if err := db.Create(&participant).Error; err != nil {
			http.Error(w, "Échec de l'ajout du participant", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(participant)
	}
}

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

func AuthenticatedAddUserToEvent(db *gorm.DB) http.HandlerFunc {
	return AuthMiddleware(AddUserToEvent(db)).(http.HandlerFunc)
}

func AuthenticatedDeleteEventByID(db *gorm.DB) http.HandlerFunc {
	return AuthMiddleware(DeleteEventByID(db)).(http.HandlerFunc)
}

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

		// Vérifier les rôles de l'utilisateur
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		// Vérifier que l'utilisateur a le droit d'ajouter de la nourriture à cet événement
		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		if user.Role != "AdminPlatform" && (user.Role != "AdminEvent" || event.CreatedBy != user.ID) {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

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
		eventID := vars["id"]

		var transportUpdate models.EventTransportUpdate
		if err := json.NewDecoder(r.Body).Decode(&transportUpdate); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		// Vérifier les rôles de l'utilisateur
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		if user.Role != "AdminPlatform" && (user.Role != "AdminEvent" || event.CreatedBy != user.ID) {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		event.TransportActive = transportUpdate.TransportActive

		if err := db.Save(&event).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(event)
	}
}

func AddTransportationToEvent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		eventIDInt, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}
		eventID := uint(eventIDInt)

		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}
		if !event.TransportActive {
			http.Error(w, "Transportation is not active for this event", http.StatusForbidden)
			return
		}

		var request models.Transportation
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Vérifier les rôles de l'utilisateur
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		var existingTransportation models.Transportation
		if err := db.Where("event_id = ? AND user_id = ?", eventID, user.ID).First(&existingTransportation).Error; err == nil {
			http.Error(w, "You already have a transportation reservation for this event", http.StatusConflict)
			return
		}

		transportation := models.Transportation{
			EventID:    eventID,
			UserID:     user.ID,
			Vehicle:    request.Vehicle,
			SeatNumber: request.SeatNumber,
		}
		if err := db.Create(&transportation).Error; err != nil {
			http.Error(w, "Failed to add transportation to event", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(transportation)
	}
}

// GetAllTransportations retrieves all transportation records
func GetAllTransportations(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var transportations []models.Transportation
		if err := db.Find(&transportations).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(transportations)
	}
}

// GetTransportationByEvent retourne tous les détails de transport pour un événement spécifique
func GetTransportationsByEvent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		eventIDInt, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}
		eventID := uint(eventIDInt)

		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}
		if !event.TransportActive {
			http.Error(w, "Transportation is not active for this event", http.StatusForbidden)
			return
		}

		var transportation []models.Transportation
		result := db.Where("event_id = ?", eventID).Find(&transportation)
		if result.Error != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		if len(transportation) == 0 {
			http.Error(w, "No transportation found for this event", http.StatusNotFound)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(transportation)
	}
}

// GetTransportationByID retrieves a transportation by its ID
func GetTransportationByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		transportationID, err := strconv.Atoi(vars["transportationId"])
		if err != nil {
			http.Error(w, "Invalid transportation ID", http.StatusBadRequest)
			return
		}

		var transportation models.Transportation
		if err := db.First(&transportation, transportationID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Transportation not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(transportation)
	}
}

// UpdateTransportationByID updates a transportation's details by its ID
func UpdateTransportationByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		transportationID, err := strconv.Atoi(vars["transportationId"])
		if err != nil {
			http.Error(w, "Invalid transportation ID", http.StatusBadRequest)
			return
		}

		var updatedTransportation models.Transportation
		if err := json.NewDecoder(r.Body).Decode(&updatedTransportation); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		var transportation models.Transportation
		if err := db.First(&transportation, transportationID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Transportation not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		transportation.Vehicle = updatedTransportation.Vehicle
		transportation.SeatNumber = updatedTransportation.SeatNumber

		if err := db.Save(&transportation).Error; err != nil {
			http.Error(w, "Failed to update transportation", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(transportation)
	}
}

// DeleteTransportationByID deletes a transportation by its ID
func DeleteTransportationByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		transportationID, err := strconv.Atoi(vars["transportationId"])
		if err != nil {
			http.Error(w, "Invalid transportation ID", http.StatusBadRequest)
			return
		}

		var transportation models.Transportation
		if err := db.First(&transportation, transportationID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Transportation not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		if err := db.Delete(&transportation).Error; err != nil {
			http.Error(w, "Failed to delete transportation", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusNoContent)
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
		eventID := uint(eventIDInt)

		var request struct {
			Material string `json:"material"`
			Utility  string `json:"utility"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Vérifier les rôles de l'utilisateur
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		if user.Role != "AdminPlatform" && (user.Role != "AdminEvent" || event.CreatedBy != user.ID) {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

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

// AddActivityToEvent permet à un participant d'ajouter une activité à un événement
func AddActivityToEvent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		eventID, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		var activity struct {
			Activity string `json:"activity"`
		}
		if err := json.NewDecoder(r.Body).Decode(&activity); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		// Vérifier les rôles de l'utilisateur
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		if user.Role != "AdminPlatform" && (user.Role != "AdminEvent" || event.CreatedBy != user.ID) {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		var activities []string
		if err := json.Unmarshal(event.Activities, &activities); err != nil {
			http.Error(w, "Failed to parse activities", http.StatusInternalServerError)
			return
		}
		activities = append(activities, activity.Activity)

		activitiesJSON, err := json.Marshal(activities)
		if err != nil {
			http.Error(w, "Failed to serialize activities", http.StatusInternalServerError)
			return
		}

		event.Activities = activitiesJSON

		if err := db.Save(&event).Error; err != nil {
			http.Error(w, "Failed to add activity", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(event)
	}
}
