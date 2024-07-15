package models

// Event représente la structure d'un événement
type Feature struct {
	ID     uint   `gorm:"primaryKey" json:"id"`
	Name   string `json:"name" required:""`
	Active bool   `json:"transport_active" gorm:"default:false"`
}
