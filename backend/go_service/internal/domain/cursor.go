package domain

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"time"
)

type cursorPayload struct {
	Timestamp string `json:"t"`
	ID        string `json:"id"`
}

// EncodeCursor packs a timestamp and record ID into an opaque Base64 cursor string.
func EncodeCursor(t time.Time, id string) string {
	payload := cursorPayload{
		Timestamp: t.UTC().Format(time.RFC3339Nano),
		ID:        id,
	}
	bytes, _ := json.Marshal(payload)
	return base64.URLEncoding.EncodeToString(bytes)
}

// DecodeCursor unpacks an opaque Base64 cursor into timestamp and record ID.
func DecodeCursor(cursorStr string) (*time.Time, *string, error) {
	if cursorStr == "" {
		return nil, nil, nil
	}

	bytes, err := base64.URLEncoding.DecodeString(cursorStr)
	if err != nil {
		return nil, nil, fmt.Errorf("invalid base64 cursor: %w", err)
	}

	var payload cursorPayload
	if err := json.Unmarshal(bytes, &payload); err != nil {
		return nil, nil, fmt.Errorf("invalid cursor json: %w", err)
	}

	t, err := time.Parse(time.RFC3339Nano, payload.Timestamp)
	if err != nil {
		return nil, nil, fmt.Errorf("invalid cursor timestamp format: %w", err)
	}

	return &t, &payload.ID, nil
}
