
extends Control

var root
var is_working = false
var is_suspended = true

var selector = preload('res://gui/selector.xscn').instance()
var selector_position = Vector2(0,0)
var game_scale
var map_pos

var hud_file
var hud_file_play_button
var hud_file_save_button
var hud_file_load_button
var hud_file_name
var hud_file_floppy

var hud_toolset
var hud_toolset_blocks
var hud_toolset_blocks_pages = []
var hud_toolset_paginator
var hud_toolset_next_button
var hud_toolset_prev_button
var hud_toolset_active

#0
var hud_toolset_clear
var hud_toolset_plain
var hud_toolset_forest
var hud_toolset_mountains
var hud_toolset_river
var hud_toolset_bridge

#1
var hud_toolset_city
var hud_toolset_statue
var hud_toolset_fence
var hud_toolset_road_city
var hud_toolset_road_country
var hud_toolset_road_mix

#2
var hud_toolset_hq_blue
var hud_toolset_hq_red
var hud_toolset_barracks
var hud_toolset_factory
var hud_toolset_airport
var hud_toolset_exit
var hud_toolset_tower

#3
var hud_toolset_soldier_blue
var hud_toolset_tank_blue
var hud_toolset_helicopter_blue
var hud_toolset_soldier_red
var hud_toolset_tank_red
var hud_toolset_helicopter_red

var hud_message
var hud_message_box
var hud_message_title
var hud_message_message

var hud_toolbox
var hud_toolbox_front
var hud_toolbox_show_button
var hud_toolbox_close_button
var hud_toolbox_fill_x
var hud_toolbox_fill_y
var hud_toolbox_fill_button
var hud_toolbox_clear_terrain
var hud_toolbox_clear_units
var hud_toolbox_turn_cap
var hud_toolbox_start_ap
var hud_toolbox_start_ap_set
var hud_toolbox_win1
var hud_toolbox_win2
var hud_toolbox_win3
var hud_toolbox_undo_button

var toolbox_is_open = false

var toolset_active_page = 0
var tool_type = "terrain"
var brush_type = 1

var restore_file_name = "restore_map"

var map
var terrain
var units
var painting = false
var painting_allowed = true
var history = []
var paint_count = 0
var autosave_after = 10
var painting_motion = false

var settings = {
	fill = [4,6,8,12,16,20,24,32,48,64],
	fill_selected = [0,0],
	turn_cap = [0,25,50,75,100],
	turn_cap_selected = 0,
	win = [true,false,false]
}



const MAP_MAX_X = 64
const MAP_MAX_Y = 64
const RIGHT_DEAD_ZONE = 136
const LEFT_DEAD_ZONE = 60

