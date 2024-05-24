package models

// User représente la structure d'un utilisateur
type User struct {
	ID       int64  `json:"id"`
	Username string `json:"username" required:""`
	Password string `json:"password" required:""`
}
