package data

import "time"

type Movie struct {
	ID        uint64    `json:"id"`
	CreatedAt time.Time `json:"-"`
	Title     string    `json:"title"`
	Year      uint32    `json:"year,omitempty"`
	Runtime   Runtime   `json:"runtime,omitempty,string"`
	Genres    []string  `json:"genres,omitempty"`
	Version   uint32    `json:"version"`
}
