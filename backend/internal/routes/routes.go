package routes

import (
	"backend/internal/controllers"
	"backend/internal/models"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/zc2638/swag"
	"github.com/zc2638/swag/endpoint"
	"gorm.io/gorm"
)

func RegisterRoutes(router *mux.Router, api *swag.API, db *gorm.DB) {
	api.AddEndpoint(
		endpoint.New(
			http.MethodGet, "/events",
			endpoint.Handler(http.HandlerFunc(controllers.GetAllEvents(db))),
			endpoint.Summary("Get all events"),
			endpoint.Description("Retrieve all events from the store"),
			endpoint.Response(http.StatusOK, "Successfully retrieved events", endpoint.SchemaResponseOption([]models.Event{})),
		),
		endpoint.New(
			http.MethodPost, "/event",
			endpoint.Handler(http.HandlerFunc(controllers.AuthenticatedAddEvent(db))),
			endpoint.Summary("Add a new event"),
			endpoint.Description("Add a new event to the store"),
			endpoint.Body(models.EventAdd{}, "Event object that needs to be added", true),
			endpoint.Response(http.StatusCreated, "Successfully added event", endpoint.SchemaResponseOption(models.Event{})),
		),
		endpoint.New(
			http.MethodGet, "/event/{eventId}",
			endpoint.Handler(http.HandlerFunc(controllers.AuthenticatedFindEventByID(db))),
			endpoint.Summary("Find event by ID"),
			endpoint.Path("eventId", "integer", "ID of event to return", true),
			endpoint.Response(http.StatusOK, "successful operation", endpoint.SchemaResponseOption(models.Event{})),
		),
		endpoint.New(
			http.MethodPut, "/event/{eventId}",
			endpoint.Handler(http.HandlerFunc(controllers.AuthenticatedUpdateEventByID(db))),
			endpoint.Path("eventId", "integer", "ID of event to update", true),
			endpoint.Body(models.Event{}, "Event object with updated details", true),
			endpoint.Response(http.StatusOK, "Successfully updated event", endpoint.SchemaResponseOption(models.Event{})),
		),
		endpoint.New(
			http.MethodPost, "/register",
			endpoint.Handler(http.HandlerFunc(controllers.RegisterUser(db))),
			endpoint.Summary("Register a new user"),
			endpoint.Description("Register a new user with a username and password"),
			endpoint.Body(models.User{}, "User object that needs to be registered", true),
			endpoint.Response(http.StatusCreated, "Successfully registered user", endpoint.SchemaResponseOption(models.User{})),
		),
		endpoint.New(
			http.MethodPost, "/login",
			endpoint.Handler(http.HandlerFunc(controllers.LoginUser(db))),
			endpoint.Summary("Login a user"),
			endpoint.Description("Login a user and get a token"),
			endpoint.Body(models.User{}, "User credentials", true),
			endpoint.Response(http.StatusOK, "Successfully logged in", endpoint.SchemaResponseOption(map[string]string{"token": ""})),
		),
		endpoint.New(
			http.MethodGet, "/users",
			endpoint.Handler(http.HandlerFunc(controllers.GetAllUsers(db))),
			endpoint.Summary("Get all users"),
			endpoint.Description("Retrieve all users"),
			endpoint.Response(http.StatusOK, "Successfully retrieved users", endpoint.SchemaResponseOption([]models.User{})),
		),
		endpoint.New(
			http.MethodPost, "/participant",
			endpoint.Handler(http.HandlerFunc(controllers.AddParticipant(db))),
			endpoint.Summary("Add a new participant"),
			endpoint.Description("Add a new participant to an event"),
			endpoint.Body(models.ParticipantAdd{}, "Participant object that needs to be added", true),
			endpoint.Response(http.StatusCreated, "Successfully added participant", endpoint.SchemaResponseOption(models.Participant{})),
		),
		endpoint.New(
			http.MethodGet, "/participants-event/{eventId}",
			endpoint.Handler(http.HandlerFunc(controllers.GetParticipantsByEventID(db))),
			endpoint.Summary("Get participants by event ID"),
			endpoint.Description("Retrieve participants associated with a specific event"),
			endpoint.Path("eventId", "integer", "ID of the event", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved participants", endpoint.SchemaResponseOption([]models.Participant{})),
		),
		endpoint.New(
			http.MethodPost, "/item",
			endpoint.Handler(http.HandlerFunc(controllers.AddItem(db))),
			endpoint.Summary("Add a new item"),
			endpoint.Description("Add a new item to an event"),
			endpoint.Body(models.ItemEvent{}, "Item object that needs to be added", true),
			endpoint.Response(http.StatusCreated, "Successfully added item", endpoint.SchemaResponseOption(models.ItemEvent{})),
		),
		endpoint.New(
			http.MethodGet, "/items",
			endpoint.Handler(http.HandlerFunc(controllers.GetAllItems(db))),
			endpoint.Summary("Get all items"),
			endpoint.Description("Retrieve all items"),
			endpoint.Response(http.StatusOK, "Successfully retrieved items", endpoint.SchemaResponseOption([]models.ItemEvent{})),
		),
		endpoint.New(
			http.MethodGet, "/items-event/{eventId}",
			endpoint.Handler(http.HandlerFunc(controllers.GetItemsByEventID(db))),
			endpoint.Summary("Get items by event ID"),
			endpoint.Description("Retrieve items associated with a specific event"),
			endpoint.Path("eventId", "integer", "ID of the event", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved items", endpoint.SchemaResponseOption([]models.ItemEvent{})),
		),
	)

	router.Path("/swagger/json").Methods("GET").Handler(api.Handler())
	router.PathPrefix("/swagger/ui").Handler(swag.UIHandler("/swagger/ui", "/swagger/json", true))

	api.Walk(func(path string, e *swag.Endpoint) {
		h := e.Handler.(http.HandlerFunc)
		router.Path(path).Methods(e.Method).Handler(h)
	})
}
