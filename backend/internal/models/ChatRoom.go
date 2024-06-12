package models

import "gorm.io/gorm"

type ChatRoom struct {
	gorm.Model
	EventID  uint
	Messages []Message
}
