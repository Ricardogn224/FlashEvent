package models

import "gorm.io/gorm"

type ChatRoom struct {
	gorm.Model
	ID      uint   `gorm:"primaryKey" json:"id"`
	Name    string `json:"name" required:""`
	EventID uint   `json:"event_id" gorm:"not null"`
}
