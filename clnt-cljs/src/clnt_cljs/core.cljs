(ns clnt-cljs.core
  (:require [clnt-cljs.state :refer [app-state]]
            [clnt-cljs.swap :as swap]
            [reagent.core :as reagent :refer [atom cursor]]
            [ajax.core :refer [GET]]
            [reagent-forms.core :refer [bind-fields]]))

(enable-console-print!)

(defn make-list [l]
  [:ol (for [i l]
         ^{:key i} [:li i])])

(def auth-form
  [:div
   [:input {:field :text
            :id :name}]
   [:input {:field :password
            :id :pword}]
   [:input {:type "button" :value "Authorize"
            :on-click (fn [] (swap/login app-state (:auth @app-state)))}]])

(defn auth-view []
  [bind-fields
   auth-form
   (cursor app-state [:auth])])

(defn swap-view []
  [:div
   [:input {:type "button" :value "Swap"
            :on-click (fn [] (swap/swap app-state (:token @app-state)))}]])

(defn swap-page []
  (println @app-state)
  [:div
   [:h1 "Lefters"]
   (make-list (get-in @app-state [:groups :left]))

   [:h1 "Righters"]
   (make-list (get-in @app-state [:groups :right]))

   [:h1 "Swappers"]
   (make-list (get-in @app-state [:groups :swappers]))

   (if (:token @app-state)
     (swap-view)
     (auth-view))
   ])

(reagent/render-component [swap-page]
                          (. js/document (getElementById "app")))

(defonce timers
  (do
    (swap/get-groups app-state)
    (js/setInterval #(swap/get-groups app-state) 10000)
    true))
