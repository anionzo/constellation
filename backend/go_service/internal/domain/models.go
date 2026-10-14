package domain

import "time"

// Profile represents a registered user profile.
type Profile struct {
	ID          string    `json:"id"`
	Email       string    `json:"email"`
	Username    string    `json:"username"`
	DisplayName string    `json:"display_name"`
	Bio         string    `json:"bio"`
	City        string    `json:"city"`
	AvatarPath  string    `json:"avatar_path"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// CircleFriend represents an active connected friend in the circle.
type CircleFriend struct {
	ID                 string `json:"id"`
	Name               string `json:"name"`
	Username           string `json:"username"`
	Bio                string `json:"bio"`
	City               string `json:"city"`
	Initials           string `json:"initials"`
	SharedMomentsCount int    `json:"shared_moments_count"`
	HasUnreadStory     bool   `json:"has_unread_story"`
}

// CircleInvite represents a shareable personal invitation link.
type CircleInvite struct {
	ID         string     `json:"id"`
	SenderID   string     `json:"sender_id"`
	InviteCode string     `json:"invite_code"`
	InviteURL  string     `json:"invite_url"`
	CreatedAt  time.Time  `json:"created_at"`
	ExpiresAt  *time.Time `json:"expires_at,omitempty"`
}

// CircleRequest represents an incoming or outgoing connection request.
type CircleRequest struct {
	ID             string    `json:"id"`
	SenderID       string    `json:"sender_id"`
	SenderName     string    `json:"sender_name"`
	SenderUsername string    `json:"sender_username"`
	SenderInitials string    `json:"sender_initials"`
	SenderBio      string    `json:"sender_bio"`
	RecipientID    string    `json:"recipient_id"`
	Status         string    `json:"status"` // pending, accepted, declined
	CreatedAt      time.Time `json:"created_at"`
}

// Article represents an editorial long-form piece.
type Article struct {
	ID              string    `json:"id"`
	AuthorID        string    `json:"author_id"`
	AuthorName      string    `json:"author_name"`
	AuthorUsername  string    `json:"author_username"`
	Title           string    `json:"title"`
	Excerpt         string    `json:"excerpt"`
	FullContent     string    `json:"full_content"`
	Category        string    `json:"category"`
	CoverImagePath  string    `json:"cover_image_path"`
	ReadTimeMinutes int       `json:"read_time_minutes"`
	IsPublic        bool      `json:"is_public"`
	LikesCount      int       `json:"likes_count"`
	IsBookmarked    bool      `json:"is_bookmarked"`
	IsLiked         bool      `json:"is_liked"`
	CreatedAt       time.Time `json:"created_at"`
}

// QuotedMomentPreview represents a thumbnail excerpt attached inside a chat message.
type QuotedMomentPreview struct {
	ID           string `json:"id"`
	ThumbnailURL string `json:"thumbnail_url"`
	Caption      string `json:"caption"`
	AuthorName   string `json:"author_name"`
}

// Moment represents a shared ephemeral photo moment.
type Moment struct {
	ID                       string     `json:"id"`
	SenderID                 string     `json:"sender_id"`
	SenderName               string     `json:"sender_name"`
	SenderInitials           string     `json:"sender_initials"`
	CircleID                 string     `json:"circle_id"`
	ImagePath                string     `json:"image_path"`
	ImageURL                 string     `json:"image_url"`
	Caption                  string     `json:"caption"`
	AutoPurgeDurationSeconds *int       `json:"auto_purge_duration_seconds,omitempty"`
	PurgedAt                 *time.Time `json:"purged_at,omitempty"`
	IsArchived               bool       `json:"is_archived"`
	LikesCount               int        `json:"likes_count"`
	IsLiked                  bool       `json:"is_liked"`
	CreatedAt                time.Time  `json:"created_at"`
}

// ChatMessage represents a 1-on-1 private message between friends.
type ChatMessage struct {
	ID           string               `json:"id"`
	SenderID     string               `json:"sender_id"`
	RecipientID  string               `json:"recipient_id"`
	MessageText  string               `json:"message_text"`
	ImagePath    *string              `json:"image_path,omitempty"`
	QuotedMoment *QuotedMomentPreview `json:"quoted_moment,omitempty"`
	SentAt       time.Time            `json:"sent_at"`
	ReadAt       *time.Time           `json:"read_at,omitempty"`
}

// ChatInboxItem represents a conversation thread in the Circle Inbox.
type ChatInboxItem struct {
	FriendID       string    `json:"friend_id"`
	FriendName     string    `json:"friend_name"`
	FriendUsername string    `json:"friend_username"`
	FriendInitials string    `json:"friend_initials"`
	LastMessage    string    `json:"last_message"`
	LastMessageAt  time.Time `json:"last_message_at"`
	UnreadCount    int       `json:"unread_count"`
}

// PaginationMetadata encapsulates cursor navigation state.
type PaginationMetadata struct {
	HasMore    bool    `json:"has_more"`
	NextCursor *string `json:"next_cursor"`
	PrevCursor *string `json:"prev_cursor,omitempty"`
	Limit      int     `json:"limit"`
	TotalCount *int    `json:"total_count,omitempty"`
}

// PaginatedResponse wraps a slice of items with standard pagination metadata.
type PaginatedResponse[T any] struct {
	Data       []T                `json:"data"`
	Pagination PaginationMetadata `json:"pagination"`
}
