	const_def
	const MARTTEXT_HOW_MANY
	const MARTTEXT_COSTS_THIS_MUCH
	const MARTTEXT_NOT_ENOUGH_MONEY
	const MARTTEXT_BAG_FULL
	const MARTTEXT_HERE_YOU_GO
	const MARTTEXT_SOLD_OUT

OpenMartDialog:: ; 15a45
	call GetMart
	ld a, c
	ld [EngineBuffer1], a
	call LoadMartPointer
	ld a, [EngineBuffer1]
	ld hl, .dialogs
	rst JumpTable
	ret
; 15a57

.dialogs
	dw MartDialog
	dw HerbShop
	dw BargainShop
	dw Pharmacist
	dw RooftopSale
	dw AdventurerMart
	dw InformalMart
	dw TMMart
; 15a61

MartDialog: ; 15a61
	xor a
	ld [EngineBuffer1], a
	ld [EngineBuffer5], a
	jp StandardMart
; 15a6e

HerbShop: ; 15a6e
	call FarReadMart
	call LoadStandardMenuDataHeader
	ld hl, Text_HerbShop_Intro
	call MartTextBox
	call BuyMenu
	ld hl, Text_HerbShop_ComeAgain
	jp MartTextBox
; 15a84

BargainShop: ; 15a84
	ld b, BANK(BargainShopData)
	ld de, BargainShopData
	call LoadMartPointer
	call ReadMart
	call LoadStandardMenuDataHeader
	ld hl, Text_BargainShop_Intro
	call MartTextBox
	call BuyMenu
	ld hl, wBargainShopFlags
	ld a, [hli]
	or [hl]
	jr z, .skip_set
	ld hl, DailyFlags ; ENGINE_GOLDENROD_UNDERGROUND_MERCHANT_CLOSED
	set 6, [hl]

.skip_set
	ld hl, Text_BargainShop_ComeAgain
	jp MartTextBox
; 15aae

Pharmacist: ; 15aae
	call FarReadMart
	call LoadStandardMenuDataHeader
	ld hl, Text_Pharmacist_Intro
	call MartTextBox
	call BuyMenu
	ld hl, Text_Pharmacist_ComeAgain
	jp MartTextBox
; 15ac4

RooftopSale: ; 15ac4
	ld b, BANK(RooftopSaleData1)
	ld de, RooftopSaleData1
	ld hl, StatusFlags
	bit 6, [hl] ; hall of fame
	jr z, .ok
	ld b, BANK(RooftopSaleData2)
	ld de, RooftopSaleData2

.ok
	call LoadMartPointer
	call ReadMart
	call LoadStandardMenuDataHeader
	ld hl, Text_Mart_HowMayIHelpYou
	call MartTextBox
	call BuyMenu
	ld hl, Text_Mart_ComeAgain
	jp MartTextBox
; 15aee

AdventurerMart:
	call FarReadMart
	call LoadStandardMenuDataHeader
	ld hl, Text_AdventurerMart_Intro
	call MartTextBox
	call BuyMenu
	ld hl, Text_AdventurerMart_ComeAgain
	jp MartTextBox

InformalMart:
	call FarReadMart
	call LoadStandardMenuDataHeader
	ld hl, Text_InformalMart_Intro
	call MartTextBox
	call BuyMenu
	ld hl, Text_InformalMart_ComeAgain
	jp MartTextBox

TMMart:
	call FarReadTMMart
	call LoadStandardMenuDataHeader
	ld hl, Text_Mart_HowMayIHelpYou
	call MartTextBox
	call BuyTMMenu
	ld hl, Text_Mart_ComeAgain
	jp MartTextBox

RooftopSaleData1: ; 15aee
	db 5
	dbw POKE_BALL,     150
	dbw GREAT_BALL,    500
	dbw SUPER_POTION,  500
	dbw FULL_HEAL,     300
	dbw REVIVE,       1200
	db -1
RooftopSaleData2: ; 15aff
	db 5
	dbw HYPER_POTION, 1000
	dbw FULL_RESTORE, 2000
	dbw FULL_HEAL,     300
	dbw ULTRA_BALL,    600
	dbw PROTEIN,      8000
	db -1
; 15b10

LoadMartPointer: ; 15b10
	ld a, b
	ld [MartPointerBank], a
	ld a, e
	ld [MartPointer], a
	ld a, d
	ld [MartPointer + 1], a
	ld hl, CurMart
	xor a
	ld bc, 16
	call ByteFill
	xor a
	ld [EngineBuffer5], a
	ld [wBargainShopFlags], a
	ld [FacingDirection], a
	ret
