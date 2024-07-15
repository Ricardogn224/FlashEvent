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
		database.MigrateChatRoom(db)            // Initialiser la table ChatRoom si elle n'existe pas
		database.MigrateChatRoomParticipant(db) // Initialiser la table ChatRoomParticipant si elle n'existe pas

		var chatRoom struct {
			models.ChatRoom
			Participants []uint `json:"participants"` // IDs des participants
		}
		if err := json.NewDecoder(r.Body).Decode(&chatRoom); err != nil {
			http.Error(w, "Invalid request payload", http.StatusBadRequest)
			return
		}

		if chatRoom.EventID == 0 || chatRoom.Name == "" {
			http.Error(w, "EventID and Name are required", http.StatusBadRequest)
			return
		}

		if err := db.Create(&chatRoom.ChatRoom).Error; err != nil {
			http.Error(w, "Failed to create chat room", http.StatusInternalServerError)
			return
		}

		for _, userID := range chatRoom.Participants {
			chatRoomParticipant := models.ChatRoomParticipant{
				UserID:     userID,
				ChatRoomID: chatRoom.ID,
				RoomType:   "Private", // Or "Public" based on your logic
			}
			db.Create(&chatRoomParticipant)
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(chatRoom.ChatRoom)
	}
}

// GetChatRooms récupère toutes les salles de chat pour un événement spécifique
func GetChatRooms(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateChatRoom(db)            // Initialiser la table ChatRoom si elle n'existe pas
		database.MigrateChatRoomParticipant(db) // Initialiser la table ChatRoomParticipant si elle n'existe pas

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

// GetChatRoomByID récupère une salle de chat par son ID
func GetChatRoomByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateChatRoom(db)            // Initialiser la table ChatRoom si elle n'existe pas
		database.MigrateChatRoomParticipant(db) // Initialiser la table ChatRoomParticipant si elle n'existe pas

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

		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		var chatRoomParticipant models.ChatRoomParticipant
		if err := db.Where("user_id = ? AND chat_room_id = ?", user.ID, chatRoomID).First(&chatRoomParticipant).Error; err != nil {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(chatRoom)
	}
}

// UpdateChatRoomByID met à jour une salle de chat par son ID
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

		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		var chatRoomParticipant models.ChatRoomParticipant
		if err := db.Where("user_id = ? AND chat_room_id = ?", user.ID, chatRoomID).First(&chatRoomParticipant).Error; err != nil {
			http.Error(w, "Forbidden", http.StatusForbidden)
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

// DeleteChatRoomByID supprime une salle de chat par son ID
func DeleteChatRoomByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateChatRoom(db) // Initialiser la table ChatRoom si elle n'existe pas

		vars := mux.Vars(r)
		chatRoomID, err := strconv.Atoi(vars["chatRoomId"])
		if err != nil {
			http.Error(w, "Invalid chat room ID", http.StatusBadRequest)
			return
		}

		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		var chatRoomParticipant models.ChatRoomParticipant
		if err := db.Where("user_id = ? AND chat_room_id = ?", user.ID, chatRoomID).First(&chatRoomParticipant).Error; err != nil {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

		if err := db.Delete(&models.ChatRoom{}, chatRoomID).Error; err != nil {
			http.Error(w, "Failed to delete chat room", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusNoContent)
	}
}
