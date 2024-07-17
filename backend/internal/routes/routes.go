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
			endpoint.Response(http.StatusCreated, "Successfully registered user", endpoint.SchemaResponseOption(&models.User{})),
			endpoint.Tags("Auth"),
		),
		endpoint.New(
			http.MethodPost, "/login",
			endpoint.Handler(http.HandlerFunc(controllers.LoginUser(db))),
			endpoint.Summary("Login a user"),
			endpoint.Description("Login a user and get a token"),
			endpoint.Body(models.User{}, "User credentials", true),
			endpoint.Response(http.StatusOK, "Successfully logged in", endpoint.SchemaResponseOption(&map[string]string{"token": ""})),
			endpoint.Tags("Auth"),
		),
		endpoint.New(
			http.MethodPost, "/forgot-password",
			endpoint.Handler(http.HandlerFunc(controllers.ForgotPassword(db))),
			endpoint.Summary("Forgot password"),
			endpoint.Description("Request a password reset"),
			endpoint.Body(struct {
				Email string `json:"email"`
			}{}, "Email for password reset", true),
			endpoint.Response(http.StatusOK, "OTP sent to email", endpoint.SchemaResponseOption(&map[string]string{"message": "OTP sent to your email"})),
			endpoint.Tags("Auth"),
		),
		endpoint.New(
			http.MethodPost, "/reset-password",
			endpoint.Handler(http.HandlerFunc(controllers.ResetPassword(db))),
			endpoint.Summary("Reset password"),
			endpoint.Description("Reset the password using OTP"),
			endpoint.Body(struct {
				Email       string `json:"email"`
				OTP         string `json:"otp"`
				NewPassword string `json:"new_password"`
			}{}, "OTP and new password", true),
			endpoint.Response(http.StatusOK, "Password reset successful", endpoint.SchemaResponseOption(&map[string]string{"message": "Password reset successful"})),
			endpoint.Tags("Auth"),
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
			http.MethodPost, "/registerAdmin",
			endpoint.Handler(http.HandlerFunc(controllers.RegisterUserAdmin(db))),
			endpoint.Summary("Register a new admin user"),
			endpoint.Description("Register a new admin user with a username and password"),
			endpoint.Body(models.User{}, "User object that needs to be registered", true),
			endpoint.Response(http.StatusCreated, "Successfully registered user", endpoint.SchemaResponseOption(&models.User{})),
			endpoint.Tags("Users"),
		),
		endpoint.New(
			http.MethodGet, "/users",
			endpoint.Handler(http.HandlerFunc(controllers.GetAllUsers(db))),
			endpoint.Summary("Get all users"),
			endpoint.Description("Retrieve all users"),
			endpoint.Response(http.StatusOK, "Successfully retrieved users", endpoint.SchemaResponseOption(&[]models.User{})),
			endpoint.Security("BearerAuth"),
			endpoint.Tags("Users"),
		),
		endpoint.New(
			http.MethodGet, "/my-user",
			endpoint.Handler(http.HandlerFunc(controllers.MyUser(db))),
			endpoint.Summary("Get my user info"),
			endpoint.Description("My user information"),
			endpoint.Response(http.StatusOK, "Successfully retrieved user", endpoint.SchemaResponseOption(&models.User{})),
			endpoint.Security("BearerAuth"),
			endpoint.Tags("Users"),
		),
		endpoint.New(
			http.MethodGet, "/users/{userId}",
			endpoint.Handler(http.HandlerFunc(controllers.GetUserByID(db))),
			endpoint.Summary("Get user by ID"),
			endpoint.Description("Retrieve a user by their ID"),
			endpoint.Path("userId", "integer", "ID of the user to retrieve", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved user", endpoint.SchemaResponseOption(&models.User{})),
			endpoint.Security("BearerAuth"),
			endpoint.Tags("Users"),
		),
		endpoint.New(
			http.MethodPatch, "/users/{userId}",
			endpoint.Handler(http.HandlerFunc(controllers.UpdateUserByID(db))),
			endpoint.Summary("Update user by ID"),
			endpoint.Description("Update a user by their ID"),
			endpoint.Path("userId", "integer", "ID of the user to update", true),
			endpoint.Body(models.User{}, "Fields to update in user object", true),
			endpoint.Response(http.StatusOK, "Successfully updated user", endpoint.SchemaResponseOption(&models.User{})),
			endpoint.Security("BearerAuth"),
			endpoint.Tags("Users"),
		),
		endpoint.New(
			http.MethodDelete, "/users/{userId}",
			endpoint.Handler(http.HandlerFunc(controllers.DeleteUserByID(db))),
			endpoint.Summary("Delete user by ID"),
			endpoint.Description("Delete a user by their ID"),
			endpoint.Path("userId", "integer", "ID of the user to delete", true),
			endpoint.Response(http.StatusNoContent, "Successfully deleted user"),
			endpoint.Security("BearerAuth"),
			endpoint.Tags("Users"),
		),
		endpoint.New(
			http.MethodGet, "/users-emails/{eventId}",
			endpoint.Handler(controllers.GetAllUserEmails(db)),
			endpoint.Summary("Get all user emails"),
			endpoint.Path("eventId", "integer", "ID of event", true),
			endpoint.Description("Retrieve all user emails from the store"),
			endpoint.Response(http.StatusOK, "Successfully retrieved user emails", endpoint.SchemaResponseOption(&[]string{})),
			endpoint.Tags("Users"),
		),
		endpoint.New(
			http.MethodGet, "/users-email/{email}",
			endpoint.Handler(http.HandlerFunc(controllers.GetUserByEmail(db))),
			endpoint.Summary("Get user by email"),
			endpoint.Description("Retrieve a user by the email"),
			endpoint.Path("email", "string", "Email of the user to retrieve", true),
			endpoint.Response(http.StatusOK, "Successfully retrieved user", endpoint.SchemaResponseOption(&models.User{})),
			endpoint.Tags("Users"),
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
