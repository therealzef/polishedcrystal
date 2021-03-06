AddPhoneNumber:: ; 90000
	call _CheckCellNum
	jr c, .cant_add
	call Phone_FindOpenSlot
	jr nc, .cant_add
	ld [hl], c
	xor a
	ret

.cant_add
	scf
	ret
; 9000f


DelCellNum:: ; 9000f
	call _CheckCellNum
	jr nc, .not_in_list
	xor a
	ld [hl], a
	ret

.not_in_list
	scf
	ret
; 90019

CheckCellNum:: ; 90019
	jp _CheckCellNum ; wtf
; 9001c

_CheckCellNum: ; 9001c
	ld hl, wPhoneList
	ld b, CONTACT_LIST_SIZE
.loop
	ld a, [hli]
	cp c
	jr z, .got_it
	dec b
	jr nz, .loop
	xor a
	ret

.got_it
	dec hl
	scf
	ret
; 9002d

Phone_FindOpenSlot: ; 9002d
	call GetRemainingSpaceInPhoneList
	ld b, a
	ld hl, wPhoneList
.loop
	ld a, [hli]
	and a
	jr z, .FoundOpenSpace
	dec b
	jr nz, .loop
	xor a
	ret

.FoundOpenSpace:
	dec hl
	scf
	ret
; 90040

GetRemainingSpaceInPhoneList: ; 90040
	xor a
	ld [Buffer1], a
	ld hl, PermanentNumbers
.loop
	ld a, [hli]
	cp -1
	jr z, .done
	cp c
	jr z, .elm_or_mom
	push bc
	push hl
	ld c, a
	call _CheckCellNum
	jr c, .elm_or_mom_in_list
	ld hl, Buffer1
	inc [hl]

.elm_or_mom_in_list
	pop hl
	pop bc

.elm_or_mom
	jr .loop

.done
	ld a, CONTACT_LIST_SIZE
	ld hl, Buffer1
	sub [hl]
	ret
; 90066

PermanentNumbers: ; 90066
	db PHONECONTACT_MOM, PHONECONTACT_ELM, -1
; 90069


FarPlaceString: ; 90069
	ld a, [hROMBank]
	push af
	ld a, b
	rst Bankswitch

	call PlaceString

	pop af
	rst Bankswitch
	ret
; 90074


CheckPhoneCall:: ; 90074 (24:4074)
; Check if the phone is ringing in the overworld.

	call CheckStandingOnEntrance
	jr z, .no_call

	call .timecheck
	jr nc, .no_call

	call Random
	ld b, a
	and 50 percent
	cp b
	jr nz, .no_call

	call GetMapHeaderPhoneServiceNybble
	and a
	jr nz, .no_call

	call GetAvailableCallers
	call ChooseRandomCaller
	jr nc, .no_call

	ld e, a
	call LoadCallerScript
	ld a, BANK(Script_ReceivePhoneCall)
	ld hl, Script_ReceivePhoneCall
	call CallScript
	scf
	ret

.no_call
	xor a
	ret

.timecheck ; 900a6 (24:40a6)
	farcall CheckReceiveCallTimer
	ret

CheckPhoneContactTimeOfDay: ; 900ad (24:40ad)
	push hl
	push bc
	push de
	push af

	farcall CheckTime
	pop af
	and (1 << MORN) + (1 << DAY) + (1 << NITE)
	and c

	pop de
	pop bc
	pop hl
	ret

ChooseRandomCaller: ; 900bf (24:40bf)
; If no one is available to call, don't return anything.
	ld a, [EngineBuffer3]
	and a
	jr z, .NothingToSample

; Sample a random number between 0 and 31.
	ld c, a
	call Random
	ld a, [hRandomAdd]
	swap a
	and $1f
; Compute that number modulo the number of available callers.
	call SimpleDivide
; Return the caller ID you just sampled.
	ld c, a
	ld b, 0
	ld hl, EngineBuffer4
	add hl, bc
	ld a, [hl]
	scf
	ret

.NothingToSample:
	xor a
	ret

GetAvailableCallers: ; 900de (24:40de)
	farcall CheckTime
	ld a, c
	ld [EngineBuffer1], a ; wd03e (aliases: MenuItemsList, CurFruitTree, CurInput)
	ld hl, EngineBuffer3
	ld bc, 11
	xor a
	call ByteFill
	ld de, wPhoneList
	ld a, CONTACT_LIST_SIZE

