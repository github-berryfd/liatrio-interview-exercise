package server

import (
	"liatrio-exercise/internal/healthcheck"
	"net/http"

	"github.com/julienschmidt/httprouter"
)

func NewServer() *http.Server {
	return &http.Server{
		Addr:    ":8080",
		Handler: newRouter(),
	}
}

func newRouter() *httprouter.Router {
	//Invoke a new Router
	mux := httprouter.New()

	//Time to assign the routes
	mux.GET("/health", healthcheck.GetHealthStatus())
	return mux
}
