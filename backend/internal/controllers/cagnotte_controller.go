package controllers

import (
	"backend/internal/models"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"gorm.io/gorm"
)

// AddCagnotte ajoute une nouvelle cagnotte à un événement
func AddCagnotte(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		models.MigrateCagnotte(db)
		models.MigrateContribution(db)

		vars := mux.Vars(r)
		eventID, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		cagnotte := models.Cagnotte{
			EventID: uint(eventID),
			Total:   0,
		}

		if err := db.Create(&cagnotte).Error; err != nil {
			http.Error(w, "Failed to create cagnotte", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(cagnotte)
	}
}

// ContributeToCagnotte permet à un utilisateur de contribuer à une cagnotte
func ContributeToCagnotte(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		models.MigrateCagnotte(db)
		models.MigrateContribution(db)

		vars := mux.Vars(r)
		cagnotteID, err := strconv.Atoi(vars["cagnotteId"])
		if err != nil {
			http.Error(w, "Invalid cagnotte ID", http.StatusBadRequest)
			return
		}

		var contribution models.Contribution
		if err := json.NewDecoder(r.Body).Decode(&contribution); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		contribution.CagnotteID = uint(cagnotteID)

		// Update the cagnotte total
		var cagnotte models.Cagnotte
		if err := db.First(&cagnotte, cagnotteID).Error; err != nil {
			http.Error(w, "Cagnotte not found", http.StatusNotFound)
			return
		}
		cagnotte.Total += contribution.Amount

		if err := db.Save(&cagnotte).Error; err != nil {
			http.Error(w, "Failed to update cagnotte", http.StatusInternalServerError)
			return
		}

		if err := db.Create(&contribution).Error; err != nil {
			http.Error(w, "Failed to contribute to cagnotte", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(contribution)
	}
}

// GetContributorsByCagnotteID retourne la liste des contributeurs d'une cagnotte
func GetContributorsByCagnotteID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		models.MigrateCagnotte(db)
		models.MigrateContribution(db)

		vars := mux.Vars(r)
		cagnotteID, err := strconv.Atoi(vars["cagnotteId"])
		if err != nil {
			http.Error(w, "Invalid cagnotte ID", http.StatusBadRequest)
			return
		}

		var contributions []models.Contribution
		if err := db.Where("cagnotte_id = ?", cagnotteID).Find(&contributions).Error; err != nil {
			http.Error(w, "Failed to retrieve contributions", http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(contributions)
	}
}

// GetCagnotteByEventID returns the cagnotte for a given event ID
func GetCagnotteByEventID(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		models.MigrateCagnotte(db)
		models.MigrateContribution(db)

		vars := mux.Vars(r)
		eventID, err := strconv.Atoi(vars["eventId"])
		if err != nil {
			http.Error(w, "Invalid event ID", http.StatusBadRequest)
			return
		}

		var cagnotte models.Cagnotte
		if err := db.Where("event_id = ?", eventID).First(&cagnotte).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				http.Error(w, "Cagnotte not found", http.StatusNotFound)
			} else {
				http.Error(w, "Failed to retrieve cagnotte", http.StatusInternalServerError)
			}
			return
		}

		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(cagnotte)
	}
}