.loop
	ld [EngineBuffer2], a
	ld a, [de]
	and a
	jr z, .not_good_for_call
	ld hl, PhoneContacts + PHONE_CONTACT_SCRIPT2_TIME
	ld bc, PHONE_TABLE_WIDTH
	call AddNTimes
	ld a, [EngineBuffer1] ; wd03e (aliases: MenuItemsList, CurFruitTree, CurInput)
	and [hl]
	jr z, .not_good_for_call
	ld bc, PHONE_CONTACT_MAP_GROUP - PHONE_CONTACT_SCRIPT2_TIME
	add hl, bc
	ld a, [MapGroup]
	cp [hl]
	jr nz, .different_map
	inc hl
	ld a, [MapNumber]
	cp [hl]
	jr z, .not_good_for_call
.different_map
	ld a, [EngineBuffer3]
	ld c, a
	ld b, $0
	inc a
	ld [EngineBuffer3], a
	ld hl, EngineBuffer4
	add hl, bc
	ld a, [de]
	ld [hl], a
.not_good_for_call
	inc de
	ld a, [EngineBuffer2]
	dec a
	jr nz, .loop
	ret

CheckSpecialPhoneCall:: ; 90136 (24:4136)
	ld a, [wSpecialPhoneCallID]
	and a
	jr z, .NoPhoneCall

	dec a
	ld c, a
	ld b, 0
	ld hl, SpecialPhoneCallList
	ld a, 6
	call AddNTimes
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call _hl_
	jr nc, .NoPhoneCall

	call .DoSpecialPhoneCall
rept 2
	inc hl
endr
	ld a, [hli]
	ld e, a
	push hl
	call LoadCallerScript
	pop hl
	ld de, wPhoneScriptPointer
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, BANK(.script)
	ld hl, .script
	call CallScript
	scf
	ret
.NoPhoneCall:
	xor a
	ret
; 90173 (24:4173)

.script ; 0x90173
	pause 30
	jump Script_ReceivePhoneCall
; 0x90178

.DoSpecialPhoneCall: ; 90178 (24:4178)
	ld a, [wSpecialPhoneCallID]
	dec a
	ld c, a
	ld b, 0
	ld hl, SpecialPhoneCallList
	ld a, 6
	jp AddNTimes

SpecialCallOnlyWhenOutside: ; 90188
	ld a, [wPermission]
	cp TOWN
	jr z, .outside
	cp ROUTE
	jr z, .outside
	xor a
	ret

.outside
	scf
	ret

SpecialCallWhereverYouAre: ; 90197
	scf
	ret

Function90199: ; 90199 (24:4199)
	; Don't do the call if you're in a link communication
	ld a, [wLinkMode]
	and a
	jr nz, .OutOfArea
	; If you're in an area without phone service, don't do the call
	call GetMapHeaderPhoneServiceNybble
	and a
	jr nz, .OutOfArea
	; If the person can't take a call at that time, don't do the call
	ld a, b
	ld [wCurrentCaller], a
	ld hl, PhoneContacts
	ld bc, PHONE_TABLE_WIDTH
	call AddNTimes
	ld d, h
	ld e, l
	ld hl, PHONE_CONTACT_SCRIPT1_TIME
	add hl, de
	ld a, [hl]
	call CheckPhoneContactTimeOfDay
	jr z, .OutOfArea
	; If we're in the same map as the person we're calling,
	; use the "Just talk to that person" script.
	ld hl, PHONE_CONTACT_MAP_GROUP
	add hl, de
	ld a, [MapGroup]
	cp [hl]
	jr nz, .GetPhoneScript
	ld hl, PHONE_CONTACT_MAP_NUMBER
	add hl, de
	ld a, [MapNumber]
	cp [hl]
	jr nz, .GetPhoneScript
	ld b, BANK(PhoneScript_JustTalkToThem)
	ld hl, PhoneScript_JustTalkToThem
	jr .DoPhoneCall

.GetPhoneScript:
	ld hl, PHONE_CONTACT_SCRIPT1_BANK
	add hl, de
	ld b, [hl]
	ld hl, PHONE_CONTACT_SCRIPT1_ADDR_LO
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jr .DoPhoneCall

