const_value set 2
	const VICTORYROAD3F_VETERAN_M
	const VICTORYROAD3F_POKE_BALL

VictoryRoad3F_MapScriptHeader:
.MapTriggers:
	db 0

.MapCallbacks:
	db 0

TrainerVeteranmRemy:
	trainer EVENT_BEAT_VETERANM_REMY, VETERANM, REMY, VeteranmRemySeenText, VeteranmRemyBeatenText, 0, VeteranmRemyScript

VeteranmRemyScript:
	end_if_just_battled
	opentext
	writetext VeteranmRemyAfterText
	waitbutton
	closetext
	end

VictoryRoad3FRazorFang:
	itemball RAZOR_FANG

VeteranmRemySeenText:
	text "If you can get"
	line "through here, you"

	para "can challenge the"
	line "Elite Four!"
	done

VeteranmRemyBeatenText:
	text "No!"
	line "Inconceivable!"
	done

VeteranmRemyAfterText:
	text "I can beat you"
	line "when it comes to"

	para "knowledge about"
	line "#mon!"
	done

VictoryRoad3F_MapEventHeader:
.Warps:
	db 3
	warp_def $5, $2, 3, VICTORY_ROAD_2F
	warp_def $b, $f, 4, VICTORY_ROAD_2F
	warp_def $d, $13, 5, VICTORY_ROAD_2F

.XYTriggers:
	db 0

.Signposts:
	db 0

.PersonEvents:
	db 2
	person_event SPRITE_VETERAN_M, 8, 11, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, (1 << 3) | PAL_OW_BROWN, PERSONTYPE_TRAINER, 4, TrainerVeteranmRemy, -1
	person_event SPRITE_BALL_CUT_FRUIT, 13, 16, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, (1 << 3) | PAL_OW_RED, PERSONTYPE_ITEMBALL, 0, VictoryRoad3FRazorFang, EVENT_VICTORY_ROAD_3F_RAZOR_FANG
