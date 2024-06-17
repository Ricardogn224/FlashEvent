package controllers

import (
	"backend/internal/models"
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

// MigrateMessage crée la table Message dans la base de données
func MigrateMessage(db *gorm.DB) {
	db.AutoMigrate(&models.Message{})
}

// SendMessage envoie un message dans une salle de chat
func SendMessage(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		MigrateMessage(db) // Initialiser la table Message si elle n'existe pas

		vars := mux.Vars(r)
		chatRoomId, err := strconv.Atoi(vars["chatRoomId"])
		if err != nil {
			http.Error(w, "Invalid chat room ID", http.StatusBadRequest)
			return
		}
		chatRoomID := uint(chatRoomId)

		var msg models.Message
		if err := json.NewDecoder(r.Body).Decode(&msg); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		msg.ChatRoomID = chatRoomID
		msg.Timestamp = time.Now()

		if err := db.Create(&msg).Error; err != nil {
			http.Error(w, "Failed to send message", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(msg)
	}
}

// GetMessages récupère les messages d'une salle de chat
func GetMessagesByChatRoom(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		MigrateMessage(db) // Initialiser la table Message si elle n'existe pas

		vars := mux.Vars(r)
		chatRoomId, err := strconv.Atoi(vars["chatRoomId"])
		if err != nil {
			http.Error(w, "Invalid chat room ID", http.StatusBadRequest)
			return
		}
		chatRoomID := uint(chatRoomId)

		var messages []models.Message
		if err := db.Where("chat_room_id = ?", chatRoomID).Find(&messages).Error; err != nil {
			http.Error(w, "Failed to retrieve messages", http.StatusInternalServerError)
			return
		}

		var responseMessages []models.MessageResponse
		for _, message := range messages {
			var user models.User
			if err := db.First(&user, message.UserID).Error; err != nil {
				http.Error(w, "Failed to retrieve user info", http.StatusInternalServerError)
				return
			}
			responseMessages = append(responseMessages, models.MessageResponse{
				ID:         message.ID,
				ChatRoomID: message.ChatRoomID,
				UserID:     user.ID,
				Email:      user.Email,
				Username:   user.Username,
				Content:    message.Content,
				Timestamp:  message.Timestamp,
			})
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(responseMessages)
	}
}
