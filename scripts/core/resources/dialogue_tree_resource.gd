class_name DialogueTreeResource
extends ContentDefinition
## Typed dialogue graph for editor-authored conversations.

@export var start_node_id: StringName
@export var nodes: Array[DialogueNodeResource] = []

func validate() -> PackedStringArray:
    var errors := super.validate()
    var ids := {}
    for node in nodes:
        errors.append_array(node.validate())
        if ids.has(node.node_id): errors.append("duplicate dialogue node: %s" % node.node_id)
        ids[node.node_id] = true
    if not ids.has(start_node_id): errors.append("start_node_id does not exist")
    return errors
