extends Node

@onready var encryption_service : EncryptionService = $EncryptionService


func _ready():
	get_puzzle("Testing puzzle output!")

func get_puzzle(plain_text: String) -> Dictionary:
	var puzzle_data : Dictionary
	puzzle_data["plainText"] = plain_text
	puzzle_data["cipherText"] = encryption_service.basic_caesar_encrypt(plain_text)
	Log.prn("puzzle manager output: ", puzzle_data)
	return puzzle_data
