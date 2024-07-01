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
			endpoint.Handler(controllers.GetAllEvents(db)),
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
			http.MethodGet, "/users/{userId}",
			endpoint.Handler(http.HandlerFunc(controllers.GetUserByID(db))),
			endpoint.Summary("Get user by ID"),
			endpoint.Description("Retrieve a user by their ID"),
			endpoint.Path("userId", "integer", "ID of the user to retrieve", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved user", endpoint.SchemaResponseOption(models.User{})),
		),
		endpoint.New(
			http.MethodGet, "/users-email/{email}",
			endpoint.Handler(http.HandlerFunc(controllers.GetUserByEmail(db))),
			endpoint.Summary("Get user by email"),
			endpoint.Description("Retrieve a user by the email"),
			endpoint.Path("email", "string", "Email of the user to retrieve", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved user", endpoint.SchemaResponseOption(models.User{})),
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
			endpoint.Body(models.ItemEventAdd{}, "Item object that needs to be added", true),
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
		endpoint.New(
			http.MethodPost, "/event/{eventId}/add-food",
			endpoint.Handler(http.HandlerFunc(controllers.AddFoodToEvent(db))),
			endpoint.Summary("Ajouter de la nourriture à un événement"),
			endpoint.Description("Permettre à un participant d'ajouter de la nourriture à un événement"),
			endpoint.Path("eventId", "integer", "ID de l'événement", true),
			endpoint.Body(struct {
				Food string `json:"food"`
			}{}, "Nourriture à ajouter à l'événement", true),
			endpoint.Response(http.StatusCreated, "Nourriture ajoutée avec succès à l'événement", endpoint.SchemaResponseOption(models.Event{})),
		),

		endpoint.New(
			http.MethodPost, "/event/{eventId}/transportations",
			endpoint.Handler(http.HandlerFunc(controllers.AddTransportationToEvent(db))),
			endpoint.Summary("Ajouter un moyen de transport à un événement"),
			endpoint.Description("Permettre à un participant d'ajouter un moyen de transport à un événement"),
			endpoint.Path("eventId", "integer", "ID de l'événement", true),
			endpoint.Body(models.TransportationAdd{}, "transportation that needs to be added", true),
			endpoint.Response(http.StatusCreated, "Transport ajouté avec succès à l'événement", endpoint.SchemaResponseOption(models.Transportation{})),
		),

		endpoint.New(
			http.MethodGet, "/get-participant/{userId}",
			endpoint.Handler(controllers.GetParticipantByUserId(db)),
			endpoint.Summary("Get transportation by event ID"),
			endpoint.Path("id", "string", "Id of the user", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved participant", endpoint.SchemaResponseOption(models.Participant{})),
		),
		endpoint.New(
			http.MethodPatch, "/participants/{participantId}",
			endpoint.Handler(http.HandlerFunc(controllers.UpdateParticipant(db))),
			endpoint.Summary("Modifier un participant"),
			endpoint.Description("Modifier participant d'un événement"),
			endpoint.Path("participantId", "integer", "ID du particpant", true),
			endpoint.Body(models.Participant{}, "Data Participant", true),
			endpoint.Response(http.StatusCreated, "Participant modifié avec succès", endpoint.SchemaResponseOption(models.Participant{})),
		),
		endpoint.New(
			http.MethodGet, "/event/{eventId}/transportations",
			endpoint.Handler(controllers.GetTransportationByEvent(db)),
			endpoint.Summary("Get transportation by event ID"),
			endpoint.Path("eventId", "integer", "ID of event to return transportation details for", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved transportation details", endpoint.SchemaResponseOption([]models.Transportation{})),
		),
		endpoint.New(
			http.MethodGet, "/transportation/{transportationId}/participants",
			endpoint.Handler(controllers.GetParticipantsWithUserByTransportationID(db)),
			endpoint.Summary("Get transportation by transportation ID"),
			endpoint.Path("transportationId", "integer", "ID of transportation to return participant details for", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved participants for transportation", endpoint.SchemaResponseOption([]models.ParticipantWithUser{})),
		),
		endpoint.New(
			http.MethodPost, "/event/{eventId}/add-utilities",
			endpoint.Handler(http.HandlerFunc(controllers.AddUtilitiesToEvent(db))),
			endpoint.Summary("Ajouter des utilitaires à un événement"),
			endpoint.Description("Permettre à un participant d'ajouter des utilitaires à un événement"),
			endpoint.Path("eventId", "integer", "ID de l'événement", true),
			endpoint.Body(struct {
				Utilities string `json:"utilities"`
			}{}, "Utilitaires à ajouter à l'événement", true),
			endpoint.Response(http.StatusCreated, "Utilitaires ajoutés avec succès à l'événement", endpoint.SchemaResponseOption(models.Event{})),
		),
		endpoint.New(
			http.MethodPost, "/event/{eventId}/chat-room",
			endpoint.Handler(http.HandlerFunc(controllers.AddChatRoom(db))),
			endpoint.Summary("Add a new chat room"),
			endpoint.Description("Add a new chat room for a specific event"),
			endpoint.Path("eventId", "integer", "ID of the event", true),
			endpoint.Body(models.ChatRoom{}, "ChatRoom object to add", true),
			endpoint.Response(http.StatusCreated, "Chat room created", endpoint.SchemaResponseOption(models.ChatRoom{})),
		),
		endpoint.New(
			http.MethodGet, "/event/{eventId}/chat-rooms",
			endpoint.Handler(http.HandlerFunc(controllers.GetChatRooms(db))),
			endpoint.Summary("Get chat rooms"),
			endpoint.Description("Retrieve all chat rooms for a specific event"),
			endpoint.Path("eventId", "integer", "ID of the event", true),
			endpoint.Response(http.StatusOK, "Chat rooms retrieved", endpoint.SchemaResponseOption([]models.ChatRoom{})),
		),
		endpoint.New(
			http.MethodPost, "/event/{chatRoomId}/message",
			endpoint.Handler(http.HandlerFunc(controllers.SendMessage(db))),
			endpoint.Summary("Send a message"),
			endpoint.Description("Send a message in the event chat room"),
			endpoint.Path("chatRoomId", "integer", "ID of the chat-room", true),
			endpoint.Body(models.MessageAdd{}, "Message object", true),
			endpoint.Response(http.StatusCreated, "Message sent", endpoint.SchemaResponseOption(models.Message{})),
		),
		endpoint.New(
			http.MethodGet, "/chat-rooms/{chatRoomId}/messages",
			endpoint.Handler(http.HandlerFunc(controllers.GetMessagesByChatRoom(db))),
			endpoint.Summary("Get messages"),
			endpoint.Description("Retrieve messages from the event chat room"),
			endpoint.Path("chatRoomId", "integer", "ID of the chat room", true),
			endpoint.Response(http.StatusOK, "Messages retrieved", endpoint.SchemaResponseOption([]models.MessageResponse{})),
		),
		endpoint.New(
			http.MethodGet, "/invitations/{email}",
			endpoint.Handler(http.HandlerFunc(controllers.GetInvitationsByUser(db))),
			endpoint.Summary("Get invitations by user"),
			endpoint.Description("Retrieve participant items where the user ID matches the provided parameter and response is true"),
			endpoint.Path("email", "string", "Email of the user", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved participants", endpoint.SchemaResponseOption([]models.Invitation{})),
		),
		endpoint.New(
			http.MethodPost, "/answer-invitation",
			endpoint.Handler(http.HandlerFunc(controllers.AnswerInvitation(db))),
			endpoint.Summary("Response to invitation"),
			endpoint.Description("Response to an invitation"),
			endpoint.Body(models.InvitationAnswer{}, "Message object", true),
			endpoint.Response(http.StatusOK, "Successfully answered invitation", endpoint.SchemaResponseOption(models.Participant{})),
		),
		endpoint.New(
			http.MethodPatch, "/events/{id}/activate-transport",
			endpoint.Handler(http.HandlerFunc(controllers.ActivateTransport(db))),
			endpoint.Summary("Activate transport for an event"),
			endpoint.Description("Update the transport active status for a given event"),
			endpoint.Path("id", "string", "ID of the event", true),
			endpoint.Body(models.EventTransportUpdate{}, "Transport update object", true),
			endpoint.Response(http.StatusOK, "Successfully updated event", endpoint.SchemaResponseOption(models.Event{})),
		),
	)

	router.Path("/swagger/json").Methods("GET").Handler(api.Handler())
	router.PathPrefix("/swagger/ui").Handler(swag.UIHandler("/swagger/ui", "/swagger/json", true))

	// Route pour WebSocket
	router.HandleFunc("/ws", controllers.WebSocketEndpoint(db)).Methods("GET")

	api.Walk(func(path string, e *swag.Endpoint) {
		h := e.Handler.(http.HandlerFunc)
		router.Path(path).Methods(e.Method).Handler(h)
	})
}
