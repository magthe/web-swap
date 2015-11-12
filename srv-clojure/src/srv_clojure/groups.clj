(ns srv-clojure.groups)

(defn create-groups [left right]
  {:left (apply hash-set left)
   :right (apply hash-set right)
   :swappers ()})

(defn which-group? [gs name]
  (cond
    (contains? (:left gs) name) :left
    (contains? (:right gs) name) :right
    :else :error))

(defn- move-to-right-group [gs name]
  (let [new-left (disj (:left gs) name)
        new-right (conj (:right gs) name)]
    (assoc gs :left new-left :right new-right)))

(defn- move-to-left-group [gs name]
  (let [new-left (conj (:left gs) name)
        new-right (disj (:right gs) name)]
    (assoc gs :left new-left :right new-right)))

(defn- enqueue-swappers [gs name]
  (let [new-swappers (concat (:swappers gs) (list name))]
    (assoc gs :swappers (distinct new-swappers))))

(defn- dequeue-swappers [gs]
  (let [new-swappers (rest (:swappers gs))
        popped (first (:swappers gs))]
    [popped, (assoc gs :swappers new-swappers)]))

(defn- swap-groups [gs name]
  (let [group (which-group? gs name)]
    (cond
      (= group :left) (move-to-right-group gs name)
      (= group :right) (move-to-left-group gs name)
      :else gs)))

(defn perform-swap [gs name]
  (let [old-group (which-group? gs name)
        [qn, qg] (dequeue-swappers gs)
        qn-group (which-group? gs qn)]
    (cond
      (= old-group :error) gs
      (empty? (:swappers gs)) (enqueue-swappers gs name)
      (= old-group qn-group) (enqueue-swappers gs name)
      :else (swap-groups (swap-groups qg qn) name))))
