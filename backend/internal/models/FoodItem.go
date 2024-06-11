package models

// FoodItem représente les informations sur un article alimentaire pour un événement
type FoodItem struct {
	ID          uint   `gorm:"primaryKey"`
	EventID     uint   // ID de l'événement lié
	Description string // Description de l'article alimentaire
	Food        string // Nom de l'article alimentaire
}
