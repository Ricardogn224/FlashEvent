package controllers

import (
	"backend/internal/database"
	"backend/internal/models"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

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

var JwtKey = []byte("your_secret_key")

type Claims struct {
	Email string `json:"email"`
	jwt.StandardClaims
}

// RegisterUser gère l'enregistrement d'un nouvel utilisateur
func RegisterUser(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser les tables nécessaires si elles n'existent pas
		database.MigrateAll(db)

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
		// Initialiser les tables nécessaires si elles n'existent pas
		database.MigrateAll(db)

		var credentials models.User
		if err := json.NewDecoder(r.Body).Decode(&credentials); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		var user models.User
		result := db.Where("email = ?", credentials.Email).First(&user)
		if result.Error != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		if bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(credentials.Password)) != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		expirationTime := time.Now().Add(5 * time.Minute)
		claims := &Claims{
			Email: user.Email,
			StandardClaims: jwt.StandardClaims{
				ExpiresAt: expirationTime.Unix(),
			},
		}

		token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
		tokenString, err := token.SignedString(JwtKey)
		if err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		// Au lieu de définir le cookie, on renvoie le token dans la réponse JSON
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"token": tokenString})
	}
}

func GetUserFromToken(r *http.Request, db *gorm.DB) (*models.User, error) {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return nil, fmt.Errorf("authorization header missing")
	}

	tokenString := strings.TrimPrefix(authHeader, "Bearer ")

	claims := &Claims{}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return JwtKey, nil
	})

	if err != nil || !token.Valid {
		return nil, fmt.Errorf("invalid token")
	}

	var user models.User
	if err := db.Where("email = ?", claims.Email).First(&user).Error; err != nil {
		return nil, fmt.Errorf("user not found")
	}

	return &user, nil
}

// GetAllUsers returns all users
func GetAllUsers(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var users []models.User
		result := db.Find(&users)
		if result.Error != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(users)
	}
}

// GetAllUserEmails returns all user emails
func GetAllUserEmails(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		eventIDInt, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}
		eventID := uint(eventIDInt)

		// Fetch all users
		var users []models.User
		result := db.Select("id, email").Find(&users)
		if result.Error != nil {
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
	}
}

// GetUserByID returns a user by their ID
func GetUserByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		id, err := strconv.Atoi(vars["userId"])
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		var user models.User
		result := db.First(&user, id)
		if result.Error != nil {
			if result.Error == gorm.ErrRecordNotFound {
				http.Error(w, "User not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(user)
	}
}

// GetUserByEmail returns a user by their email
func GetUserByEmail(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)
		email := params["email"]

		var user models.User
		if err := db.Where("email = ?", email).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(user)
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
			return JwtKey, nil
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
