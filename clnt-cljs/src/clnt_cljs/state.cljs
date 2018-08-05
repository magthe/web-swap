(ns clnt-cljs.state
  (:require [reagent.core :as reagent :refer [atom]]))

(defonce app-state (atom {:groups {}
                          :token nil
                          :auth {}}))

(defn update-groups [s gs]
  (assoc s :groups gs))

(defn update-token [s t]
  (assoc s :token t))
