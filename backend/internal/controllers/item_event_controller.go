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
			http.Error(w, "Erreur interne du serveur", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(items)
	}
}

func AddItem(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Migration de la table Item
		MigrateItem(db)

		var itemRequestAdd models.ItemEventAdd
		if err := json.NewDecoder(r.Body).Decode(&itemRequestAdd); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Validate that the user exists
		var user models.User
		if err := db.Where("email = ?", itemRequestAdd.Email).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Create a new Participant instance
		itemRequest := models.ItemEvent{
			UserID:  user.ID,
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

func GetItemsByEventID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
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
