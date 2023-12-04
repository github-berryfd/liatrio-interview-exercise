package server

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

// This test is focused on testing the server configuration and integration of handlers
func TestNewServer(t *testing.T) {
	srv := NewServer()

	testServer := httptest.NewUnstartedServer(srv.Handler)
	testServer.Start()

	//Lets make sure we clean up
	defer testServer.Close()

	// Make a request to the `/health` endpoint
	resp, err := http.Get(testServer.URL + "/health")
	if err != nil {
		t.Fatalf("NewServer() FAILED -Failed to send GET request: %v", err)
	}
	defer resp.Body.Close()

	// Check the status code
	if resp.StatusCode != http.StatusOK {
		t.Errorf("NewServer() FAILED - Expected status OK; got %v", resp.Status)
	}
}
