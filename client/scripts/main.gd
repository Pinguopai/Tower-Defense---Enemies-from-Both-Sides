extends Node3D

const UNIT_DATA := {
	"shield": {"name": "刀盾兵", "cost": 80, "damage": 18.0, "range": 3.2, "rate": 0.75, "color": Color("4f78a8")},
	"archer": {"name": "弓手", "cost": 100, "damage": 28.0, "range": 7.0, "rate": 1.0, "color": Color("4e9861")},
	"spear": {"name": "长枪兵", "cost": 110, "damage": 38.0, "range": 4.2, "rate": 1.2, "color": Color("8a62a8")}
}
const ENEMY_DATA := {
	"infantry": {"name": "步兵", "health": 80.0, "speed": 1.25, "reward": 16, "damage": 10, "color": Color("bd594b"), "scale": 0.75},
	"scout": {"name": "斥候", "health": 55.0, "speed": 2.2, "reward": 20, "damage": 14, "color": Color("d69243"), "scale": 0.62},
	"heavy": {"name": "重甲军", "health": 220.0, "speed": 0.72, "reward": 32, "damage": 24, "color": Color("713d3d"), "scale": 1.0}
}
const WAVES := [
	[{"type": "infantry", "count": 6, "gap": 1.0}],
	[{"type": "infantry", "count": 9, "gap": 0.78}],
	[{"type": "scout", "count": 7, "gap": 0.9}],
	[{"type": "infantry", "count": 7, "gap": 0.7}, {"type": "heavy", "count": 3, "gap": 1.35}],
	[{"type": "scout", "count": 6, "gap": 0.65}, {"type": "heavy", "count": 5, "gap": 1.0}]
]
const PATH_POINTS := [Vector3(-13.0, 0.25, 0.0), Vector3(-7.0, 0.25, 0.0), Vector3(-3.0, 0.25, 2.7), Vector3(2.0, 0.25, 2.7), Vector3(6.0, 0.25, 0.0), Vector3(11.0, 0.25, 0.0)]

var camera: Camera3D
var battlefield: Node3D
var hud: CanvasLayer
var status_label: Label
var message_label: Label
var next_wave_button: Button
var result_panel: PanelContainer
var result_label: Label
var supplies := 300
var city_health := 100
var current_wave := 0
var selected_unit := "shield"
var enemies: Array[Dictionary] = []
var towers: Array[Dictionary] = []
var spots: Array[Dictionary] = []
var wave_running := false
var game_finished := false
var spawn_queue: Array[Dictionary] = []
var spawn_wait := 0.0
var income_wait := 0.0
var camera_angle := 0.0
var camera_distance := 20.0
var story_panel: PanelContainer
var story_label: Label
var story_next_button: Button
var story_page := 0
var story_pages := [
	"崇祯十七年，春。\n\n大明的诏令仍从北京发往天下，可许多驿路已经没有回音。\n\n西面，大顺军越过山西诸关；东北，清军压在山海关外。",
	"紫禁城中，朱由检仍是天下名义上的皇帝。\n\n只是他的命令，常常找不到粮、找不到兵，也找不到愿意承担后果的人。",
	"【昌平粮台急报】\n\n宁武方向烽火已绝。库中尚有京师急需的粮秣与箭药，守军不足，请示焚仓撤退。",
	"你的手指触及山河图。散落的兵牌重新排列，封死的军械库自行开启。\n\n奇观没有创造士兵。它只是让来不及集结的人，赶在城门关闭前站到了自己的位置上。"
]

func _ready() -> void:
	_build_world()
	_build_hud()
	_update_status()
	_show_story()

