package main

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"

	"github.com/julienschmidt/httprouter"
)

type envelope map[string]interface{}

func (app *application) readIDParam(r *http.Request) (uint64, error) {
	params := httprouter.ParamsFromContext(r.Context())
	id, err := strconv.ParseUint(params.ByName("id"), 10, 64)
	if err != nil {
		return 0, errors.New("invalid id parameter")
	}
	return id, nil
}

func (app *application) writeJSON(w http.ResponseWriter, status int, data interface{}, headers http.Header) error {
	encodedData, err := json.MarshalIndent(data, "", "\t")
	if err != nil {
		return err
	}
	encodedData = append(encodedData, '\n')
	for key, value := range headers {
		w.Header()[key] = value
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	w.Write(encodedData)

	return nil
}
