extends HBoxContainer

onready var key = $key
onready var value = $value

func init_stat(k, v):
	key.text = str(k) + ": "
	value.text = str(v)
