package controllers

import (
	"backend/internal/models"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

// création de la table event
func MigrateEvent(db *gorm.DB) {
	db.AutoMigrate(&models.Event{})
}

// GetAllEvents retourne tous les événements
func GetAllEvents(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser la table Event si elle n'existe pas
		MigrateEvent(db)

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
		// Initialiser la table Event si elle n'existe pas
		MigrateEvent(db)

		var eventAdd models.EventAdd
		if err := json.NewDecoder(r.Body).Decode(&eventAdd); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Find the user by email
		var user models.User
		if err := db.Where("email = ?", eventAdd.Email).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Create the event
		event := models.Event{
			Name:        eventAdd.Name,
			Description: eventAdd.Description,
		}
		result := db.Create(&event)
		if result.Error != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		// Create the participant using the retrieved user ID
		participant := models.Participant{
			UserID:  user.ID,
			EventID: event.ID,
			Active:  true, // Set the participant as active by default
		}
		if err := addParticipantEvent(db, participant); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(event)
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

		var updatedEvent models.Event
		if err := json.NewDecoder(r.Body).Decode(&updatedEvent); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Mise à jour de l'événement dans la base de données
		result := db.Model(&models.Event{}).Where("id = ?", id).Updates(&updatedEvent)
		if result.Error != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(updatedEvent)
	}
}

// Secure handler functions with AuthMiddleware
func AuthenticatedAddEvent(db *gorm.DB) http.HandlerFunc {
	return AuthMiddleware(AddEvent(db)).(http.HandlerFunc)
}

func AuthenticatedFindEventByID(db *gorm.DB) http.HandlerFunc {
	return AuthMiddleware(FindEventByID(db)).(http.HandlerFunc)
}

func AuthenticatedUpdateEventByID(db *gorm.DB) http.HandlerFunc {
	return AuthMiddleware(UpdateEventByID(db)).(http.HandlerFunc)
}
