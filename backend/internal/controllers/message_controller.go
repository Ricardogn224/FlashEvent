package controllers

import (
	"backend/internal/database"
	"backend/internal/models"
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

// SendMessage envoie un message dans une salle de chat
func SendMessage(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateMessage(db) // Initialiser la table Message si elle n'existe pas

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

		// Vérifier les rôles de l'utilisateur
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		message := models.Message{
			UserID:     user.ID,
			ChatRoomID: chatRoomID,
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
		database.MigrateMessage(db) // Initialiser la table Message si elle n'existe pas

		vars := mux.Vars(r)
		chatRoomId, err := strconv.Atoi(vars["chatRoomId"])
		if err != nil {
			http.Error(w, "Invalid chat room ID", http.StatusBadRequest)
			return
		}
		chatRoomID := uint(chatRoomId)

		// Get the authenticated user
		authUser, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		// Check user role
		if authUser.Role == "AdminEvent" && authUser.Role != "User" {
			http.Error(w, "Forbidden", http.StatusForbidden)
			return
		}

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

// GetAllMessages retrieves all messages
func GetAllMessages(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateMessage(db) // Initialize the Message table if it doesn't exist

		var messages []models.Message
		if err := db.Find(&messages).Error; err != nil {
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

// GetMessageByID retrieves a message by its ID
func GetMessageByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateMessage(db) // Initialize the Message table if it doesn't exist

		vars := mux.Vars(r)
		messageId, err := strconv.Atoi(vars["messageId"])
		if err != nil {
			http.Error(w, "Invalid message ID", http.StatusBadRequest)
			return
		}
		messageID := uint(messageId)

		var message models.Message
		if err := db.First(&message, messageID).Error; err != nil {
			http.Error(w, "Message not found", http.StatusNotFound)
			return
		}

		var user models.User
		if err := db.First(&user, message.UserID).Error; err != nil {
			http.Error(w, "Failed to retrieve user info", http.StatusInternalServerError)
			return
		}

		responseMessage := models.MessageResponse{
			ID:         message.ID,
			ChatRoomID: message.ChatRoomID,
			UserID:     user.ID,
			Email:      user.Email,
			Username:   user.Username,
			Content:    message.Content,
			Timestamp:  message.Timestamp,
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(responseMessage)
	}
}

// UpdateMessageByID updates a message by its ID
func UpdateMessageByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateMessage(db) // Initialize the Message table if it doesn't exist

		vars := mux.Vars(r)
		messageId, err := strconv.Atoi(vars["messageId"])
		if err != nil {
			http.Error(w, "Invalid message ID", http.StatusBadRequest)
			return
		}
		messageID := uint(messageId)

		var message models.Message
		if err := db.First(&message, messageID).Error; err != nil {
			http.Error(w, "Message not found", http.StatusNotFound)
			return
		}

		var updatedMessage models.Message
		if err := json.NewDecoder(r.Body).Decode(&updatedMessage); err != nil {
			http.Error(w, "Invalid request payload", http.StatusBadRequest)
			return
		}

		message.Content = updatedMessage.Content
		message.Timestamp = time.Now() // Update the timestamp to the current time

		if err := db.Save(&message).Error; err != nil {
			http.Error(w, "Failed to update message", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(message)
	}
}

// DeleteMessageByID deletes a message by its ID
func DeleteMessageByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateMessage(db) // Initialize the Message table if it doesn't exist

		vars := mux.Vars(r)
		messageId, err := strconv.Atoi(vars["messageId"])
		if err != nil {
			http.Error(w, "Invalid message ID", http.StatusBadRequest)
			return
		}
		messageID := uint(messageId)

		if err := db.Delete(&models.Message{}, messageID).Error; err != nil {
			http.Error(w, "Failed to delete message", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusNoContent)
	}
}