func init_gui():
	hud_file = self.get_node("file_card/center")
	hud_file_floppy = hud_file.get_node("floppy/anim")
	hud_file_name = hud_file.get_node("name")
	hud_file_play_button = hud_file.get_node("play")
	hud_file_save_button = hud_file.get_node("save")
	hud_file_load_button = hud_file.get_node("load")
	hud_file_play_button.connect("pressed", self, "play_map")
	hud_file_save_button.connect("pressed", self, "save_map", [hud_file_name, true])
	hud_file_load_button.connect("pressed", self, "load_map", [hud_file_name, true])

	map = get_node("blueprint/center/scale/map")
	terrain = map.get_node("terrain")
	units = map.get_node("terrain/units")
	
	game_scale = get_node("blueprint/center/scale")

	hud_toolset = self.get_node("toolset/center")
	hud_toolset_blocks = hud_toolset.get_node("blocks")
	hud_toolset_blocks_pages.append(hud_toolset_blocks.get_node("0"))
	hud_toolset_blocks_pages.append(hud_toolset_blocks.get_node("1"))
	hud_toolset_blocks_pages.append(hud_toolset_blocks.get_node("2"))
	hud_toolset_blocks_pages.append(hud_toolset_blocks.get_node("3"))
	hud_toolset_paginator = hud_toolset.get_node("paginator")
	hud_toolset_next_button = hud_toolset.get_node("next")
	hud_toolset_prev_button = hud_toolset.get_node("prev")

	hud_toolset_next_button.connect("pressed", self, "toolset_next_page")
	hud_toolset_prev_button.connect("pressed", self, "toolset_prev_page")

	#0
	hud_toolset_clear = hud_toolset_blocks_pages[0].get_node("clear")
	hud_toolset_plain = hud_toolset_blocks_pages[0].get_node("plain")
	hud_toolset_forest = hud_toolset_blocks_pages[0].get_node("forest")
	hud_toolset_mountains = hud_toolset_blocks_pages[0].get_node("mountains")
	hud_toolset_river = hud_toolset_blocks_pages[0].get_node("river")
	hud_toolset_bridge = hud_toolset_blocks_pages[0].get_node("bridge")

	#1
	hud_toolset_city = hud_toolset_blocks_pages[1].get_node("city")
	hud_toolset_statue = hud_toolset_blocks_pages[1].get_node("statue")
	hud_toolset_tower = hud_toolset_blocks_pages[1].get_node("tower")
	#hud_toolset_fence = hud_toolset_blocks_pages[1].get_node("fence")
	hud_toolset_road_city = hud_toolset_blocks_pages[1].get_node("road_city")
	hud_toolset_road_country = hud_toolset_blocks_pages[1].get_node("road_country")
	hud_toolset_road_mix = hud_toolset_blocks_pages[1].get_node("road_mix")

	#2
	hud_toolset_hq_blue = hud_toolset_blocks_pages[2].get_node("hq_blue")
	hud_toolset_hq_red = hud_toolset_blocks_pages[2].get_node("hq_red")
	hud_toolset_barracks = hud_toolset_blocks_pages[2].get_node("barracks")
	hud_toolset_factory = hud_toolset_blocks_pages[2].get_node("factory")
	hud_toolset_airport = hud_toolset_blocks_pages[2].get_node("airport")
	hud_toolset_exit = hud_toolset_blocks_pages[2].get_node("exit")

	#3
	hud_toolset_soldier_blue = hud_toolset_blocks_pages[3].get_node("soldier_blue")
	hud_toolset_tank_blue = hud_toolset_blocks_pages[3].get_node("tank_blue")
	hud_toolset_helicopter_blue = hud_toolset_blocks_pages[3].get_node("helicopter_blue")
	hud_toolset_soldier_red = hud_toolset_blocks_pages[3].get_node("soldier_red")
	hud_toolset_tank_red = hud_toolset_blocks_pages[3].get_node("tank_red")
	hud_toolset_helicopter_red = hud_toolset_blocks_pages[3].get_node("helicopter_red")

	hud_toolset_active = hud_toolset_plain.get_node("active")
	hud_toolset_active.show()

	# message
	hud_message = self.get_node("message")

	#0
	hud_toolset_clear.connect("pressed", self, "select_tool", ["terrain",-1,hud_toolset_clear.get_node("active")])
	hud_toolset_plain.connect("pressed", self, "select_tool", ["terrain",1,hud_toolset_plain.get_node("active")])
	hud_toolset_forest.connect("pressed", self, "select_tool", ["terrain",2,hud_toolset_forest.get_node("active")])
	hud_toolset_mountains.connect("pressed", self, "select_tool", ["terrain",3,hud_toolset_mountains.get_node("active")])
	hud_toolset_river.connect("pressed", self, "select_tool", ["terrain",17,hud_toolset_river.get_node("active")])
	hud_toolset_bridge.connect("pressed", self, "select_tool", ["terrain",18,hud_toolset_bridge.get_node("active")])
	#1
	hud_toolset_city.connect("pressed", self, "select_tool", ["terrain",4,hud_toolset_city.get_node("active")])
	hud_toolset_statue.connect("pressed", self, "select_tool", ["terrain",5,hud_toolset_statue.get_node("active")])
	hud_toolset_tower.connect("pressed", self, "select_tool", ["terrain",11,hud_toolset_tower.get_node("active")])
	#hud_toolset_fence.connect("pressed", self, "select_tool", ["terrain",12,hud_toolset_fence.get_node("active")])
	hud_toolset_road_city.connect("pressed", self, "select_tool", ["terrain",14,hud_toolset_road_city.get_node("active")])
	hud_toolset_road_country.connect("pressed", self, "select_tool", ["terrain",15,hud_toolset_road_country.get_node("active")])
	hud_toolset_road_mix.connect("pressed", self, "select_tool", ["terrain",16,hud_toolset_road_mix.get_node("active")])
	#2
	hud_toolset_hq_blue.connect("pressed", self, "select_tool", ["terrain",6,hud_toolset_hq_blue.get_node("active")])
	hud_toolset_hq_red.connect("pressed", self, "select_tool", ["terrain",7,hud_toolset_hq_red.get_node("active")])
	hud_toolset_barracks.connect("pressed", self, "select_tool", ["terrain",8,hud_toolset_barracks.get_node("active")])
	hud_toolset_factory.connect("pressed", self, "select_tool", ["terrain",9,hud_toolset_factory.get_node("active")])
	hud_toolset_airport.connect("pressed", self, "select_tool", ["terrain",10,hud_toolset_airport.get_node("active")])
	hud_toolset_exit.connect("pressed", self, "select_tool", ["terrain",13,hud_toolset_exit.get_node("active")])

	#3
	hud_toolset_soldier_blue.connect("pressed", self, "select_tool", ["units",0,hud_toolset_soldier_blue.get_node("active")])
	hud_toolset_tank_blue.connect("pressed", self, "select_tool", ["units",1,hud_toolset_tank_blue.get_node("active")])
	hud_toolset_helicopter_blue.connect("pressed", self, "select_tool", ["units",2,hud_toolset_helicopter_blue.get_node("active")])
	hud_toolset_soldier_red.connect("pressed", self, "select_tool", ["units",3,hud_toolset_soldier_red.get_node("active")])
	hud_toolset_tank_red.connect("pressed", self, "select_tool", ["units",4,hud_toolset_tank_red.get_node("active")])
	hud_toolset_helicopter_red.connect("pressed", self, "select_tool", ["units",5,hud_toolset_helicopter_red.get_node("active")])
	
	# toolbox
	hud_toolbox = self.get_node("toolbox_menu")
	hud_toolbox_front = hud_toolbox.get_node("center/toolbox/front/")
	hud_toolbox_show_button = self.get_node("toolbox/center/box")
	hud_toolbox_close_button = hud_toolbox_front.get_node("close")
	hud_toolbox_undo_button = self.get_node("toolbox/center/undo")
	
	hud_toolbox_fill_x = hud_toolbox_front.get_node("x")
	hud_toolbox_fill_y = hud_toolbox_front.get_node("y")
	hud_toolbox_fill_button = hud_toolbox_front.get_node("fill")
	
	hud_toolbox_fill_x.get_node('label').set_text(str(settings.fill[settings.fill_selected[0]]))
	hud_toolbox_fill_y.get_node('label').set_text(str(settings.fill[settings.fill_selected[1]]))
	
	hud_toolbox_clear_terrain = hud_toolbox_front.get_node("clear_terrain")
	hud_toolbox_clear_units = hud_toolbox_front.get_node("clear_units")

	hud_toolbox_turn_cap = hud_toolbox_front.get_node("turn_cap")
	hud_toolbox_start_ap = hud_toolbox_front.get_node("start_ap/ap")
	hud_toolbox_start_ap_set = hud_toolbox_front.get_node("start_ap_set")
	hud_toolbox_win1 = hud_toolbox_front.get_node("win1")
	hud_toolbox_win2 = hud_toolbox_front.get_node("win2")
	hud_toolbox_win3 = hud_toolbox_front.get_node("win3")
	
	hud_toolbox_show_button.connect("pressed",self,"toggle_toolbox")
	hud_toolbox_close_button.connect("pressed",self,"toggle_toolbox")
	hud_toolbox_undo_button.connect("pressed",self,"undo_last_action")
	
	hud_toolbox_fill_x.connect("pressed",self,"toggle_fill", [0,hud_toolbox_fill_x.get_node("label")])
	hud_toolbox_fill_y.connect("pressed",self,"toggle_fill", [1,hud_toolbox_fill_y.get_node("label")])
	hud_toolbox_fill_button.connect("pressed",self,"toolbox_fill")
	hud_toolbox_clear_terrain.connect("pressed",self,"toolbox_clear", [0])
	hud_toolbox_clear_units.connect("pressed",self,"toolbox_clear", [1])
	
	hud_toolbox_turn_cap.connect("pressed",self,"toggle_turn_cap", [hud_toolbox_turn_cap.get_node("label")])
	hud_toolbox_win1.connect("pressed",self,"toolbox_win", [0,hud_toolbox_win1.get_node("label")])
	hud_toolbox_win2.connect("pressed",self,"toolbox_win", [1,hud_toolbox_win2.get_node("label")])
	hud_toolbox_win3.connect("pressed",self,"toolbox_win", [2,hud_toolbox_win3.get_node("label")])
	
	self.hud_message.show_message("Welcome!",["This is workshop. A place to create awesome maps.","Keep in mind that this tool is still in developement and may contain nasty bugs."])

	self.load_map(restore_file_name)
	return

