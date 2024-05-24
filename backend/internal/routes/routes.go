package routes

import (
	"backend/internal/controllers"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/zc2638/swag"
	"github.com/zc2638/swag/endpoint"
	"gorm.io/gorm"
)

func RegisterRoutes(router *mux.Router, api *swag.API, db *gorm.DB) {
	api.AddEndpoint(
		endpoint.New(
			http.MethodPost, "/event",
			endpoint.Handler(controllers.AuthMiddleware(http.HandlerFunc(controllers.AddEvent(db)))),
			endpoint.Summary("Add a new event"),
			endpoint.Description("Add a new event to the store"),
			endpoint.Body(controllers.Event{}, "Event object that needs to be added", true),
			endpoint.Response(http.StatusCreated, "Successfully added event", endpoint.SchemaResponseOption(controllers.Event{})),
		),
		endpoint.New(
			http.MethodGet, "/event/{eventId}",
			endpoint.Handler(http.HandlerFunc(controllers.FindEventByID(db))), // Correction ici
			endpoint.Summary("Find event by ID"),
			endpoint.Path("eventId", "integer", "ID of event to return", true),
			endpoint.Response(http.StatusOK, "successful operation", endpoint.SchemaResponseOption(controllers.Event{})),
		),
		endpoint.New(
			http.MethodPut, "/event/{eventId}",
			endpoint.Handler(controllers.AuthMiddleware(http.HandlerFunc(controllers.UpdateEventByID(db)))),
			endpoint.Path("eventId", "integer", "ID of event to update", true),
			endpoint.Body(controllers.Event{}, "Event object with updated details", true),
			endpoint.Response(http.StatusOK, "Successfully updated event", endpoint.SchemaResponseOption(controllers.Event{})),
		),
		endpoint.New(
			http.MethodPost, "/register",
			endpoint.Handler(http.HandlerFunc(controllers.RegisterUser)), // Correction ici
			endpoint.Summary("Register a new user"),
			endpoint.Description("Register a new user with a username and password"),
			endpoint.Body(controllers.User{}, "User object that needs to be registered", true),
			endpoint.Response(http.StatusCreated, "Successfully registered user", endpoint.SchemaResponseOption(controllers.User{})),
		),
		endpoint.New(
			http.MethodPost, "/login",
			endpoint.Handler(http.HandlerFunc(controllers.LoginUser)), // Correction ici
			endpoint.Summary("Login a user"),
			endpoint.Description("Login a user and get a token"),
			endpoint.Body(controllers.User{}, "User credentials", true),
			endpoint.Response(http.StatusOK, "Successfully logged in", endpoint.SchemaResponseOption(map[string]string{"message": ""})),
		),
	)

	router.Path("/swagger/json").Methods("GET").Handler(api.Handler())
	router.PathPrefix("/swagger/ui").Handler(swag.UIHandler("/swagger/ui", "/swagger/json", true))

	api.Walk(func(path string, e *swag.Endpoint) {
		h := e.Handler.(http.HandlerFunc)
		router.Path(path).Methods(e.Method).Handler(h)
	})
}
