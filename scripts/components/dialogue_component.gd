class_name DialogueComponent
extends Node
## Actor dialogue identity; traversal remains in DialogueManager.

var dialogue_id: StringName

func configure(value: StringName) -> void:
    dialogue_id = value

func begin() -> bool:
    return not String(dialogue_id).is_empty() and DialogueManager.start(dialogue_id)