; 15b31

GetMart: ; 15b31
	ld hl, Marts
rept 2
	add hl, de
endr
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld b, BANK(Marts)
	ret
; 15b47

StandardMart: ; 15b47
.loop
	ld a, [EngineBuffer5]
	ld hl, .MartFunctions
	rst JumpTable
	ld [EngineBuffer5], a
	cp $ff
	jr nz, .loop
	ret

.MartFunctions:
	dw .HowMayIHelpYou
	dw .TopMenu
	dw .Buy
	dw .Sell
	dw .Quit
	dw .AnythingElse
; 15b62

.HowMayIHelpYou: ; 15b62
	call LoadStandardMenuDataHeader
	ld hl, Text_Mart_HowMayIHelpYou
	call PrintText
	ld a, $1 ; top menu
	ret
; 15b6e

.TopMenu: ; 15b6e
	ld hl, MenuDataHeader_BuySell
	call CopyMenuDataHeader
	call VerticalMenu
	jr c, .quit
	ld a, [wMenuCursorY]
	cp $1
	jr z, .buy
	cp $2
	jr z, .sell
.quit
	ld a, $4 ;  Come again!
	ret
.buy
	ld a, $2 ; buy
	ret
.sell
	ld a, $3 ; sell
	ret
; 15b8d

.Buy: ; 15b8d
	call ExitMenu
	call FarReadMart
	call BuyMenu
	and a
	ld a, $5 ; Anything else?
	ret
; 15b9a

.Sell: ; 15b9a
	call ExitMenu
	call SellMenu
	ld a, $5 ; Anything else?
	ret
; 15ba3

.Quit: ; 15ba3
	call ExitMenu
	ld hl, Text_Mart_ComeAgain
	call MartTextBox
	ld a, $ff ; exit
	ret
; 15baf

.AnythingElse: ; 15baf
	call LoadStandardMenuDataHeader
	ld hl, Text_Mart_AnythingElse
	call PrintText
	ld a, $1 ; top menu
	ret
; 15bbb

FarReadMart: ; 15bbb
	ld hl, MartPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, CurMart
.CopyMart:
	ld a, [MartPointerBank]
	call GetFarByte
	ld [de], a
	inc hl
	inc de
	cp -1
	jr nz, .CopyMart
	ld hl, wMartItem1BCD
	ld de, CurMart + 1
.ReadMartItem:
	ld a, [de]
	inc de
	cp -1
	ret z
	push de
	call GetMartItemPrice
	pop de
	jr .ReadMartItem
; 15be5

FarReadTMMart:
; Load the mart pointer.  Mart data is local (no need for bank).
	ld hl, MartPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
; set hl to the first item
	inc hl
	ld bc, wMartItem1BCD
	ld de, CurMart + 1
.loop
; copy the item to CurMart + (ItemIndex)
	ld a, [MartPointerBank]
	call GetFarByte
	inc hl
	ld [de], a
	inc de
; -1 is the terminator
	cp -1
	jr z, .done

	push de
; copy the price to de
	ld a, [MartPointerBank]
	call GetFarByte
	inc hl
	ld e, a
	ld a, [MartPointerBank]
	call GetFarByte
	inc hl
	ld d, a
; convert the price to 3-byte BCD at [bc]
	push hl
	ld h, b
	ld l, c
	call GetMartPrice
	ld b, h
	ld c, l
	pop hl

	pop de
	jr .loop

.done
	pop hl
	ld a, [MartPointerBank]
	call GetFarByte
	ld [CurMart], a
	ret

GetMartItemPrice: ; 15be5
; Return the price of item a in BCD at hl and in tiles at StringBuffer1.
	push hl
	ld [CurItem], a
	farcall GetItemPrice
	pop hl

GetMartPrice: ; 15bf0
; Return price de in BCD at hl and in tiles at StringBuffer1.
	push hl
	ld a, d
	ld [StringBuffer2], a
	ld a, e
	ld [StringBuffer2 + 1], a
	ld hl, StringBuffer1
	ld de, StringBuffer2
	lb bc, PRINTNUM_LEADINGZEROS | 2, 6 ; 6 digits
	call PrintNum
	pop hl

	ld de, StringBuffer1
	ld c, 6 / 2 ; 6 digits
.loop
	call .CharToNybble
	swap a
	ld b, a
	call .CharToNybble
	or b
	ld [hli], a
	dec c
	jr nz, .loop
	ret
