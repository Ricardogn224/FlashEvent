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

func RegisterPublicRoutes(router *mux.Router, api *swag.API, db *gorm.DB) {
	api.AddEndpoint(
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
	)

	api.Walk(func(path string, e *swag.Endpoint) {
		h := e.Handler.(http.HandlerFunc)
		router.Path(path).Methods(e.Method).Handler(h)
	})
}

func RegisterAuthRoutes(router *mux.Router, api *swag.API, db *gorm.DB) {
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
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodGet, "/users-emails/{eventId}",
			endpoint.Handler(controllers.GetAllUserEmails(db)),
			endpoint.Summary("Get all user emails"),
			endpoint.Path("eventId", "integer", "ID of event", true),
			endpoint.Description("Retrieve all user emails from the store"),
			endpoint.Response(http.StatusOK, "Successfully retrieved user emails", endpoint.SchemaResponseOption([]string{})),
		),
		endpoint.New(
			http.MethodGet, "/event/{eventId}",
			endpoint.Handler(http.HandlerFunc(controllers.AuthenticatedFindEventByID(db))),
			endpoint.Summary("Find event by ID"),
			endpoint.Path("eventId", "integer", "ID of event to return", true),
			endpoint.Response(http.StatusOK, "successful operation", endpoint.SchemaResponseOption(models.Event{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodPut, "/event/{eventId}",
			endpoint.Handler(http.HandlerFunc(controllers.AuthenticatedUpdateEventByID(db))),
			endpoint.Path("eventId", "integer", "ID of event to update", true),
			endpoint.Body(models.Event{}, "Event object with updated details", true),
			endpoint.Response(http.StatusOK, "Successfully updated event", endpoint.SchemaResponseOption(models.Event{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodGet, "/users",
			endpoint.Handler(http.HandlerFunc(controllers.GetAllUsers(db))),
			endpoint.Summary("Get all users"),
			endpoint.Description("Retrieve all users"),
			endpoint.Response(http.StatusOK, "Successfully retrieved users", endpoint.SchemaResponseOption([]models.User{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodGet, "/users/{userId}",
			endpoint.Handler(http.HandlerFunc(controllers.GetUserByID(db))),
			endpoint.Summary("Get user by ID"),
			endpoint.Description("Retrieve a user by their ID"),
			endpoint.Path("userId", "integer", "ID of the user to retrieve", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved user", endpoint.SchemaResponseOption(models.User{})),
			endpoint.Security("BearerAuth"),
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
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodGet, "/participants-event/{eventId}",
			endpoint.Handler(http.HandlerFunc(controllers.GetParticipantsByEventID(db))),
			endpoint.Summary("Get participants by event ID"),
			endpoint.Description("Retrieve participants associated with a specific event"),
			endpoint.Path("eventId", "integer", "ID of the event", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved participants", endpoint.SchemaResponseOption([]models.Participant{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodPost, "/item",
			endpoint.Handler(http.HandlerFunc(controllers.AddItem(db))),
			endpoint.Summary("Add a new item"),
			endpoint.Description("Add a new item to an event"),
			endpoint.Body(models.ItemEventAdd{}, "Item object that needs to be added", true),
			endpoint.Response(http.StatusCreated, "Successfully added item", endpoint.SchemaResponseOption(models.ItemEvent{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodGet, "/items",
			endpoint.Handler(http.HandlerFunc(controllers.GetAllItems(db))),
			endpoint.Summary("Get all items"),
			endpoint.Description("Retrieve all items"),
			endpoint.Response(http.StatusOK, "Successfully retrieved items", endpoint.SchemaResponseOption([]models.ItemEvent{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodGet, "/items-event/{eventId}",
			endpoint.Handler(http.HandlerFunc(controllers.GetItemsByEventID(db))),
			endpoint.Summary("Get items by event ID"),
			endpoint.Description("Retrieve items associated with a specific event"),
			endpoint.Path("eventId", "integer", "ID of the event", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved items", endpoint.SchemaResponseOption([]models.ItemEvent{})),
			endpoint.Security("BearerAuth"),
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
			endpoint.Security("BearerAuth"),
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
			http.MethodGet, "/get-participant/{eventId}",
			endpoint.Handler(controllers.GetParticipantByEventId(db)),
			endpoint.Summary("Get participant by user ID and event ID"),
			endpoint.Path("eventId", "string", "ID of the event", true),
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
			endpoint.Body(struct {
				Transportation string `json:"transportation"`
			}{}, "Moyen de transport à ajouter à l'événement", true),
			endpoint.Response(http.StatusCreated, "Transport ajouté avec succès à l'événement", endpoint.SchemaResponseOption(models.Event{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodPost, "/event/{eventId}/add-activity",
			endpoint.Handler(http.HandlerFunc(controllers.AddActivityToEvent(db))),
			endpoint.Summary("Ajouter une activité à un événement"),
			endpoint.Description("Permettre à un participant d'ajouter une activité à un événement"),
			endpoint.Path("eventId", "integer", "ID de l'événement", true),
			endpoint.Body(struct {
				Activity string `json:"activity"`
			}{}, "Activité à ajouter à l'événement", true),
			endpoint.Response(http.StatusCreated, "Activité ajoutée avec succès à l'événement", endpoint.SchemaResponseOption(models.Event{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodPost, "/event/{eventId}/chat",
			endpoint.Handler(http.HandlerFunc(controllers.AddMessageToChat(db))),
			endpoint.Summary("Envoyer un message dans la salle de chat de l'événement"),
			endpoint.Description("Envoyer un message dans la salle de chat de l'événement"),
			endpoint.Path("eventId", "integer", "ID de l'événement de la salle de chat", true),
			endpoint.Body(models.MessageAdd{}, "Message object", true),
			endpoint.Response(http.StatusCreated, "Message sent", endpoint.SchemaResponseOption(models.Message{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodGet, "/chat-rooms/{chatRoomId}/messages",
			endpoint.Handler(http.HandlerFunc(controllers.GetMessagesByChatRoom(db))),
			endpoint.Summary("Get messages"),
			endpoint.Description("Retrieve messages from the event chat room"),
			endpoint.Path("chatRoomId", "integer", "ID of the chat room", true),
			endpoint.Response(http.StatusOK, "Messages retrieved", endpoint.SchemaResponseOption([]models.MessageResponse{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodGet, "/invitations/{email}",
			endpoint.Handler(http.HandlerFunc(controllers.GetInvitationsByUser(db))),
			endpoint.Summary("Get invitations by user"),
			endpoint.Description("Retrieve participant items where the user ID matches the provided parameter and response is true"),
			endpoint.Path("email", "string", "Email of the user", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved participants", endpoint.SchemaResponseOption([]models.Invitation{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodPost, "/answer-invitation",
			endpoint.Handler(http.HandlerFunc(controllers.AnswerInvitation(db))),
			endpoint.Summary("Response to invitation"),
			endpoint.Description("Response to an invitation"),
			endpoint.Body(models.InvitationAnswer{}, "Message object", true),
			endpoint.Response(http.StatusOK, "Successfully answered invitation", endpoint.SchemaResponseOption(models.Participant{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodPatch, "/events/{id}/activate-transport",
			endpoint.Handler(http.HandlerFunc(controllers.ActivateTransport(db))),
			endpoint.Summary("Activate transport for an event"),
			endpoint.Description("Update the transport active status for a given event"),
			endpoint.Path("id", "string", "ID of the event", true),
			endpoint.Body(models.EventTransportUpdate{}, "Transport update object", true),
			endpoint.Response(http.StatusOK, "Successfully updated event", endpoint.SchemaResponseOption(models.Event{})),
			endpoint.Security("BearerAuth"),
		),

		endpoint.New(
			http.MethodPost, "/event/{eventId}/cagnotte",
			endpoint.Handler(controllers.AuthMiddleware(controllers.AddCagnotte(db))),
			endpoint.Summary("Ajouter une cagnotte"),
			endpoint.Description("Ajouter une cagnotte à un événement"),
			endpoint.Path("eventId", "integer", "ID de l'événement", true),
			endpoint.Response(http.StatusCreated, "Cagnotte ajoutée avec succès", endpoint.SchemaResponseOption(models.Cagnotte{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodPost, "/cagnotte/{cagnotteId}/contribution",
			endpoint.Handler(controllers.AuthMiddleware(controllers.ContributeToCagnotte(db))),
			endpoint.Summary("Contribuer à une cagnotte"),
			endpoint.Description("Contribuer à une cagnotte existante"),
			endpoint.Path("cagnotteId", "integer", "ID de la cagnotte", true),
			endpoint.Response(http.StatusCreated, "Contribution ajoutée avec succès", endpoint.SchemaResponseOption(models.Contribution{})),
			endpoint.Security("BearerAuth"),
		),
		endpoint.New(
			http.MethodGet, "/cagnotte/{cagnotteId}/contributors",
			endpoint.Handler(controllers.AuthMiddleware(controllers.GetContributorsByCagnotteID(db))),
			endpoint.Summary("Voir les contributeurs d'une cagnotte"),
			endpoint.Description("Voir la liste des personnes ayant contribué à une cagnotte"),
			endpoint.Path("cagnotteId", "integer", "ID de la cagnotte", true),
			endpoint.Response(http.StatusOK, "Liste des contributeurs récupérée avec succès", endpoint.SchemaResponseOption([]models.Contribution{})),
			endpoint.Security("BearerAuth"),
		),
	)

	api.Walk(func(path string, e *swag.Endpoint) {
		h := e.Handler.(http.HandlerFunc)
		router.Path(path).Methods(e.Method).Handler(h)
	})
}

func RegisterSwaggerRoutes(router *mux.Router, api *swag.API) {
	// Ajout des routes Swagger
	router.Path("/swagger/json").Methods("GET").Handler(api.Handler())
	router.PathPrefix("/swagger/ui").Handler(swag.UIHandler("/swagger/ui", "/swagger/json", true))
}
