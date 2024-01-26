package main

import (
	"flag"
	"log"
	"net/http"
	"os"
)

func main() {
	addr := flag.String("addr", ":9000", "Server address")
	flag.Parse()

	content, err := os.ReadFile("./cmd/example/cors/preflight/example.html")
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("starting server on %s", *addr)
	err = http.ListenAndServe(*addr, http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write(content)
	}))
	if err != nil {
		log.Fatal(err)
	}
}