func _process(delta: float) -> void:
	if Input.is_action_pressed("camera_rotate_left"):
		camera_angle += delta
		_update_camera()
	if Input.is_action_pressed("camera_rotate_right"):
		camera_angle -= delta
		_update_camera()
	if game_finished:
		return
	if story_panel and story_panel.visible:
		return
	_income_tick(delta)
	_spawn_tick(delta)
	_update_enemies(delta)
	_update_towers(delta)
	_check_wave_complete()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance = max(14.0, camera_distance - 1.0)
			_update_camera()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance = min(28.0, camera_distance + 1.0)
			_update_camera()
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			_select_unit("shield")
		elif event.keycode == KEY_2:
			_select_unit("archer")
		elif event.keycode == KEY_3:
			_select_unit("spear")

func _build_world() -> void:
	var environment := WorldEnvironment.new()
	var environment_resource := Environment.new()
	environment_resource.background_mode = Environment.BG_COLOR
	environment_resource.background_color = Color("9bb3b0")
	environment_resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment_resource.ambient_light_color = Color("dce4d5")
	environment_resource.ambient_light_energy = 0.65
	environment.environment = environment_resource
	add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -35, 0)
	light.light_energy = 1.25
	light.shadow_enabled = true
	add_child(light)
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 42.0
	add_child(camera)
	battlefield = Node3D.new()
	add_child(battlefield)
	_add_box(Vector3(30, 0.35, 18), Vector3(0, -0.2, 0), Color("879a67"))
	for index in range(PATH_POINTS.size() - 1):
		_add_road(PATH_POINTS[index], PATH_POINTS[index + 1])
	_add_city()
	_add_gate()
	_add_deployment_spots()
	for x in [-11.0, -8.5, -5.5, -1.0, 3.5, 7.5]:
		_add_tree(Vector3(x, 0, -6.8))
	for x in [-10.0, -6.5, -1.8, 4.5, 8.0]:
		_add_tree(Vector3(x, 0, 6.7))
	_update_camera()

func _build_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var top_panel := PanelContainer.new()
	top_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_bottom = 68
	hud.add_child(top_panel)
	var top_box := HBoxContainer.new()
	top_box.add_theme_constant_override("separation", 24)
	top_panel.add_child(top_box)
	var title := Label.new()
	title.text = "  昌平粮台 · 第一关"
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_box.add_child(title)
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 20)
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_box.add_child(status_label)
	var spacer := Control.new()
	spacer.custom_minimum_size.x = 18
	top_box.add_child(spacer)
	var bottom_panel := PanelContainer.new()
	bottom_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_panel.offset_top = -112
	hud.add_child(bottom_panel)
	var bottom_box := HBoxContainer.new()
	bottom_box.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_box.add_theme_constant_override("separation", 14)
	bottom_panel.add_child(bottom_box)
	for unit_id in ["shield", "archer", "spear"]:
		var button := Button.new()
		var data: Dictionary = UNIT_DATA[unit_id]
		button.text = "%s  %d军资" % [data.name, data.cost]
		button.custom_minimum_size = Vector2(170, 62)
		button.pressed.connect(_select_unit.bind(unit_id))
		bottom_box.add_child(button)
	next_wave_button = Button.new()
	next_wave_button.text = "开始第 1 波"
	next_wave_button.custom_minimum_size = Vector2(180, 62)
	next_wave_button.pressed.connect(_start_next_wave)
	bottom_box.add_child(next_wave_button)
	message_label = Label.new()
	message_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	message_label.position = Vector2(-350, 82)
	message_label.size = Vector2(700, 52)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 18)
	hud.add_child(message_label)
	result_panel = PanelContainer.new()
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.position = Vector2(-300, -190)
	result_panel.size = Vector2(600, 380)
	result_panel.visible = false
	hud.add_child(result_panel)
	var result_box := VBoxContainer.new()
	result_box.alignment = BoxContainer.ALIGNMENT_CENTER
	result_panel.add_child(result_box)
	result_label = Label.new()
	result_label.custom_minimum_size = Vector2(540, 270)
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 28)
	result_box.add_child(result_label)
	var restart := Button.new()
	restart.text = "重新开始"
	restart.custom_minimum_size = Vector2(180, 52)
	restart.pressed.connect(get_tree().reload_current_scene)
	result_box.add_child(restart)
	_build_story_panel()

