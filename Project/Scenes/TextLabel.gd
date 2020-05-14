extends Label

export (String) var lang_tile

func _ready():
	Language.connect("language_changed", self, "_on_language_changed")
	_on_language_changed(Language.current)

func _on_language_changed(new_lang):
	match new_lang:
		Language.languages.ENGLISH:
			if Language.lang_english.has(lang_tile):
				change_text(Language.lang_english[lang_tile])
		Language.languages.GERMAN:
			if Language.lang_german.has(lang_tile):
				change_text(Language.lang_german[lang_tile])

func change_text(s):
	text = str(s)
