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

		var msg models.MessageAdd
		if err := json.NewDecoder(r.Body).Decode(&msg); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Validate that the user exists
		var user models.User
		if err := db.Where("email = ?", msg.Email).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		message := models.Message{
			UserID:     uint(user.ID),
			ChatRoomID: uint(chatRoomID),
			Content:    msg.Content,
			Timestamp:  time.Now(),
		}

		if err := db.Create(&message).Error; err != nil {
			http.Error(w, "Failed to send message", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(message)
	}
}

// GetMessagesByChatRoom récupère les messages d'une salle de chat
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

// AddMessageToChat permet d'envoyer un message dans la salle de chat de l'événement
func AddMessageToChat(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		eventID, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		var message models.MessageAdd
		if err := json.NewDecoder(r.Body).Decode(&message); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		var event models.Event
		if err := db.First(&event, eventID).Error; err != nil {
			http.Error(w, "Event not found", http.StatusNotFound)
			return
		}

		// Validate that the user exists
		var user models.User
		if err := db.Where("email = ?", message.Email).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		chatMessage := models.Message{
			ChatRoomID: event.ID, // Utilisez l'ID de l'événement comme ChatRoomID
			UserID:     user.ID,
			Content:    message.Content,
			Timestamp:  time.Now(),
		}
		if err := db.Create(&chatMessage).Error; err != nil {
			http.Error(w, "Failed to send message", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(chatMessage)
	}
}
