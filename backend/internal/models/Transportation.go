package models

// Transportation représente les informations sur le transport pour un événement
type Transportation struct {
	ID         uint   `gorm:"primaryKey"`
	EventID    uint   // ID de l'événement lié
	Vehicle    string // Nom du véhicule
	SeatNumber int    // Nombre de places dans le véhicule
}
