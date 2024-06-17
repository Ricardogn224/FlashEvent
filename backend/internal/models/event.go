package models

// Event représente la structure d'un événement
type Event struct {
	ID             uint   `gorm:"primaryKey" json:"id"`
	Name           string `json:"name" required:""`
	Description    string `json:"description" required:""`
	IsPrivate      bool   `json:"is_private"`
	InvitationLink string `json:"invitation_link,omitempty"`
}

// EventRequest represents the request body for adding an event
type EventAdd struct {
	Name        string `json:"name" validate:"required"`
	Description string `json:"description"`
	Email       string `json:"email"`
	IsPrivate   bool   `json:"is_private"`
}