.OutOfArea:
	ld b, BANK(UnknownScript_0x90209)
	ld de, UnknownScript_0x90209
	jp ExecuteCallbackScript

.DoPhoneCall:
	ld a, b
	ld [wd002], a
	ld a, l
	ld [wd003], a
	ld a, h
	ld [wd004], a
	ld b, BANK(UnknownScript_0x90205)
	ld de, UnknownScript_0x90205
	jp ExecuteCallbackScript
; 90205 (24:4205)

UnknownScript_0x90205: ; 0x90205
	ptcall wd002
	return
; 0x90209

UnknownScript_0x90209: ; 0x90209
	scall UnknownScript_0x90657
	return
; 0x9020d

LoadCallerScript: ; 9020d (24:420d)
	ld a, e
	ld [wCurrentCaller], a
	and a
	jr nz, .actualcaller
	ld a, BANK(WrongNumber)
	ld hl, WrongNumber
	jr .proceed

.actualcaller
	ld hl, PhoneContacts
	ld bc, 12
	ld a, e
	call AddNTimes
	ld a, BANK(PhoneContacts)
.proceed
	ld de, EngineBuffer2
	ld bc, 12
	jp FarCopyBytes
; 90233 (24:4233)

WrongNumber: ; 90233
	db TRAINER_NONE, PHONE_00
	dba .script
.script
	writetext .text
	end
.text
	; Huh? Sorry, wrong number!
	text_jump UnknownText_0x1c5565
	db "@"
; 90241

Script_ReceivePhoneCall: ; 0x90241
	refreshscreen
	callasm RingTwice_StartCall
	ptcall wPhoneScriptPointer
	waitbutton
	callasm HangUp
	closetext
	callasm InitCallReceiveDelay
	end
; 0x90255

Script_SpecialBillCall:: ; 0x90255
	callasm .LoadBillScript
	jump Script_ReceivePhoneCall

.LoadBillScript:
	ld e, PHONE_BILL
	jp LoadCallerScript
; 90261

RingTwice_StartCall: ; 9026f
	call .Ring
	;jp .Ring
; 9027c

.Ring: ; 9027c (24:427c)
	call Phone_StartRinging
	call Phone_Wait20Frames
	call Phone_CallerTextboxWithName
	call Phone_Wait20Frames
	call Phone_CallerTextbox
	call Phone_Wait20Frames
	;jp Phone_CallerTextboxWithName

Phone_CallerTextboxWithName: ; 90292 (24:4292)
	ld a, [wCurrentCaller]
	ld b, a
	jp Function90363

PhoneCall:: ; 9029a
	ld a, b
	ld [PhoneScriptBank], a
	ld a, e
	ld [PhoneCallerLo], a
	ld a, d
	ld [PhoneCallerHi], a
	call Phone_FirstOfTwoRings
	;jp Phone_FirstOfTwoRings
; 902b3

Phone_FirstOfTwoRings: ; 902b3
	call Phone_StartRinging
	call Phone_Wait20Frames
	call Phone_CallerTextboxWithName2
	call Phone_Wait20Frames
	call Phone_CallerTextbox
	call Phone_Wait20Frames
	;jp Phone_CallerTextboxWithName2
; 902c9

Phone_CallerTextboxWithName2: ; 902c9
	call Phone_CallerTextbox
	hlcoord 1, 2
	ld [hl], $62
rept 2
	inc hl
endr
	ld a, [PhoneScriptBank]
	ld b, a
	ld a, [PhoneCallerLo]
	ld e, a
	ld a, [PhoneCallerHi]
	ld d, a
	jp FarPlaceString
; 902e3


Phone_NoSignal: ; 902e3 (24:42e3)
	ld de, SFX_NO_SIGNAL
	call PlaySFX
	jr Phone_CallEnd

HangUp:: ; 902eb
	call HangUp_Beep
	call HangUp_Wait20Frames
Phone_CallEnd:
	call HangUp_BoopOn
	call HangUp_Wait20Frames
	call SpeechTextBox
	call HangUp_Wait20Frames
	call HangUp_BoopOn
	call HangUp_Wait20Frames
	call SpeechTextBox
	call HangUp_Wait20Frames
	call HangUp_BoopOn
	call HangUp_Wait20Frames
	call SpeechTextBox
	jp HangUp_Wait20Frames
