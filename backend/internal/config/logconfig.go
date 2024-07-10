package config

import (
	"os"

	log "github.com/sirupsen/logrus"
)

// SetupLogger configures and returns a logger instance
func SetupLogger() *log.Logger {
	logger := log.New()
	logger.SetFormatter(&log.TextFormatter{
		DisableColors: false,
		FullTimestamp: true,
		ForceColors:   true,
	})
	logger.SetOutput(os.Stdout)
	logger.SetLevel(log.InfoLevel)
	return logger
}
