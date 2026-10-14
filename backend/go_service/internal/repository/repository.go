package repository

import (
	"context"
	"fmt"
	"strings"
	"sync"
	"time"

	"constellation/backend/go_service/internal/domain"
)

// Repository defines all data-access methods required by Golang BFF handlers.
type Repository interface {
	// Profiles
	GetProfileByID(ctx context.Context, id string) (*domain.Profile, error)
	GetProfileByUsername(ctx context.Context, username string) (*domain.Profile, error)
	UpdateProfile(ctx context.Context, p *domain.Profile) error

	// Circle & Invites
	GetFriends(ctx context.Context, userID string) ([]domain.CircleFriend, error)
	RemoveFriend(ctx context.Context, userID, friendID string) error
	CreateInvite(ctx context.Context, invite *domain.CircleInvite) error
	GetReceivedRequests(ctx context.Context, recipientID string) ([]domain.CircleRequest, error)
	AcceptRequest(ctx context.Context, recipientID, requestID string) (*domain.CircleFriend, error)
	DeclineRequest(ctx context.Context, recipientID, requestID string) error

	// Articles
	GetArticles(ctx context.Context, userID, scope, topic string, cursorTime *time.Time, cursorID *string, limit int) ([]domain.Article, bool, *string, error)
	PublishArticle(ctx context.Context, a *domain.Article) error
	ToggleLikeArticle(ctx context.Context, userID, articleID string) (bool, int, error)
	BookmarkArticle(ctx context.Context, userID, articleID string) error
	UnbookmarkArticle(ctx context.Context, userID, articleID string) error

	// Moments
	GetFeed(ctx context.Context, userID, circleID string, cursorTime *time.Time, cursorID *string, limit int) ([]domain.Moment, bool, *string, error)
	PostMoment(ctx context.Context, m *domain.Moment) error
	ToggleLikeMoment(ctx context.Context, userID, momentID string) (bool, int, error)
	GetArchive(ctx context.Context, userID string, cursorTime *time.Time, cursorID *string, limit int) ([]domain.Moment, bool, *string, error)
	RestoreMoment(ctx context.Context, userID, momentID string) error
	DeleteMomentPermanently(ctx context.Context, userID, momentID string) error

	// Chat
	GetInbox(ctx context.Context, userID string) ([]domain.ChatInboxItem, error)
	GetMessages(ctx context.Context, userID, friendID string, cursorTime *time.Time, cursorID *string, limit int) ([]domain.ChatMessage, bool, *string, error)
	SendMessage(ctx context.Context, msg *domain.ChatMessage) error
}

// MemoryRepository is an in-memory thread-safe implementation of Repository for testing and standalone execution.
type MemoryRepository struct {
	mu           sync.RWMutex
	profiles     map[string]*domain.Profile
	friends      map[string][]domain.CircleFriend
	requests     map[string][]domain.CircleRequest
	invites      map[string]*domain.CircleInvite
	articles     []*domain.Article
	moments      []*domain.Moment
	bookmarks    map[string]map[string]bool // userID -> articleID -> true
	chatMessages []*domain.ChatMessage
}

