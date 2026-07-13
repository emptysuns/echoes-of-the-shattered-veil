class_name StatusEffectResource
extends ContentDefinition
## Stackable status data; execution remains in CombatSystem.

enum StackMode { REFRESH, ADD_DURATION, ADD_STACK, REPLACE }
enum TickTiming { BEFORE_ACTION, AFTER_ACTION, TIMELINE_STEP }

@export var stack_mode: StackMode = StackMode.REFRESH
@export var tick_timing: TickTiming = TickTiming.AFTER_ACTION
@export_range(1, 99, 1) var max_stacks: int = 1
@export_range(1, 99, 1) var base_duration: int = 1
@export var attack_modifier: int = 0
@export var defense_modifier: int = 0
@export var speed_modifier: int = 0
@export var periodic_effect_id: StringName

func validate() -> PackedStringArray:
    var errors := super.validate()
    if max_stacks < 1: errors.append("max_stacks must be positive")
    if base_duration < 1: errors.append("base_duration must be positive")
    return errors