# 创建序章剧情面板，用于交代朱由检和京畿战局。
func _build_story_panel() -> void:
	story_panel = PanelContainer.new()
	story_panel.set_anchors_preset(Control.PRESET_CENTER)
	story_panel.position = Vector2(-340, -205)
	story_panel.size = Vector2(680, 410)
	hud.add_child(story_panel)
	var story_box := VBoxContainer.new()
	story_box.alignment = BoxContainer.ALIGNMENT_CENTER
	story_box.add_theme_constant_override("separation", 24)
	story_panel.add_child(story_box)
	var story_title := Label.new()
	story_title.text = "序章 · 山河将熄"
	story_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story_title.add_theme_font_size_override("font_size", 30)
	story_box.add_child(story_title)
	story_label = Label.new()
	story_label.custom_minimum_size = Vector2(600, 230)
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	story_label.add_theme_font_size_override("font_size", 21)
	story_box.add_child(story_label)
	story_next_button = Button.new()
	story_next_button.text = "继续"
	story_next_button.custom_minimum_size = Vector2(180, 52)
	story_next_button.pressed.connect(_advance_story)
	story_box.add_child(story_next_button)

# 显示当前序章页，并在末页提示玩家进入战斗。
func _show_story() -> void:
	story_label.text = story_pages[story_page]
	story_next_button.text = "进入战斗" if story_page == story_pages.size() - 1 else "继续"

# 推进序章；阅读结束后关闭面板并恢复部署引导。
func _advance_story() -> void:
	story_page += 1
	if story_page >= story_pages.size():
		story_panel.visible = false
		_show_message("保住粮台，让粮秣与军报送入北京。选择兵种并点击蓝色部署台。")
		return
	_show_story()

func _add_deployment_spots() -> void:
	var positions := [Vector3(-8, 0.15, -3.0), Vector3(-5, 0.15, 3.3), Vector3(-1, 0.15, -0.9), Vector3(2.5, 0.15, 5.1), Vector3(4.5, 0.15, -2.9), Vector3(7.2, 0.15, 3.0)]
	for index in positions.size():
		var body := StaticBody3D.new()
		body.position = positions[index]
		battlefield.add_child(body)
		var mesh := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 1.05
		cylinder.bottom_radius = 1.05
		cylinder.height = 0.25
		mesh.mesh = cylinder
		mesh.material_override = _material(Color("4d91b8"))
		body.add_child(mesh)
		var collision := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = 1.1
		shape.height = 0.35
		collision.shape = shape
		body.add_child(collision)
		body.input_event.connect(_on_spot_input.bind(index))
		spots.append({"body": body, "occupied": false, "mesh": mesh})