// NewMemoryRepository initializes sample seed data matching Quire's quiet editorial universe.
func NewMemoryRepository() *MemoryRepository {
	repo := &MemoryRepository{
		profiles:  make(map[string]*domain.Profile),
		friends:   make(map[string][]domain.CircleFriend),
		requests:  make(map[string][]domain.CircleRequest),
		invites:   make(map[string]*domain.CircleInvite),
		bookmarks: make(map[string]map[string]bool),
	}

	// Default user profile
	defaultUser := &domain.Profile{
		ID:          "usr_1",
		Email:       "ban@example.com",
		Username:    "@ban.quire",
		DisplayName: "Bạn",
		Bio:         "Thành viên từ tháng 3 · Lisbon",
		City:        "Lisbon",
		AvatarPath:  "",
		CreatedAt:   time.Now().Add(-180 * 24 * time.Hour),
		UpdatedAt:   time.Now(),
	}
	repo.profiles["usr_1"] = defaultUser
	repo.profiles["default-user-id"] = defaultUser

	// Sample circle friends (unconstrained list)
	repo.friends["usr_1"] = []domain.CircleFriend{
		{ID: "f1", Name: "Mai", Username: "@mai.tran", Bio: "Nhiếp ảnh gia nghiệp dư · Lisbon", City: "Lisbon", Initials: "M", SharedMomentsCount: 14, HasUnreadStory: true},
		{ID: "f2", Name: "Tuấn", Username: "@tuan.coffee", Bio: "Đọc sách bên tách cà phê sáng", City: "Kyoto", Initials: "T", SharedMomentsCount: 9, HasUnreadStory: false},
		{ID: "f3", Name: "Linh", Username: "@linh.art", Bio: "Gốm thủ công & hoa dại", City: "Đà Lạt", Initials: "L", SharedMomentsCount: 6, HasUnreadStory: false},
		{ID: "f4", Name: "An", Username: "@an.architect", Bio: "Kiến trúc sư cảnh quan nhiệt đới", City: "Sài Gòn", Initials: "A", SharedMomentsCount: 11, HasUnreadStory: false},
		{ID: "f5", Name: "Hà", Username: "@ha.travel", Bio: "Tản bộ qua các ngõ vắng", City: "Hà Nội", Initials: "H", SharedMomentsCount: 7, HasUnreadStory: false},
	}
	repo.friends["default-user-id"] = repo.friends["usr_1"]

	// Sample received requests
	repo.requests["usr_1"] = []domain.CircleRequest{
		{ID: "req_1", SenderID: "usr_lanhuong", SenderName: "Lan Hương", SenderUsername: "@lan.huong", SenderInitials: "LH", SenderBio: "Đà Lạt · Bạn cùng lớp", RecipientID: "usr_1", Status: "pending", CreatedAt: time.Now().Add(-2 * time.Hour)},
		{ID: "req_2", SenderID: "usr_ducminh", SenderName: "Đức Minh", SenderUsername: "@duc.minh", SenderInitials: "DM", SenderBio: "Hà Nội · Thích nhiếp ảnh", RecipientID: "usr_1", Status: "pending", CreatedAt: time.Now().Add(-5 * time.Hour)},
	}

	// Sample articles
	repo.articles = []*domain.Article{
		{
			ID:              "art_1",
			AuthorID:        "usr_ines",
			AuthorName:      "Inês Castro",
			AuthorUsername:  "@ines.castro",
			Title:           "Nghệ thuật của gạch men azulejo ở Lisbon",
			Excerpt:         "Mặt tiền azulejo không đơn thuần là trang trí. Đó là tấm lưới giải quyết vi khí hậu...",
			FullContent:     "Mặt tiền azulejo không đơn thuần là trang trí. Đó là tấm lưới giải quyết vi khí hậu và kể lại ký ức đô thị qua hàng thế kỷ...",
			Category:        "Kiến trúc",
			CoverImagePath:  "https://picsum.photos/seed/lisbon/800/500",
			ReadTimeMinutes: 7,
			IsPublic:        true,
			LikesCount:      24,
			CreatedAt:       time.Now().Add(-3 * time.Hour),
		},
		{
			ID:              "art_2",
			AuthorID:        "usr_kenji",
			AuthorName:      "Kenji Sato",
			AuthorUsername:  "@kenji.sato",
			Title:           "Những thư viện im lặng ở cố đô Kyoto",
			Excerpt:         "Giữa lòng cố đô náo nhiệt, có những căn phòng gỗ tối nơi người ta đến chỉ để nghe tiếng lật giấy...",
			FullContent:     "Giữa lòng cố đô náo nhiệt, có những căn phòng gỗ tối nơi người ta đến chỉ để nghe tiếng lật giấy và tiếng gió lùa qua rèm trúc...",
			Category:        "Tản văn",
			CoverImagePath:  "https://picsum.photos/seed/kyoto/800/500",
			ReadTimeMinutes: 5,
			IsPublic:        false, // Circle only!
			LikesCount:      18,
			CreatedAt:       time.Now().Add(-1 * 24 * time.Hour),
		},
	}

	// Sample moments
	repo.moments = []*domain.Moment{
		{
			ID:             "mom_1",
			SenderID:       "f1",
			SenderName:     "Mai",
			SenderInitials: "M",
			CircleID:       "circle_1",
			ImagePath:      "https://picsum.photos/seed/grass/800/800",
			ImageURL:       "https://picsum.photos/seed/grass/800/800",
			Caption:        "Buổi chiều nắng nhẹ trên hiên nhà cũ.",
			IsArchived:     false,
			LikesCount:     3,
			CreatedAt:      time.Now().Add(-2 * time.Hour),
		},
		{
			ID:             "mom_2",
			SenderID:       "f2",
			SenderName:     "Tuấn",
			SenderInitials: "T",
			CircleID:       "circle_1",
			ImagePath:      "https://picsum.photos/seed/coffee/800/800",
			ImageURL:       "https://picsum.photos/seed/coffee/800/800",
			Caption:        "Ghé quán cà phê quen, đọc xong chương cuối cuốn tiểu thuyết.",
			IsArchived:     false,
			LikesCount:     2,
			CreatedAt:      time.Now().Add(-5 * time.Hour),
		},
	}

	// Sample chat messages
	repo.chatMessages = []*domain.ChatMessage{
		{
			ID:          "msg_1",
			SenderID:    "f1",
			RecipientID: "usr_1",
			MessageText: "Cậu xem bức ảnh tớ vừa chụp ở góc phố cũ chưa?",
			SentAt:      time.Now().Add(-45 * time.Minute),
		},
		{
			ID:          "msg_2",
			SenderID:    "usr_1",
			RecipientID: "f1",
			MessageText: "Nắng chiều đẹp lắm, tớ thả tim rồi đó!",
			SentAt:      time.Now().Add(-40 * time.Minute),
		},
	}

	return repo
}

