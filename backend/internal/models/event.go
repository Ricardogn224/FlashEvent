package models

import (
	"gorm.io/datatypes"
)

// Event représente la structure d'un événement
type Event struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	Name            string         `json:"name" required:""`
	Description     string         `json:"description" required:""`
	TransportActive bool           `json:"trnsport_active" gorm:"default:false"`
	Activities      datatypes.JSON `json:"activities"` // Utilisation de JSON pour les activités
	TransportStart  string         `json:"transport_start"`
}

// EventRequest represents the request body for adding an event
type EventAdd struct {
	Name            string `json:"name" validate:"required"`
	Description     string `json:"description"`
	Email           string `json:"email"`
	TransportActive bool   `json:"transport_active"`
}

type EventTransportUpdate struct {
	TransportActive bool `json:"transport_active"`
}
