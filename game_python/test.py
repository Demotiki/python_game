try:
    with open("text_editor.txt", "r") as file:
        data = file.read()
        exec(f"{data}")
except Exception:
    print("Error")