package controllers

import (
	"backend/internal/models"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

func MigrateFeature(db *gorm.DB) {
	db.AutoMigrate(&models.Feature{})
}

// AddFeature adds a new feature
func AddFeature(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		MigrateFeature(db)
		var feature models.Feature
		if err := json.NewDecoder(r.Body).Decode(&feature); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		if err := db.Create(&feature).Error; err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(feature)
	}
}

// GetAllFeatures retrieves all features
func GetAllFeatures(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		MigrateFeature(db)
		var features []models.Feature
		if err := db.Find(&features).Error; err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(features)
	}
}

// GetFeatureByID retrieves a feature by its ID
func GetFeatureByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)
		id, err := strconv.Atoi(params["featureId"])
		if err != nil {
			http.Error(w, "Invalid feature ID", http.StatusBadRequest)
			return
		}

		var feature models.Feature
		if err := db.First(&feature, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Feature not found", http.StatusNotFound)
			} else {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(feature)
	}
}

// UpdateFeatureByID updates a feature by its ID
func UpdateFeatureByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)
		id, err := strconv.Atoi(params["featureId"])
		if err != nil {
			http.Error(w, "Invalid feature ID", http.StatusBadRequest)
			return
		}

		var feature models.Feature
		if err := db.First(&feature, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Feature not found", http.StatusNotFound)
			} else {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
			return
		}

		if err := json.NewDecoder(r.Body).Decode(&feature); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		if err := db.Save(&feature).Error; err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(feature)
	}
}

// DeleteFeatureByID deletes a feature by its ID
func DeleteFeatureByID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		params := mux.Vars(r)
		id, err := strconv.Atoi(params["featureId"])
		if err != nil {
			http.Error(w, "Invalid feature ID", http.StatusBadRequest)
			return
		}

		if err := db.Delete(&models.Feature{}, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Feature not found", http.StatusNotFound)
			} else {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
			return
		}

		w.WriteHeader(http.StatusNoContent)
	}
}

func GetFeatureActive(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		keyword := "transport" // The keyword to search for in feature names

		var feature models.Feature
		if err := db.Where("name LIKE ?", "%"+keyword+"%").First(&feature).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				// If no feature with the keyword in its name is found, return false for active status
				json.NewEncoder(w).Encode(false)
			} else {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
			return
		}

		// Return the active status of the found feature
		json.NewEncoder(w).Encode(feature.Active)
	}
}
