package config

import "os"

type Config struct {
	ListenAddress    string
	DatabaseURL      string
	DevelopmentToken string
}

func Load() Config {
	return Config{
		ListenAddress:    value("LISTEN_ADDRESS", ":8080"),
		DatabaseURL:      value("DATABASE_URL", "postgres://wvpn:wvpn@localhost:5432/wvpn?sslmode=disable"),
		DevelopmentToken: value("DEVELOPMENT_TOKEN", "local-development-only"),
	}
}

func value(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
