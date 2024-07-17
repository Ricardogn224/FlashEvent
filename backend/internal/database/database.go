package database

import (
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type DB interface {
	Create(value interface{}) error
	Find(out interface{}, where ...interface{}) error
	Where(query interface{}, args ...interface{}) DB
	First(out interface{}, where ...interface{}) error
	Delete(value interface{}, where ...interface{}) error
	Update(column string, value interface{}) error
}
type GormDB struct {
	DB *gorm.DB
}

func (g *GormDB) Create(value interface{}) error {
	return g.DB.Create(value).Error
}

func (g *GormDB) Find(out interface{}, where ...interface{}) error {
	return g.DB.Find(out, where...).Error
}

func ConnectDB() (*gorm.DB, error) {
	dsn := "user=janire password=password dbname=articlesDB port=5432 sslmode=disable host=database"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, err
	}
	return db, nil
}

func NewGormDB(db *gorm.DB) *GormDB {
	return &GormDB{DB: db}
}
