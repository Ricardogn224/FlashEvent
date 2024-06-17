package models

type ItemEvent struct {
	ID             uint   `gorm:"primaryKey" json:"id"`
	Name           string `json:"name" required:""`
	Description    string `json:"description" required:""`
	IsPrivate      bool   `json:"is_private"`
	InvitationLink string `json:"invitation_link,omitempty"`
	Food           string `json:"food,omitempty"`            // Nourriture
	Logistics      string `json:"logistics,omitempty"`       // Logistique
	OtherUtilities string `json:"other_utilities,omitempty"` // Autres utilita
}

type ItemEventAdd struct {
	ID      uint   `gorm:"primaryKey" json:"id"`
	Name    string `json:"name" gorm:"not null"`
	Email   string `json:"email" gorm:"not null"`
	EventID uint   `json:"event_id" gorm:"not null"`
}