; 15c1a

.CharToNybble: ; 15c1a
	ld a, [de]
	inc de
	cp " "
	jr nz, .not_space
	ld a, "0"

.not_space
	sub "0"
	ret
; 15c25

ReadMart: ; 15c25
; Load the mart pointer.  Mart data is local (no need for bank).
	ld hl, MartPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
; set hl to the first item
	inc hl
	ld bc, wMartItem1BCD
	ld de, CurMart + 1
.loop
; copy the item to CurMart + (ItemIndex)
	ld a, [hli]
	ld [de], a
	inc de
; -1 is the terminator
	cp -1
	jr z, .done

	push de
; copy the price to de
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
; convert the price to 3-byte BCD at [bc]
	push hl
	ld h, b
	ld l, c
	call GetMartPrice
	ld b, h
	ld c, l
	pop hl

	pop de
	jr .loop

.done
	pop hl
	ld a, [hl]
	ld [CurMart], a
	ret
; 15c51

BargainShopData: ; 15c51
	db 5
	dbw NUGGET,     4500
	dbw PEARL,       650
	dbw BIG_PEARL,  3500
	dbw STARDUST,    900
	dbw STAR_PIECE, 4600
	db -1
; 15c62


BuyMenu: ; 15c62
	call BuyMenu_InitGFX
	xor a
	ld [wMenuScrollPositionBackup], a
	ld a, 1
	ld [wMenuCursorBufferBackup], a
.loop
	call BuyMenuLoop ; menu loop
	jr nc, .loop
	call ReturnToMapWithSpeechTextbox
	and a
	ret
; 15c7d

BuyTMMenu:
	call BuyMenu_InitGFX
	farcall LoadTMHMIcon
	xor a
	ld [wMenuScrollPositionBackup], a
	ld a, 1
	ld [wMenuCursorBufferBackup], a
.loop
	call BuyTMMenuLoop ; menu loop
	jr nc, .loop
	call ReturnToMapWithSpeechTextbox
	and a
	ret

BuyMenu_InitGFX:
	xor a
	ld [hBGMapMode], a
	farcall FadeOutPalettes
	call ClearBGPalettes
	call ClearTileMap
	call ClearSprites
	call DisableSpriteUpdates
	call DisableLCD
	ld hl, PackLeftColumnGFX
	ld de, VTiles2 tile $0e
	ld bc, 18 tiles
	ld a, BANK(PackLeftColumnGFX)
	call FarCopyBytes
; This is where the items themselves will be listed.
;	hlcoord 5, 3
;	lb bc, 9, 15
;	call ClearBox
; Place the text box for bag quantity
	hlcoord 0, 0
	lb bc, 1, 8
	call TextBox
; Place the left column
	hlcoord 0, 3
	ld de, .BuyLeftColumnTilemapString
	ld bc, SCREEN_WIDTH - 5
.loop
	ld a, [de]
	and a
	jr nz, .continue
	add hl, bc
	jr .next
.continue
	cp $ff
	jr z, .ok
	ld [hli], a
.next
	inc de
	jr .loop
.ok
; Place the textbox for displaying the item description
;	hlcoord 0, SCREEN_HEIGHT - 4 - 2
;	lb bc, 4, SCREEN_WIDTH - 2
;	call TextBox
	call EnableLCD
	call WaitBGMap
	ld b, SCGB_BUYMENU_PALS
	call GetSGBLayout
	call SetPalettes
	jp DelayFrame

.BuyLeftColumnTilemapString:
	db $0e, $0e, $0e, $0e, $0e, $00
	db $0e, $0e, $0e, $0e, $0e, $00
	db $0e, $0e, $0e, $0e, $0e, $00
	db $0e, $0e, $0e, $0e, $0e, $00
	db $0f, $10, $10, $10, $11, $00
	db $12, $17, $18, $19, $13, $00
	db $12, $1a, $1b, $1c, $13, $00
	db $12, $1d, $1e, $1f, $13, $00
	db $14, $15, $15, $15, $16, $ff

LoadBuyMenuText: ; 15c7d
; load text from a nested table
; which table is in EngineBuffer1
; which entry is in register a
	push af
	call GetMartDialogGroup ; gets a pointer from GetMartDialogGroup.MartTextFunctionPointers
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	ld e, a
	ld d, 0
rept 2
	add hl, de
endr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp PrintText
; 15c91

MartAskPurchaseQuantity: ; 15c91
	ld a, [CurItem]
	call GetMartDialogGroup ; gets a pointer from GetMartDialogGroup.MartTextFunctionPointers
