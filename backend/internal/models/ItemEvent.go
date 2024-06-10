package models

type ItemEvent struct {
	ID      uint   `gorm:"primaryKey" json:"id"`
	Name    string `json:"name" gorm:"not null"`
	UserID  uint   `json:"user_id" gorm:"not null"`
	EventID uint   `json:"event_id" gorm:"not null"`
}

type ItemEventAdd struct {
	ID      uint   `gorm:"primaryKey" json:"id"`
	Name    string `json:"name" gorm:"not null"`
	Email   string `json:"email" gorm:"not null"`
	EventID uint   `json:"event_id" gorm:"not null"`
}
