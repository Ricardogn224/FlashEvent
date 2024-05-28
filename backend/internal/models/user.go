package models

// User représente la structure d'un utilisateur
type User struct {
	ID        uint   `gorm:"primaryKey" json:"id"`
	Email     string `json:"email" required:""`
	Firstname string `json:"firstname" required:""`
	Lastname  string `json:"lastname" required:""`
	Username  string `json:"username" required:""`
	Password  string `json:"password" required:""`
}
