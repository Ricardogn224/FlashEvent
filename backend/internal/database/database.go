package database

import (
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// ConnectDB crée une connexion à la base de données PostgreSQL avec GORM
func ConnectDB() (*gorm.DB, error) {
	dsn := "user=janire password=password dbname=articlesDB port=5432 sslmode=disable host=localhost"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, err
	}
	return db, nil
}
