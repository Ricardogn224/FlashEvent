package models

// Event représente la structure d'un événement
type Event struct {
	ID             uint   `gorm:"primaryKey" json:"id"`
	Name           string `json:"name" required:""`
	Description    string `json:"description" required:""`
	Place          string `json:"place" required:""`
	Date           string `json:"description" required:""`
	IsPrivate      bool   `json:"is_private"`
	InvitationLink string `json:"invitation_link,omitempty"`
	TransportActive bool   `json:"transport_active" gorm:"default:false"`
}

// EventRequest represents the request body for adding an event
type EventAdd struct {
	Name        string `json:"name" validate:"required"`
	Description string `json:"description"`
	Email       string `json:"email"`
	Place       string `json:"email validate:"required"`
	Date        string `json:"email validate:"required"`
	IsPrivate   bool   `json:"is_private"`
	TransportActive bool   `json:"transport_active"`
}

type EventTransportUpdate struct {
	TransportActive bool `json:"transport_active"`
}
