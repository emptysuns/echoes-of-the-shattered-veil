class_name ActorFactory
extends RefCounted

const ACTOR_SCENE := preload("res://scenes/entities/actor.tscn")

static func create(entity_definition_id: StringName, actor_id: StringName, grid_position: Vector2i, spawn_sequence := 0) -> Actor:
    var definition := ContentRegistry.get_definition(entity_definition_id) as EntityDefinitionResource
    if definition == null:
        Logger.error(&"entity", &"ENTITY_DEFINITION_MISSING", "Cannot create actor", {"definition_id": entity_definition_id})
        return null
    var actor := ACTOR_SCENE.instantiate() as Actor
    actor.configure(definition, actor_id, grid_position, spawn_sequence)
    return actor
