extends Area3D

## reels
@export_dir var reelFolder: String = "res://Reels"
@onready var layer: CanvasLayer = $CanvasLayer
@onready var player: VideoStreamPlayer = $CanvasLayer/CenterContainer/VideoStreamPlayer

## hitbox
@export var showHitbox: bool = false
@onready var debugMesh: MeshInstance3D = $MeshInstance3D

var played := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	player.finished.connect(_on_video_finished)

func _on_body_entered(body: Node3D) -> void:
	if played or not body.is_in_group("Player"):
		return
	played = true
	_play_random_video()

func _play_random_video() -> void:
	var videos: Array[String] = []
	for file in DirAccess.get_files_at(reelFolder):
		if file.get_extension() == "ogv":
			videos.append(file)

	if videos.is_empty():
		push_warning("No .ogv videos found in " + reelFolder)
		played = false
		return

	var stream := VideoStreamTheora.new()
	stream.file = reelFolder.path_join(videos.pick_random())
	player.stream = stream
	layer.visible = true
	player.play()

func _on_video_finished() -> void:
	layer.visible = false
	# played stays true, so it only triggers once.
	# Set played = false here if it should be re-triggerable,
	# or call queue_free() to remove the area entirely.
