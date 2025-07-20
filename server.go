/*----------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See LICENSE in the project root for license information.
 *---------------------------------------------------------------------------------------*/

package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"net/http"

	"github.com/microsoft/vscode-remote-try-go/hello"
	"github.com/redis/go-redis/v9"
)

var rdb *redis.Client

func handle(w http.ResponseWriter, r *http.Request) {
	ctx := context.Background()
	
	// Increment visit counter in Redis
	visits, err := rdb.Incr(ctx, "visits").Result()
	if err != nil {
		log.Printf("Redis error: %v", err)
		visits = -1 // fallback value
	}
	
	// Get hello message and add visit count
	helloMsg := hello.Hello()
	response := fmt.Sprintf("%s (Visit #%d)", helloMsg, visits)
	
	io.WriteString(w, response)
}

func main() {
	// Initialize Redis client
	rdb = redis.NewClient(&redis.Options{
		Addr:     "redis:6379", // Redis service name from docker-compose
		Password: "",           // no password
		DB:       0,            // default DB
	})
	
	// Test Redis connection
	ctx := context.Background()
	_, err := rdb.Ping(ctx).Result()
	if err != nil {
		log.Printf("Failed to connect to Redis: %v", err)
	} else {
		log.Println("Connected to Redis successfully")
	}

	portNumber := "9000"
	http.HandleFunc("/", handle)
	fmt.Println("Server listening on port ", portNumber)
	http.ListenAndServe(":"+portNumber, nil)
}