func add_action(params):
	var last_brush
	
	if params.tool_type == "terrain":
		last_brush = terrain.get_cell(params.position.x,params.position.y)
	
	if params.tool_type == "units":
		last_brush = units.get_cell(params.position.x,params.position.y)
		
	history.append({
		position = params.position,
		tool_type = params.tool_type,
		brush_type = last_brush
		})
	paint_count += 1
	if not painting_motion and paint_count >= autosave_after:
		self.save_map(restore_file_name)
		paint_count = 0
	
	hud_toolbox_undo_button.set_disabled(false)
	
func undo_last_action():
	var last_action
	if history.size() > 0:
		last_action = history[history.size()-1]
		self.paint(last_action.position,last_action.tool_type,last_action.brush_type, true)
		history.remove(history.size()-1)
	else:
		hud_toolbox_undo_button.set_disabled(true)

func toolbox_win(option,label):
	settings.win[option] = not settings.win[option]
	var text = "off"
	if settings.win[option]:
		text = "on"
	label.set_text(text)
	return
	
func toggle_fill(axis,label):
	if settings.fill_selected[axis] < settings.fill.size()-1:
		settings.fill_selected[axis] += 1
	else:
		settings.fill_selected[axis] = 0
	
	label.set_text(str(settings.fill[settings.fill_selected[axis]]))
	return

