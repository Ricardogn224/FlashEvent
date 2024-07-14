package controllers

import (
	"backend/internal/database"
	"backend/internal/models"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

// GetAllItems retourne tous les éléments
func GetAllItems(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateItem(db) // Initialiser la table Item si elle n'existe pas

		var items []models.ItemEvent
		if err := db.Find(&items).Error; err != nil {
			http.Error(w, "Erreur interne du serveur", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(items)
	}
}

// AddItem gère l'ajout d'un nouvel élément
func AddItem(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateItem(db) // Initialiser la table Item si elle n'existe pas

		var itemRequestAdd models.ItemEvent
		if err := json.NewDecoder(r.Body).Decode(&itemRequestAdd); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Verify user roles and permissions
		authUser, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		// Check if the authenticated user is an admin or the creator of the event
		if authUser.Role != "AdminPlatform" {
			// Check if the user is an AdminEvent and the creator of the event
			if authUser.Role == "AdminEvent" {
				var event models.Event
				if err := db.First(&event, itemRequestAdd.EventID).Error; err != nil {
					http.Error(w, "Event not found", http.StatusNotFound)
					return
				}
				if event.CreatedBy != authUser.ID {
					http.Error(w, "Forbidden", http.StatusForbidden)
					return
				}
			} else {
				// Check if the user is a participant of the event
				var participant models.Participant
				if err := db.Where("event_id = ? AND user_id = ?", itemRequestAdd.EventID, authUser.ID).First(&participant).Error; err != nil {
					http.Error(w, "Forbidden", http.StatusForbidden)
					return
				}
			}
		}

		// Create a new ItemEvent instance
		itemRequest := models.ItemEvent{
			UserID:  authUser.ID,
			EventID: itemRequestAdd.EventID,
			Name:    itemRequestAdd.Name,
		}

		// Création de l'élément
		if err := db.Create(&itemRequest).Error; err != nil {
			http.Error(w, "Erreur interne du serveur", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(itemRequest)
	}
}

// GetItemsByEventID retourne les éléments par ID d'événement
func GetItemsByEventID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateItem(db) // Initialiser la table Item si elle n'existe pas

		params := mux.Vars(r)
		eventID := params["eventId"]

		var items []models.ItemEvent
		if err := db.Where("event_id = ?", eventID).Find(&items).Error; err != nil {
			http.Error(w, "Erreur interne du serveur", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(items)
	}
}

// GetItemByID retrieves an item by its ID
func GetItemByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateItem(db) // Ensure the table Item exists

		params := mux.Vars(r)
		itemID, err := strconv.Atoi(params["itemId"])
		if err != nil {
			http.Error(w, "Invalid item ID", http.StatusBadRequest)
			return
		}

		var item models.ItemEvent
		if err := db.First(&item, itemID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Item not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(item)
	}
}

// DeleteItemByID deletes an item by its ID
func DeleteItemByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateItem(db) // Ensure the table Item exists

		params := mux.Vars(r)
		itemID, err := strconv.Atoi(params["itemId"])
		if err != nil {
			http.Error(w, "Invalid item ID", http.StatusBadRequest)
			return
		}

		var item models.ItemEvent
		if err := db.First(&item, itemID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Item not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		// Verify user roles and permissions
		authUser, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		var event models.Event
		if err := db.First(&event, item.EventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		if authUser.Role != "AdminPlatform" && (authUser.Role != "AdminEvent" || event.CreatedBy != authUser.ID) {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		if err := db.Delete(&item).Error; err != nil {
			http.Error(w, "Failed to delete item", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusNoContent)
	}
}

// UpdateItemByID updates an item's details by its ID
func UpdateItemByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateItem(db) // Ensure the table Item exists

		params := mux.Vars(r)
		itemID, err := strconv.Atoi(params["itemId"])
		if err != nil {
			http.Error(w, "Invalid item ID", http.StatusBadRequest)
			return
		}

		var updatedItem models.ItemEvent
		if err := json.NewDecoder(r.Body).Decode(&updatedItem); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		var item models.ItemEvent
		if err := db.First(&item, itemID).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Item not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		// Verify user roles and permissions
		authUser, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		var event models.Event
		if err := db.First(&event, item.EventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		if authUser.Role != "AdminPlatform" && (authUser.Role != "AdminEvent" || event.CreatedBy != authUser.ID) {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		item.Name = updatedItem.Name

		if err := db.Save(&item).Error; err != nil {
			http.Error(w, "Failed to update item", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(item)
	}
}
