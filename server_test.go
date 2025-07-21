package main

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/redis/go-redis/v9"
)

func TestHandle(t *testing.T) {
	// Setup test Redis client using miniredis or mock
	// For this test, we'll use a real Redis client but handle connection errors gracefully
	originalRdb := rdb
	defer func() { rdb = originalRdb }()

	// Initialize Redis client for testing
	rdb = redis.NewClient(&redis.Options{
		Addr:     "redis:6379",
		Password: "",
		DB:       1, // Use different DB for testing
	})

	// Test the handler
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(handle)

	handler.ServeHTTP(rr, req)

	// Check status code
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	// Check response body contains expected content
	body := rr.Body.String()
	if !strings.Contains(body, "Hello") {
		t.Errorf("handler returned unexpected body: got %v", body)
	}

	// Check that response contains visit count format
	if !strings.Contains(body, "Visit #") {
		t.Errorf("handler should include visit count: got %v", body)
	}

	// Clean up test data
	ctx := context.Background()
	rdb.Del(ctx, "visits")
}

func TestHandleRedisDown(t *testing.T) {
	// Test behavior when Redis is unavailable
	originalRdb := rdb
	defer func() { rdb = originalRdb }()

	// Use invalid Redis connection
	rdb = redis.NewClient(&redis.Options{
		Addr:     "invalid:6379",
		Password: "",
		DB:       0,
	})

	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(handle)

	handler.ServeHTTP(rr, req)

	// Should still return 200 even if Redis is down
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	// Check response body contains expected content with fallback visit count
	body := rr.Body.String()
	if !strings.Contains(body, "Hello") {
		t.Errorf("handler returned unexpected body: got %v", body)
	}

	// Should show fallback visit count (-1)
	if !strings.Contains(body, "Visit #-1") {
		t.Errorf("handler should show fallback visit count: got %v", body)
	}
}