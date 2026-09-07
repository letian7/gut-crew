extends Control
var game
var hit_time := 0.0
var hurt_time := 0.0
var hurt_strength := 0.0
var recoil := 0.0
var kill_hit := false
var source := Vector3.ZERO
var directional := false
var last_hp := 100.0
var sound_lock := 0.0
var hit_player: AudioStreamPlayer
var hurt_player: AudioStreamPlayer
var sounds: Array[AudioStreamWAV] = []
var hit_events := 0
var hurt_events := 0
# Dedicated/headless runs have no speakers or active output mixer.
var audio_enabled := DisplayServer.get_name() != "headless"

func sound(frequency: float, duration: float, noise: float) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var count := int(duration*22050)
	var data := PackedByteArray()
	data.resize(count*2)
	for i in range(count):
		var t := float(i)/22050.0
		var fade := pow(1.0-float(i)/float(count),2.0)*minf(1.0,float(i)/55.0)
		var grit := sin(float(i)*12.9898)*sin(float(i)*78.233)
		var wave := (sin(TAU*frequency*t*(1.0-t*2.0))*(1.0-noise)+grit*noise)*fade
		data.encode_s16(i*2,int(wave*20000))
	stream.data = data
	return stream

func build(host) -> void:
	game = host
	name = "ImpactFeedback26"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for f in [660.0,170.0,260.0,410.0]: sounds.append(sound(f,0.075,0.22))
	sounds.append(sound(880.0,0.12,0.08))
	hit_player = AudioStreamPlayer.new()
	hit_player.volume_db = -18.0
	add_child(hit_player)
	hurt_player = AudioStreamPlayer.new()
	hurt_player.volume_db = -18.0
	hurt_player.stream = sound(100.0,0.13,0.32)
	add_child(hurt_player)
	last_hp = game.hp

func report_hit(amount: float, killed: bool) -> void:
	if amount <= 0.0: return
	hit_events += 1
	hit_time = 0.23 if killed else 0.13
	kill_hit = killed
	var strength: float = [0.012,0.032,0.025,0.018][game.role_index]
	recoil = maxf(recoil,strength*(1.25 if amount>=25.0 else 1.0))
	if sound_lock <= 0.0 or killed:
		hit_player.stream = sounds[4 if killed else game.role_index]
		if audio_enabled: hit_player.play()
		sound_lock = 0.08
	queue_redraw()

func report_hurt(origin: Vector3, has_direction := true, amount := 10.0) -> void:
	hurt_events += 1
	last_hp = game.hp
	source = origin
	directional = has_direction
	hurt_strength = maxf(hurt_strength, clampf(amount / 22.0, 0.28, 1.0))
	if hurt_time <= 0.0 and audio_enabled: hurt_player.play()
	hurt_time = maxf(hurt_time, 0.46 + hurt_strength * 0.22)
	queue_redraw()

func tick(delta: float) -> void:
	visible = game.role_selected and not game.game_paused and not game.inventory_open and not game._cinematic_locked()
	if not visible:
		hit_player.stop()
		hurt_player.stop()
		game.camera_1p.v_offset = 0.0
		game.camera_3p.v_offset = 0.0
		if not game.game_paused:
			hit_time = 0.0
			hurt_time = 0.0
			recoil = 0.0
			last_hp = game.hp
		return
	if game.hp < last_hp: report_hurt(Vector3.ZERO, false, last_hp - game.hp)
	last_hp = game.hp
	hit_time = maxf(0.0,hit_time-delta)
	hurt_time = maxf(0.0,hurt_time-delta)
	if hurt_time <= 0.0: hurt_strength = move_toward(hurt_strength, 0.0, delta * 4.0)
	sound_lock = maxf(0.0,sound_lock-delta)
	recoil = move_toward(recoil,0.0,delta*0.28)
	game.camera_1p.v_offset = recoil
	game.camera_3p.v_offset = recoil*0.7
	queue_redraw()

func _process(delta: float) -> void:
	if is_instance_valid(game): tick(delta)

func _exit_tree() -> void:
	for player in [hit_player,hurt_player]:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	sounds.clear()

func _draw() -> void:
	if not is_instance_valid(game): return
	var center := get_viewport_rect().size*0.5
	if hit_time > 0.0:
		var color := Color("ffcb72") if kill_hit else Color("fff5d6")
		color.a = minf(1.0,hit_time*14.0)
		var gap := 8.0+hit_time*12.0
		for x in [-1.0,1.0]:
			for y in [-1.0,1.0]:
				var axis := Vector2(x,y).normalized()
				draw_line(center+axis*gap,center+axis*(gap+7.0),color,3.0 if kill_hit else 2.0,true)
	var screen := get_viewport_rect().size
	var low_hp := clampf((36.0 - game.hp) / 36.0, 0.0, 1.0)
	var low_pulse := low_hp * (0.08 + (sin(Time.get_ticks_msec() * 0.006) * 0.5 + 0.5) * 0.09)
	var impact_alpha := clampf(hurt_time * 0.62 * hurt_strength, 0.0, 0.42)
	var edge_alpha := maxf(low_pulse, impact_alpha)
	if edge_alpha > 0.001:
		for i in range(4):
			var width := 18.0 + i * 12.0
			var alpha := edge_alpha * (1.0 - i * 0.19)
			var edge := Color(0.72, 0.02, 0.06, alpha)
			draw_rect(Rect2(Vector2(0, i * 8), Vector2(screen.x, width)), edge)
			draw_rect(Rect2(Vector2(0, screen.y - width - i * 8), Vector2(screen.x, width)), edge)
			draw_rect(Rect2(Vector2(i * 8, 0), Vector2(width, screen.y)), edge)
			draw_rect(Rect2(Vector2(screen.x - width - i * 8, 0), Vector2(width, screen.y)), edge)
	if hurt_time > 0.0 and directional:
		var delta: Vector3 = source-game.player.position
		# World left projects screen-left; only the indicator rotates, never the aim.
		var angle: float = -atan2(-delta.x,-delta.z)+game.yaw-PI*0.5
		var color := Color(1.0,0.35,0.31,minf(0.95,hurt_time*3.0*maxf(0.45,hurt_strength)))
		draw_arc(center,52,angle-0.34,angle+0.34,18,color,5.0,true)