func (m *MemoryRepository) GetProfileByID(ctx context.Context, id string) (*domain.Profile, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	p, ok := m.profiles[id]
	if !ok {
		return nil, fmt.Errorf("profile not found: %s", id)
	}
	return p, nil
}

func (m *MemoryRepository) GetProfileByUsername(ctx context.Context, username string) (*domain.Profile, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	target := strings.ToLower(username)
	for _, p := range m.profiles {
		if strings.ToLower(p.Username) == target {
			return p, nil
		}
	}
	return nil, fmt.Errorf("profile with username %s not found", username)
}

func (m *MemoryRepository) UpdateProfile(ctx context.Context, p *domain.Profile) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	p.UpdatedAt = time.Now()
	m.profiles[p.ID] = p
	return nil
}

func (m *MemoryRepository) GetFriends(ctx context.Context, userID string) ([]domain.CircleFriend, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	friends, ok := m.friends[userID]
	if !ok {
		return []domain.CircleFriend{}, nil
	}
	return friends, nil
}

func (m *MemoryRepository) RemoveFriend(ctx context.Context, userID, friendID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	list := m.friends[userID]
	var updated []domain.CircleFriend
	for _, f := range list {
		if f.ID != friendID {
			updated = append(updated, f)
		}
	}
	m.friends[userID] = updated
	return nil
}

func (m *MemoryRepository) CreateInvite(ctx context.Context, invite *domain.CircleInvite) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.invites[invite.InviteCode] = invite
	return nil
}

func (m *MemoryRepository) GetReceivedRequests(ctx context.Context, recipientID string) ([]domain.CircleRequest, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()
	return m.requests[recipientID], nil
}

