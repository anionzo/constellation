package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"constellation/backend/go_service/internal/domain"
)

// PostgresRepository executes actual SQL queries against PostgreSQL using connection pooling.
type PostgresRepository struct {
	pool *pgxpool.Pool
}

// NewPostgresRepository initializes a Postgres-backed repository.
func NewPostgresRepository(pool *pgxpool.Pool) *PostgresRepository {
	return &PostgresRepository{pool: pool}
}

// ==========================================
// 1. Profiles
// ==========================================

func (r *PostgresRepository) GetProfileByID(ctx context.Context, id string) (*domain.Profile, error) {
	query := `
		SELECT id, email, COALESCE(username, ''), display_name, COALESCE(bio, ''), COALESCE(city, ''), COALESCE(avatar_path, ''), created_at, updated_at
		FROM public.profiles
		WHERE id = $1;
	`
	p := &domain.Profile{}
	err := r.pool.QueryRow(ctx, query, id).Scan(
		&p.ID, &p.Email, &p.Username, &p.DisplayName, &p.Bio, &p.City, &p.AvatarPath, &p.CreatedAt, &p.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, fmt.Errorf("profile not found: %s", id)
		}
		return nil, fmt.Errorf("failed to query profile by id: %w", err)
	}
	return p, nil
}

func (r *PostgresRepository) GetProfileByUsername(ctx context.Context, username string) (*domain.Profile, error) {
	query := `
		SELECT id, email, COALESCE(username, ''), display_name, COALESCE(bio, ''), COALESCE(city, ''), COALESCE(avatar_path, ''), created_at, updated_at
		FROM public.profiles
		WHERE LOWER(username) = LOWER($1);
	`
	p := &domain.Profile{}
	err := r.pool.QueryRow(ctx, query, username).Scan(
		&p.ID, &p.Email, &p.Username, &p.DisplayName, &p.Bio, &p.City, &p.AvatarPath, &p.CreatedAt, &p.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, fmt.Errorf("profile with username %s not found", username)
		}
		return nil, fmt.Errorf("failed to query profile by username: %w", err)
	}
	return p, nil
}

func (r *PostgresRepository) UpdateProfile(ctx context.Context, p *domain.Profile) error {
	query := `
		UPDATE public.profiles
		SET display_name = $1, username = $2, bio = $3, city = $4, avatar_path = $5, updated_at = now()
		WHERE id = $6;
	`
	_, err := r.pool.Exec(ctx, query, p.DisplayName, p.Username, p.Bio, p.City, p.AvatarPath, p.ID)
	if err != nil {
		return fmt.Errorf("failed to update profile: %w", err)
	}
	return nil
}

// ==========================================
// 2. Circle & Invites (Unconstrained)
// ==========================================

func (r *PostgresRepository) GetFriends(ctx context.Context, userID string) ([]domain.CircleFriend, error) {
	query := `
		SELECT p.id, p.display_name, COALESCE(p.username, ''), COALESCE(p.bio, ''), COALESCE(p.city, 'Lisbon')
		FROM public.circle_members cm
		JOIN public.profiles p ON p.id = cm.friend_id
		WHERE cm.user_id = $1 AND cm.status = 'active'
		ORDER BY cm.created_at ASC;
	`
	rows, err := r.pool.Query(ctx, query, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to query friends: %w", err)
	}
	defer rows.Close()

	var friends []domain.CircleFriend
	for rows.Next() {
		var f domain.CircleFriend
		if err := rows.Scan(&f.ID, &f.Name, &f.Username, &f.Bio, &f.City); err != nil {
			return nil, err
		}
		if len(f.Name) > 0 {
			f.Initials = strings.ToUpper(string([]rune(f.Name)[:1]))
		}
		f.SharedMomentsCount = 8
		friends = append(friends, f)
	}
	return friends, nil
}

func (r *PostgresRepository) RemoveFriend(ctx context.Context, userID, friendID string) error {
	query := `
		DELETE FROM public.circle_members
		WHERE (user_id = $1 AND friend_id = $2) OR (user_id = $2 AND friend_id = $1);
	`
	_, err := r.pool.Exec(ctx, query, userID, friendID)
	if err != nil {
		return fmt.Errorf("failed to remove friend: %w", err)
	}
	return nil
}

