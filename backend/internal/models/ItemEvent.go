package models

type ItemEvent struct {
	ID      uint   `gorm:"primaryKey" json:"id"`
	Name    string `json:"name" gorm:"not null"`
	UserID  uint   `json:"user_id" gorm:"not null"`
	EventID uint   `json:"event_id" gorm:"not null"`
}