func (m *MemoryRepository) AcceptRequest(ctx context.Context, recipientID, requestID string) (*domain.CircleFriend, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	reqs := m.requests[recipientID]
	var target *domain.CircleRequest
	var updatedReqs []domain.CircleRequest
	for _, r := range reqs {
		if r.ID == requestID {
			target = &r
		} else {
			updatedReqs = append(updatedReqs, r)
		}
	}
	if target == nil {
		return nil, fmt.Errorf("request not found: %s", requestID)
	}
	m.requests[recipientID] = updatedReqs

	newFriend := domain.CircleFriend{
		ID:                 target.SenderID,
		Name:               target.SenderName,
		Username:           target.SenderUsername,
		Bio:                target.SenderBio,
		City:               "Đà Lạt",
		Initials:           target.SenderInitials,
		SharedMomentsCount: 1,
	}
	m.friends[recipientID] = append(m.friends[recipientID], newFriend)
	return &newFriend, nil
}

func (m *MemoryRepository) DeclineRequest(ctx context.Context, recipientID, requestID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	reqs := m.requests[recipientID]
	var updatedReqs []domain.CircleRequest
	for _, r := range reqs {
		if r.ID != requestID {
			updatedReqs = append(updatedReqs, r)
		}
	}
	m.requests[recipientID] = updatedReqs
	return nil
}

func (m *MemoryRepository) GetArticles(ctx context.Context, userID, scope, topic string, cursorTime *time.Time, cursorID *string, limit int) ([]domain.Article, bool, *string, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	var matched []domain.Article
	for _, a := range m.articles {
		if scope == "circle" && a.IsPublic {
			continue
		}
		if scope == "public" && !a.IsPublic {
			continue
		}
		if topic != "" && topic != "Tất cả" && a.Category != topic {
			continue
		}

		// Cursor evaluation: strictly strictly older than cursor
		if cursorTime != nil && !a.CreatedAt.Before(*cursorTime) {
			continue
		}

		artCopy := *a
		if userBm, ok := m.bookmarks[userID]; ok {
			artCopy.IsBookmarked = userBm[a.ID]
		}
		matched = append(matched, artCopy)
		if len(matched) >= limit {
			break
		}
	}

	hasMore := len(matched) >= limit
	var nextCursor *string
	if len(matched) > 0 && hasMore {
		last := matched[len(matched)-1]
		c := domain.EncodeCursor(last.CreatedAt, last.ID)
		nextCursor = &c
	}

	return matched, hasMore, nextCursor, nil
}

func (m *MemoryRepository) PublishArticle(ctx context.Context, a *domain.Article) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	a.CreatedAt = time.Now()
	m.articles = append([]*domain.Article{a}, m.articles...)
	return nil
}

func (m *MemoryRepository) ToggleLikeArticle(ctx context.Context, userID, articleID string) (bool, int, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, a := range m.articles {
		if a.ID == articleID {
			a.IsLiked = !a.IsLiked
			if a.IsLiked {
				a.LikesCount++
			} else {
				a.LikesCount--
			}
			return a.IsLiked, a.LikesCount, nil
		}
	}
	return false, 0, fmt.Errorf("article not found: %s", articleID)
}

func (m *MemoryRepository) BookmarkArticle(ctx context.Context, userID, articleID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.bookmarks[userID] == nil {
		m.bookmarks[userID] = make(map[string]bool)
	}
	m.bookmarks[userID][articleID] = true
	return nil
}

func (m *MemoryRepository) UnbookmarkArticle(ctx context.Context, userID, articleID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.bookmarks[userID] != nil {
		delete(m.bookmarks[userID], articleID)
	}
	return nil
}

func (m *MemoryRepository) GetFeed(ctx context.Context, userID, circleID string, cursorTime *time.Time, cursorID *string, limit int) ([]domain.Moment, bool, *string, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	var active []domain.Moment
	for _, mmt := range m.moments {
		if mmt.IsArchived || mmt.PurgedAt != nil {
			continue
		}
		if cursorTime != nil && !mmt.CreatedAt.Before(*cursorTime) {
			continue
		}
		active = append(active, *mmt)
		if len(active) >= limit {
			break
		}
	}

	hasMore := len(active) >= limit
	var nextCursor *string
	if len(active) > 0 && hasMore {
		last := active[len(active)-1]
		c := domain.EncodeCursor(last.CreatedAt, last.ID)
		nextCursor = &c
	}
	return active, hasMore, nextCursor, nil
}

