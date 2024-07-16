// test/test_utils.go
package test

import (
	"backend/internal/database"
	"backend/internal/models"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func SetupTestDB() *gorm.DB {
	db, err := gorm.Open(sqlite.Open("file::memory:?cache=shared"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	database.MigrateAll(db)
	return db
}

func GetTokenForUser(user models.User) string {
	// Generate a JWT token for testing (you might need to use a real token generator)
	return "Bearer your_generated_token"
}
