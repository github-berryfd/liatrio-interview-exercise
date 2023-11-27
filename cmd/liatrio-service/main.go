package main

import (
	"context"
	"errors"
	"liatrio-exercise/internal/server"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	//Create the HTTP Server, it accepts port host and the handler. We are using the
	//julienschmidt httprouter instead of normal mux
	srv := server.NewServer()

	idleConnsClosed := make(chan struct{})
	//Run Asyncronously
	go func() {
		//Set up a channel that will handle os.Signal Type
		sigint := make(chan os.Signal, 1)
		//Tell GO to pass the signal to sigint if it is either the Interrupt or terminate signal
		signal.Notify(sigint, os.Interrupt)    // Interrupt Signal
		signal.Notify(sigint, syscall.SIGTERM) //Terminate Signal
		//Block until one of the signals is recieved
		<-sigint
		//Receieved
		log.Println("Service interrupt was recieved")

		//Create a context with a timeout of 60 seconds.
		//The 60 seconds is how long it should take to complete.
		//context.Background() is where almost all contexts are derrived from.
		//This context (ctx) is empty and never cancelled by default.
		//Cancel() cancels the created context (ctx) regardless of timeout
		ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)

		//This will call cancel when this anon-function exits.
		defer cancel()

		if err := srv.Shutdown(ctx); err != nil {
			log.Printf("Http Server Shutdown Error: %v", err)
		}
		log.Println("Service successfully shutdown")
		close(idleConnsClosed)
	}()

	log.Println("Starting service on port 8080")
	//Tell the service to start up, if it failed lets print the error
	//If with a short statement. THe ListenAndServe BLOCKS until it is killed, at which time we shut down.
	if err := srv.ListenAndServe(); err != nil {
		//Make sure its a normal close
		if !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("The server failed to start correctly: %v", err)
		}
	}

	<-idleConnsClosed
	log.Println("Service Stopped")
}
