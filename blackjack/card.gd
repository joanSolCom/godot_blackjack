extends Sprite2D

@export var card_id: String = "unknown";
var base_path_info = "./card_info/"
var base_img_path = "./assets/images/cards/"
var card_info

func load_card_info():
	var file = base_path_info + card_id + ".json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	return json_as_dict

func show_image():
	card_info = load_card_info()
	if card_info:
		var img_path = "res://" + base_img_path + card_info.get("front_image")
		texture = load(img_path)
		
		
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
