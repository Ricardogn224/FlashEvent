package models

import "gorm.io/gorm"

// Cagnotte représente une cagnotte associée à un événement
type Cagnotte struct {
	ID      uint    `gorm:"primaryKey" json:"id"`
	EventID uint    `json:"event_id"`
	Total   float64 `json:"total"`
}

// Contribution représente une contribution à une cagnotte
type Contribution struct {
	ID            uint    `gorm:"primaryKey" json:"id"`
	CagnotteID    uint    `json:"cagnotte_id"`
	ParticipantID uint    `json:"participant_id"`
	Amount        float64 `json:"amount"`
}

// MigrateCagnotte initialise la table Cagnotte
func MigrateCagnotte(db *gorm.DB) {
	db.AutoMigrate(&Cagnotte{})
}

// MigrateContribution initialise la table Contribution
func MigrateContribution(db *gorm.DB) {
	db.AutoMigrate(&Contribution{})
}
