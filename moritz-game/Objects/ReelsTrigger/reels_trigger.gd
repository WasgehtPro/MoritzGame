extends Area3D

## refs
@export_dir var reelFolder: String = "res://Reels"
@onready var layer: CanvasLayer = $CanvasLayer
@onready var player: VideoStreamPlayer = $CanvasLayer/CenterContainer/VideoStreamPlayer
@onready var debugMesh: MeshInstance3D = $MeshInstance3D
@onready var timer: Timer = $Timer

## vars
@export var minCooldown: float = 3.0
@export var maxCooldown: float = 15.0
@export var minPlayTime: float = 5.0
@export var maxPlayTime: float = 5.0
@export var showHitbox: bool = false

var nextCooldown: float = 15.0
var nextPlayTime: float = 5.0
var onCooldown := false
var isPlaying := false

func _ready() -> void:
	debugMesh.visible = showHitbox
	layer.visible = false
	timer.one_shot = true
	body_entered.connect(_on_body_entered)
	player.finished.connect(_end_video)
	timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body: Node3D) -> void:
	if isPlaying or onCooldown or not body.is_in_group("Player"):
		return
	_play_random_video()

func _play_random_video() -> void:
	var videos: Array[String] = []
	for file in DirAccess.get_files_at(reelFolder):
		if file.get_extension() == "ogv":
			videos.append(file)

	if videos.is_empty():
		push_warning("No .ogv videos found in " + reelFolder)
		return

	var chosen: String = reelFolder.path_join(videos.pick_random()) ##"res://Reels/WheresLois.ogv"
	print("Playing: ", chosen)  # if a video fails, this shows which file is bad

	var stream := VideoStreamTheora.new()
	stream.file = chosen
	player.stream = stream

	nextPlayTime = randf_range(minPlayTime, maxf(maxPlayTime, minPlayTime))
	nextCooldown = randf_range(minCooldown, maxf(maxCooldown, minCooldown))

	layer.visible = true
	isPlaying = true
	player.play()
	timer.start(nextPlayTime)  # cuts the video off at max play time

func _end_video() -> void:
	if not isPlaying:
		return
	isPlaying = false
	player.stop()
	layer.visible = false

	onCooldown = true
	timer.start(nextCooldown)

func _on_timer_timeout() -> void:
	if isPlaying:
		_end_video()  # play time reached
		return

	onCooldown = false  # cooldown over
	# If the player is still standing inside, retrigger (body_entered won't fire again)
	for body in get_overlapping_bodies():
		if body.is_in_group("Player"):
			_play_random_video()
			break
