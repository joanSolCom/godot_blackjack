extends Sprite2D

var deck: Array
var N_DECKS = 6

var dealer_slots: Array
var player_slots: Array
var player_scores: Array
var dealer_scores: Array

func build_deck():
	var card_names_path = "res://card_info/deck.txt"
	var i = 0;
	var file = FileAccess.open(card_names_path, FileAccess.READ)
	var content = Array(file.get_as_text().strip_edges().split("\n"))
	deck = content
	while i < N_DECKS:
		deck += content
		i+=1
		
	shuffle_deck()
	

func shuffle_deck():
	randomize()
	deck.shuffle()

func pick_card():
	if len(deck) == 0:
		build_deck()

	return deck.pop_at(0)

func cleanup():
	player_scores = []
	dealer_scores = []
	$score_player.text = "0"
	$score_dealer.text = "0"
	$status.text = ""
	
	var j = 0
	while j < len(dealer_slots):
		if j >=2:
			dealer_slots[j].hide()
			player_slots[j].hide()
			player_slots[j].card_id = "unknown"
			dealer_slots[j].card_id = "unknown"
		else:
			dealer_slots[j].card_id = "unknown"
			show_element(dealer_slots[j], "unknown")
			player_slots[j].card_id = "unknown"
			
		j+=1

func start_game():
	cleanup()
	var dealer_shown_card = pick_card()
	show_element(dealer_slots[1], dealer_shown_card)
	var player_card1 = pick_card()
	show_element(player_slots[0], player_card1)
	var player_card2 = pick_card()
	show_element(player_slots[1], player_card2)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_deck()
	dealer_slots = $Dealer.get_children()
	player_slots = $Player.get_children()
	start_game()
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func show_element(sprite: Sprite2D, card_id: String):
	if sprite:
		if sprite.visible == false:
			sprite.show()

		sprite.card_id = card_id
		sprite.show_image()
		update_score(sprite)
	
func update_score(sprite: Sprite2D):
	var card_info = sprite.load_card_info()
	var value = card_info.get("value")
	var score = 0
	if value not in ["A", "J", "Q", "K"]:
		score = int(value)
	elif value == "A":
		score = 11
	else:
		score = 10
	
	var sprite_name = sprite.name
	var score_label = $score_player
	var score_array
	
	if sprite_name.split("_")[1] == "dealer":
		score_label = $score_dealer
		score_array = dealer_scores
		dealer_scores.append(score)
	else:
		score_array = player_scores
		player_scores.append(score)

	var current_score = compute_score(score_array)
	score_label.text = str(current_score)

func compute_score(score_array: Array):
	var score = 0
	var ace_count = 0

	for card_value in score_array:
		if card_value == 11:  # Ace
			score += 11
			ace_count += 1
		else:
			score += card_value

	# Convert Aces from 11 to 1 if needed to avoid bust
	while score > 21 and ace_count > 0:
		score -= 10
		ace_count -= 1

	return score
	
func _on_hit_pressed() -> void:
	if $status.text == "":
		var next_slot
		for player_slot in player_slots:
			if player_slot.card_id == "unknown":
				next_slot = player_slot
				break
		
		var player_card = pick_card()
		show_element(next_slot, player_card)
		if int($score_player.text) > 21:
			$status.text = "YOU LOST"


func play_dealer():
	var finished = false
	while not finished:
		var next_slot
		for dealer_slot in dealer_slots:
			if dealer_slot.card_id == "unknown":
				next_slot = dealer_slot
				break
		
		var card = pick_card()
		show_element(next_slot, card)
		if int($score_dealer.text) > 21:
			finished = true
		elif int($score_dealer.text) >= 16:
			finished = true
	
	var score_dealer = int($score_dealer.text)
	var score_player = int($score_player.text)
	if int($score_dealer.text) > 21:
		$status.text = "YOU WIN"
	else:
		if score_dealer == score_player:
			$status.text = "DRAW"
		elif score_dealer < score_player:
			$status.text = "YOU WIN"
		else:
			$status.text = "YOU LOSE"
	

func _on_stay_pressed() -> void:
	if $status.text == "":
		play_dealer()


func _on_restart_pressed() -> void:
	start_game()
