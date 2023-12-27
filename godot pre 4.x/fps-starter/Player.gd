extends KinematicBody

const GRAVITY = -24.8
const MAX_SPEED = 20
const JUMP_SPEED = 18
const JUMP_DURATION = 2
const SPRINT_SPEED = 30

const ACCEL = 4.5
const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40

var velocity : Vector3
var direction : Vector3

var current_weapon_name = "UNARMED"
var weapons = {"UNARMED":null, "KNIFE":null, "PISTOL":null, "RIFLE":null}
const WEAPON_NUMBER_TO_NAME = {0:"UNARMED", 1:"KNIFE", 2:"PISTOL", 3:"RIFLE"}
const WEAPON_NAME_TO_NUMBER = {"UNARMED":0, "KNIFE":1, "PISTOL":2, "RIFLE":3}
var changing_weapon = false
var changing_weapon_name = "UNARMED"
var reloading_weapon = false

var simple_audio_player = preload("res://Simple_Audio_Player.tscn")

var health = 100

onready var camera = $Rotation_Helper/Camera
onready var rotation_helper = $Rotation_Helper
onready var flashlight = $Rotation_Helper/Flashlight
onready var UI_status_label = $HUD/Panel/Gun_label
onready var animation_manager = $Rotation_Helper/Model/Animation_Player

const MOUSE_SENSITIVITY = 0.05

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_manager.callback_function = funcref(self, "fire_bullet")
	
	weapons["KNIFE"] = $Rotation_Helper/Gun_Fire_Points/Knife_Point
	weapons["PISTOL"] = $Rotation_Helper/Gun_Fire_Points/Pistol_Point
	weapons["RIFLE"] = $Rotation_Helper/Gun_Fire_Points/Rifle_Point

	var gun_aim_point_pos = $Rotation_Helper/Gun_Aim_Point.global_transform.origin

	for weapon in weapons:
		var weapon_node = weapons[weapon]
		if weapon_node != null:
			weapon_node.player_node = self
			weapon_node.look_at(gun_aim_point_pos, Vector3(0, 1, 0))
			weapon_node.rotate_object_local(Vector3(0, 1, 0), deg2rad(180))

	current_weapon_name = "UNARMED"
	changing_weapon_name = "UNARMED"

func _physics_process(delta: float) -> void:
	process_input(delta)
	process_movement(delta)
	process_changing_weapons(delta)
	process_reloading()
	process_UI()

func process_input(delta : float):
	
	# Based on input, setup movement along the ground plane
	# where Y is forward, X is sideways.
	var input_movement_vector = Vector2()
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
		
	# Make sure diagonal movement isn't faster than along X/Z
	input_movement_vector = input_movement_vector.normalized()
	
	# Get global camera direction along the x/z plane, i.e. ground plane.
	var cam_xform = camera.get_global_transform()
	direction = Vector3()
	# In 3D, Z is forward/backwards, X sideways. Z is 'reversed', so negate it.
	direction += -cam_xform.basis.z * input_movement_vector.y
	direction += cam_xform.basis.x * input_movement_vector.x
	direction = direction.normalized()

	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			velocity.y = JUMP_SPEED
			
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
			
	# Capture/free cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		print(Input.get_mouse_mode())
		
	var weapon_change_number = WEAPON_NAME_TO_NUMBER[current_weapon_name]

	if Input.is_key_pressed(KEY_1):
		weapon_change_number = 0
	if Input.is_key_pressed(KEY_2):
		weapon_change_number = 1
	if Input.is_key_pressed(KEY_3):
		weapon_change_number = 2
	if Input.is_key_pressed(KEY_4):
		weapon_change_number = 3
	
	if Input.is_action_just_pressed("shift_weapon_positive"):
		weapon_change_number += 1
	if Input.is_action_just_pressed("shift_weapon_negative"):
		weapon_change_number -= 1
	
	weapon_change_number = clamp(weapon_change_number, 0, WEAPON_NUMBER_TO_NAME.size() - 1)
	
	if !changing_weapon && !reloading_weapon:
		if WEAPON_NUMBER_TO_NAME[weapon_change_number] != current_weapon_name:
			changing_weapon_name = WEAPON_NUMBER_TO_NAME[weapon_change_number]
			changing_weapon = true
	# ----------------------------------
	
	if !reloading_weapon && !changing_weapon:
		if Input.is_action_just_pressed("reload"):
			var current_weapon = weapons[current_weapon_name]
			if current_weapon != null:
				if current_weapon.CAN_RELOAD == true:
					var current_anim_state = animation_manager.current_state
					var is_reloading = false
					for weapon in weapons:
						var weapon_node = weapons[weapon]
						if weapon_node != null:
							is_reloading = current_anim_state == weapon_node.RELOADING_ANIM_NAME
								
					if is_reloading == false:
						reloading_weapon = true
	
	# ----------------------------------
	# Firing the weapons
	if !reloading_weapon && !changing_weapon && Input.is_action_pressed("fire"):
		var current_weapon = weapons[current_weapon_name]
		if current_weapon != null:
			if current_weapon.ammo_in_weapon > 0:
				if animation_manager.current_state == current_weapon.IDLE_ANIM_NAME:
					animation_manager.set_animation(current_weapon.FIRE_ANIM_NAME)
			else:
				reloading_weapon = true
	# ----------------------------------
	
