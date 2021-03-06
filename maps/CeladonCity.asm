const_value set 2
	const CELADONCITY_RICH_BOY
	const CELADONCITY_FISHER
	const CELADONCITY_POLIWRATH
	const CELADONCITY_TEACHER1
	const CELADONCITY_GRAMPS1
	const CELADONCITY_GRAMPS2
	const CELADONCITY_YOUNGSTER1
	const CELADONCITY_YOUNGSTER2
	const CELADONCITY_TEACHER2
	const CELADONCITY_LASS1
	const CELADONCITY_BIG_SNORLAX
	const CELADONCITY_LASS2
	const CELADONCITY_CUT_TREE

CeladonCity_MapScriptHeader:
.MapTriggers:
	db 0

.MapCallbacks:
	db 1
	dbw MAPCALLBACK_NEWMAP, .FlyPoint

.FlyPoint:
	setflag ENGINE_FLYPOINT_CELADON
	return

CeladonCityScript:
	faceplayer
	opentext
	checkevent EVENT_LISTENED_TO_SWAGGER_INTRO
	iftrue CeladonCityTutorSwaggerScript
	writetext CeladonCityRichBoyText
	waitbutton
	setevent EVENT_LISTENED_TO_SWAGGER_INTRO
CeladonCityTutorSwaggerScript:
	writetext Text_CeladonCityTutorSwagger
	waitbutton
	checkitem SILVER_LEAF
	iffalse .NoSilverLeaf
	writetext Text_CeladonCityTutorQuestion
	yesorno
	iffalse .TutorRefused
	writebyte SWAGGER
	writetext Text_CeladonCityTutorClear
	special Special_MoveTutor
	if_equal $0, .TeachMove
.TutorRefused
	writetext Text_CeladonCityTutorRefused
	waitbutton
	closetext
	end

.NoSilverLeaf
	writetext Text_CeladonCityTutorNoSilverLeaf
	waitbutton
	closetext
	end

.TeachMove
	takeitem SILVER_LEAF
	writetext Text_CeladonCityTutorTaught
	waitbutton
	closetext
	end

FisherScript_0x1a9f43:
	jumptextfaceplayer UnknownText_0x1a9f7d

CeladonCityPoliwrath:
	opentext
	writetext CeladonCityPoliwrathText
	cry POLIWRATH
	waitbutton
	closetext
	end

TeacherScript_0x1a9f50:
	jumptextfaceplayer UnknownText_0x1a9fde

GrampsScript_0x1a9f53:
	jumptextfaceplayer UnknownText_0x1aa043

GrampsScript_0x1a9f56:
	jumptextfaceplayer UnknownText_0x1aa0dc

YoungsterScript_0x1a9f59:
	jumptextfaceplayer UnknownText_0x1aa115

YoungsterScript_0x1a9f5c:
	jumptextfaceplayer UnknownText_0x1aa155

TeacherScript_0x1a9f5f:
	jumptextfaceplayer UnknownText_0x1aa1bd

LassScript_0x1a9f62:
	jumptextfaceplayer UnknownText_0x1aa25b

CeladonCityLassScript:
	jumptextfaceplayer CeladonCityLassText

CeladonCitySign:
	jumptext CeladonCitySignText

CeladonGymSign:
	jumptext CeladonGymSignText

CeladonCityCutTree:
	jumpstd cuttree

CeladonUniversitySign:
	jumptext CeladonUniversitySignText

CeladonCityDeptStoreSign:
	jumptext CeladonCityDeptStoreSignText

CeladonCityHomeDecorStoreSign:
	jumptext CeladonCityHomeDecorStoreSignText

CeladonCityMansionSign:
	jumptext CeladonCityMansionSignText

CeladonCityGameCornerSign:
	jumptext CeladonCityGameCornerSignText

CeladonCityTrainerTips:
	jumptext CeladonCityTrainerTipsText

CeladonCityHiddenPpUp:
	dwb EVENT_CELADON_CITY_HIDDEN_PP_UP, PP_UP

CeladonCityRichBoyText:
	text "Is my suit not"
	line "bedazzling?"

	para "It turns heads"
	line "when I swagger"
	cont "down the street!"

	para "The people love"
	line "me!"

	para "I'm in a generous"
	line "mood today."
	done

Text_CeladonCityTutorSwagger:
	text "I shall teach"
	line "your #mon to"

	para "Swagger like me"
	line "for merely a"
	cont "Silver Leaf."
	done

