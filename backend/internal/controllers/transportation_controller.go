package controllers

import (
	"backend/internal/models"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

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