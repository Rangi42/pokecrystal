MACRO map_id
;\1: map id
	assert DEF(GROUP_\1) && DEF(MAP_\1), \
		"Missing 'map_const \1' in constants/map_constants.asm"
	db GROUP_\1, MAP_\1
ENDM

DEF object_const_def EQUS "const_def 2"

MACRO def_scene_scripts
	REDEF _NUM_SCENE_SCRIPTS EQUS "_NUM_SCENE_SCRIPTS_\@"
	db {_NUM_SCENE_SCRIPTS}
	const_def
	DEF {_NUM_SCENE_SCRIPTS} = 0
ENDM

MACRO scene_const
;\1: scene id constant
	const \1
	EXPORT \1
ENDM

MACRO scene_script
;\1: script pointer
;\2: scene id constant
	dw \1
	dw 0 ; filler
	if _NARG == 2
		scene_const \2
	else
		const_skip
	endc
	DEF {_NUM_SCENE_SCRIPTS} += 1
ENDM

MACRO def_callbacks
	REDEF _NUM_CALLBACKS EQUS "_NUM_CALLBACKS_\@"
	db {_NUM_CALLBACKS}
	DEF {_NUM_CALLBACKS} = 0
ENDM

MACRO callback
;\1: type: a MAPCALLBACK_* constant
;\2: script pointer
	dbw \1, \2
	DEF {_NUM_CALLBACKS} += 1
ENDM

MACRO def_warp_events
	REDEF _NUM_WARP_EVENTS EQUS "_NUM_WARP_EVENTS_\@"
	db {_NUM_WARP_EVENTS}
	DEF {_NUM_WARP_EVENTS} = 0
ENDM

MACRO warp_event
;\1: x: left to right, starts at 0
;\2: y: top to bottom, starts at 0
;\3: map id: from constants/map_constants.asm
;\4: warp destination: starts at 1
	db \2, \1, \4
	map_id \3
	DEF {_NUM_WARP_EVENTS} += 1
ENDM

MACRO def_coord_events
	REDEF _NUM_COORD_EVENTS EQUS "_NUM_COORD_EVENTS_\@"
	db {_NUM_COORD_EVENTS}
	DEF {_NUM_COORD_EVENTS} = 0
ENDM

MACRO coord_event
;\1: x: left to right, starts at 0
;\2: y: top to bottom, starts at 0
;\3: scene id: a SCENE_* constant; controlled by setscene/setmapscene
;\4: script pointer
	db \3, \2, \1
	db 0 ; filler
	dw \4
	dw 0 ; filler
	DEF {_NUM_COORD_EVENTS} += 1
ENDM

MACRO def_bg_events
	REDEF _NUM_BG_EVENTS EQUS "_NUM_BG_EVENTS_\@"
	db {_NUM_BG_EVENTS}
	DEF {_NUM_BG_EVENTS} = 0
ENDM

MACRO bg_event
;\1: x: left to right, starts at 0
;\2: y: top to bottom, starts at 0
;\3: function: a BGEVENT_* constant
;\4: script pointer
	db \2, \1, \3
	dw \4
	DEF {_NUM_BG_EVENTS} += 1
ENDM

MACRO def_object_events
	REDEF _NUM_OBJECT_EVENTS EQUS "_NUM_OBJECT_EVENTS_\@"
	db {_NUM_OBJECT_EVENTS}
	DEF {_NUM_OBJECT_EVENTS} = 0
ENDM

MACRO object_event
;\1: x: left to right, starts at 0
;\2: y: top to bottom, starts at 0
;\3: sprite: a SPRITE_* constant
;\4: movement function: a SPRITEMOVEDATA_* constant
;\5, \6: movement radius: x, y
;\7, \8: hour limits: h1, h2 (0-23)
;  * if h1 < h2, the object_event will only appear from h1 to h2
;  * if h1 > h2, the object_event will not appear from h2 to h1
;  * if h1 == h2, the object_event will always appear
;  * if h1 == -1, h2 is treated as a time-of-day value:
;    a combo of MORN, DAY, and/or NITE, or -1 to always appear
;\9: palette: a PAL_NPC_* constant, or 0 for sprite default
;\<10>: function: a OBJECTTYPE_* constant
;\<11>: sight range: applies to OBJECTTYPE_TRAINER
;\<12>: script pointer
;\<13>: event flag: an EVENT_* constant, or -1 to always appear
	db \3, \2 + 4, \1 + 4, \4
	dn \6, \5
	db \7, \8
	dn \9, \<10>
	db \<11>
	dw \<12>, \<13>
	; the dummy PlayerObjectTemplate object_event has no def_object_events
	if DEF(_NUM_OBJECT_EVENTS)
		DEF {_NUM_OBJECT_EVENTS} += 1
	endc
ENDM