rept 2
	inc hl
endr
	ld a, [hl]
	and a
	jp z, StandardMartAskPurchaseQuantity
	cp 1
	jp z, BargainShopAskPurchaseQuantity
	jp RooftopSaleAskPurchaseQuantity
; 15ca3

GetMartDialogGroup: ; 15ca3
	ld a, [EngineBuffer1]
	ld e, a
	ld d, 0
	ld hl, .MartTextFunctionPointers
rept 3
	add hl, de
endr
	ret
; 15cb0

.MartTextFunctionPointers: ; 15cb0
	dwb .StandardMartPointers, 0
	dwb .HerbShopPointers, 0
	dwb .BargainShopPointers, 1
	dwb .PharmacyPointers, 0
	dwb .StandardMartPointers, 2
	dwb .AdventurerMartPointers, 2
	dwb .InformalMartPointers, 0
	dwb .TMMartPointers, 0
; 15cbf

.StandardMartPointers: ; 15cbf
	dw Text_Mart_HowMany
	dw Text_Mart_CostsThisMuch
	dw Text_Mart_InsufficientFunds
	dw Text_Mart_BagFull
	dw Text_Mart_HereYouGo
	dw BuyMenuLoop

.HerbShopPointers: ; 15ccb
	dw Text_HerbShop_HowMany
	dw Text_HerbShop_CostsThisMuch
	dw Text_HerbShop_InsufficientFunds
	dw Text_HerbShop_BagFull
	dw Text_HerbShop_HereYouGo
	dw BuyMenuLoop

.BargainShopPointers: ; 15cd7
	dw BuyMenuLoop
	dw Text_BargainShop_CostsThisMuch
	dw Text_BargainShop_InsufficientFunds
	dw Text_BargainShop_BagFull
	dw Text_BargainShop_HereYouGo
	dw Text_BargainShop_SoldOut

.PharmacyPointers: ; 15ce3
	dw Text_Pharmacy_HowMany
	dw Text_Pharmacy_CostsThisMuch
	dw Text_Pharmacy_InsufficientFunds
	dw Text_Pharmacy_BagFull
	dw Text_Pharmacy_HereYouGo
	dw BuyMenuLoop
; 15cef

.AdventurerMartPointers:
	dw Text_AdventurerMart_HowMany
	dw Text_AdventurerMart_CostsThisMuch
	dw Text_AdventurerMart_InsufficientFunds
	dw Text_AdventurerMart_BagFull
	dw Text_AdventurerMart_HereYouGo
	dw BuyMenuLoop

.InformalMartPointers:
	dw Text_InformalMart_HowMany
	dw Text_InformalMart_CostsThisMuch
	dw Text_InformalMart_InsufficientFunds
	dw Text_InformalMart_BagFull
	dw Text_InformalMart_HereYouGo
	dw BuyMenuLoop

.TMMartPointers:
	dw Text_Mart_HowMany
	dw Text_TMMart_CostsThisMuch
	dw Text_Mart_InsufficientFunds
	dw Text_Mart_BagFull
	dw Text_Mart_HereYouGo
	dw BuyTMMenuLoop


BuyMenuLoop: ; 15cef
	farcall PlaceMoneyTopRight
	call UpdateSprites
	ld hl, MenuDataHeader_Buy
	call CopyMenuDataHeader
	ld a, [wMenuCursorBufferBackup]
	ld [wMenuCursorBuffer], a
	ld a, [wMenuScrollPositionBackup]
	ld [wMenuScrollPosition], a
	call ScrollingMenu
	ld a, [wMenuScrollPosition]
	ld [wMenuScrollPositionBackup], a
	ld a, [wMenuCursorY]
	ld [wMenuCursorBufferBackup], a
	call SpeechTextBox
	ld a, [wMenuJoypad]
	cp B_BUTTON
	jr z, .set_carry
	call MartAskPurchaseQuantity
	jr c, .cancel
	call MartConfirmPurchase
	jr c, .cancel
	ld de, Money
	ld bc, hMoneyTemp
	call CompareMoney
	jr c, .insufficient_funds
	ld hl, NumItems
	call ReceiveItem
	jr nc, .insufficient_bag_space
	ld a, [wMartItemID]
	ld e, a
	ld d, $0
	ld b, SET_FLAG
	ld hl, wBargainShopFlags
	call FlagAction
	call PlayTransactionSound
	ld de, Money
	ld bc, hMoneyTemp
	call TakeMoney
	ld a, MARTTEXT_HERE_YOU_GO
	call LoadBuyMenuText
	call JoyWaitAorB
	farcall CheckItemPocket
	ld a, [wItemAttributeParamBuffer]
	cp BALL
	jr nz, .cancel
	ld a, [wItemQuantityChangeBuffer]
	cp 10
	jr c, .cancel
	ld a, PREMIER_BALL
	ld [CurItem], a
	ld a, [wItemQuantityChangeBuffer]
	ld c, 10
	call SimpleDivide
	ld a, b
	ld [wItemQuantityChangeBuffer], a
	ld hl, NumItems
	call ReceiveItem
	jr nc, .cancel
	ld hl, .PremierBallText
	call PrintText
	call JoyWaitAorB

