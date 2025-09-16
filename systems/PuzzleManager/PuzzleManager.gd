extends Node
# PUZZLE MANAGER
@onready var encryption_service : EncryptionService = $EncryptionService


#func _ready():
	#process_plain_text("Testing puzzle output!")

func process_plain_text(plain_text: String) -> Dictionary:
	var puzzle_data : Dictionary
	var cipher_and_chars = encryption_service.pop_random_encrypt(plain_text)
	puzzle_data["plainText"] = plain_text
	puzzle_data["cipherText"] = cipher_and_chars["encrypted_text"]
	puzzle_data["unique_chars"] = cipher_and_chars["unique_chars"]
	puzzle_data["cipher"] = cipher_and_chars["cipher"]
	return puzzle_data