; 90316

HangUp_Beep: ; 9031d
	ld hl, UnknownText_0x9032a
	call PrintText
	ld de, SFX_HANG_UP
	jp PlaySFX
; 9032a

UnknownText_0x9032a: ; 9032a
	text_jump UnknownText_0x1c5580
	db "@"
; 9032f


HangUp_BoopOn: ; 9032f
	ld hl, UnknownText_0x90336
	jp PrintText
; 90336

UnknownText_0x90336: ; 0x90336
	text_jump UnknownText_0x1c5588
	db "@"
; 0x9033b


Phone_StartRinging: ; 9033f
	call WaitSFX
	ld de, SFX_CALL
	call PlaySFX
	call Phone_CallerTextbox
	call UpdateSprites
	farcall PhoneRing_LoadEDTile
	ret
; 90355

HangUp_Wait20Frames: ; 90355
Phone_Wait20Frames:
	ld c, 20
	call DelayFrames
	farcall PhoneRing_LoadEDTile
	ret
; 90363


Function90363: ; 90363 (24:4363)
	push bc
	call Phone_CallerTextbox
	hlcoord 1, 1
	ld [hl], "<PHONE>"
rept 2
	inc hl
endr
	ld d, h
	ld e, l
	pop bc
	jp Function90380


Phone_CallerTextbox: ; 90375
	hlcoord 0, 0
	ld b, 2
	ld c, SCREEN_WIDTH - 2
	jp TextBox
; 90380


Function90380: ; 90380 (24:4380)
	ld h, d
	ld l, e
	ld a, b
	call GetCallerTrainerClass
	jp GetCallerName

CheckCanDeletePhoneNumber: ; 9038a (24:438a)
	ld a, c
	call GetCallerTrainerClass
	ld a, c
;	and a
;	ret nz
	ld a, b
	cp PHONECONTACT_MOM
	ret z
	cp PHONECONTACT_ELM
	ret z
	ld c, $1
	ret

GetCallerTrainerClass: ; 9039a
	push hl
	ld hl, PhoneContacts + PHONE_CONTACT_TRAINER_CLASS
	ld bc, PHONE_TABLE_WIDTH
	call AddNTimes
	ld a, [hli]
	ld b, [hl]
	ld c, a
	pop hl
	ret
; 903a9


GetCallerName: ; 903a9 (24:43a9)
	ld a, c
	and a
	jr z, .NotTrainer

	call Phone_GetTrainerName
	push hl
	push bc
	call PlaceString
	ld a, ":"
	ld [bc], a
	pop bc
	pop hl
	ld de, SCREEN_WIDTH + 3
	add hl, de
	call Phone_GetTrainerClassName
	jp PlaceString

.NotTrainer:
	push hl
	ld c, b
	ld b, 0
	ld hl, NonTrainerCallerNames
rept 2
	add hl, bc
endr
	ld a, [hli]
	ld e, a
	ld d, [hl]
	pop hl
	jp PlaceString
; 903d6 (24:43d6)

NonTrainerCallerNames: ; 903d6
	dw .none
	dw .mom
	dw .bikeshop
	dw .bill
	dw .elm
	dw .lyra
	dw .buena

.none db "----------@"
.mom db "Mom:@"
.bill db "Bill:<LNBRK>   #maniac@"
.elm db "Prof.Elm:<LNBRK>   #mon Prof.@"
.bikeshop db "Miracle Cycle:@"
.lyra db "Lyra:<LNBRK>   <PK><MN> Trainer@"
.buena db "Buena:<LNBRK>   Disc Jockey@"
; 90423

Phone_GetTrainerName: ; 90423 (24:4423)
	push hl
	push bc
	farcall GetTrainerName
	pop bc
	pop hl
	ret

Phone_GetTrainerClassName: ; 9042e (24:442e)
	push hl
	push bc
	farcall GetTrainerClassName
	pop bc
	pop hl
	ret

GetCallerLocation: ; 90439
	ld a, [wCurrentCaller]
	call GetCallerTrainerClass
	ld d, c
	ld e, b
	push de
	ld a, [wCurrentCaller]
	ld hl, PhoneContacts + PHONE_CONTACT_MAP_GROUP
	ld bc, PHONE_TABLE_WIDTH
	call AddNTimes
	ld b, [hl]
	inc hl
	ld c, [hl]
	push bc
	call GetWorldMapLocation
	ld e, a
	farcall GetLandmarkName
	pop bc
	pop de
	ret
