package main

import (
	"flag"
	"log"
	"net/http"
	"os"
)

func main() {
	contents, err := os.ReadFile("./cmd/example/cors/simple/example.html")
	if err != nil {
		log.Fatal(err)
	}
	addr := flag.String("addr", ":9000", "Server address")
	flag.Parse()
	log.Printf("starting server on %s", *addr)

	err = http.ListenAndServe(*addr, http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(contents))
	}))
	log.Fatal(err)
}
