extends Label

func _process(delta: float) -> void:
	text = "Deaths: " + str(Data.deaths)