func _on_spot_input(_camera_node: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_index: int, spot_index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_deploy_unit(spot_index)

func _deploy_unit(spot_index: int) -> void:
	if game_finished or spots[spot_index].occupied:
		_show_message("这个部署台已经被占用。")
		return
	var data: Dictionary = UNIT_DATA[selected_unit]
	if supplies < data.cost:
		_show_message("军资不足，击败敌人或等待军资增长。")
		return
	supplies -= data.cost
	spots[spot_index].occupied = true
	spots[spot_index].mesh.visible = false
	var tower_node := Node3D.new()
	tower_node.position = spots[spot_index].body.position + Vector3(0, 0.8, 0)
	battlefield.add_child(tower_node)
	var body := _mesh_box(Vector3(0.75, 1.35, 0.75), data.color)
	tower_node.add_child(body)
	var head := _mesh_sphere(0.38, Color("e3c39a"))
	head.position.y = 0.9
	tower_node.add_child(head)
	if selected_unit == "archer":
		var bow := _mesh_box(Vector3(0.12, 0.75, 0.12), Color("5c3a24"))
		bow.position = Vector3(0.42, 0.15, 0)
		tower_node.add_child(bow)
	elif selected_unit == "spear":
		var spear := _mesh_box(Vector3(0.1, 1.7, 0.1), Color("d6c2a0"))
		spear.position = Vector3(0.42, 0.35, 0)
		tower_node.add_child(spear)
	towers.append({"node": tower_node, "type": selected_unit, "cooldown": 0.0})
	_show_message("%s部署完成。" % data.name)
	_update_status()

func _start_next_wave() -> void:
	if wave_running or current_wave >= WAVES.size() or game_finished:
		return
	current_wave += 1
	wave_running = true
	next_wave_button.disabled = true
	spawn_queue.clear()
	for group in WAVES[current_wave - 1]:
		for index in group.count:
			spawn_queue.append({"type": group.type, "gap": group.gap})
	spawn_wait = 0.0
	_show_message("第 %d 波来袭！" % current_wave)
	_update_status()

func _spawn_tick(delta: float) -> void:
	if spawn_queue.is_empty():
		return
	spawn_wait -= delta
	if spawn_wait <= 0:
		var item: Dictionary = spawn_queue.pop_front()
		_spawn_enemy(item.type)
		spawn_wait = item.gap

func _spawn_enemy(enemy_type: String) -> void:
	var data: Dictionary = ENEMY_DATA[enemy_type]
	var enemy_node := Node3D.new()
	enemy_node.position = PATH_POINTS[0]
	battlefield.add_child(enemy_node)
	var body := _mesh_box(Vector3(0.8, 1.25, 0.8) * data.scale, data.color)
	body.position.y = 0.55 * data.scale
	enemy_node.add_child(body)
	var health_bar := _mesh_box(Vector3(0.9, 0.1, 0.08), Color("54d16a"))
	health_bar.position = Vector3(0, 1.45 * data.scale, 0)
	enemy_node.add_child(health_bar)
	enemies.append({"node": enemy_node, "type": enemy_type, "health": data.health, "max_health": data.health, "path_index": 1, "health_bar": health_bar})

func _update_enemies(delta: float) -> void:
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy.node):
			continue
		var target: Vector3 = PATH_POINTS[enemy.path_index]
		var offset: Vector3 = target - enemy.node.position
		var speed: float = ENEMY_DATA[enemy.type].speed
		if offset.length() <= speed * delta:
			enemy.node.position = target
			enemy.path_index += 1
			if enemy.path_index >= PATH_POINTS.size():
				_enemy_reached_city(enemy)
		else:
			enemy.node.position += offset.normalized() * speed * delta

func _update_towers(delta: float) -> void:
	for tower in towers:
		tower.cooldown -= delta
		if tower.cooldown > 0:
			continue
		var data: Dictionary = UNIT_DATA[tower.type]
		var target := _find_target(tower.node.position, data.range)
		if target.is_empty():
			continue
		var damage: float = data.damage
		if tower.type == "spear" and target.type == "heavy":
			damage *= 1.65
		_damage_enemy(target, damage)
		tower.cooldown = data.rate
		tower.node.look_at(Vector3(target.node.position.x, tower.node.position.y, target.node.position.z))

func _find_target(origin: Vector3, attack_range: float) -> Dictionary:
	var result: Dictionary = {}
	var best_progress := -1
	for enemy in enemies:
		if is_instance_valid(enemy.node) and origin.distance_to(enemy.node.position) <= attack_range and enemy.path_index > best_progress:
			result = enemy
			best_progress = enemy.path_index
	return result

func _damage_enemy(enemy: Dictionary, damage: float) -> void:
	enemy.health -= damage
	var ratio: float = max(enemy.health, 0.0) / enemy.max_health
	enemy.health_bar.scale.x = ratio
	enemy.health_bar.position.x = -0.45 * (1.0 - ratio)
	if enemy.health <= 0:
		supplies += ENEMY_DATA[enemy.type].reward
		enemies.erase(enemy)
		enemy.node.queue_free()
		_update_status()

