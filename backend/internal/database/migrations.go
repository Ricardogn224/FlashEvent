package database

import (
	"backend/internal/models"

	"gorm.io/gorm"
)

// MigrateEvent migre la table Event
func MigrateEvent(db *gorm.DB) {
	db.AutoMigrate(&models.Event{})
}

// MigrateFood migre la table FoodItem
func MigrateFood(db *gorm.DB) {
	db.AutoMigrate(&models.FoodItem{})
}

// MigrateTransportation migre la table Transportation
func MigrateTransportation(db *gorm.DB) {
	db.AutoMigrate(&models.Transportation{})
}

// MigrateParticipant migre la table Participant
func MigrateParticipant(db *gorm.DB) {
	db.AutoMigrate(&models.Participant{})
}

// MigrateItem migre la table ItemEvent
func MigrateItem(db *gorm.DB) {
	db.AutoMigrate(&models.ItemEvent{})
}

// MigrateMessage migre la table Message
func MigrateMessage(db *gorm.DB) {
	db.AutoMigrate(&models.Message{})
}

// MigrateChatRoom migre la table ChatRoom
func MigrateChatRoom(db *gorm.DB) {
	db.AutoMigrate(&models.ChatRoom{})
}

// MigrateUser migre la table User
func MigrateUser(db *gorm.DB) {
	db.AutoMigrate(&models.User{})
}

// MigrateUtilities migre la table Utilities
func MigrateUtilities(db *gorm.DB) {
	db.AutoMigrate(&models.Utilities{})
}

// MigrateAll migre toutes les tables
func MigrateAll(db *gorm.DB) {
	MigrateEvent(db)
	MigrateFood(db)
	MigrateTransportation(db)
	MigrateParticipant(db)
	MigrateMessage(db)
	MigrateItem(db)
	MigrateChatRoom(db)
	MigrateUser(db)
	MigrateUtilities(db)
}