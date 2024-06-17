package controllers

import (
	"backend/internal/models"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

// MigrateChatRoom creates the ChatRoom table in the database
func MigrateChatRoom(db *gorm.DB) {
	db.AutoMigrate(&models.ChatRoom{})
}

// AddChatRoom adds a new chat room associated with an event
func AddChatRoom(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		MigrateChatRoom(db) // Ensure the ChatRoom table is created

		var chatRoom models.ChatRoom
		if err := json.NewDecoder(r.Body).Decode(&chatRoom); err != nil {
			http.Error(w, "Invalid request payload", http.StatusBadRequest)
			return
		}

		if chatRoom.EventID == 0 || chatRoom.Name == "" {
			http.Error(w, "EventID and Name are required", http.StatusBadRequest)
			return
		}

		if err := db.Create(&chatRoom).Error; err != nil {
			http.Error(w, "Failed to create chat room", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(chatRoom)
	}
}

// GetChatRooms retrieves all chat rooms for a specific event
func GetChatRooms(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		MigrateChatRoom(db) // Ensure the ChatRoom table is created

		vars := mux.Vars(r)
		eventIDInt, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		eventID := uint(eventIDInt)
		var chatRooms []models.ChatRoom
		if err := db.Where("event_id = ?", eventID).Find(&chatRooms).Error; err != nil {
			http.Error(w, "Failed to retrieve chat rooms", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(chatRooms)
	}
}
