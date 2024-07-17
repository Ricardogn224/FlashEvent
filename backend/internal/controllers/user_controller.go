package controllers

import (
	"backend/internal/database"
	"backend/internal/models"
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/golang-jwt/jwt"
	"github.com/gorilla/mux"
	"golang.org/x/crypto/bcrypt"
	"gopkg.in/gomail.v2"
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

func HasRole(user *models.User, roles ...string) bool {
	for _, role := range roles {
		if user.Role == role {
			return true
		}
	}
	return false
}

var jwtKey = []byte("your_secret_key")

type Claims struct {
    Email string `json:"email"`
    Role  string `json:"role"` // Ajouter ce champ
    jwt.StandardClaims

}

var otpStore = make(map[string]string)

// RegisterUser gère l'enregistrement d'un nouvel utilisateur
func RegisterUser(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser les tables nécessaires si elles n'existent pas
		database.MigrateAll(db)

		var user models.User
		if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
			http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
			return
		}

		// Valider les champs requis
		if user.Email == "" || user.Firstname == "" || user.Lastname == "" || user.Password == "" {
			http.Error(w, "Email, firstname, lastname and password are required fields", http.StatusBadRequest)
			return
		}

		// Vérifier si l'email existe déjà
		var existingUser models.User
		if err := db.Where("email = ?", user.Email).First(&existingUser).Error; err == nil {
			http.Error(w, "Email already exists", http.StatusConflict)
			return
		}

		// Attribuer le rôle "user" par défaut
		user.Role = "user"

		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
		if err != nil {
			http.Error(w, fmt.Sprintf("Error hashing password: %v", err), http.StatusInternalServerError)
			return
		}
		user.Password = string(hashedPassword)

		result := db.Create(&user)
		if result.Error != nil {
			http.Error(w, fmt.Sprintf("Error creating user: %v", result.Error), http.StatusInternalServerError)
			return
		}

		sendWelcomeEmail(user.Email)

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(user)
	}
}

// RegisterUser gère l'enregistrement d'un nouvel utilisateur
func RegisterUserAdmin(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Initialiser les tables nécessaires si elles n'existent pas
		database.MigrateAll(db)

		var user models.User
		if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
			http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
			return
		}

		// Verify user roles and permissions
		authUser, err := GetUserFromToken(r, db)
		if err != nil {
			log.Printf("Unauthorized: %v", err)
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		if authUser.Role != "AdminPlatform" && user.Role == "AdminPlatform" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		// Valider les champs requis
		if user.Email == "" || user.Firstname == "" || user.Lastname == "" || user.Password == "" {
			http.Error(w, "Email, firstname, lastname and password are required fields", http.StatusBadRequest)
			return
		}

		// Vérifier si l'email existe déjà
		var existingUser models.User
		if err := db.Where("email = ?", user.Email).First(&existingUser).Error; err == nil {
			http.Error(w, "Email already exists", http.StatusConflict)
			return
		}

		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
		if err != nil {
			http.Error(w, fmt.Sprintf("Error hashing password: %v", err), http.StatusInternalServerError)
			return
		}
		user.Password = string(hashedPassword)

		result := db.Create(&user)
		if result.Error != nil {
			http.Error(w, fmt.Sprintf("Error creating user: %v", result.Error), http.StatusInternalServerError)
			return
		}

		sendWelcomeEmail(user.Email)

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(user)
	}
}

// sendWelcomeEmail envoie un e-mail de bienvenue
func sendWelcomeEmail(email string) {
	mailer := gomail.NewMessage()
	mailer.SetHeader("From", os.Getenv("SMTP_USER"))
	mailer.SetHeader("To", email)
	mailer.SetHeader("Subject", "Welcome to Event Platform")
	mailer.SetBody("text/plain", "Thank you for registering!")

	dialer := gomail.NewDialer(os.Getenv("SMTP_HOST"), 465, os.Getenv("SMTP_USER"), os.Getenv("SMTP_PASS"))
	dialer.SSL = true

	if err := dialer.DialAndSend(mailer); err != nil {
		fmt.Println("Error sending welcome email:", err)
	}
}