; 9045f

PhoneContacts: ; 9045f
phone: MACRO
	db  \1, \2 ; trainer
	map \3     ; map
	db  \4
	dba \5 ; script 1
	db  \6
	dba \7 ; script 2
ENDM

	phone TRAINER_NONE, PHONE_00,              N_A,                       0, UnusedPhoneScript,   0, UnusedPhoneScript
	phone TRAINER_NONE, PHONECONTACT_MOM,      KRISS_HOUSE_1F,            7, MomPhoneScript,      0, UnusedPhoneScript
	phone TRAINER_NONE, PHONECONTACT_BIKESHOP, OAKS_LAB,                  0, UnusedPhoneScript,   0, UnusedPhoneScript
	phone TRAINER_NONE, PHONECONTACT_BILL,     N_A,                       7, BillPhoneScript1,    0, BillPhoneScript2
	phone TRAINER_NONE, PHONECONTACT_ELM,      ELMS_LAB,                  7, ElmPhoneScript1,     0, ElmPhoneScript2
	phone TRAINER_NONE, PHONECONTACT_LYRA,     LYRAS_HOUSE_1F,            7, LyraPhoneScript,     0, LyraPhoneScript2
	phone SCHOOLBOY,    JACK1,                 NATIONAL_PARK,             7, JackPhoneScript1,    7, JackPhoneScript2
	phone POKEFANF,     BEVERLY1,              NATIONAL_PARK,             7, BeverlyPhoneScript1, 7, BeverlyPhoneScript2
	phone SAILOR,       HUEY1,                 OLIVINE_LIGHTHOUSE_2F,     7, HueyPhoneScript1,    7, HueyPhoneScript2
	phone TRAINER_NONE, PHONE_00,              N_A,                       0, UnusedPhoneScript,   0, UnusedPhoneScript
	phone TRAINER_NONE, PHONE_00,              N_A,                       0, UnusedPhoneScript,   0, UnusedPhoneScript
	phone COOLTRAINERM, GAVEN1,                ROUTE_26,                  7, GavenPhoneScript1,   7, GavenPhoneScript2
	phone COOLTRAINERF, BETH1,                 ROUTE_26,                  7, BethPhoneScript1,    7, BethPhoneScript2
	phone BIRD_KEEPER,  JOSE1,                 ROUTE_27,                  7, JosePhoneScript1,    7, JosePhoneScript2
	phone COOLTRAINERF, REENA1,                ROUTE_27,                  7, ReenaPhoneScript1,   7, ReenaPhoneScript2
	phone YOUNGSTER,    JOEY1,                 ROUTE_30,                  7, JoeyPhoneScript1,    7, JoeyPhoneScript2
	phone BUG_CATCHER,  WADE1,                 ROUTE_31,                  7, WadePhoneScript1,    7, WadePhoneScript2
	phone FISHER,       RALPH1,                ROUTE_32,                  7, RalphPhoneScript1,   7, RalphPhoneScript2
	phone PICNICKER,    LIZ1,                  ROUTE_32,                  7, LizPhoneScript1,     7, LizPhoneScript2
	phone HIKER,        ANTHONY1,              ROUTE_33,                  7, AnthonyPhoneScript1, 7, AnthonyPhoneScript2
	phone CAMPER,       TODD1,                 ROUTE_34,                  7, ToddPhoneScript1,    7, ToddPhoneScript2
	phone PICNICKER,    GINA1,                 ROUTE_34,                  7, GinaPhoneScript1,    7, GinaPhoneScript2
	phone JUGGLER,      IRWIN1,                ROUTE_35,                  7, IrwinPhoneScript1,   7, IrwinPhoneScript2
	phone BUG_CATCHER,  ARNIE1,                ROUTE_35,                  7, ArniePhoneScript1,   7, ArniePhoneScript2
	phone SCHOOLBOY,    ALAN1,                 ROUTE_36,                  7, AlanPhoneScript1,    7, AlanPhoneScript2
	phone TRAINER_NONE, PHONE_00,              N_A,                       0, UnusedPhoneScript,   0, UnusedPhoneScript
	phone LASS,         DANA1,                 ROUTE_38,                  7, DanaPhoneScript1,    7, DanaPhoneScript2
	phone SCHOOLBOY,    CHAD1,                 ROUTE_38,                  7, ChadPhoneScript1,    7, ChadPhoneScript2
	phone POKEFANM,     DEREK1,                ROUTE_39,                  7, DerekPhoneScript1,   7, DerekPhoneScript2
	phone FISHER,       TULLY1,                ROUTE_42,                  7, TullyPhoneScript1,   7, TullyPhoneScript2
	phone POKEMANIAC,   BRENT1,                ROUTE_43,                  7, BrentPhoneScript1,   7, BrentPhoneScript2
	phone PICNICKER,    TIFFANY1,              ROUTE_43,                  7, TiffanyPhoneScript1, 7, TiffanyPhoneScript2
	phone BIRD_KEEPER,  VANCE1,                ROUTE_44,                  7, VancePhoneScript1,   7, VancePhoneScript2
	phone FISHER,       WILTON1,               ROUTE_44,                  7, WiltonPhoneScript1,  7, WiltonPhoneScript2
	phone BLACKBELT_T,  KENJI1,                ROUTE_45,                  7, KenjiPhoneScript1,   7, KenjiPhoneScript2
	phone HIKER,        PARRY1,                ROUTE_45,                  7, ParryPhoneScript1,   7, ParryPhoneScript2
	phone PICNICKER,    ERIN1,                 ROUTE_46,                  7, ErinPhoneScript1,    7, ErinPhoneScript2
	phone TRAINER_NONE, PHONECONTACT_BUENA,    GOLDENROD_DEPT_STORE_ROOF, 7, BuenaPhoneScript1,   7, BuenaPhoneScript2
