package models

type Participant struct {
	ID      uint  `gorm:"primaryKey" json:"id"`
	UserID  uint  `json:"user_id" gorm:"not null"`
	User    User  `gorm:"foreignKey:UserID"`
	EventID uint  `json:"event_id" gorm:"not null"`
	Event   Event `gorm:"foreignKey:EventID"`
	Active  bool  `json:"active" gorm:"default:true"` // New active field
}

type ParticipantAdd struct {
	UserID  uint `json:"user_id" gorm:"not null"`
	EventID uint `json:"event_id" gorm:"not null"`
	Active  bool `json:"active" gorm:"default:true"` // New active field
}