func (m *MemoryRepository) PostMoment(ctx context.Context, mmt *domain.Moment) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	mmt.CreatedAt = time.Now()
	m.moments = append([]*domain.Moment{mmt}, m.moments...)
	return nil
}

func (m *MemoryRepository) ToggleLikeMoment(ctx context.Context, userID, momentID string) (bool, int, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, mmt := range m.moments {
		if mmt.ID == momentID {
			mmt.IsLiked = !mmt.IsLiked
			if mmt.IsLiked {
				mmt.LikesCount++
			} else {
				mmt.LikesCount--
			}
			return mmt.IsLiked, mmt.LikesCount, nil
		}
	}
	return false, 0, fmt.Errorf("moment not found: %s", momentID)
}

func (m *MemoryRepository) GetArchive(ctx context.Context, userID string, cursorTime *time.Time, cursorID *string, limit int) ([]domain.Moment, bool, *string, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	var archived []domain.Moment
	for _, mmt := range m.moments {
		if mmt.SenderID != userID {
			continue
		}
		if cursorTime != nil && !mmt.CreatedAt.Before(*cursorTime) {
			continue
		}
		archived = append(archived, *mmt)
		if len(archived) >= limit {
			break
		}
	}
	hasMore := len(archived) >= limit
	var nextCursor *string
	if len(archived) > 0 && hasMore {
		last := archived[len(archived)-1]
		c := domain.EncodeCursor(last.CreatedAt, last.ID)
		nextCursor = &c
	}
	return archived, hasMore, nextCursor, nil
}

func (m *MemoryRepository) RestoreMoment(ctx context.Context, userID, momentID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, mmt := range m.moments {
		if mmt.ID == momentID && mmt.SenderID == userID {
			mmt.IsArchived = false
			mmt.PurgedAt = nil
			return nil
		}
	}
	return fmt.Errorf("moment not found or unauthorized: %s", momentID)
}

func (m *MemoryRepository) DeleteMomentPermanently(ctx context.Context, userID, momentID string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	var updated []*domain.Moment
	for _, mmt := range m.moments {
		if !(mmt.ID == momentID && mmt.SenderID == userID) {
			updated = append(updated, mmt)
		}
	}
	m.moments = updated
	return nil
}

func (m *MemoryRepository) GetInbox(ctx context.Context, userID string) ([]domain.ChatInboxItem, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	friends := m.friends[userID]
	var items []domain.ChatInboxItem
	for _, f := range friends {
		items = append(items, domain.ChatInboxItem{
			FriendID:       f.ID,
			FriendName:     f.Name,
			FriendUsername: f.Username,
			FriendInitials: f.Initials,
			LastMessage:    "Nắng chiều đẹp lắm, tớ thả tim rồi đó!",
			LastMessageAt:  time.Now().Add(-15 * time.Minute),
			UnreadCount:    0,
		})
	}
	return items, nil
}

func (m *MemoryRepository) GetMessages(ctx context.Context, userID, friendID string, cursorTime *time.Time, cursorID *string, limit int) ([]domain.ChatMessage, bool, *string, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	var thread []domain.ChatMessage
	for _, msg := range m.chatMessages {
		if (msg.SenderID == userID && msg.RecipientID == friendID) || (msg.SenderID == friendID && msg.RecipientID == userID) {
			thread = append(thread, *msg)
		}
	}
	return thread, false, nil, nil
}

func (m *MemoryRepository) SendMessage(ctx context.Context, msg *domain.ChatMessage) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	msg.SentAt = time.Now()
	m.chatMessages = append(m.chatMessages, msg)
	return nil
}