func (r *PostgresRepository) CreateInvite(ctx context.Context, invite *domain.CircleInvite) error {
	query := `
		INSERT INTO public.circle_invites (sender_id, invite_code, invite_url, expires_at)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at;
	`
	return r.pool.QueryRow(ctx, query, invite.SenderID, invite.InviteCode, invite.InviteURL, invite.ExpiresAt).
		Scan(&invite.ID, &invite.CreatedAt)
}

func (r *PostgresRepository) GetReceivedRequests(ctx context.Context, recipientID string) ([]domain.CircleRequest, error) {
	query := `
		SELECT cr.id, cr.sender_id, p.display_name, COALESCE(p.username, ''), COALESCE(p.bio, ''), cr.recipient_id, cr.status, cr.created_at
		FROM public.circle_requests cr
		JOIN public.profiles p ON p.id = cr.sender_id
		WHERE cr.recipient_id = $1 AND cr.status = 'pending'
		ORDER BY cr.created_at DESC;
	`
	rows, err := r.pool.Query(ctx, query, recipientID)
	if err != nil {
		return nil, fmt.Errorf("failed to query received requests: %w", err)
	}
	defer rows.Close()

	var reqs []domain.CircleRequest
	for rows.Next() {
		var cr domain.CircleRequest
		if err := rows.Scan(&cr.ID, &cr.SenderID, &cr.SenderName, &cr.SenderUsername, &cr.SenderBio, &cr.RecipientID, &cr.Status, &cr.CreatedAt); err != nil {
			return nil, err
		}
		if len(cr.SenderName) > 0 {
			cr.SenderInitials = strings.ToUpper(string([]rune(cr.SenderName)[:1]))
		}
		reqs = append(reqs, cr)
	}
	return reqs, nil
}

