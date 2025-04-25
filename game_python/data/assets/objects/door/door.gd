extends StaticBody2D


func _ready() -> void:
	var computers = get_tree().get_nodes_in_group("computers")
	for computer in computers:
		computer.connect("open_door", Callable(self, "_open"))
	

func _open():
	var file = FileAccess.open("res://text_editor.txt", FileAccess.READ).get_as_text()
	if test():
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property($".", "global_position:y", -5, 0.5)
		await tween.finished
		queue_free()


func test():
	var ans = ["18\r\n"]
	var output = []

	var cmd = "cmd.exe" if OS.get_name() == "Windows" else "sh"
	var args = ["/C", "python", "test.py"] if OS.get_name() == "Windows" else ["-c", "python3 test.py"]
	OS.execute(cmd, args, output, true)
	
	if output[0] == "Error": 
		print("Error")
	elif ans == output:
		return 1
	return 0
