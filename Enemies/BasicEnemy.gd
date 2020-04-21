extends KinematicBody

signal fire_bullet
var enemy_bullet = preload("res://Enemies/EnemyBullet.tscn")
onready var muzzle = $Muzzle
onready var radar_mesh = $RadarMesh
var target

var speed = 1300
var velocity = Vector3()

var active = false

func _ready():
	for node in get_tree().get_nodes_in_group("game"):
		connect("fire_bullet", node, "_fire_bullet")
	var target_array = get_tree().get_nodes_in_group("player")
	target = target_array[0]
		
func _physics_process(delta):
	if active:
		aim()
		velocity = Vector3()
		velocity += -transform.basis.z * speed * delta
		velocity = move_and_slide(velocity, Vector3.UP)
		
	# Lock Radar Mesh
	radar_mesh.global_transform.origin = Vector3(global_transform.origin.x, 0.0, global_transform.origin.z) 

func aim():
	var desired_rotation = global_transform.looking_at(target.global_transform.origin, Vector3(0,1,0))
	var a = Quat(global_transform.basis.get_rotation_quat()).slerp(desired_rotation.basis.get_rotation_quat(), 0.02)
	global_transform.basis = Basis(a)
	
func activate():
	$ShootTimer.start()
	active = true
	
func deactivate():
	$ShootTimer.stop()
	active = false
	
func _on_Timer_timeout():
	var orig = muzzle.global_transform.origin
	var direction = global_transform.basis
	emit_signal("fire_bullet", orig, direction, enemy_bullet)
