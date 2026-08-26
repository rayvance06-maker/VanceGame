extends Area2D

func _on_body_entered(_body):
	print("+1 Coins!")
	queue_free()
 