func toggle_turn_cap(label):
	if settings.turn_cap_selected < settings.turn_cap.size()-1:
		settings.turn_cap_selected += 1
	else:
		settings.turn_cap_selected = 0
	self.root.settings.turns_cap = settings.turn_cap[settings.turn_cap_selected]
	label.set_text(str(settings.turn_cap[settings.turn_cap_selected]))
	return

func toolbox_fill():
	map.fill(settings.fill[settings.fill_selected[0]],settings.fill[settings.fill_selected[1]])
	self.hud_message.show_message("Toolbox", ["Terrain filled. Dimmension:" + str(settings.fill[settings.fill_selected[0]]) + "x" + str(settings.fill[settings.fill_selected[1]])])
	return
	
func toolbox_clear(layer):
	if layer == 0:
		# clear terrain and units
		map.clear_layer(0)
		self.hud_message.show_message("Toolbox", ["Terrain and units layer cleared!"])
	if layer == 1:
		map.clear_layer(1)
		self.hud_message.show_message("Toolbox", ["Units layer cleared!"])
	return

func toggle_toolbox():
	toolbox_is_open = not toolbox_is_open
	if toolbox_is_open:
		hud_toolbox_show_button.set_disabled(true)
		hud_toolbox.show()
		self.painting_allowed = false
		# show toolbox
	else:
		hud_toolbox_show_button.set_disabled(false)
		hud_toolbox.hide()
		self.painting_allowed = true
		# hide toolbox
	return

func toolset_next_page():
	hud_toolset_blocks_pages[toolset_active_page].hide()
	toolset_active_page += 1
	if toolset_active_page >= hud_toolset_blocks_pages.size():
		toolset_active_page = 0
	hud_toolset_blocks_pages[toolset_active_page].show()
	hud_toolset_paginator.set_frame(toolset_active_page)
	return

func toolset_prev_page():
	hud_toolset_blocks_pages[toolset_active_page].hide()
	toolset_active_page -= 1
	if toolset_active_page < 0:
		toolset_active_page = hud_toolset_blocks_pages.size()-1
	hud_toolset_blocks_pages[toolset_active_page].show()
	hud_toolset_paginator.set_frame(toolset_active_page)
	return

