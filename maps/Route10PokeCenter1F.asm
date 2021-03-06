const_value set 2
	const ROUTE10POKECENTER1F_NURSE
	const ROUTE10POKECENTER1F_GENTLEMAN
	const ROUTE10POKECENTER1F_GYM_GUY
	const ROUTE10POKECENTER1F_COOLTRAINER_F

Route10PokeCenter1F_MapScriptHeader:
.MapTriggers:
	db 0

.MapCallbacks:
	db 0

NurseScript_0x188bd4:
	jumpstd pokecenternurse

GentlemanScript_0x188bd7:
	jumptextfaceplayer UnknownText_0x188bf1

GymGuyScript_0x188bda:
	faceplayer
	opentext
	checkevent EVENT_RETURNED_MACHINE_PART
	iftrue UnknownScript_0x188be8
	writetext UnknownText_0x188c26
	waitbutton
	closetext
	end

UnknownScript_0x188be8:
	writetext UnknownText_0x188c9e
	waitbutton
	closetext
	end

CooltrainerFScript_0x188bee:
	jumptextfaceplayer UnknownText_0x188d0c

PokemonJournalAgathaScript:
	setflag ENGINE_READ_AGATHA_JOURNAL
	jumptext PokemonJournalAgathaText

UnknownText_0x188bf1:
	text "A #mon Center"
	line "near a cave?"

	para "That's mighty"
	line "convenient."
	done

UnknownText_0x188c26:
	text "The Power Plant's"
	line "Manager is looking"

	para "for a strong #-"
	line "mon trainer."

	para "He needs help"
	line "getting back"

	para "something that"
	line "was stolen."
	done

UnknownText_0x188c9e:
	text "I hear Team Rocket"
	line "got back together"

	para "in Johto but fell"
	line "apart right away."

	para "I didn't know any-"
	line "thing about that."
	done

UnknownText_0x188d0c:
	text "When you go out-"
	line "side, you can see"

	para "the roof of a big"
	line "building."

	para "That's the Power"
	line "Plant."
	done

PokemonJournalAgathaText:
	text "#mon Journal"

	para "Special Feature:"
	line "Ex-Elite Agatha!"

	para "In their youth,"
	line "Agatha and Prof."
	cont "Oak were rivals"

	para "who vied for supr-"
	line "emacy as trainers."
	done

Route10PokeCenter1F_MapEventHeader:
.Warps:
	db 3
	warp_def $7, $5, 1, ROUTE_10_NORTH
	warp_def $7, $6, 1, ROUTE_10_NORTH
	warp_def $7, $0, 1, POKECENTER_2F

.XYTriggers:
	db 0

.Signposts:
	db 1
	signpost 1, 10, SIGNPOST_READ, PokemonJournalAgathaScript

.PersonEvents:
	db 4
	person_event SPRITE_NURSE, 1, 5, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, NurseScript_0x188bd4, -1
	person_event SPRITE_GENTLEMAN, 4, 9, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, (1 << 3) | PAL_OW_RED, PERSONTYPE_SCRIPT, 0, GentlemanScript_0x188bd7, -1
	person_event SPRITE_GYM_GUY, 2, 8, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, (1 << 3) | PAL_OW_GREEN, PERSONTYPE_SCRIPT, 0, GymGuyScript_0x188bda, -1
	person_event SPRITE_COOLTRAINER_F, 3, 2, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, CooltrainerFScript_0x188bee, -1