Text_CeladonCityTutorNoSilverLeaf:
	text "…You have no"
	line "Silver Leaf?"
	cont "What a pity."
	done

Text_CeladonCityTutorQuestion:
	text "You wish me to"
	line "teach your #-"
	cont "mon Swagger?"
	done

Text_CeladonCityTutorRefused:
	text "Then goodbye!"
	done

Text_CeladonCityTutorClear:
	text ""
	done

Text_CeladonCityTutorTaught:
	text "Behold! Your #-"
	line "mon has learned"
	cont "to Swagger!"
	done

UnknownText_0x1a9f7d:
	text "This Poliwrath is"
	line "my partner."

	para "I wonder if it'll"
	line "ever evolve into a"
	cont "frog #mon."
	done

CeladonCityPoliwrathText:
	text "Poliwrath: Croak!"
	done

UnknownText_0x1a9fde:
	text "I lost at the slot"
	line "machines again…"

	para "We girls also play"
	line "the slots now."

	para "You should check"
	line "them out too."
	done

UnknownText_0x1aa043:
	text "Grimer have been"
	line "appearing lately."

	para "See that pond out"
	line "in front of the"

	para "house? Grimer live"
	line "there now."

	para "Where did they"
	line "come from? This is"
	cont "a serious problem…"
	done

UnknownText_0x1aa0dc:
	text "Nihihi! This Gym"
	line "is great! Only"

	para "girls are allowed"
	line "here!"
	done

UnknownText_0x1aa115:
	text "Want to know a"
	line "secret?"

	para "Celadon Mansion"
	line "has a hidden back"
	cont "door."
	done

UnknownText_0x1aa155:
	text "The restaurant"
	line "there is having an"
	cont "eating contest."

	para "There's one con-"
	line "testant from the"

	para "Sinnoh region this"
	line "year."

	para "Just watching her"
	line "go at it makes me"
	cont "feel bloated…"
	done

UnknownText_0x1aa1bd:
	text "Celadon Dept.Store"
	line "has the biggest"

	para "and best selection"
	line "of merchandise."

	para "If you can't get"
	line "it there, you"

	para "can't get it any-"
	line "where."

	para "Gee… I sound like"
	line "a sales clerk."
	done

UnknownText_0x1aa25b:
	text "I love being"
	line "surrounded by tall"
	cont "buildings!"

	para "Isn't it true that"
	line "Goldenrod #mon"

	para "Center was made"
	line "much, much bigger?"

	para "That is so neat!"
	line "I wish we had a"

	para "place like that in"
	line "Kanto…"
	done

CeladonCityLassText:
	text "#mon are offer-"
	line "ed as prizes at"
	cont "the Game Corner."

	para "The poor things…"
	done

CeladonCitySignText:
	text "Celadon City"

	para "The City of"
	line "Rainbow Dreams"
	done

CeladonGymSignText:
	text "Celadon City"
	line "#mon Gym"
	cont "Leader: Erika"

	para "The Nature-Loving"
	line "Princess"
	done

CeladonUniversitySignText:
	text "Celadon University"
	done

CeladonCityDeptStoreSignText:
	text "Find What You"
	line "Need at Celadon"
	cont "Dept.Store!"
	done

CeladonCityHomeDecorStoreSignText:
	text "Celadon Dept.Store"
	line "Home Decor Wing"
	done

CeladonCityMansionSignText:
	text "Celadon Mansion"
	done

CeladonCityGameCornerSignText:
	text "The Playground for"
	line "Everybody--Celadon"
	cont "Game Corner"
	done

CeladonCityTrainerTipsText:
	text "Trainer Tips"

	para "Guard Spec."
	line "protects #mon"

	para "against stat"
	line "reductions."

	para "Get your items at"
	line "Celadon Dept."
	cont "Store!"
	done

CeladonCity_MapEventHeader:
.Warps:
	db 16
	warp_def $9, $8, 1, CELADON_DEPT_STORE_1F
	warp_def $9, $14, 1, CELADON_MANSION_1F
	warp_def $3, $14, 3, CELADON_MANSION_1F
	warp_def $3, $15, 3, CELADON_MANSION_1F
	warp_def $9, $21, 1, CELADON_POKECENTER_1F
	warp_def $13, $16, 1, CELADON_GAME_CORNER
	warp_def $13, $1b, 1, CELADON_GAME_CORNER_PRIZE_ROOM
	warp_def $1d, $e, 1, CELADON_GYM
	warp_def $1d, $19, 1, CELADON_CAFE
	warp_def $1d, $21, 1, CELADON_CHIEF_HOUSE
	warp_def $1d, $25, 1, CELADON_HOTEL_1F
	warp_def $9, $d, 1, CELADON_HOME_DECOR_STORE_1F
	warp_def $1d, $4, 1, CELADON_UNIVERSITY_1F
	warp_def $9, $1d, 1, EUSINES_HOUSE
	warp_def $13, $21, 1, CELADON_OLD_MAN_SPEECH_HOUSE
	warp_def $13, $25, 1, CELADON_DEVELOPMENT_SPEECH_HOUSE