.cancel
	call SpeechTextBox
	and a
	ret

.set_carry
	scf
	ret

.insufficient_bag_space
	ld a, MARTTEXT_BAG_FULL
	call LoadBuyMenuText
	call JoyWaitAorB
	and a
	ret

.insufficient_funds
	ld a, MARTTEXT_NOT_ENOUGH_MONEY
	call LoadBuyMenuText
	call JoyWaitAorB
	and a
	ret
; 15d83

.PremierBallText
	text_jump MartPremierBallText
	db "@"

BuyTMMenuLoop:
	farcall PlaceMoneyTopRight
	call UpdateSprites
	ld hl, TMMenuDataHeader_Buy
	call CopyMenuDataHeader
	ld a, [wMenuCursorBufferBackup]
	ld [wMenuCursorBuffer], a
	ld a, [wMenuScrollPositionBackup]
	ld [wMenuScrollPosition], a
	call ScrollingMenu
	ld a, [wMenuScrollPosition]
	ld [wMenuScrollPositionBackup], a
	ld a, [wMenuCursorY]
	ld [wMenuCursorBufferBackup], a
	call SpeechTextBox
	ld a, [wMenuJoypad]
	cp B_BUTTON
	jr z, .set_carry
	cp A_BUTTON
	call TMMartAskPurchaseQuantity
	jr c, .cancel
	call TMMartConfirmPurchase
	jr c, .cancel
	ld de, Money
	ld bc, hMoneyTemp
	call CompareMoney
	jr c, .insufficient_funds
	call ReceiveTMHM
	call PlayTransactionSound
	ld de, Money
	ld bc, hMoneyTemp
	call TakeMoney
	ld a, MARTTEXT_HERE_YOU_GO
	call LoadBuyMenuText
	call JoyWaitAorB

.cancel
	call SpeechTextBox
	and a
	ret

.set_carry
	scf
	ret

.insufficient_funds
	ld a, MARTTEXT_NOT_ENOUGH_MONEY
	call LoadBuyMenuText
	call JoyWaitAorB
	and a
	ret

StandardMartAskPurchaseQuantity:
	ld a, MARTTEXT_HOW_MANY
	call LoadBuyMenuText
	farcall SelectQuantityToBuy
	jp ExitMenu
; 15d97

MartConfirmPurchase: ; 15d97
	predef PartyMonItemName
	ld a, MARTTEXT_COSTS_THIS_MUCH
	call LoadBuyMenuText
	jp YesNoBox
; 15da5

TMMartConfirmPurchase:
	ld a, [CurTMHM]
	ld [wd265], a
	call GetTMHMName
	call CopyName1

	; off by one error?
	ld a, [wd265]
	inc a
	ld [wd265], a

	predef GetTMHMMove
	ld a, [wd265]
	ld [wPutativeTMHMMove], a
	call GetMoveName

	ld a, MARTTEXT_COSTS_THIS_MUCH
	call LoadBuyMenuText
	jp YesNoBox

BargainShopAskPurchaseQuantity:
	ld a, 1
	ld [wItemQuantityChangeBuffer], a
	ld a, [wMartItemID]
	ld e, a
	ld d, $0
	ld b, CHECK_FLAG
	ld hl, wBargainShopFlags
	call FlagAction
	ld a, c
	and a
	jr nz, .SoldOut
	ld a, [wMartItemID]
	ld e, a
	ld d, $0
	ld hl, MartPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl
rept 3
	add hl, de
endr
	inc hl
	ld a, [hli]
	ld [hMoneyTemp + 2], a
	ld a, [hl]
	ld [hMoneyTemp + 1], a
	xor a
	ld [hMoneyTemp], a
	and a
	ret

.SoldOut:
	ld a, MARTTEXT_SOLD_OUT
	call LoadBuyMenuText
	call JoyWaitAorB
	scf
	ret
