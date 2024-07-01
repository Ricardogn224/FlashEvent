package controllers

import (
	"backend/internal/models"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
	"gorm.io/gorm"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type WebSocketManager struct {
	clients map[*websocket.Conn]bool
	mutex   sync.Mutex
}

var wsManager = WebSocketManager{
	clients: make(map[*websocket.Conn]bool),
}

func (manager *WebSocketManager) addClient(conn *websocket.Conn) {
	manager.mutex.Lock()
	defer manager.mutex.Unlock()
	manager.clients[conn] = true
}

func (manager *WebSocketManager) removeClient(conn *websocket.Conn) {
	manager.mutex.Lock()
	defer manager.mutex.Unlock()
	delete(manager.clients, conn)
}

func (manager *WebSocketManager) broadcastMessage(msg models.Message) {
	manager.mutex.Lock()
	defer manager.mutex.Unlock()
	for client := range manager.clients {
		err := client.WriteJSON(msg)
		if err != nil {
			client.Close()
			delete(manager.clients, client)
		}
	}
}

func WebSocketEndpoint(db *gorm.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			http.Error(w, "Failed to upgrade connection", http.StatusInternalServerError)
			return
		}
		defer conn.Close()

		wsManager.addClient(conn)
		defer wsManager.removeClient(conn)

		for {
			var msg models.Message
			err := conn.ReadJSON(&msg)
			if err != nil {
				if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
					http.Error(w, "Unexpected error", http.StatusInternalServerError)
				}
				break
			}

			if err := db.Create(&msg).Error; err != nil {
				http.Error(w, "Failed to save message", http.StatusInternalServerError)
				return
			}

			wsManager.broadcastMessage(msg)
		}
	}
}
