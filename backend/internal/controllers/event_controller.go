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

// création de la table food
func MigrateFood(db *gorm.DB) {
	db.AutoMigrate(&models.FoodItem{})
}

// GetAllEvents retourne tous les événements
func GetAllEvents(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser la table Event si elle n'existe pas
		MigrateEvent(db)

		// migrate food
		MigrateFood(db)

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

		// Migrate food
		MigrateFood(db)

		var eventAdd models.EventAdd
		if err := json.NewDecoder(r.Body).Decode(&eventAdd); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Trouver l'utilisateur par email
		var user models.User
		if err := db.Where("email = ?", eventAdd.Email).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Créer l'événement
		event := models.Event{
			Name:        eventAdd.Name,
			Description: eventAdd.Description,
			Place:       eventAdd.Place,
			Date:        eventAdd.Date,
			IsPrivate:   eventAdd.IsPrivate,
		}
		result := db.Create(&event)
		if result.Error != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		// Générer un lien d'invitation si l'événement est privé
		if event.IsPrivate {
			invitationLink := GenerateInvitationLink(event)
			event.InvitationLink = invitationLink
			db.Save(&event) // Sauvegarder l'événement mis à jour avec le lien d'invitation
		}

		// Créer le participant en utilisant l'ID de l'utilisateur récupéré
		participant := models.Participant{
			UserID:  user.ID,
			EventID: event.ID,
			Active:  true, // Définir le participant comme actif par défaut
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

		// Générer ou supprimer le lien d'invitation en fonction de la confidentialité
		if updatedEvent.IsPrivate && updatedEvent.InvitationLink == "" {
			updatedEvent.InvitationLink = GenerateInvitationLink(updatedEvent)
		} else if !updatedEvent.IsPrivate {
			updatedEvent.InvitationLink = ""
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

func AddUserToEvent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		eventIDInt, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "ID d'événement invalide", http.StatusBadRequest)
			return
		}
		eventID := uint(eventIDInt) // Correction : utilisation de :=

		var request struct {
			Email string `json:"email"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		var user models.User
		if err := db.Where("email = ?", request.Email).First(&user).Error; err != nil {
			http.Error(w, "Utilisateur introuvable", http.StatusNotFound)
			return
		}

		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			http.Error(w, "Événement introuvable", http.StatusNotFound)
			return
		}

		participant := models.Participant{
			UserID:  user.ID,
			EventID: uint(eventID),
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

// AddItemToEvent ajoute un élément à un événement
func AddItemToEvent(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		eventID, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		var request struct {
			Name           string `json:"name"`
			Description    string `json:"description"`
			Food           string `json:"food,omitempty"`
			Logistics      string `json:"logistics,omitempty"`
			OtherUtilities string `json:"other_utilities,omitempty"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		item := models.ItemEvent{
			Name:           request.Name,
			Description:    request.Description,
			Food:           request.Food,
			Logistics:      request.Logistics,
			OtherUtilities: request.OtherUtilities,
		}

		if err := db.Create(&item).Error; err != nil {
			http.Error(w, "Failed to add item to event", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(item)
	}
}

// GenerateInvitationLink génère un lien d'invitation pour un événement privé
func GenerateInvitationLink(event models.Event) string {
	if event.IsPrivate {
		// Logique de génération de lien d'invitation (par exemple, un UUID ou un token unique)
		return "/invite/" + strconv.Itoa(int(event.ID)) + "/" + generateUniqueToken()
	}
	return ""
}

// generateUniqueToken génère un token unique
func generateUniqueToken() string {
	// Implémentation de génération d'un token unique (par exemple, UUID)
	return "unique-token" // Remplacer par la logique réelle
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
func AddTransportationToEvent(db *gorm.DB) http.HandlerFunc {
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
			Vehicle    string `json:"vehicle"`
			SeatNumber int    `json:"seat_number"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Enregistrer les informations sur le transport dans la base de données
		transportation := models.Transportation{
			EventID:    eventID,
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
