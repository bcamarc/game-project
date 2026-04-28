extends Node2D

#testetstetsetsetes for andrwe
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name ==  "Knight":
		
		get_node("../../Stats").add_coin(2)
		queue_free()
	
	
	
