package controllers

import (
	"backend/internal/database"
	"backend/internal/models"
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

// AddChatRoom adds a new chat room associated with an event
func AddChatRoom(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Extract eventId from URL parameters
		vars := mux.Vars(r)
		eventIdStr := vars["eventId"]
		eventId, err := strconv.Atoi(eventIdStr)
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		database.MigrateChatRoom(db)            // Initialize the ChatRoom table if it doesn't exist
		database.MigrateChatRoomParticipant(db) // Initialize the ChatRoomParticipant table if it doesn't exist

		var chatRoom models.ChatRoom
		if err := json.NewDecoder(r.Body).Decode(&chatRoom); err != nil {
			http.Error(w, "Invalid request payload", http.StatusBadRequest)
			return
		}

		chatRoom.EventID = uint(eventId)

		if chatRoom.Name == "" {
			http.Error(w, "Name is required", http.StatusBadRequest)
			return
		}

		user, err := GetUserFromToken(r, db)
		if err != nil {
			log.Printf("Error getting user from token: %v", err)
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		if err := db.Create(&chatRoom).Error; err != nil {
			log.Printf("Error creating chat room: %v", err)
			http.Error(w, "Could not create chat room", http.StatusInternalServerError)
			return
		}

		chatRoomParticipant := models.ChatRoomParticipant{
			UserID:     user.ID,
			ChatRoomID: chatRoom.ID,
			RoomType:   "Public", // Or set this based on your logic
		}

		if err := db.Create(&chatRoomParticipant).Error; err != nil {
			log.Printf("Error creating chat room participant: %v", err)
			http.Error(w, "Could not create chat room participant", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(chatRoom)
	}
}

// AddChatRoomParticipant adds a participant to a chat room by email
func AddChatRoomParticipant(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateChatRoomParticipant(db) // Initialize the ChatRoomParticipant table if it doesn't exist
		database.MigrateUser(db)                // Initialize the User table if it doesn't exist

		var requestBody struct {
			Email string `json:"email"`
		}

		if err := json.NewDecoder(r.Body).Decode(&requestBody); err != nil {
			http.Error(w, "Invalid request payload", http.StatusBadRequest)
			return
		}

		if requestBody.Email == "" {
			http.Error(w, "Email is required", http.StatusBadRequest)
			return
		}

		vars := mux.Vars(r)
		chatRoomID, err := strconv.Atoi(vars["chatRoomId"])
		if err != nil {
			http.Error(w, "Invalid chat room ID", http.StatusBadRequest)
			return
		}

		// Retrieve the user by email
		var user models.User
		if err := db.Where("email = ?", requestBody.Email).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Check if the user is already a participant in the chat room
		var existingParticipant models.ChatRoomParticipant
		if err := db.Where("user_id = ? AND chat_room_id = ?", user.ID, chatRoomID).First(&existingParticipant).Error; err == nil {
			http.Error(w, "User is already a participant in the chat room", http.StatusConflict)
			return
		}

		// Create a new participant entry in ChatRoomParticipant
		newParticipant := models.ChatRoomParticipant{
			UserID:     user.ID,
			ChatRoomID: uint(chatRoomID),
			RoomType:   "Public", // Or set this based on your logic
		}

		if err := db.Create(&newParticipant).Error; err != nil {
			log.Printf("Error creating chat room participant: %v", err)
			http.Error(w, "Could not create chat room participant", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(newParticipant)
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

// GetChatRoomsByEventIDAndUserID retrieves all chat rooms for a specific event where the user is a participant
func GetChatRoomsByEventIDAndUserID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateChatRoom(db)            // Initialize the ChatRoom table if it doesn't exist
		database.MigrateChatRoomParticipant(db) // Initialize the ChatRoomParticipant table if it doesn't exist

		vars := mux.Vars(r)
		eventIDInt, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		eventID := uint(eventIDInt)

		user, err := GetUserFromToken(r, db)
		if err != nil {
			log.Printf("Error getting user from token: %v", err)
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		var chatRoomParticipants []models.ChatRoomParticipant
		if err := db.Where("user_id = ?", user.ID).Find(&chatRoomParticipants).Error; err != nil {
			http.Error(w, "Failed to retrieve chat room participants", http.StatusInternalServerError)
			return
		}

		var chatRoomIDs []uint
		for _, participant := range chatRoomParticipants {
			chatRoomIDs = append(chatRoomIDs, participant.ChatRoomID)
		}

		var chatRooms []models.ChatRoom
		if err := db.Where("event_id = ? AND id IN ?", eventID, chatRoomIDs).Find(&chatRooms).Error; err != nil {
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

// GetUnassociatedEmails retrieves the emails of users who are participants in the event but not associated with the chat room in ChatRoomParticipant
func GetUnassociatedEmails(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		database.MigrateChatRoom(db)            // Initialize the ChatRoom table if it doesn't exist
		database.MigrateChatRoomParticipant(db) // Initialize the ChatRoomParticipant table if it doesn't exist
		database.MigrateParticipant(db)         // Initialize the Participant table if it doesn't exist

		vars := mux.Vars(r)
		chatRoomID, err := strconv.Atoi(vars["chatRoomId"])
		if err != nil {
			http.Error(w, "Invalid chat room ID", http.StatusBadRequest)
			return
		}

		// Retrieve the ChatRoom to get the EventID
		var chatRoom models.ChatRoom
		if err := db.First(&chatRoom, chatRoomID).Error; err != nil {
			http.Error(w, "Chat room not found", http.StatusNotFound)
			return
		}

		eventID := chatRoom.EventID

		// Get participants for the event who are active and have responded
		var participants []models.Participant
		if err := db.Where("event_id = ? AND active = ? AND response = ?", eventID, true, true).Find(&participants).Error; err != nil {
			http.Error(w, "Failed to retrieve participants", http.StatusInternalServerError)
			return
		}

		// Get the IDs of users who are already in the chat room
		var chatRoomParticipants []models.ChatRoomParticipant
		if err := db.Where("chat_room_id = ?", chatRoomID).Find(&chatRoomParticipants).Error; err != nil {
			http.Error(w, "Failed to retrieve chat room participants", http.StatusInternalServerError)
			return
		}

		// Create a map of user IDs who are already in the chat room for easy lookup
		associatedUserIDs := make(map[uint]bool)
		for _, participant := range chatRoomParticipants {
			associatedUserIDs[participant.UserID] = true
		}

		// Get the emails of users who are not associated with the chat room
		var unassociatedEmails []string
		for _, participant := range participants {
			if _, exists := associatedUserIDs[participant.UserID]; !exists {
				var user models.User
				if err := db.First(&user, participant.UserID).Error; err == nil {
					unassociatedEmails = append(unassociatedEmails, user.Email)
				}
			}
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(unassociatedEmails)
	}
}
