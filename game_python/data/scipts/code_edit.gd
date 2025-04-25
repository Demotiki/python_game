extends Window

@onready var code = $CodeEdit
@onready var window = $"."

func _ready() -> void:
	window.popup()
	window.mode = true
	window.exclusive = true
	window.process_mode = Node.PROCESS_MODE_ALWAYS
	code.process_mode = Node.PROCESS_MODE_ALWAYS
	
	
	visible()
	
	var file = FileAccess.open("res://text_editor.txt", FileAccess.READ)
	code.text = file.get_as_text()
	file.close()
	
	
func _process(delta: float) -> void:
		if Input.is_action_just_pressed("esc"):
			_on_close_requested()

	
	
func visible():
	#Настрйока внешнего вида CodeEdit
	code.gutters_draw_line_numbers = true
	code.gutters_zero_pad_line_numbers = false
	code.highlight_current_line = true

	code.add_theme_color_override("code_font_color", Color.TRANSPARENT)

	# Основные цвета фона и текста
	code.add_theme_color_override("background_color", Color("#1e1e1e"))  # Основной фон
	code.add_theme_color_override("font_color", Color("#d4d4d4"))       # Основной текст
	
	# Цвета строк
	code.add_theme_color_override("current_line_color", Color("#2a2d2e"))  # Текущая строка
	code.add_theme_color_override("line_number_color", Color("#858585"))   # Номера строк
	
	# Выделение
	code.add_theme_color_override("selection_color", Color("#264f78"))     # Выделенный текст
	code.add_theme_color_override("word_highlighted_color", Color("#37373d")) # Подсветка одинаковых слов
	
	# Скобки
	code.add_theme_color_override("brace_mismatch_color", Color("#f44747")) # Ошибка в скобках
	code.add_theme_color_override("highlight_matching_braces_color", Color("#0066ff")) # Подсветка парных
	
	# Гуттер (область с номерами строк)
	code.add_theme_color_override("gutters_bg_color", Color("#1e1e1e"))
	
	# Автодополнение
	code.add_theme_color_override("completion_background_color", Color("#252526"))
	code.add_theme_color_override("completion_selected_color", Color("#37373d"))
	code.add_theme_color_override("completion_existing_color", Color("#3a3d41"))

	
	
	
	
func _on_close_requested() -> void:
	queue_free()
	get_tree().paused = false
	

func _on_button_pressed() -> void:
	var text = code.text
	var file = FileAccess.open("res://text_editor.txt", FileAccess.WRITE)
	
	file.store_string(text)
	file.close()
