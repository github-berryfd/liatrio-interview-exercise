package healthcheck

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/julienschmidt/httprouter"
)

type HealthStatus struct {
	Message   string `json:"message"`
	Timestamp int64  `json:"timestamp"`
}

func GetHealthStatus() httprouter.Handle {
	//When the endpoint is reached, this function will be called with the following parameters.
	return func(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
		response := HealthStatus{
			Message:   "Automate all t he things x4!",
			Timestamp: time.Now().UnixMilli(),
		}

		jsonReponse, err := json.Marshal(response)
		if err != nil {

			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		w.Header().Set("Content-Type", "application/json")

		w.Write(jsonReponse)
	}
}