// ForgotPassword gère la demande de réinitialisation du mot de passe
func ForgotPassword(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var request struct {
			Email string `json:"email"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		var user models.User
		if err := db.Where("email = ?", request.Email).First(&user).Error; err != nil {
			http.Error(w, "User not found", http.StatusNotFound)
			return

		}

		otp := fmt.Sprintf("%06d", rand.Intn(1000000))
		otpStore[request.Email] = otp
		sendOTPEmail(request.Email, otp)

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"message": "OTP sent to your email"})
	}
}

// sendOTPEmail envoie un e-mail contenant l'OTP
func sendOTPEmail(email, otp string) {
	mailer := gomail.NewMessage()
	mailer.SetHeader("From", os.Getenv("SMTP_USER"))
	mailer.SetHeader("To", email)
	mailer.SetHeader("Subject", "Password Reset OTP")
	mailer.SetBody("text/plain", fmt.Sprintf("Your OTP for password reset is: %s", otp))

	dialer := gomail.NewDialer(os.Getenv("SMTP_HOST"), 465, os.Getenv("SMTP_USER"), os.Getenv("SMTP_PASS"))
	dialer.SSL = true

	if err := dialer.DialAndSend(mailer); err != nil {
		fmt.Println("Error sending OTP email:", err)
	}
}

// ResetPassword gère la réinitialisation du mot de passe avec OTP
func ResetPassword(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var request struct {
			Email       string `json:"email"`
			OTP         string `json:"otp"`
			NewPassword string `json:"new_password"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		storedOTP, exists := otpStore[request.Email]
		if !exists || storedOTP != request.OTP {
			http.Error(w, "Invalid or expired OTP", http.StatusUnauthorized)
			return
		}

		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(request.NewPassword), bcrypt.DefaultCost)
		if err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		if err := db.Model(&models.User{}).Where("email = ?", request.Email).Update("password", string(hashedPassword)).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		delete(otpStore, request.Email)


		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"message": "Password reset successful"})
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

        expirationTime := time.Now().Add(24 * time.Hour) // Token valid for 24 hours
        claims := &Claims{
            Email: user.Email,
            Role:  user.Role, // Ajouter le rôle de l'utilisateur ici
            StandardClaims: jwt.StandardClaims{
            ExpiresAt: expirationTime.Unix(),
            },
        }

        token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
        tokenString, err := token.SignedString(jwtKey)
        if err != nil {
            http.Error(w, "Internal server error", http.StatusInternalServerError)
            return
        }


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
		return jwtKey, nil
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

// GetUserByID returns a user by their ID
func MyUser(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		// Vérifier les rôles de l'utilisateur
		user, err := GetUserFromToken(r, db)
		if err != nil {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(user)
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

// UpdateUserByID updates a user by their ID
func UpdateUserByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		id, err := strconv.Atoi(vars["userId"])
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		authUser, err := GetUserFromToken(r, db)
		if err != nil {
			log.Printf("Unauthorized: %v", err)
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		var updates map[string]interface{}
		if err := json.NewDecoder(r.Body).Decode(&updates); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		if authUser.Role != "AdminPlatform" && updates["role"].(string) == "AdminPlatform" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		if password, ok := updates["password"].(string); ok && password != "" {
			hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
			if err != nil {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
				return
			}
			updates["password"] = string(hashedPassword)
		} else {
			delete(updates, "password")
		}

		var existingUser models.User
		result := db.First(&existingUser, id)
		if result.Error != nil {
			if result.Error == gorm.ErrRecordNotFound {
				http.Error(w, "User not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		if err := db.Model(&existingUser).Updates(updates).Error; err != nil {
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(existingUser)
	}
}

// DeleteUserByID deletes a user by their ID
func DeleteUserByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		id, err := strconv.Atoi(vars["userId"])
		if err != nil {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		if err := db.Delete(&models.User{}, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "User not found", http.StatusNotFound)
			} else {
				http.Error(w, "Internal server error", http.StatusInternalServerError)
			}
			return
		}

		w.WriteHeader(http.StatusNoContent)
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

		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
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
