class_name Player
extends CharacterBody2D

# Настройки движения
@export var max_speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# Настройки уклонения
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5

# Переменные состояния
var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO

# Ссылки на ноды
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer


func _ready() -> void:
	# Настройка таймеров
	dash_timer.wait_time = dash_duration
	dash_cooldown_timer.wait_time = dash_cooldown


func _physics_process(delta: float) -> void:
	if is_dashing:
		velocity = dash_direction * dash_speed
	else:
		handle_movement(delta)
	
	move_and_slide()

func handle_movement(delta: float) -> void:
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_axis("left", "right")
	input_vector.y = Input.get_axis("up", "down")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
		dash_direction = input_vector
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Активация уклонения
	if Input.is_action_just_pressed("dash") and can_dash and input_vector != Vector2.ZERO:
		start_dash()

func start_dash() -> void:
	is_dashing = true
	can_dash = false
	dash_timer.start()
	dash_cooldown_timer.start()

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	velocity *= 0.5  # Сброс скорости после дэша

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true