func check_map_integrity():
	#var hq_red_check = false
	#var hq_blue_check = false

	#for x in range(MAP_MAX_X):
	#	for y in range(MAP_MAX_Y):
	#		if terrain.get_cell(x,y) == 6:
	#			hq_blue_check = true
	#		if terrain.get_cell(x,y) == 7:
	#			hq_red_check = true
	#	if hq_red_check and hq_blue_check:
	#		return true
	#return false
	return true

func play_map():
	self.save_map(restore_file_name)
	if self.check_map_integrity():
		self.is_working = false
		self.is_suspended = true
		root.load_map("workshop", restore_file_name)
		root.toggle_menu()
		root.menu.hide_workshop()
	else:
		self.hud_message.show_message("HQ missing", ["In this map mode there need to be HQ building for each player. Blue and Red."])
	return

func save_map(name, input = false):
	if input:
		name = name.get_text()
	if map.save_map(name):
		self.hud_message.show_message("Map saved", ["Success","File name: "+str(name)])
		hud_file_floppy.play("save")
	else:
		self.hud_message.show_message("File error", ["Failure!","File name: "+str(name)])

func load_map(name, input = false):
	if input:
		name = name.get_text()
	if map.load_map(name):
		self.hud_message.show_message("Map loaded", ["Success","File name: "+str(name)])
		hud_file_floppy.play("save")
	else:
		self.hud_message.show_message("File not found", ["Failure!","File name: "+str(name)])
		

func select_tool(tool_type,brush_type,button):
	hud_toolset_active.hide()
	hud_toolset_active = button
	self.tool_type = tool_type
	self.brush_type = brush_type
	hud_toolset_active.show()
	return

func paint(position, tool_type = null,brush_type = null, undo_action = false):
	if hud_message.is_visible():
		return false
		
	if tool_type == null:
		tool_type = self.tool_type
	if brush_type == null:
		brush_type = self.brush_type
	
	
	if position.x < 0 or position.y < 0 or position.x >= MAP_MAX_X or position.y >= MAP_MAX_Y:
		return false
	else:
		if tool_type == "terrain":
			if brush_type == -1 and units.get_cell(position.x,position.y) > -1:
				if not undo_action:
					add_action({position=Vector2(position.x,position.y),tool_type="units"})
				units.set_cell(position.x,position.y,brush_type)
			else:
				if terrain.get_cell(position.x,position.y) != brush_type:
					if not undo_action:
						add_action({position=Vector2(position.x,position.y),tool_type="terrain"})
					terrain.set_cell(position.x,position.y,brush_type)
				
		if tool_type == "units":
			if units.get_cell(position.x,position.y) != brush_type:
				if terrain.get_cell(position.x, position.y) in [1,13,14,15,16,17,18]:
					if not undo_action:
						add_action({position=Vector2(position.x,position.y),tool_type="units"})
					units.set_cell(position.x,position.y,brush_type)
				else:
					self.hud_message.show_message("Invalid field", ["Unit can be placed only on land, river and roads."])
					return false
	units.raise()
	selector.raise()
	return true

func init(root):
	self.root = root
	terrain.add_child(selector)
	map.set_default_zoom()
	game_scale.set_scale(map.scale)
	set_process_input(true)

func _input(event):
	if self.is_working && not self.is_suspended && self.painting_allowed:
		if(event.type == InputEvent.MOUSE_BUTTON):
			if (event.button_index == BUTTON_LEFT):
				if event.pressed:
					painting = true
				else:
					painting = false
					painting_motion = false

		if (event.type == InputEvent.MOUSE_MOTION):
			map_pos = terrain.get_global_pos() / Vector2(map.scale.x,map.scale.y)
			selector_position = terrain.world_to_map( Vector2((event.x/map.scale.x)-map_pos.x,(event.y/map.scale.y)-map_pos.y))
			var position = terrain.map_to_world(selector_position)
			selector.set_pos(position)
			painting_motion = true

		if painting and event.x < OS.get_video_mode_size().x - RIGHT_DEAD_ZONE and event.x > LEFT_DEAD_ZONE :
			self.paint(selector_position)

	if Input.is_action_pressed('ui_cancel'):
		self.toggle_menu()

func toggle_menu():
	if not self.is_working:
		print('skip')
		return

	if self.is_hidden():
		self.is_suspended = false
		root.menu.show_workshop()
	else:
		self.is_suspended = true
		root.menu.hide_workshop()

func _ready():
	init_gui()
	pass


