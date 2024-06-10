package controllers

import (
	"backend/internal/models"
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

func MigrateItem(db *gorm.DB) {
	db.AutoMigrate(&models.ItemEvent{})
}

func GetAllItems(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var items []models.ItemEvent
		if err := db.Find(&items).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(items)
	}
}

func AddItem(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Migrate the Item table
		MigrateItem(db)

		var itemRequest models.ItemEventAdd
		if err := json.NewDecoder(r.Body).Decode(&itemRequest); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		var user models.User
		if err := db.Where("email = ?", itemRequest.Email).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Create the item
		item := models.ItemEvent{
			Name:    itemRequest.Name,
			UserID:  user.ID,
			EventID: itemRequest.EventID,
		}
		if err := db.Create(&item).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(item)
	}
}

func GetItemsByEventID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)
		eventID := params["eventId"]

		var items []models.ItemEvent
		if err := db.Where("event_id = ?", eventID).Find(&items).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(items)
	}
}
