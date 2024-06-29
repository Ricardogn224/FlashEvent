package models

// Utilities représente les informations sur les utilitaires pour un événement
type Utilities struct {
	ID       uint   `gorm:"primaryKey"`
	EventID  uint   // ID de l'événement lié
	Material string // Nom du matériel
	Utility  string // Utilité du matériel
}
