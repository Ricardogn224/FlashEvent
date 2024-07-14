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

// AddChatRoom ajoute une nouvelle salle de chat associée à un événement
func AddChatRoom(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateChatRoom(db) // Initialiser la table ChatRoom si elle n'existe pas

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

// GetChatRooms récupère toutes les salles de chat pour un événement spécifique
func GetChatRooms(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateChatRoom(db) // Initialiser la table ChatRoom si elle n'existe pas

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

func GetChatRoomByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateChatRoom(db) // Initialiser la table ChatRoom si elle n'existe pas

		vars := mux.Vars(r)
		chatRoomID, err := strconv.Atoi(vars["chatRoomId"])
		if err != nil {
			http.Error(w, "Invalid chat room ID", http.StatusBadRequest)
			return
		}

		var chatRoom models.ChatRoom
		if err := db.First(&chatRoom, chatRoomID).Error; err != nil {
			http.Error(w, "Chat room not found", http.StatusNotFound)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(chatRoom)
	}
}

// UpdateChatRoomByID updates a chat room by its ID
func UpdateChatRoomByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateChatRoom(db) // Initialiser la table ChatRoom si elle n'existe pas

		vars := mux.Vars(r)
		chatRoomID, err := strconv.Atoi(vars["chatRoomId"])
		if err != nil {
			http.Error(w, "Invalid chat room ID", http.StatusBadRequest)
			return
		}

		var chatRoom models.ChatRoom
		if err := db.First(&chatRoom, chatRoomID).Error; err != nil {
			http.Error(w, "Chat room not found", http.StatusNotFound)
			return
		}

		var updatedChatRoom models.ChatRoom
		if err := json.NewDecoder(r.Body).Decode(&updatedChatRoom); err != nil {
			http.Error(w, "Invalid request payload", http.StatusBadRequest)
			return
		}

		chatRoom.Name = updatedChatRoom.Name
		// Update other fields as necessary

		if err := db.Save(&chatRoom).Error; err != nil {
			http.Error(w, "Failed to update chat room", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(chatRoom)
	}
}

// DeleteChatRoomByID deletes a chat room by its ID
func DeleteChatRoomByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateChatRoom(db) // Initialiser la table ChatRoom si elle n'existe pas

		vars := mux.Vars(r)
		chatRoomID, err := strconv.Atoi(vars["chatRoomId"])
		if err != nil {
			http.Error(w, "Invalid chat room ID", http.StatusBadRequest)
			return
		}

		if err := db.Delete(&models.ChatRoom{}, chatRoomID).Error; err != nil {
			http.Error(w, "Failed to delete chat room", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusNoContent)
	}
}