func (r *PostgresRepository) AcceptRequest(ctx context.Context, recipientID, requestID string) (*domain.CircleFriend, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)

	var senderID string
	err = tx.QueryRow(ctx, `
		UPDATE public.circle_requests
		SET status = 'accepted', updated_at = now()
		WHERE id = $1 AND recipient_id = $2
		RETURNING sender_id;
	`, requestID, recipientID).Scan(&senderID)
	if err != nil {
		return nil, fmt.Errorf("request not found or already handled: %w", err)
	}

	// Insert bidirectional circle membership (unconstrained, no 12-member limit)
	_, err = tx.Exec(ctx, `
		INSERT INTO public.circle_members (user_id, friend_id, status)
		VALUES ($1, $2, 'active'), ($2, $1, 'active')
		ON CONFLICT DO NOTHING;
	`, recipientID, senderID)
	if err != nil {
		return nil, fmt.Errorf("failed to add circle members: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}

	profile, err := r.GetProfileByID(ctx, senderID)
	if err != nil {
		return nil, err
	}

	return &domain.CircleFriend{
		ID:                 profile.ID,
		Name:               profile.DisplayName,
		Username:           profile.Username,
		Bio:                profile.Bio,
		City:               profile.City,
		Initials:           strings.ToUpper(string([]rune(profile.DisplayName)[:1])),
		SharedMomentsCount: 1,
	}, nil
}

func (r *PostgresRepository) DeclineRequest(ctx context.Context, recipientID, requestID string) error {
	query := `
		UPDATE public.circle_requests
		SET status = 'declined', updated_at = now()
		WHERE id = $1 AND recipient_id = $2;
	`
	_, err := r.pool.Exec(ctx, query, requestID, recipientID)
	return err
}

// ==========================================
// 3. Articles (Cursor Pagination & Visibility)
// ==========================================

func (r *PostgresRepository) GetArticles(ctx context.Context, userID, scope, topic string, cursorTime *time.Time, cursorID *string, limit int) ([]domain.Article, bool, *string, error) {
	var cursorClause string
	args := []interface{}{}
	argIdx := 1

	baseQuery := `
		SELECT a.id, a.author_id, p.display_name, COALESCE(p.username, ''), a.title, a.excerpt,
		       a.full_content, a.category, COALESCE(a.cover_image_path, ''), a.read_time_minutes,
		       a.is_public, a.likes_count, a.created_at,
		       EXISTS(SELECT 1 FROM public.saved_items s WHERE s.user_id = $1 AND s.target_id = a.id AND s.target_type = 'article') as is_bookmarked
		FROM public.articles a
		JOIN public.profiles p ON p.id = a.author_id
		WHERE 1=1
	`
	args = append(args, userID)
	argIdx++

	if scope == "circle" {
		baseQuery += fmt.Sprintf(" AND a.is_public = false")
	} else if scope == "public" {
		baseQuery += fmt.Sprintf(" AND a.is_public = true")
	}

	if topic != "" && topic != "Tất cả" {
		baseQuery += fmt.Sprintf(" AND a.category = $%d", argIdx)
		args = append(args, topic)
		argIdx++
	}

	if cursorTime != nil && cursorID != nil {
		cursorClause = fmt.Sprintf(" AND (a.created_at, a.id) < ($%d, $%d)", argIdx, argIdx+1)
		args = append(args, *cursorTime, *cursorID)
		argIdx += 2
	}

	orderLimitClause := fmt.Sprintf(" ORDER BY a.created_at DESC, a.id DESC LIMIT $%d;", argIdx)
	args = append(args, limit+1)

	finalQuery := baseQuery + cursorClause + orderLimitClause

	rows, err := r.pool.Query(ctx, finalQuery, args...)
	if err != nil {
		return nil, false, nil, fmt.Errorf("failed to query articles: %w", err)
	}
	defer rows.Close()

	var articles []domain.Article
	for rows.Next() {
		var a domain.Article
		if err := rows.Scan(
			&a.ID, &a.AuthorID, &a.AuthorName, &a.AuthorUsername, &a.Title, &a.Excerpt,
			&a.FullContent, &a.Category, &a.CoverImagePath, &a.ReadTimeMinutes,
			&a.IsPublic, &a.LikesCount, &a.CreatedAt, &a.IsBookmarked,
		); err != nil {
			return nil, false, nil, err
		}
		articles = append(articles, a)
	}

	hasMore := len(articles) > limit
	if hasMore {
		articles = articles[:limit]
	}

	var nextCursor *string
	if len(articles) > 0 && hasMore {
		last := articles[len(articles)-1]
		c := domain.EncodeCursor(last.CreatedAt, last.ID)
		nextCursor = &c
	}

	return articles, hasMore, nextCursor, nil
}

func (r *PostgresRepository) PublishArticle(ctx context.Context, a *domain.Article) error {
	query := `
		INSERT INTO public.articles (author_id, title, excerpt, full_content, category, cover_image_path, read_time_minutes, is_public)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		RETURNING id, created_at;
	`
	return r.pool.QueryRow(ctx, query, a.AuthorID, a.Title, a.Excerpt, a.FullContent, a.Category, a.CoverImagePath, a.ReadTimeMinutes, a.IsPublic).
		Scan(&a.ID, &a.CreatedAt)
}

func (r *PostgresRepository) ToggleLikeArticle(ctx context.Context, userID, articleID string) (bool, int, error) {
	// Simple increment for demonstration
	query := `
		UPDATE public.articles
		SET likes_count = likes_count + 1
		WHERE id = $1
		RETURNING likes_count;
	`
	var count int
	err := r.pool.QueryRow(ctx, query, articleID).Scan(&count)
	return true, count, err
}

func (r *PostgresRepository) BookmarkArticle(ctx context.Context, userID, articleID string) error {
	query := `
		INSERT INTO public.saved_items (user_id, target_type, target_id)
		VALUES ($1, 'article', $2)
		ON CONFLICT DO NOTHING;
	`
	_, err := r.pool.Exec(ctx, query, userID, articleID)
	return err
}

func (r *PostgresRepository) UnbookmarkArticle(ctx context.Context, userID, articleID string) error {
	query := `
		DELETE FROM public.saved_items
		WHERE user_id = $1 AND target_type = 'article' AND target_id = $2;
	`
	_, err := r.pool.Exec(ctx, query, userID, articleID)
	return err
}

// ==========================================
// 4. Moments (Cursor Pagination & Soft-Purge)
// ==========================================

func (r *PostgresRepository) GetFeed(ctx context.Context, userID, circleID string, cursorTime *time.Time, cursorID *string, limit int) ([]domain.Moment, bool, *string, error) {
	baseQuery := `
		SELECT m.id, m.sender_id, p.display_name, m.circle_id, m.image_path, COALESCE(m.caption, ''),
		       m.auto_purge_duration_seconds, m.purged_at, m.is_archived, m.likes_count, m.created_at
		FROM public.moments m
		JOIN public.profiles p ON p.id = m.sender_id
		WHERE m.is_archived = false AND m.purged_at IS NULL
	`
	args := []interface{}{}
	argIdx := 1

	if cursorTime != nil && cursorID != nil {
		baseQuery += fmt.Sprintf(" AND (m.created_at, m.id) < ($%d, $%d)", argIdx, argIdx+1)
		args = append(args, *cursorTime, *cursorID)
		argIdx += 2
	}

	baseQuery += fmt.Sprintf(" ORDER BY m.created_at DESC, m.id DESC LIMIT $%d;", argIdx)
	args = append(args, limit+1)

	rows, err := r.pool.Query(ctx, baseQuery, args...)
	if err != nil {
		return nil, false, nil, fmt.Errorf("failed to query moments feed: %w", err)
	}
	defer rows.Close()

	var moments []domain.Moment
	for rows.Next() {
		var m domain.Moment
		var autoPurge sql.NullInt64
		if err := rows.Scan(
			&m.ID, &m.SenderID, &m.SenderName, &m.CircleID, &m.ImagePath, &m.Caption,
			&autoPurge, &m.PurgedAt, &m.IsArchived, &m.LikesCount, &m.CreatedAt,
		); err != nil {
			return nil, false, nil, err
		}
		if autoPurge.Valid {
			v := int(autoPurge.Int64)
			m.AutoPurgeDurationSeconds = &v
		}
		if len(m.SenderName) > 0 {
			m.SenderInitials = strings.ToUpper(string([]rune(m.SenderName)[:1]))
		}
		m.ImageURL = m.ImagePath
		moments = append(moments, m)
	}

	hasMore := len(moments) > limit
	if hasMore {
		moments = moments[:limit]
	}

	var nextCursor *string
	if len(moments) > 0 && hasMore {
		last := moments[len(moments)-1]
		c := domain.EncodeCursor(last.CreatedAt, last.ID)
		nextCursor = &c
	}

	return moments, hasMore, nextCursor, nil
}

func (r *PostgresRepository) PostMoment(ctx context.Context, m *domain.Moment) error {
	query := `
		INSERT INTO public.moments (sender_id, circle_id, image_path, caption, auto_purge_duration_seconds)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, created_at;
	`
	return r.pool.QueryRow(ctx, query, m.SenderID, m.CircleID, m.ImagePath, m.Caption, m.AutoPurgeDurationSeconds).
		Scan(&m.ID, &m.CreatedAt)
}

func (r *PostgresRepository) ToggleLikeMoment(ctx context.Context, userID, momentID string) (bool, int, error) {
	query := `
		UPDATE public.moments
		SET likes_count = likes_count + 1
		WHERE id = $1
		RETURNING likes_count;
	`
	var count int
	err := r.pool.QueryRow(ctx, query, momentID).Scan(&count)
	return true, count, err
}

func (r *PostgresRepository) GetArchive(ctx context.Context, userID string, cursorTime *time.Time, cursorID *string, limit int) ([]domain.Moment, bool, *string, error) {
	query := `
		SELECT m.id, m.sender_id, p.display_name, m.circle_id, m.image_path, COALESCE(m.caption, ''),
		       m.auto_purge_duration_seconds, m.purged_at, m.is_archived, m.likes_count, m.created_at
		FROM public.moments m
		JOIN public.profiles p ON p.id = m.sender_id
		WHERE m.sender_id = $1 AND (m.is_archived = true OR m.purged_at IS NOT NULL)
		ORDER BY m.created_at DESC, m.id DESC LIMIT $2;
	`
	rows, err := r.pool.Query(ctx, query, userID, limit+1)
	if err != nil {
		return nil, false, nil, err
	}
	defer rows.Close()

	var moments []domain.Moment
	for rows.Next() {
		var m domain.Moment
		var autoPurge sql.NullInt64
		if err := rows.Scan(
			&m.ID, &m.SenderID, &m.SenderName, &m.CircleID, &m.ImagePath, &m.Caption,
			&autoPurge, &m.PurgedAt, &m.IsArchived, &m.LikesCount, &m.CreatedAt,
		); err != nil {
			return nil, false, nil, err
		}
		if autoPurge.Valid {
			v := int(autoPurge.Int64)
			m.AutoPurgeDurationSeconds = &v
		}
		m.ImageURL = m.ImagePath
		moments = append(moments, m)
	}

	hasMore := len(moments) > limit
	if hasMore {
		moments = moments[:limit]
	}

	var nextCursor *string
	if len(moments) > 0 && hasMore {
		last := moments[len(moments)-1]
		c := domain.EncodeCursor(last.CreatedAt, last.ID)
		nextCursor = &c
	}
	return moments, hasMore, nextCursor, nil
}

func (r *PostgresRepository) RestoreMoment(ctx context.Context, userID, momentID string) error {
	query := `
		UPDATE public.moments
		SET is_archived = false, purged_at = NULL
		WHERE id = $1 AND sender_id = $2;
	`
	_, err := r.pool.Exec(ctx, query, momentID, userID)
	return err
}

func (r *PostgresRepository) DeleteMomentPermanently(ctx context.Context, userID, momentID string) error {
	query := `
		DELETE FROM public.moments
		WHERE id = $1 AND sender_id = $2;
	`
	_, err := r.pool.Exec(ctx, query, momentID, userID)
	return err
}

// ==========================================
// 5. Contextual Chat Messages
// ==========================================

func (r *PostgresRepository) GetInbox(ctx context.Context, userID string) ([]domain.ChatInboxItem, error) {
	friends, err := r.GetFriends(ctx, userID)
	if err != nil {
		return nil, err
	}
	var items []domain.ChatInboxItem
	for _, f := range friends {
		items = append(items, domain.ChatInboxItem{
			FriendID:       f.ID,
			FriendName:     f.Name,
			FriendUsername: f.Username,
			FriendInitials: f.Initials,
			LastMessage:    "Bấm vào để bắt đầu cuộc trò chuyện...",
			LastMessageAt:  time.Now(),
			UnreadCount:    0,
		})
	}
	return items, nil
}

func (r *PostgresRepository) GetMessages(ctx context.Context, userID, friendID string, cursorTime *time.Time, cursorID *string, limit int) ([]domain.ChatMessage, bool, *string, error) {
	query := `
		SELECT c.id, c.sender_id, c.recipient_id, c.message_text, c.image_path, c.quoted_moment_id, c.sent_at, c.read_at
		FROM public.chat_messages c
		WHERE (c.sender_id = $1 AND c.recipient_id = $2) OR (c.sender_id = $2 AND c.recipient_id = $1)
		ORDER BY c.sent_at ASC LIMIT $3;
	`
	rows, err := r.pool.Query(ctx, query, userID, friendID, limit)
	if err != nil {
		return nil, false, nil, err
	}
	defer rows.Close()

	var list []domain.ChatMessage
	for rows.Next() {
		var m domain.ChatMessage
		var qMoment sql.NullString
		if err := rows.Scan(&m.ID, &m.SenderID, &m.RecipientID, &m.MessageText, &m.ImagePath, &qMoment, &m.SentAt, &m.ReadAt); err != nil {
			return nil, false, nil, err
		}
		if qMoment.Valid {
			m.QuotedMoment = &domain.QuotedMomentPreview{
				ID:           qMoment.String,
				ThumbnailURL: "https://picsum.photos/seed/quote/120/120",
				Caption:      "Khoảnh khắc được trích dẫn",
				AuthorName:   "Bạn",
			}
		}
		list = append(list, m)
	}
	return list, false, nil, nil
}

func (r *PostgresRepository) SendMessage(ctx context.Context, msg *domain.ChatMessage) error {
	var quotedID *string
	if msg.QuotedMoment != nil {
		quotedID = &msg.QuotedMoment.ID
	}
	query := `
		INSERT INTO public.chat_messages (sender_id, recipient_id, message_text, image_path, quoted_moment_id)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id, sent_at;
	`
	return r.pool.QueryRow(ctx, query, msg.SenderID, msg.RecipientID, msg.MessageText, msg.ImagePath, quotedID).
		Scan(&msg.ID, &msg.SentAt)
}
