class_name Actor
extends Node2D
## Node2D shell composed from focused child Components.

signal grid_position_changed(actor: Actor, previous: Vector2i, current: Vector2i)
signal died(actor: Actor, source: Node)

var sprite: Sprite2D
var health: HealthComponent
var combat: CombatComponent
var timeline: EnergyTimelineComponent
var statuses: StatusComponent
var ai: AIComponent
var inventory: InventoryComponent
var dialogue: DialogueComponent
var narrative_trigger: NarrativeTriggerComponent

var actor_id: StringName
var definition: EntityDefinitionResource
var grid_position := Vector2i.ZERO
var spawn_sequence := 0
var elite := false
var player_controlled := false

func _ready() -> void:
    _cache_components()
    if not health.depleted.is_connected(_on_depleted): health.depleted.connect(_on_depleted)

func _cache_components() -> void:
    sprite = get_node("Sprite2D") as Sprite2D
    health = get_node("HealthComponent") as HealthComponent
    combat = get_node("CombatComponent") as CombatComponent
    timeline = get_node("EnergyTimelineComponent") as EnergyTimelineComponent
    statuses = get_node("StatusComponent") as StatusComponent
    ai = get_node("AIComponent") as AIComponent
    inventory = get_node("InventoryComponent") as InventoryComponent
    dialogue = get_node("DialogueComponent") as DialogueComponent
    narrative_trigger = get_node("NarrativeTriggerComponent") as NarrativeTriggerComponent

func configure(source: EntityDefinitionResource, id: StringName, position_value: Vector2i, sequence := 0) -> void:
    _cache_components()
    definition = source
    actor_id = id
    spawn_sequence = sequence
    player_controlled = source.faction == &"player"
    set_grid_position(position_value)
    health.configure(source.stats.max_health + (InventorySystem.equipment_bonus(&"health") if player_controlled else 0))
    combat.configure(source.stats, source.action_ids)
    timeline.configure(source.stats.speed)
    ai.configure(source.ai_profile)
    inventory.configure(id)
    dialogue.configure(source.dialogue_id)
    var texture := load(source.texture_path) as Texture2D
    if texture != null:
        sprite.texture = texture
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    elite = false

func make_elite() -> void:
    if elite or player_controlled: return
    elite = true
    health.maximum += 4
    health.current += 4
    combat.base_attack += 1
    sprite.modulate = Color("d59a42")

func set_grid_position(value: Vector2i) -> void:
    var previous := grid_position
    grid_position = value
    position = Vector2(value * 32)
    if previous != value: grid_position_changed.emit(self, previous, value)

func get_attack() -> int:
    return maxi(0, combat.attack_value(player_controlled) + statuses.modifier(&"attack"))

func get_defense() -> int:
    return maxi(0, combat.defense_value(player_controlled) + statuses.modifier(&"defense"))

func get_critical_chance() -> int:
    return combat.critical_chance

func take_damage(amount: int, source: Node = null) -> int:
    return health.damage(amount, source)

func heal(amount: int) -> int:
    return health.heal(amount)

func apply_status(status_id: StringName, duration := 0) -> bool:
    return statuses.apply(status_id, duration)

func modify_energy(amount: int) -> void:
    timeline.energy = maxi(0, timeline.energy + amount)

func is_alive() -> bool:
    return health.current > 0

func _on_depleted(source: Node) -> void:
    died.emit(self, source)
    EventBus.actor_defeated.emit(actor_id, source.actor_id if source is Actor else &"environment")
