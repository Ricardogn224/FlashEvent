package models

// Participant représente un participant à un événement
type Participant struct {
	ID               uint    `gorm:"primaryKey" json:"id"`
	UserID           uint    `json:"user_id" gorm:"not null"`
	User             User    `gorm:"foreignKey:UserID" json:"user"`
	EventID          uint    `json:"event_id" gorm:"not null"`
	Event            Event   `gorm:"foreignKey:EventID" json:"event"`
	TransportationID uint    `json:"transportation_id"`
	Active           bool    `json:"active" gorm:"default:false"`   // New active field
	Response         bool    `json:"response" gorm:"default:false"` // New active field
	Present          bool    `json:"present" gorm:"default:false"`
	Contribution     float64 `json:"contribution" gorm:"default:0"`
}

// ParticipantAdd représente les données nécessaires pour ajouter un participant
type ParticipantAdd struct {
	EventID uint   `json:"event_id" gorm:"not null"`
	Email   string `json:"email"`
}

// ParticipantWithUser représente un participant avec les informations utilisateur
type ParticipantWithUser struct {
	UserID           uint   `json:"user_id"`
	Email            string `json:"email"`
	Firstname        string `json:"firstname"`
	Lastname         string `json:"lastname"`
	EventID          uint   `json:"event_id"`
	ParticipantID    uint   `json:"participant_id"`
	TransportationID uint   `json:"transportation_id"`
}

// Invitation représente une invitation à un événement
type Invitation struct {
	ParticipantID uint   `json:"participant_id"`
	EventID       uint   `json:"event_id"`
	EventName     string `json:"event_name"`
	UserID        uint   `json:"user_id"`
}

// InvitationAnswer représente la réponse à une invitation
type InvitationAnswer struct {
	ParticipantID uint `json:"participant_id"`
	Active        bool `json:"active"`
}
