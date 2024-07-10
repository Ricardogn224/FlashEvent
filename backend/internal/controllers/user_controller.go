package controllers

import (
	"backend/internal/config"
	"backend/internal/models"
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	log "github.com/sirupsen/logrus"

	"github.com/golang-jwt/jwt"
	"github.com/gorilla/mux"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func contains(slice []uint, item uint) bool {
	for _, v := range slice {
		if v == item {
			return true
		}
	}
	return false
}

var jwtKey = []byte("your_secret_key")

type Claims struct {
	Email string `json:"email"`
	jwt.StandardClaims
}

func init() {
	config.SetupLogger()
}

// MigrateUser crée la table User si elle n'existe pas
func MigrateUser(db *gorm.DB) {
	db.AutoMigrate(&models.User{})
}
func MigrateChat(db *gorm.DB) {
	db.AutoMigrate(&models.Message{}, &models.ChatRoom{})
}

// RegisterUser gère l'enregistrement d'un nouvel utilisateur
func RegisterUser(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser la table User si elle n'existe pas
		MigrateUser(db)

		// migrer chat
		MigrateChat(db)

		var user models.User
		if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
		if err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}
		user.Password = string(hashedPassword)

		result := db.Create(&user)
		if result.Error != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(user)
	}
}

// LoginUser gère la connexion d'un utilisateur
func LoginUser(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser la table User si elle n'existe pas
		MigrateUser(db)

		log.Info("Login request received")

		var credentials models.User
		if err := json.NewDecoder(r.Body).Decode(&credentials); err != nil {
			log.WithFields(log.Fields{
				"error": err,
			}).Error("Error decoding request body")
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		log.WithFields(log.Fields{
			"email": credentials.Email,
		}).Info("Attempting to fetch user from the database")

		var user models.User
		result := db.Where("email = ?", credentials.Email).First(&user)
		if result.Error != nil {
			log.WithFields(log.Fields{
				"email": credentials.Email,
				"error": result.Error,
			}).Error("User not found or error occurred while fetching user")
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		log.WithFields(log.Fields{
			"email": credentials.Email,
		}).Info("User found, verifying password")

		if bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(credentials.Password)) != nil {
			log.WithFields(log.Fields{
				"email": credentials.Email,
			}).Error("Password verification failed")
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		log.WithFields(log.Fields{
			"email": credentials.Email,
		}).Info("Password verification succeeded, generating JWT token")

		expirationTime := time.Now().Add(5 * time.Minute)
		claims := &Claims{
			Email: user.Email,
			StandardClaims: jwt.StandardClaims{
				ExpiresAt: expirationTime.Unix(),
			},
		}

		token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
		tokenString, err := token.SignedString(jwtKey)
		if err != nil {
			log.WithFields(log.Fields{
				"email": credentials.Email,
				"error": err,
			}).Error("Error signing JWT token")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		log.WithFields(log.Fields{
			"email": credentials.Email,
		}).Info("JWT token generated successfully")

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(map[string]string{"token": tokenString}); err != nil {
			log.WithFields(log.Fields{
				"email": credentials.Email,
				"error": err,
			}).Error("Error encoding response JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		log.WithFields(log.Fields{
			"email": credentials.Email,
		}).Info("Login successful, response sent")
	}
}

// GetAllUsers returns all users
func GetAllUsers(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var users []models.User

		log.Info("Fetching all users from the database")

		result := db.Find(&users)
		if result.Error != nil {
			log.WithFields(log.Fields{
				"error": result.Error,
			}).Error("Error occurred while fetching users from the database")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		log.WithFields(log.Fields{
			"count": len(users),
		}).Info("Successfully fetched users from the database")

		w.WriteHeader(http.StatusOK)
		if err := json.NewEncoder(w).Encode(users); err != nil {
			log.WithFields(log.Fields{
				"error": err,
			}).Error("Error occurred while encoding users to JSON")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		log.Info("Successfully sent response with users data")
	}
}

// GetAllUserEmails returns all user emails
func GetAllUserEmails(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		vars := mux.Vars(r)

		log.Info("Fetching all users emails available to an event")

		eventIDInt, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			log.WithFields(log.Fields{
				"error": err,
			}).Error("Invalid event ID")
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}
		eventID := uint(eventIDInt)

		context := log.WithFields(log.Fields{"event_id": eventID})

		// Fetch all users
		var users []models.User
		result := db.Select("id, email").Find(&users)
		if result.Error != nil {
			context.Error("Error while retrieving users email")
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		var participants []models.Participant
		if eventID != 0 {
			db.Where("event_id = ? AND (active = ? AND response = ? OR response = ?)", eventID, true, true, false).Find(&participants)
		}
		// Extract participant user IDs
		participantIDs := make([]uint, len(participants))
		for i, participant := range participants {
			participantIDs[i] = participant.UserID
		}

		// Filter out participants from the user list
		emails := make([]string, 0)
		for _, user := range users {
			if !contains(participantIDs, user.ID) {
				emails = append(emails, user.Email)
			}
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(emails)

		context.Info("Successfully sent emails available data")
	}
}

// GetUserByID returns a user by their ID
func GetUserByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)

		log.Info("Fetching an user with id")
		id, err := strconv.Atoi(vars["userId"])
		if err != nil {
			log.WithFields(log.Fields{
				"error": err,
			}).Error("Invalid user ID")
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		context := log.WithFields(log.Fields{"user_id": id})
		context.Info("Attempting to fetch user")

		var user models.User
		result := db.First(&user, id)
		if result.Error != nil {
			if result.Error == gorm.ErrRecordNotFound {
				context.Error("Unknown user")
				http.Error(w, "User not found", http.StatusNotFound)
			} else {
				context.Error("Problem occured while retrieving the user")
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(user)
		context.Info("Successfully sent user data")
	}
}

// GetUserByID returns a user by their ID
func GetUserByEmail(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)

		log.Info("Fetching an user with email")

		email := params["email"]

		context := log.WithFields(log.Fields{"email": email})
		context.Info("Attempting to fetch user")

		var user models.User
		if err := db.Where("email = ?", email).First(&user).Error; err != nil {
			context.Info("User not found with that email")
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(user)

		context.Info("Successfully sent user data")
	}
}

// AuthMiddleware vérifie le token JWT
func AuthMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		tokenStr := authHeader[len("Bearer "):]
		claims := &Claims{}

		token, err := jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
			return jwtKey, nil
		})
		if err != nil {
			if err == jwt.ErrSignatureInvalid {
				http.Error(w, "Unauthorized", http.StatusUnauthorized)
				return
			}
			http.Error(w, "Bad request", http.StatusBadRequest)
			return
		}
		if !token.Valid {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		next.ServeHTTP(w, r)
	})
}
