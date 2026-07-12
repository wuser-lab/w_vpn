package store

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Store struct{ pool *pgxpool.Pool }

type Region struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	City        string `json:"city"`
	CountryCode string `json:"countryCode"`
	Endpoint    string `json:"endpoint"`
	PublicKey   string `json:"publicKey"`
	Load        int    `json:"load"`
}
type Device struct {
	ID        string    `json:"id"`
	AccountID string    `json:"accountID"`
	Name      string    `json:"name"`
	Platform  string    `json:"platform"`
	PublicKey string    `json:"publicKey"`
	CreatedAt time.Time `json:"createdAt"`
}
type Entitlement struct {
	Plan      string     `json:"plan"`
	Status    string     `json:"status"`
	Source    string     `json:"source"`
	ExpiresAt *time.Time `json:"expiresAt,omitempty"`
}
type Tunnel struct{ ID, Address, DNS, Endpoint, ServerPublicKey string }

func Open(ctx context.Context, url string) (*Store, error) {
	pool, err := pgxpool.New(ctx, url)
	if err != nil {
		return nil, err
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, err
	}
	return &Store{pool: pool}, nil
}
func (s *Store) Close() { s.pool.Close() }

func (s *Store) Migrate(ctx context.Context) error {
	_, err := s.pool.Exec(ctx, `
CREATE TABLE IF NOT EXISTS accounts (id UUID PRIMARY KEY, created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE IF NOT EXISTS devices (
  id UUID PRIMARY KEY, account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  name TEXT NOT NULL, platform TEXT NOT NULL, public_key TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(), revoked_at TIMESTAMPTZ
);
CREATE TABLE IF NOT EXISTS entitlements (
  account_id UUID PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE,
  plan TEXT NOT NULL, status TEXT NOT NULL, source TEXT NOT NULL,
  expires_at TIMESTAMPTZ, updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS regions (
  id TEXT PRIMARY KEY, name TEXT NOT NULL, city TEXT NOT NULL, country_code TEXT NOT NULL,
  endpoint TEXT NOT NULL, public_key TEXT NOT NULL, load_percent INTEGER NOT NULL DEFAULT 0,
  enabled BOOLEAN NOT NULL DEFAULT true
);
CREATE TABLE IF NOT EXISTS tunnels (
  id UUID PRIMARY KEY, account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  device_id UUID NOT NULL REFERENCES devices(id) ON DELETE CASCADE,
  region_id TEXT NOT NULL REFERENCES regions(id), address INET NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(), revoked_at TIMESTAMPTZ
);
INSERT INTO regions(id,name,city,country_code,endpoint,public_key,load_percent) VALUES
 ('nl-ams','Netherlands','Amsterdam','NL','nl.example.invalid:51820','replace-me',29),
 ('de-fra','Germany','Frankfurt','DE','de.example.invalid:51820','replace-me',38),
 ('us-nyc','United States','New York','US','us.example.invalid:51820','replace-me',41),
 ('sg-sin','Singapore','Singapore','SG','sg.example.invalid:51820','replace-me',33)
ON CONFLICT (id) DO NOTHING;`)
	return err
}

func (s *Store) CreateTunnel(ctx context.Context, id, accountID, deviceID, regionID string) (Tunnel, error) {
	var t Tunnel
	err := s.pool.QueryRow(ctx, `
WITH slot AS (SELECT 10 + count(*)::int AS n FROM tunnels WHERE revoked_at IS NULL),
created AS (
 INSERT INTO tunnels(id,account_id,device_id,region_id,address)
 SELECT $1,$2,$3,$4,('10.64.0.' || slot.n::text || '/32')::inet FROM slot
 RETURNING id,address,region_id
)
SELECT created.id::text,host(created.address),regions.endpoint,regions.public_key
FROM created JOIN regions ON regions.id=created.region_id
WHERE EXISTS(SELECT 1 FROM devices WHERE id=$3 AND account_id=$2 AND revoked_at IS NULL)
`, id, accountID, deviceID, regionID).Scan(&t.ID, &t.Address, &t.Endpoint, &t.ServerPublicKey)
	if err != nil {
		return Tunnel{}, err
	}
	t.DNS = "10.64.0.1"
	return t, nil
}

func (s *Store) Regions(ctx context.Context) ([]Region, error) {
	rows, err := s.pool.Query(ctx, `SELECT id,name,city,country_code,endpoint,public_key,load_percent FROM regions WHERE enabled ORDER BY id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var result []Region
	for rows.Next() {
		var r Region
		if err := rows.Scan(&r.ID, &r.Name, &r.City, &r.CountryCode, &r.Endpoint, &r.PublicKey, &r.Load); err != nil {
			return nil, err
		}
		result = append(result, r)
	}
	return result, rows.Err()
}

func (s *Store) CreateDevice(ctx context.Context, d Device) error {
	_, err := s.pool.Exec(ctx, `INSERT INTO accounts(id) VALUES($1) ON CONFLICT DO NOTHING`, d.AccountID)
	if err != nil {
		return err
	}
	_, err = s.pool.Exec(ctx, `INSERT INTO devices(id,account_id,name,platform,public_key) VALUES($1,$2,$3,$4,$5)`, d.ID, d.AccountID, d.Name, d.Platform, d.PublicKey)
	return err
}

func (s *Store) Entitlement(ctx context.Context, accountID string) (Entitlement, error) {
	var e Entitlement
	err := s.pool.QueryRow(ctx, `SELECT plan,status,source,expires_at FROM entitlements WHERE account_id=$1`, accountID).Scan(&e.Plan, &e.Status, &e.Source, &e.ExpiresAt)
	if err != nil {
		return Entitlement{}, errors.New("entitlement not found")
	}
	return e, nil
}
