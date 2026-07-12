package httpapi

import (
	"crypto/rand"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/wvpn/service/services/api/internal/config"
	"github.com/wvpn/service/services/api/internal/store"
)

type API struct {
	cfg   config.Config
	store *store.Store
}

func New(cfg config.Config, db *store.Store) http.Handler {
	a := &API{cfg: cfg, store: db}
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", a.health)
	mux.HandleFunc("GET /v1/regions", a.auth(a.regions))
	mux.HandleFunc("POST /v1/devices", a.auth(a.createDevice))
	mux.HandleFunc("GET /v1/me/entitlement", a.auth(a.entitlement))
	mux.HandleFunc("POST /v1/tunnels", a.auth(a.createTunnel))
	return security(mux)
}

func (a *API) auth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer ") != a.cfg.DevelopmentToken {
			problem(w, http.StatusUnauthorized, "unauthorized")
			return
		}
		if r.Header.Get("X-Account-ID") == "" {
			problem(w, http.StatusBadRequest, "missing X-Account-ID")
			return
		}
		next(w, r)
	}
}
func (a *API) health(w http.ResponseWriter, _ *http.Request) {
	write(w, http.StatusOK, map[string]string{"status": "ok"})
}
func (a *API) regions(w http.ResponseWriter, r *http.Request) {
	regions, err := a.store.Regions(r.Context())
	if err != nil {
		problem(w, 500, "regions unavailable")
		return
	}
	write(w, 200, regions)
}
func (a *API) entitlement(w http.ResponseWriter, r *http.Request) {
	e, err := a.store.Entitlement(r.Context(), r.Header.Get("X-Account-ID"))
	if err != nil {
		write(w, 200, store.Entitlement{Plan: "none", Status: "inactive", Source: "none"})
		return
	}
	write(w, 200, e)
}
func (a *API) createDevice(w http.ResponseWriter, r *http.Request) {
	var in struct{ ID, Name, Platform, PublicKey string }
	if json.NewDecoder(http.MaxBytesReader(w, r.Body, 32<<10)).Decode(&in) != nil || in.ID == "" || in.PublicKey == "" {
		problem(w, 400, "invalid device")
		return
	}
	d := store.Device{ID: in.ID, AccountID: r.Header.Get("X-Account-ID"), Name: in.Name, Platform: in.Platform, PublicKey: in.PublicKey, CreatedAt: time.Now()}
	if err := a.store.CreateDevice(r.Context(), d); err != nil {
		problem(w, 409, "device exists or is invalid")
		return
	}
	write(w, 201, d)
}
func (a *API) createTunnel(w http.ResponseWriter, r *http.Request) {
	var in struct{ DeviceID, RegionID, Mode string }
	if json.NewDecoder(http.MaxBytesReader(w, r.Body, 16<<10)).Decode(&in) != nil || in.DeviceID == "" || in.RegionID == "" {
		problem(w, 400, "invalid tunnel request")
		return
	}
	id, err := uuid()
	if err != nil {
		problem(w, 500, "could not allocate tunnel")
		return
	}
	t, err := a.store.CreateTunnel(r.Context(), id, r.Header.Get("X-Account-ID"), in.DeviceID, in.RegionID)
	if err != nil {
		problem(w, 400, "device or region is invalid")
		return
	}
	write(w, http.StatusCreated, map[string]any{"id": t.ID, "interface": map[string]any{"address": t.Address + "/32", "dns": []string{t.DNS}}, "peer": map[string]any{"publicKey": t.ServerPublicKey, "endpoint": t.Endpoint, "allowedIPs": []string{"0.0.0.0/0", "::/0"}, "persistentKeepalive": 25}, "mode": in.Mode})
}
func security(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("Cache-Control", "no-store")
		next.ServeHTTP(w, r)
	})
}
func write(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
func problem(w http.ResponseWriter, status int, message string) {
	write(w, status, map[string]string{"error": message})
}
func uuid() (string, error) {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	return fmt.Sprintf("%08x-%04x-%04x-%04x-%012x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16]), nil
}
