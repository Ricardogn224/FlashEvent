package models

import "gorm.io/gorm"

type ChatRoomParticipant struct {
	gorm.Model
	ID         uint   `gorm:"primaryKey" json:"id"`
	UserID     uint   `json:"user_id"`
	ChatRoomID uint   `json:"chat_room_id"`
	RoomType   string `json:"room_type"` // Public or Private
}