; 15de2

RooftopSaleAskPurchaseQuantity:
	ld a, MARTTEXT_HOW_MANY
	call LoadBuyMenuText
	call .GetSalePrice
	farcall RooftopSale_SelectQuantityToBuy
	jp ExitMenu
; 15df9

.GetSalePrice: ; 15df9
	ld a, [wMartItemID]
	ld e, a
	ld d, 0
	ld hl, MartPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl
rept 3
	add hl, de
endr
	inc hl
	ld e, [hl]
	inc hl
	ld d, [hl]
	ret
; 15e0e

TMMartAskPurchaseQuantity:
	ld a, [CurTMHM]
	call CheckTMHM
	jr c, .AlreadyHaveTM

	ld a, 1
	ld [wItemQuantityChangeBuffer], a
	ld a, [wMartItemID]
	ld e, a
	ld d, $0
	ld hl, MartPointer
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc hl
rept 3
	add hl, de
endr
	inc hl
	ld a, [hli]
	ld [hMoneyTemp + 2], a
	ld a, [hl]
	ld [hMoneyTemp + 1], a
	xor a
	ld [hMoneyTemp], a
	and a
	ret

.AlreadyHaveTM
	ld hl, .AlreadyHaveTMText
	call PrintText
	call JoyWaitAorB
	scf
	ret

.AlreadyHaveTMText
	text_jump AlreadyHaveTMText
	db "@"


Text_Mart_HowMany: ; 0x15e0e
	; How many?
	text_jump UnknownText_0x1c4bfd
	db "@"
; 0x15e13

Text_Mart_CostsThisMuch: ; 0x15e13
Text_AdventurerMart_CostsThisMuch:
	; @ (S) will be ¥@ .
	text_jump UnknownText_0x1c4c08
	db "@"
; 0x15e18

MenuDataHeader_Buy: ; 0x15e18
	db $40 ; flags
	db 03, 06 ; start coords
	db 11, 19 ; end coords
	dw .menudata2
	db 1 ; default option
; 0x15e20

.menudata2 ; 0x15e20
	db $30 ; pointers
	db 4, 8 ; rows, columns
	db 1 ; horizontal spacing
	dbw 0, CurMart
	dba PlaceMenuItemName
	dba .PrintBCDPrices
	dba UpdateItemIconAndDescriptionAndBagQuantity
; 15e30

.PrintBCDPrices: ; 15e30
	ld a, [wScrollingMenuCursorPosition]
	ld c, a
	ld b, 0
	ld hl, wMartItem1BCD
rept 3
	add hl, bc
endr
	push de
	ld d, h
	ld e, l
	pop hl
	ld bc, SCREEN_WIDTH - 5
	add hl, bc
	ld c, PRINTNUM_LEADINGZEROS | PRINTNUM_MONEY | 3
	jp PrintBCDNumber
; 15e4a (5:5e4a)

TMMenuDataHeader_Buy:
	db $40 ; flags
	db 03, 06 ; start coords
	db 11, 19 ; end coords
	dw .menudata2
	db 1 ; default option
; 0x15e20

.menudata2 ; 0x15e20
	db $30 ; pointers
	db 4, 8 ; rows, columns
	db 1 ; horizontal spacing
	dbw 0, CurMart
	dba PlaceMenuTMHMName
	dba .PrintBCDPrices
	dba UpdateTMHMIconAndDescriptionAndOwnership
; 15e30

.PrintBCDPrices: ; 15e30
	ld a, [wScrollingMenuCursorPosition]
	ld c, a
	ld b, 0
	ld hl, wMartItem1BCD
rept 3
	add hl, bc
endr
	push de
	ld d, h
	ld e, l
	pop hl
	ld bc, SCREEN_WIDTH - 5
	add hl, bc
	ld c, PRINTNUM_LEADINGZEROS | PRINTNUM_MONEY | 3
	jp PrintBCDNumber

Text_HerbShop_Intro: ; 0x15e4a
	; Hello, dear. I sell inexpensive herbal medicine. They're good, but a trifle bitter. Your #MON may not like them. Hehehehe…
	text_jump UnknownText_0x1c4c28
	db "@"
; 0x15e4f

Text_HerbShop_HowMany: ; 0x15e4f
	; How many?
	text_jump UnknownText_0x1c4ca3
	db "@"
; 0x15e54

Text_HerbShop_CostsThisMuch: ; 0x15e54
	; @ (S) will be ¥@ .
	text_jump UnknownText_0x1c4cae
	db "@"
