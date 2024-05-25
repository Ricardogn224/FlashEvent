package models

// Event représente la structure d'un événement
type Event struct {
	ID          int64  `json:"id"`
	Name        string `json:"name" required:""`
	Description string `json:"description" required:""`
}
