package models

import "gorm.io/datatypes"

// Event représente la structure d'un événement
type Event struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	Name            string         `json:"name" required:""`
	Description     string         `json:"description" required:""`
	Place           string         `json:"place"`
	DateStart       string         `json:"date_start"`
	DateEnd         string         `json:"date_end"`
	TransportActive bool           `json:"transport_active" gorm:"default:false"`
	Activities      datatypes.JSON `json:"activities"` // Utilisation de JSON pour les activités
	TransportStart  string         `json:"transport_start"`
	CreatedBy       uint           `json:"created_by"` // ID de l'utilisateur qui a créé l'événement
	Cagnotte        float64        `json:"cagnotte" gorm:"default:0"`
}

type EventTransportUpdate struct {
	TransportActive bool `json:"transport_active"`
}