; 0x15e59

Text_HerbShop_HereYouGo: ; 0x15e59
	; Thank you, dear. Hehehehe…
	text_jump UnknownText_0x1c4cce
	db "@"
; 0x15e5e

Text_HerbShop_BagFull: ; 0x15e5e
	; Oh? Your PACK is full, dear.
	text_jump UnknownText_0x1c4cea
	db "@"
; 0x15e63

Text_HerbShop_InsufficientFunds: ; 0x15e63
	; Hehehe… You don't have the money.
	text_jump UnknownText_0x1c4d08
	db "@"
; 0x15e68

Text_HerbShop_ComeAgain: ; 0x15e68
	; Come again, dear. Hehehehe…
	text_jump UnknownText_0x1c4d2a
	db "@"
; 0x15e6d

Text_BargainShop_Intro: ; 0x15e6d
	; Hiya! Care to see some bargains? I sell rare items that nobody else carries--but only one of each item.
	text_jump UnknownText_0x1c4d47
	db "@"
; 0x15e72

Text_BargainShop_CostsThisMuch: ; 0x15e72
	; costs ¥@ . Want it?
	text_jump UnknownText_0x1c4db0
	db "@"
; 0x15e77

Text_BargainShop_HereYouGo: ; 0x15e77
Text_AdventurerMart_HereYouGo:
	; Thanks.
	text_jump UnknownText_0x1c4dcd
	db "@"
; 0x15e7c

Text_BargainShop_BagFull: ; 0x15e7c
Text_AdventurerMart_BagFull:
	; Uh-oh, your PACK is chock-full.
	text_jump UnknownText_0x1c4dd6
	db "@"
; 0x15e81

Text_BargainShop_SoldOut: ; 0x15e81
	; You bought that already. I'm all sold out of it.
	text_jump UnknownText_0x1c4df7
	db "@"
; 0x15e86

Text_BargainShop_InsufficientFunds: ; 0x15e86
Text_AdventurerMart_InsufficientFunds:
	; Uh-oh, you're short on funds.
	text_jump UnknownText_0x1c4e28
	db "@"
; 0x15e8b

Text_BargainShop_ComeAgain: ; 0x15e8b
	; Come by again sometime.
	text_jump UnknownText_0x1c4e46
	db "@"
; 0x15e90

Text_Pharmacist_Intro: ; 0x15e90
	; What's up? Need some medicine?
	text_jump UnknownText_0x1c4e5f
	db "@"
; 0x15e95

Text_Pharmacy_HowMany: ; 0x15e95
Text_AdventurerMart_HowMany:
Text_InformalMart_HowMany:
	; How many?
	text_jump UnknownText_0x1c4e7e
	db "@"
; 0x15e9a

Text_Pharmacy_CostsThisMuch: ; 0x15e9a
Text_InformalMart_CostsThisMuch:
	; @ (S) will cost ¥@ .
	text_jump UnknownText_0x1c4e89
	db "@"
; 0x15e9f

Text_Pharmacy_HereYouGo: ; 0x15e9f
Text_InformalMart_HereYouGo:
	; Thanks much!
	text_jump UnknownText_0x1c4eab
	db "@"
; 0x15ea4

Text_Pharmacy_BagFull: ; 0x15ea4
Text_InformalMart_BagFull:
	; You don't have any more space.
	text_jump UnknownText_0x1c4eb9
	db "@"
; 0x15ea9

Text_Pharmacy_InsufficientFunds: ; 0x15ea9
Text_InformalMart_InsufficientFunds:
	; Huh? That's not enough money.
	text_jump UnknownText_0x1c4ed8
	db "@"
; 0x15eae

Text_Pharmacist_ComeAgain: ; 0x15eae
Text_InformalMart_ComeAgain:
	; All right. See you around.
	text_jump UnknownText_0x1c4ef6
	db "@"
; 0x15eb3

Text_AdventurerMart_Intro:
	text_jump AdventurerMartIntroText
	db "@"

Text_AdventurerMart_ComeAgain:
	; Come by again!
	text_jump AdventurerMartComeAgainText
	db "@"

Text_InformalMart_Intro:
	; What's up? Need some supplies?
	text_jump InformalMartIntroText
	db "@"

Text_TMMart_CostsThisMuch:
	; @  @  will be ¥@ .
	text_jump TMMartCostsThisMuchText
	db "@"


SellMenu: ; 15eb3
	call DisableSpriteUpdates
	farcall DepositSellInitPackBuffers
