package controllers_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"

	"backend/internal/controllers"
	"backend/internal/models"

	"github.com/gorilla/mux"
)

func TestAddItem(t *testing.T) {
	db := setupTestDB()

	// Create a test user and event
	testUser := models.User{
		Email:     "ar@metooptic.fr",
		Firstname: "Test",
		Lastname:  "User",
		Password:  "password",
		Role:      "user",
	}
	db.Create(&testUser)

	testEvent := models.Event{
		Name:        "Test Event",
		Description: "Event for testing",
		CreatedBy:   testUser.ID,
	}
	db.Create(&testEvent)

	// Make the test user a participant of the event
	testParticipant := models.Participant{
		UserID:  testUser.ID,
		EventID: testEvent.ID,
		Active:  true,
	}
	db.Create(&testParticipant)

	handler := controllers.AddItem(db)

	// Create a token for the test user
	token := generateTestToken(testUser.Email)

	itemRequest := models.ItemEvent{
		Name: "Test Item",
	}

	jsonItemRequest, _ := json.Marshal(itemRequest)
	req, _ := http.NewRequest("POST", "/events/"+strconv.Itoa(int(testEvent.ID))+"/items", bytes.NewBuffer(jsonItemRequest))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	rr := httptest.NewRecorder()
	router := mux.NewRouter()
	router.HandleFunc("/events/{eventId}/items", handler).Methods("POST")
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusCreated {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusCreated)
	}

	var returnedItem models.ItemEvent
	if err := json.NewDecoder(rr.Body).Decode(&returnedItem); err != nil {
		t.Errorf("handler returned invalid body: %v", err)
	}

	if returnedItem.Name != itemRequest.Name {
		t.Errorf("handler returned unexpected item: got %v want %v", returnedItem.Name, itemRequest.Name)
	}
}

// Util function to generate test token
func generateTestToken(email string) string {
	// This function should generate a valid JWT for the given email
	// You can mock or hardcode a valid token for testing purposes
	return "test_token"
}

func TestAddEvent(t *testing.T) {
	db := setupTestDB()

	// Create a test user
	testUser := models.User{
		Email:     "testadmin@example.com",
		Firstname: "Admin",
		Lastname:  "User",
		Password:  "password",
		Role:      "AdminPlatform",
	}
	db.Create(&testUser)

	handler := controllers.AddEvent(db)

	// Create a token for the test user
	token := generateTestToken(testUser.Email)

	eventRequest := models.Event{
		Name:        "Test Event",
		Description: "Event for testing",
	}

	jsonEventRequest, _ := json.Marshal(eventRequest)
	req, _ := http.NewRequest("POST", "/events", bytes.NewBuffer(jsonEventRequest))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	rr := httptest.NewRecorder()
	router := mux.NewRouter()
	router.HandleFunc("/events", handler).Methods("POST")
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusCreated {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusCreated)
	}

	var returnedEvent models.Event
	if err := json.NewDecoder(rr.Body).Decode(&returnedEvent); err != nil {
		t.Errorf("handler returned invalid body: %v", err)
	}

	if returnedEvent.Name != eventRequest.Name {
		t.Errorf("handler returned unexpected event: got %v want %v", returnedEvent.Name, eventRequest.Name)
	}
}

func TestGetAllEvents(t *testing.T) {
	db := setupTestDB()

	// Create a test event
	testEvent := models.Event{
		Name:        "Test Event",
		Description: "Event for testing",
	}
	db.Create(&testEvent)

	handler := controllers.GetAllEvents(db)

	req, _ := http.NewRequest("GET", "/events", nil)

	rr := httptest.NewRecorder()
	router := mux.NewRouter()
	router.HandleFunc("/events", handler).Methods("GET")
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	var events []models.Event
	if err := json.NewDecoder(rr.Body).Decode(&events); err != nil {
		t.Errorf("handler returned invalid body: %v", err)
	}

	if len(events) != 1 {
		t.Errorf("handler returned wrong number of events: got %v want %v", len(events), 1)
	}

	if events[0].Name != testEvent.Name {
		t.Errorf("handler returned unexpected event: got %v want %v", events[0].Name, testEvent.Name)
	}
}