.XYTriggers:
	db 0

.Signposts:
	db 9
	signpost 18, 9, SIGNPOST_READ, CeladonCitySign
	signpost 31, 15, SIGNPOST_READ, CeladonGymSign
	signpost 31, 3, SIGNPOST_READ, CeladonUniversitySign
	signpost 9, 10, SIGNPOST_READ, CeladonCityDeptStoreSign
	signpost 9, 14, SIGNPOST_READ, CeladonCityHomeDecorStoreSign
	signpost 9, 17, SIGNPOST_READ, CeladonCityMansionSign
	signpost 21, 21, SIGNPOST_READ, CeladonCityGameCornerSign
	signpost 21, 33, SIGNPOST_READ, CeladonCityTrainerTips
	signpost 21, 41, SIGNPOST_ITEM, CeladonCityHiddenPpUp

.PersonEvents:
	db 13
	person_event SPRITE_RICH_BOY, 17, 4, SPRITEMOVEDATA_WALK_UP_DOWN, 2, 0, -1, -1, (1 << 3) | PAL_OW_GREEN, PERSONTYPE_SCRIPT, 0, CeladonCityScript, -1
	person_event SPRITE_FISHER, 11, 30, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, (1 << 3) | PAL_OW_GREEN, PERSONTYPE_SCRIPT, 0, FisherScript_0x1a9f43, -1
	person_event SPRITE_POLIWRATH, 11, 31, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, (1 << 3) | PAL_OW_BLUE, PERSONTYPE_SCRIPT, 0, CeladonCityPoliwrath, -1
	person_event SPRITE_TEACHER, 24, 24, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 0, 2, -1, -1, (1 << 3) | PAL_OW_RED, PERSONTYPE_SCRIPT, 0, TeacherScript_0x1a9f50, -1
	person_event SPRITE_GRAMPS, 16, 17, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, (1 << 3) | PAL_OW_BROWN, PERSONTYPE_SCRIPT, 0, GrampsScript_0x1a9f53, -1
	person_event SPRITE_GRAMPS, 31, 12, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, (1 << 3) | PAL_OW_RED, PERSONTYPE_SCRIPT, 0, GrampsScript_0x1a9f56, -1
	person_event SPRITE_YOUNGSTER, 13, 22, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 0, 2, -1, -1, (1 << 3) | PAL_OW_BLUE, PERSONTYPE_SCRIPT, 0, YoungsterScript_0x1a9f59, -1
	person_event SPRITE_YOUNGSTER, 33, 27, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, (1 << 3) | PAL_OW_GREEN, PERSONTYPE_SCRIPT, 0, YoungsterScript_0x1a9f5c, -1
	person_event SPRITE_TEACHER, 13, 12, SPRITEMOVEDATA_WANDER, 2, 2, -1, -1, (1 << 3) | PAL_OW_GREEN, PERSONTYPE_SCRIPT, 0, TeacherScript_0x1a9f5f, -1
	person_event SPRITE_LASS, 22, 10, SPRITEMOVEDATA_WALK_UP_DOWN, 2, 0, -1, -1, (1 << 3) | PAL_OW_RED, PERSONTYPE_SCRIPT, 0, LassScript_0x1a9f62, -1
	person_event SPRITE_BIG_SNORLAX, 10, 45, SPRITEMOVEDATA_SNORLAX, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, ObjectEvent, EVENT_ROUTE_8_SNORLAX
	person_event SPRITE_LASS, 23, 35, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 0, 1, -1, -1, (1 << 3) | PAL_OW_BROWN, PERSONTYPE_SCRIPT, 0, CeladonCityLassScript, -1
	person_event SPRITE_BALL_CUT_FRUIT, 34, 32, SPRITEMOVEDATA_CUTTABLE_TREE, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, CeladonCityCutTree, EVENT_CELADON_CITY_CUT_TREE
