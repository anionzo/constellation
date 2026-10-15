package realtime

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sync"
	"time"
)

// Event represents a push notification or realtime chat payload.
type Event struct {
	Type      string      `json:"type"` // "chat_message", "notification", "friend_request"
	Timestamp time.Time   `json:"timestamp"`
	Data      interface{} `json:"data"`
}

// Hub manages active Server-Sent Events (SSE) connections per user.
type Hub struct {
	mu      sync.RWMutex
	clients map[string]map[chan Event]bool // userID -> set of client channels
}

// NewHub constructs a new Realtime Hub.
func NewHub() *Hub {
	return &Hub{
		clients: make(map[string]map[chan Event]bool),
	}
}

// Register connects a new client channel for a user.
func (h *Hub) Register(userID string) chan Event {
	h.mu.Lock()
	defer h.mu.Unlock()

	ch := make(chan Event, 32)
	if h.clients[userID] == nil {
		h.clients[userID] = make(map[chan Event]bool)
	}
	h.clients[userID][ch] = true
	return ch
}

// Unregister disconnects and closes a client channel.
func (h *Hub) Unregister(userID string, ch chan Event) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if userClients, ok := h.clients[userID]; ok {
		delete(userClients, ch)
		close(ch)
		if len(userClients) == 0 {
			delete(h.clients, userID)
		}
	}
}

// BroadcastToUser sends an event to all active sessions of a given user in < 5ms.
func (h *Hub) BroadcastToUser(userID, eventType string, data interface{}) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	userClients, ok := h.clients[userID]
	if !ok || len(userClients) == 0 {
		return
	}

	ev := Event{
		Type:      eventType,
		Timestamp: time.Now(),
		Data:      data,
	}

	for ch := range userClients {
		select {
		case ch <- ev:
		default:
			// Non-blocking drop if client buffer is congested
		}
	}
}

// ServeSSE handles the HTTP connection and streams events using standard Server-Sent Events.
func (h *Hub) ServeSSE(w http.ResponseWriter, r *http.Request, userID string) {
	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "Streaming unsupported", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	ch := h.Register(userID)
	defer h.Unregister(userID, ch)

	// Send initial connected event
	initialJSON, _ := json.Marshal(map[string]string{"status": "connected", "user_id": userID})
	fmt.Fprintf(w, "event: ready\ndata: %s\n\n", initialJSON)
	flusher.Flush()

	// 20-second heartbeat ticker to keep socket alive and prevent proxy drops
	ticker := time.NewTicker(20 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-r.Context().Done():
			return
		case <-ticker.C:
			fmt.Fprintf(w, ": ping\n\n")
			flusher.Flush()
		case ev, ok := <-ch:
			if !ok {
				return
			}
			payload, err := json.Marshal(ev.Data)
			if err != nil {
				continue
			}
			fmt.Fprintf(w, "event: %s\ndata: %s\n\n", ev.Type, payload)
			flusher.Flush()
		}
	}
}
