package pkg

import (
	"math/rand"
	"time"
)

const (
	baseBytes = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
)

func RandomPass(length int) []byte {

	pass := make([]byte, length)
	rand.Seed(time.Now().UnixNano())
	for i := range pass {
		pass[i] = baseBytes[rand.Intn(len(baseBytes))]
	}
	return pass
}
