package models

import "time"

// Event représente la structure d'un événement
type Event struct {
	ID          int64     `json:"id"`
	Name        string    `json:"name" required:""`
	Date        time.Time `json:"date" required:""`
	Description string    `json:"description" required:""`
}