func process_movement(delta : float):
	# https://docs.godotengine.org/en/3.1/tutorials/3d/fps_tutorial/part_one.html#tutorial-introduction
	
	# Decrease vertical velocity each frame to end a jump
	velocity.y += GRAVITY * delta
	
	var xz_plane_velocity : Vector3 = velocity
	xz_plane_velocity.y = 0
	
	var target : Vector3 = direction * (SPRINT_SPEED if Input.is_action_pressed("movement_sprint") else MAX_SPEED)
	
	var acceleration = ACCEL if direction.dot(xz_plane_velocity) > 0 else DEACCEL

	xz_plane_velocity = xz_plane_velocity.linear_interpolate(target, acceleration * delta)

	velocity.x = xz_plane_velocity.x
	velocity.z = xz_plane_velocity.z
	
	velocity = move_and_slide(velocity, Vector3.UP)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

func fire_bullet():
	if !changing_weapon:
		weapons[current_weapon_name].fire_weapon()
		
func process_changing_weapons(delta):
	if changing_weapon == true:

		var weapon_unequipped = false
		var current_weapon = weapons[current_weapon_name]

		if current_weapon == null:
			weapon_unequipped = true
		else:
			if current_weapon.is_weapon_enabled == true:
				weapon_unequipped = current_weapon.unequip_weapon()
			else:
				weapon_unequipped = true

		if weapon_unequipped == true:

			var weapon_equipped = false
			var weapon_to_equip = weapons[changing_weapon_name]

			if weapon_to_equip == null:
				weapon_equipped = true
			else:
				if weapon_to_equip.is_weapon_enabled == false:
					weapon_equipped = weapon_to_equip.equip_weapon()
				else:
					weapon_equipped = true

			if weapon_equipped == true:
				changing_weapon = false
				current_weapon_name = changing_weapon_name
				changing_weapon_name = ""
				
func process_UI():
	if current_weapon_name == "UNARMED" || current_weapon_name == "KNIFE":
		UI_status_label.text = "HEALTH: " + str(health)
	else:
		var current_weapon = weapons[current_weapon_name]
		UI_status_label.text = "HEALTH: " + str(health) + \
			"\nAMMO: " + str(current_weapon.ammo_in_weapon) + "/" + str(current_weapon.spare_ammo)
			
func process_reloading():
	if reloading_weapon:
		var current_weapon = weapons[current_weapon_name]
		if current_weapon != null:
			current_weapon.reload_weapon()
		reloading_weapon = false
		
func create_sound(sound_name : String, position = null):
	var clone = simple_audio_player.instance();
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone)
	clone.play_sound(sound_name, position)