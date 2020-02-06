	object_const_def
	const INDIGOPLATEAUPOKECENTER1F_NURSE
	const INDIGOPLATEAUPOKECENTER1F_CLERK

IndigoPlateauPokecenter1F_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_NEWMAP, IndigoPlateauPokecenter1FPrepareElite4Callback

IndigoPlateauPokecenter1FPrepareElite4Callback:
	setmapscene WILLS_ROOM, SCENE_WILLSROOM_LOCK_DOOR
	setmapscene KOGAS_ROOM, SCENE_KOGASROOM_LOCK_DOOR
	setmapscene BRUNOS_ROOM, SCENE_BRUNOSROOM_LOCK_DOOR
	setmapscene KARENS_ROOM, SCENE_KARENSROOM_LOCK_DOOR
	setmapscene LANCES_ROOM, SCENE_LANCESROOM_LOCK_DOOR
	setmapscene HALL_OF_FAME, SCENE_HALLOFFAME_ENTER
	clearevent EVENT_WILLS_ROOM_ENTRANCE_CLOSED
	clearevent EVENT_WILLS_ROOM_EXIT_OPEN
	clearevent EVENT_KOGAS_ROOM_ENTRANCE_CLOSED
	clearevent EVENT_KOGAS_ROOM_EXIT_OPEN
	clearevent EVENT_BRUNOS_ROOM_ENTRANCE_CLOSED
	clearevent EVENT_BRUNOS_ROOM_EXIT_OPEN
	clearevent EVENT_KARENS_ROOM_ENTRANCE_CLOSED
	clearevent EVENT_KARENS_ROOM_EXIT_OPEN
	clearevent EVENT_LANCES_ROOM_ENTRANCE_CLOSED
	clearevent EVENT_LANCES_ROOM_EXIT_OPEN
	clearevent EVENT_BEAT_ELITE_4_WILL
	clearevent EVENT_BEAT_ELITE_4_KOGA
	clearevent EVENT_BEAT_ELITE_4_BRUNO
	clearevent EVENT_BEAT_ELITE_4_KAREN
	clearevent EVENT_BEAT_CHAMPION_LANCE
	setevent EVENT_LANCES_ROOM_OAK_AND_MARY
	endcallback

IndigoPlateauPokecenter1FNurseScript:
	jumpstd PokecenterNurseScript

IndigoPlateauPokecenter1FClerkScript:
	opentext
	pokemart MARTTYPE_STANDARD, MART_INDIGO_PLATEAU
	closetext
	end

IndigoPlateauPokecenter1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  5, 13, NEW_BARK_TOWN, 3
	warp_event  6, 13, NEW_BARK_TOWN, 3
	warp_event  0, 13, POKECENTER_2F, 1
	warp_event 14,  3, WILLS_ROOM, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event  3,  7, SPRITE_NURSE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, IndigoPlateauPokecenter1FNurseScript, -1
	object_event 11,  7, SPRITE_CLERK, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, IndigoPlateauPokecenter1FClerkScript, -1
