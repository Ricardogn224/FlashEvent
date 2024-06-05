package main

import (
    "encoding/json"
    "net/http"
    "strconv"
    "sync"
    "time"

    "github.com/gorilla/mux"
    "github.com/zc2638/swag"
    "github.com/zc2638/swag/endpoint"
    "github.com/zc2638/swag/option"
    "golang.org/x/crypto/bcrypt"
    "log"
    "github.com/gorilla/sessions"
)

// User structure
type User struct {
    ID       int64  `json:"id"`
    Username string `json:"username" required:""`
    Password string `json:"password" required:""`
}

// Event structure
type Event struct {
    ID          int64     `json:"id"`
    Name        string    `json:"name" required:""`
    Date        time.Time `json:"date" required:""`
    Description string    `json:"description" required:""`
}

var (
    events     = make(map[int64]Event)
    users      = make(map[string]User)
    currentEventID int64
    currentUserID  int64
    mu         sync.Mutex
    store      = sessions.NewCookieStore([]byte("secret"))
)

// Handler to register a new user
func registerUser(w http.ResponseWriter, r *http.Request) {
    var user User
    if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
    if err != nil {
        http.Error(w, "Internal server error", http.StatusInternalServerError)
        return
    }
    user.Password = string(hashedPassword)

    mu.Lock()
    currentUserID++
    user.ID = currentUserID
    users[user.Username] = user
    mu.Unlock()

    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(user)
}

// Handler to login a user with username and password
func loginUser(w http.ResponseWriter, r *http.Request) {
    var credentials User
    if err := json.NewDecoder(r.Body).Decode(&credentials); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    mu.Lock()
    user, exists := users[credentials.Username]
    mu.Unlock()

    if !exists || bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(credentials.Password)) != nil {
        http.Error(w, "Unauthorized", http.StatusUnauthorized)
        return
    }

    session, err := store.Get(r, "session")
    if err != nil {
        http.Error(w, "Internal server error", http.StatusInternalServerError)
        return
    }

    session.Values["authenticated"] = true
    session.Save(r, w)

    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(map[string]string{"message": "Successfully logged in"})
}

// Middleware for simple username/password authentication
func authMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        session, err := store.Get(r, "session")
        if err != nil {
            http.Error(w, "Internal server error", http.StatusInternalServerError)
            return
        }

        // Check if user is authenticated
        if auth, ok := session.Values["authenticated"].(bool); !ok || !auth {
            http.Error(w, "Unauthorized", http.StatusUnauthorized)
            return
        }

        next.ServeHTTP(w, r)
    })
}

// Handler to add a new event
func addEvent(w http.ResponseWriter, r *http.Request) {
    var event Event
    if err := json.NewDecoder(r.Body).Decode(&event); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    mu.Lock()
    currentEventID++
    event.ID = currentEventID
    events[currentEventID] = event
    mu.Unlock()

    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(event)
}

// Handler to find an event by ID
func findEventByID(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    id, err := strconv.ParseInt(vars["eventId"], 10, 64)
    if err != nil {
        http.Error(w, "Invalid event ID", http.StatusBadRequest)
        return
    }

    mu.Lock()
    event, ok := events[id]
    mu.Unlock()

    if !ok {
        http.Error(w, "Event not found", http.StatusNotFound)
        return
    }

    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(event)
}

// Handler to update an event by ID
func updateEventByID(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    id, err := strconv.ParseInt(vars["eventId"], 10, 64)
    if err != nil {
        http.Error(w, "Invalid event ID", http.StatusBadRequest)
        return
    }

    var updatedEvent Event
    if err := json.NewDecoder(r.Body).Decode(&updatedEvent); err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

    mu.Lock()
    event, ok := events[id]
    if !ok {
        mu.Unlock()
        http.Error(w, "Event not found", http.StatusNotFound)
        return
    }

    updatedEvent.ID = event.ID // Ensure the ID remains unchanged
    events[id] = updatedEvent
    mu.Unlock()

    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(updatedEvent)
}

func main() {
    api := swag.New(
        option.Title("Swagger Event API"),
    )

    api.AddEndpoint(
        endpoint.New(
            http.MethodPost, "/event",
            endpoint.Handler(authMiddleware(http.HandlerFunc(addEvent))),
            endpoint.Summary("Add a new event"),
            endpoint.Description("Add a new event to the store"),
            endpoint.Body(Event{}, "Event object that needs to be added", true),
            endpoint.Response(http.StatusCreated, "Successfully added event", endpoint.SchemaResponseOption(Event{})),
            endpoint.Tags("Events"),
        ),
        endpoint.New(
            http.MethodGet, "/event/{eventId}",
            endpoint.Handler(findEventByID),
            endpoint.Summary("Find event by ID"),
            endpoint.Path("eventId", "integer", "ID of event to return", true),
            endpoint.Response(http.StatusOK, "successful operation", endpoint.SchemaResponseOption(Event{})),
            endpoint.Tags("Events"),
        ),
        endpoint.New(
            http.MethodPut, "/event/{eventId}",
            endpoint.Handler(authMiddleware(http.HandlerFunc(updateEventByID))),
            endpoint.Path("eventId", "integer", "ID of event to update", true),
            endpoint.Body(Event{}, "Event object with updated details", true),
            endpoint.Response(http.StatusOK, "Successfully updated event", endpoint.SchemaResponseOption(Event{})),
            endpoint.Tags("Events"),
        ),
        endpoint.New(
            http.MethodPost, "/register",
            endpoint.Handler(registerUser),
            endpoint.Summary("Register a new user"),
            endpoint.Description("Register a new user with a username and password"),
            endpoint.Body(User{}, "User object that needs to be registered", true),
            endpoint.Response(http.StatusCreated, "Successfully registered user", endpoint.SchemaResponseOption(User{})),
            endpoint.Tags("Users"),
        ),
        endpoint.New(
            http.MethodPost,"/login",
            endpoint.Handler(loginUser),
            endpoint.Summary("Login a user"),
            endpoint.Description("Login a user and get a token"),
            endpoint.Body(User{}, "User credentials", true),
            endpoint.Response(http.StatusOK, "Successfully logged in", endpoint.SchemaResponseOption(map[string]string{"message": ""})),
            endpoint.Tags("Users"),
        ),
    )

    router := mux.NewRouter()
    api.Walk(func(path string, e *swag.Endpoint) {
        h := e.Handler.(http.HandlerFunc)
        router.Path(path).Methods(e.Method).Handler(h)
    })

    router.Path("/swagger/json").Methods("GET").Handler(api.Handler())
    router.PathPrefix("/swagger/ui").Handler(swag.UIHandler("/swagger/ui", "/swagger/json", true))

    log.Fatal(http.ListenAndServe(":8080", router))
}