; 90627

SpecialPhoneCallList: ; 90627
	; SPECIALCALL_POKERUS
	dw SpecialCallOnlyWhenOutside
	db PHONE_ELM
	dba ElmPhoneScript2

	; SPECIALCALL_ROBBED
	dw SpecialCallOnlyWhenOutside
	db PHONE_ELM
	dba ElmPhoneScript2

	; SPECIALCALL_ASSISTANT
	dw SpecialCallOnlyWhenOutside
	db PHONE_ELM
	dba ElmPhoneScript2

	; SPECIALCALL_WEIRDBROADCAST
	dw SpecialCallOnlyWhenOutside
	db PHONE_ELM
	dba ElmPhoneScript2

	; SPECIALCALL_SSTICKET
	dw SpecialCallWhereverYouAre
	db PHONE_ELM
	dba ElmPhoneScript2

	; SPECIALCALL_BIKESHOP
	dw SpecialCallWhereverYouAre
	db PHONE_OAK ; ????????
	dba BikeShopPhoneScript ; bike shop

	; SPECIALCALL_WORRIED
	dw SpecialCallWhereverYouAre
	db PHONE_MOM
	dba MomPhoneLectureScript

	; SPECIALCALL_MASTERBALL
	dw SpecialCallOnlyWhenOutside
	db PHONE_ELM
	dba ElmPhoneScript2

	; SPECIALCALL_YELLOWFOREST
	dw SpecialCallOnlyWhenOutside
	db PHONE_LYRA
	dba LyraPhoneScript2

	; SPECIALCALL_FIRSTBADGE
	dw SpecialCallOnlyWhenOutside
	db PHONE_LYRA
	dba LyraPhoneScript2

	; SPECIALCALL_SECONDBADGE
	dw SpecialCallOnlyWhenOutside
	db PHONE_BILL
	dba BillPhoneScript2

	; SPECIALCALL_LYRASEGG
	dw SpecialCallOnlyWhenOutside
	db PHONE_LYRA
	dba LyraPhoneScript2
; 90657

UnknownScript_0x90657: ; 0x90657
	writetext UnknownText_0x9065b
	end
; 0x9065b

UnknownText_0x9065b: ; 0x9065b
	; That number is out of the area.
	text_jump UnknownText_0x1c558b
	db "@"
; 0x90660

PhoneScript_JustTalkToThem: ; 0x90660
	writetext UnknownText_0x90664
	end
; 0x90664

UnknownText_0x90664: ; 0x90664
	; Just go talk to that person!
	text_jump UnknownText_0x1c55ac
	db "@"
; 0x90669
