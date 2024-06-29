package models

import "time"

// Message représente un message dans une salle de chat
type Message struct {
	ID         uint      `gorm:"primaryKey" json:"id"`
	ChatRoomID uint      `json:"chat_room_id"`
	UserID     uint      `json:"user_id"`
	Content    string    `json:"content"`
	Timestamp  time.Time `json:"timestamp"`
}

type MessageAdd struct {
	Email   string `json:"email"`
	Content string `json:"content"`
}

type MessageResponse struct {
	ID         uint      `gorm:"primaryKey" json:"id"`
	ChatRoomID uint      `json:"chat_room_id"`
	UserID     uint      `json:"user_id"`
	Email      string    `json:"email" required:""`
	Username   string    `json:"username" required:""`
	Content    string    `json:"content"`
	Timestamp  time.Time `json:"timestamp"`
}