MACRO trainer
;\1: trainer group
;\2: trainer id
;\3: flag: an EVENT_BEAT_* constant
;\4: seen text
;\5: win text
;\6: loss text
;\7: after-battle text
	dw \3
	db \1, \2
	dw \4, \5, \6, \7
ENDM

MACRO itemball
;\1: item: from constants/item_constants.asm
;\2: quantity: default 1
	if _NARG == 1
		itemball \1, 1
	else
		db \1, \2
	endc
ENDM

MACRO hiddenitem
;\1: item: from constants/item_constants.asm
;\2: flag: an EVENT_* constant
	dwb \2, \1
ENDM

MACRO elevfloor
;\1: floor: a FLOOR_* constant
;\2: warp destination: starts at 1
;\3: map id
	db \1, \2
	map_id \3
ENDM

MACRO conditional_event
;\1: flag: an EVENT_* constant
;\2: script pointer
	dw \1, \2
ENDM

MACRO cmdqueue
;\1: type: a CMDQUEUE_* constant
;\2: data pointer
	dbw \1, \2
	dw 0 ; filler
ENDM

MACRO stonetable
;\1: warp id
;\2: object_event id
;\3: script pointer
	db \1, \2
	dw \3
ENDM

; Connections go in order: north, south, west, east
MACRO connection
;\1: direction
;\2: map name
;\3: map id
;\4: offset of the target map relative to the current map
;    (x offset for east/west, y offset for north/south)

	; LEGACY: Support for old connection macro
	if _NARG == 6
		connection \1, \2, \3, (\4) - (\5)
	else

		; Calculate tile offsets for source (current) and target maps
		DEF _src = 0
		DEF _tgt = (\4) + MAP_CONNECTION_PADDING_WIDTH
		if _tgt < 0
			DEF _src = -_tgt
			DEF _tgt = 0
		endc

		if !STRCMP("\1", "north")
			DEF _blk = \3_WIDTH * (\3_HEIGHT - MAP_CONNECTION_PADDING_WIDTH) + _src
			DEF _map = _tgt
			DEF _win = (\3_WIDTH + MAP_CONNECTION_PADDING_WIDTH * 2) * \3_HEIGHT + 1
			DEF _y = \3_HEIGHT * 2 - 1
			DEF _x = (\4) * -2
			DEF _len = CURRENT_MAP_WIDTH + MAP_CONNECTION_PADDING_WIDTH - (\4)
			if _len > \3_WIDTH
				DEF _len = \3_WIDTH
			endc

		elif !STRCMP("\1", "south")
			DEF _blk = _src
			DEF _map = (CURRENT_MAP_WIDTH + MAP_CONNECTION_PADDING_WIDTH * 2) * (CURRENT_MAP_HEIGHT + MAP_CONNECTION_PADDING_WIDTH) + _tgt
			DEF _win = \3_WIDTH + MAP_CONNECTION_PADDING_WIDTH * 2 + 1
			DEF _y = 0
			DEF _x = (\4) * -2
			DEF _len = CURRENT_MAP_WIDTH + MAP_CONNECTION_PADDING_WIDTH - (\4)
			if _len > \3_WIDTH
				DEF _len = \3_WIDTH
			endc

		elif !STRCMP("\1", "west")
			DEF _blk = (\3_WIDTH * _src) + \3_WIDTH - MAP_CONNECTION_PADDING_WIDTH
			DEF _map = (CURRENT_MAP_WIDTH + MAP_CONNECTION_PADDING_WIDTH * 2) * _tgt
			DEF _win = (\3_WIDTH + MAP_CONNECTION_PADDING_WIDTH * 2) * 2 - MAP_CONNECTION_PADDING_WIDTH * 2
			DEF _y = (\4) * -2
			DEF _x = \3_WIDTH * 2 - 1
			DEF _len = CURRENT_MAP_HEIGHT + MAP_CONNECTION_PADDING_WIDTH - (\4)
			if _len > \3_HEIGHT
				DEF _len = \3_HEIGHT
			endc

		elif !STRCMP("\1", "east")
			DEF _blk = (\3_WIDTH * _src)
			DEF _map = (CURRENT_MAP_WIDTH + MAP_CONNECTION_PADDING_WIDTH * 2) * _tgt + CURRENT_MAP_WIDTH + MAP_CONNECTION_PADDING_WIDTH
			DEF _win = \3_WIDTH + MAP_CONNECTION_PADDING_WIDTH * 2 + 1
			DEF _y = (\4) * -2
			DEF _x = 0
			DEF _len = CURRENT_MAP_HEIGHT + MAP_CONNECTION_PADDING_WIDTH - (\4)
			if _len > \3_HEIGHT
				DEF _len = \3_HEIGHT
			endc

		else
			fail "Invalid direction for 'connection'."
		endc

	map_id \3
	dw \2_Blocks + _blk
	dw wOverworldMapBlocks + _map
	db _len - _src
	db \3_WIDTH
	db _y, _x
	dw wOverworldMapBlocks + _win

	endc
ENDM
