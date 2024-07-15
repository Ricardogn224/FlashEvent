package models

import "gorm.io/gorm"

type ChatRoomParticipant struct {
	gorm.Model
	UserID     uint   `json:"user_id"`
	ChatRoomID uint   `json:"chat_room_id"`
	RoomType   string `json:"room_type"` // Public or Private
}
