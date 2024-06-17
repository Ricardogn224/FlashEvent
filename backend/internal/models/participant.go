package models

type Participant struct {
	ID       uint  `gorm:"primaryKey" json:"id"`
	UserID   uint  `json:"user_id" gorm:"not null"`
	User     User  `gorm:"foreignKey:UserID"`
	EventID  uint  `json:"event_id" gorm:"not null"`
	Event    Event `gorm:"foreignKey:EventID"`
	Active   bool  `json:"active" gorm:"default:false"`   // New active field
	Response bool  `json:"response" gorm:"default:false"` // New active field
}

type ParticipantAdd struct {
	EventID uint   `json:"event_id" gorm:"not null"`
	Email   string `json:"email"`
}
