package healthcheck

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/julienschmidt/httprouter"
)

// This test is specifically focused to target the /health endpoint handler
// Only 75% Coverage due to us not testing json.Marshaller which is OK
func TestGetHealthStatus(t *testing.T) {
	//Set up Router
	handler := GetHealthStatus()
	router := httprouter.New()
	router.GET("/health", handler)

	//Create Request
	req, err := http.NewRequest(http.MethodGet, "/health", nil)
	if err != nil {
		t.Fatal(err)
	}
	//Use HTTPTest to mock the Recorder
	rr := httptest.NewRecorder()

	//Send Request
	router.ServeHTTP(rr, req)

	//Check request response
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("GetHealthStatus() FAILED - Handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	var response HealthStatus
	err = json.Unmarshal(rr.Body.Bytes(), &response)
	if err != nil {
		t.Fatalf("GetHealthStatus() FAILED - Error unmarshaling response: %v", err)
	}

	//Check the status message
	expectedSubstring := "Automate all the things"
	if !strings.Contains(response.Message, expectedSubstring) {
		t.Errorf("GetHealthStatus() FAILED - Unexpected response message: got %v, want a string containing %v", response.Message, expectedSubstring)
	}
	// Check the timestamp is reasonable (e.g., not zero)
	if response.Timestamp <= 0 {
		t.Errorf("GetHealthStatus() FAILED - Timestamp should be positive, got %v", response.Timestamp)
	}

	contentType := rr.Header().Get("Content-Type")
	expectedContentType := "application/json"
	if contentType != expectedContentType {
		t.Errorf("GetHealthStatus() FAILED - Content type header does not match: got %v want %v", contentType, expectedContentType)
	}
}
