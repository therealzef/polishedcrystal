const_value set 2
	const ECRUTEAKMART_CLERK
	const ECRUTEAKMART_SUPER_NERD
	const ECRUTEAKMART_RICH_BOY

EcruteakMart_MapScriptHeader:
.MapTriggers:
	db 0

.MapCallbacks:
	db 0

ClerkScript_0x99c3b:
	opentext
	pokemart MARTTYPE_STANDARD, MART_ECRUTEAK
	closetext
	end

SuperNerdScript_0x99c42:
	jumptextfaceplayer UnknownText_0x99c48

RichBoyScript_0x99c45:
	jumptextfaceplayer UnknownText_0x99cd5

UnknownText_0x99c48:
	text "My Eevee evolved"
	line "into an Espeon."

	para "But my friend's"
	line "Eevee turned into"
	cont "an Umbreon."

	para "I wonder why? We"
	line "both were raising"

	para "our Eevee in the"
	line "same way…"
	done

UnknownText_0x99cd5:
	text "The Magnet Train"
	line "in Goldenrod is"
	cont "great, but there"

	para "were also plans to"
	line "put a station in"
	cont "Ecruteak at first."
	done

EcruteakMart_MapEventHeader:
.Warps:
	db 2
	warp_def $7, $2, 9, ECRUTEAK_CITY
	warp_def $7, $3, 9, ECRUTEAK_CITY

.XYTriggers:
	db 0

.Signposts:
	db 0

.PersonEvents:
	db 3
	person_event SPRITE_CLERK, 3, 1, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, ClerkScript_0x99c3b, -1
	person_event SPRITE_SUPER_NERD, 2, 5, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 0, 1, -1, -1, (1 << 3) | PAL_OW_GREEN, PERSONTYPE_SCRIPT, 0, SuperNerdScript_0x99c42, -1
	person_event SPRITE_RICH_BOY, 6, 6, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, (1 << 3) | PAL_OW_PURPLE, PERSONTYPE_SCRIPT, 0, RichBoyScript_0x99c45, -1