func _enemy_reached_city(enemy: Dictionary) -> void:
	city_health = max(0, city_health - int(ENEMY_DATA[enemy.type].damage))
	enemies.erase(enemy)
	enemy.node.queue_free()
	_update_status()
	if city_health <= 0:
		_finish_game(false)

func _check_wave_complete() -> void:
	if wave_running and spawn_queue.is_empty() and enemies.is_empty():
		wave_running = false
		if current_wave >= WAVES.size():
			_finish_game(true)
		else:
			supplies += 45
			next_wave_button.disabled = false
			next_wave_button.text = "开始第 %d 波" % (current_wave + 1)
			_show_message("第 %d 波守住了，获得整备军资 45。" % current_wave)
			_update_status()

func _income_tick(delta: float) -> void:
	income_wait += delta
	if income_wait >= 3.0:
		income_wait -= 3.0
		supplies += 8
		_update_status()

func _finish_game(victory: bool) -> void:
	game_finished = true
	wave_running = false
	next_wave_button.disabled = true
	result_panel.visible = true
	if victory:
		result_label.text = "昌平粮台守住了\n\n捷报正在送往北京\n山河图边缘却浮现出不属于此世的城影\n\n此处已暂时稳定——请选择下一个世界\n\n城防 %d%% · 剩余军资 %d · 战果 %d" % [city_health, supplies, 300 + city_health * 2]
	else:
		result_label.text = "城池失守\n\n防线已被突破\n调整兵种位置后再战"

func _select_unit(unit_id: String) -> void:
	selected_unit = unit_id
	var data: Dictionary = UNIT_DATA[unit_id]
	_show_message("已选择%s，点击蓝色部署台进行部署。" % data.name)

func _show_message(text: String) -> void:
	message_label.text = text

func _update_status() -> void:
	if status_label:
		status_label.text = "军资 %d（每3秒 +8）    城池耐久 %d%%    波次 %d/%d  " % [supplies, city_health, current_wave, WAVES.size()]

func _update_camera() -> void:
	if camera:
		camera.position = Vector3(sin(camera_angle) * camera_distance, camera_distance * 0.72, cos(camera_angle) * camera_distance)
		camera.look_at(Vector3(0, 0, 0))

func _add_city() -> void:
	_add_box(Vector3(3.6, 2.5, 5.0), Vector3(12.2, 1.25, 0), Color("b9a27a"))
	_add_box(Vector3(1.2, 4.0, 1.2), Vector3(10.4, 2.0, -2.4), Color("726552"))
	_add_box(Vector3(1.2, 4.0, 1.2), Vector3(10.4, 2.0, 2.4), Color("726552"))

func _add_gate() -> void:
	_add_box(Vector3(1.2, 2.6, 5.0), Vector3(-14.1, 1.3, 0), Color("705b48"))

func _add_tree(position_value: Vector3) -> void:
	_add_box(Vector3(0.28, 1.2, 0.28), position_value + Vector3(0, 0.6, 0), Color("5b4630"))
	var crown := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.7
	mesh.height = 1.4
	crown.mesh = mesh
	crown.material_override = _material(Color("3f6d46"))
	crown.position = position_value + Vector3(0, 1.55, 0)
	battlefield.add_child(crown)

func _add_road(start: Vector3, end: Vector3) -> void:
	var midpoint := (start + end) * 0.5
	var distance := start.distance_to(end)
	var road := _mesh_box(Vector3(2.2, 0.08, distance), Color("c6ad7d"))
	road.position = Vector3(midpoint.x, 0.02, midpoint.z)
	battlefield.add_child(road)
	road.look_at(Vector3(end.x, road.position.y, end.z))

func _add_box(size: Vector3, position_value: Vector3, color: Color) -> void:
	var node := _mesh_box(size, color)
	node.position = position_value
	battlefield.add_child(node)

func _mesh_box(size: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = _material(color)
	return node

func _mesh_sphere(radius: float, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	node.mesh = mesh
	node.material_override = _material(color)
	return node

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material
