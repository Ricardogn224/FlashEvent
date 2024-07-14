package models

// User représente la structure d'un utilisateur
type User struct {
	ID        uint   `gorm:"primaryKey" json:"id"`
	Email     string `gorm:"unique;not null" json:"email"`
	Firstname string `json:"firstname" required:""`
	Lastname  string `json:"lastname" required:""`
	Username  string `json:"username" required:""`
	Password  string `json:"password" required:""`
	Role      string `json:"role" gorm:"default:user"` // Ajout du champ Role
}