.loop
	farcall DepositSellPack
	ld a, [wcf66]
	and a
	jp z, .quit
	call .TryToSellItem
	jr .loop

.quit
	call ReturnToMapWithSpeechTextbox
	and a
	ret
; 15ed3

.TryToSellItem: ; 15ee0
	ld a, [wCurrPocket]
	cp TM_HM - 1
	jr z, .cant_sell_tm
	farcall CheckItemMenu
	ld a, [wItemAttributeParamBuffer]
	ld hl, .dw
	rst JumpTable
	ret
; 15eee

.dw ; 15eee
	dw .try_sell
	dw .cant_buy
	dw .cant_buy
	dw .cant_buy
	dw .try_sell
	dw .try_sell
	dw .try_sell
; 15efc

.try_sell ; 15efd
	farcall _CheckTossableItem
	ld a, [wItemAttributeParamBuffer]
	and a
	jr z, .okay_to_sell
.cant_sell_tm
	ld hl, TextMart_CantBuyFromYou
	call PrintText
	and a
.cant_buy ; 15efc
	ret

.okay_to_sell
	ld hl, Text_Mart_SellHowMany
	call PrintText
	farcall PlaceMoneyAtTopLeftOfTextbox
	farcall SelectQuantityToSell
	call ExitMenu
	jr c, .declined
	hlcoord 1, 14
	lb bc, 3, 18
	call ClearBox
	ld hl, Text_Mart_ICanPayThisMuch
	call PrintTextBoxText
	call YesNoBox
	jr c, .declined
	ld de, Money
	ld bc, hMoneyTemp
	call GiveMoney
	ld a, [wMartItemID]
	ld hl, NumItems
	call TossItem
	predef PartyMonItemName
	hlcoord 1, 14
	lb bc, 3, 18
	call ClearBox
	ld hl, Text_Mart_SoldForAmount
	call PrintTextBoxText
	call PlayTransactionSound
	farcall PlaceMoneyBottomLeft
	call JoyWaitAorB

.declined
	call ExitMenu
	and a
	ret
; 15f73

Text_Mart_SellHowMany: ; 0x15f73
	; How many?
	text_jump UnknownText_0x1c4f33
	db "@"
; 0x15f78

Text_Mart_ICanPayThisMuch: ; 0x15f78
	; I can pay you ¥@ . Is that OK?
	text_jump UnknownText_0x1c4f3e
	db "@"
; 0x15f7d

Text_Mart_HowMayIHelpYou: ; 0x15f83
	; Welcome! How may I help you?
	text_jump UnknownText_0x1c4f62
	db "@"
; 0x15f88

MenuDataHeader_BuySell: ; 0x15f88
	db $40 ; flags
	db 00, 00 ; start coords
	db 08, 07 ; end coords
	dw .menudata2
	db 1 ; default option
; 0x15f90

.menudata2 ; 0x15f90
	db $80 ; strings
	db 3 ; items
	db "Buy@"
	db "Sell@"
	db "Quit@"
; 0x15f96

Text_Mart_HereYouGo: ; 0x15fa0
	; Here you are. Thank you!
	text_jump UnknownText_0x1c4f80
	db "@"
; 0x15fa5

Text_Mart_InsufficientFunds: ; 0x15fa5
	; You don't have enough money.
	text_jump UnknownText_0x1c4f9a
	db "@"
; 0x15faa

Text_Mart_BagFull: ; 0x15faa
	; You can't carry any more items.
	text_jump UnknownText_0x1c4fb7
	db "@"
; 0x15faf

TextMart_CantBuyFromYou: ; 0x15faf
	; Sorry, I can't buy that from you.
	text_jump UnknownText_0x1c4fd7
	db "@"
; 0x15fb4

Text_Mart_ComeAgain: ; 0x15fb4
	; Please come again!
	text_jump UnknownText_0x1c4ff9
	db "@"
; 0x15fb9

Text_Mart_AnythingElse: ; 0x15fb9
	text_jump UnknownText_0x1c500d
	db "@"
; 0x15fbe

Text_Mart_SoldForAmount: ; 0x15fbe
	text_jump UnknownText_0x1c502e
	db "@"
; 0x15fc3

PlayTransactionSound: ; 15fc3
	call WaitSFX
	ld de, SFX_TRANSACTION
	jp PlaySFX
; 15fcd

MartTextBox: ; 15fcd
	call MenuTextBox
	call JoyWaitAorB
	jp ExitMenu
; 15fd7
