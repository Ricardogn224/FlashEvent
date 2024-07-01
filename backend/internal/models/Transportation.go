package models

// Transportation représente les informations sur le transport pour un événement
type Transportation struct {
	ID         uint   `gorm:"primaryKey" json:"id"`
	EventID    uint   `json:"event_id" gorm:"not null"`
	UserID     uint   `json:"user_id"`
	Vehicle    string `json:"vehicle"`
	SeatNumber int    `json:"seat_number"`
}

type TransportationAdd struct {
	Email      string `json:"email"`
	Vehicle    string `json:"vehicle"`
	SeatNumber int    `json:"seat_number"`
}
