# Translators

A quick guide to adding new translations to Titan Tactics

## Story

The bulk of the translations will take place in the story files. They are here:

* res://Resources/Story/en_US/*.json
* res://Resources/Story/nl_NL/*.json
* res://Resources/Story/es_ES/*.json
* res://Resources/Story/<locale>/*.json

Where <locale> is a locale code as found here: https://docs.godotengine.org/en/stable/tutorials/i18n/locales.html#doc-locales

## Menus

Menu translations are done in a CSV file located at res://Resources/translations.csv
The format of this file is documented here: 
https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_translations.html#doc-importing-translations

## Adding the language option to the landing menu

This part is a bit messy at the moment. A human-readable local name for the language is added in the landing script *_ready* function:

```
func _ready():
	$Locale.add_item("English")
	$Locale.add_item("Nederlands")
```

And then to make it selectable, in the *_on_Locale_item_selected* function, add it to the *items* array:

```
func _on_Locale_item_selected(index):
	var items = [ "en_US", "nl_NL", "es_ES" ]
```
