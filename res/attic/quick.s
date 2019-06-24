!cpu 6502
!to "quick#061000",plain
*=$1000

zpword	=	$0 ;and $1
zpstring=	$2 ;and $3
runningscore=	$4 ;and $5
startat	=	$6
i	=	$7
tmp	=	$8

jsr quick
tax
lda #0
jmp $ed24 ;hex to dec

quick

	lda	#<word
	sta	zpword
	lda	#>word
	sta	zpword+1
	lda	#<string
	sta	zpstring
	lda	#>string
	sta	zpstring+1
	ldy	word
	cpy	string
	bne	+
-	lda	(zpword), y
	cmp	(zpstring), y
	bne	+
	dey
	bne	-
	lda	#100
	rts

+	lda	#0
	sta	runningscore
	sta	runningscore+1
	ldy	#1
	sty	startat
-	sty	i
	lda	(zpword), y
	jsr	tolower
	sta	tmp
	ldy	startat
--	lda	(zpstring), y
	jsr	tolower
	cmp	tmp
	beq	+
	cpy	string
	iny
	bcc	--
	lda	#0
	rts

+	ldx	#80
	cpy	startat
	beq	+
	ldx	#10
	cpy     #1
	beq	+
        dey
	lda	(zpstring), y
        iny
	cmp	' '
	bne	+
        ldx     #90
+       txa
	clc
	adc	runningscore
	sta	runningscore
	bcc	+
	inc	runningscore+1
+	iny
	sty	startat
	ldy	i
	cpy	word
	iny
	bcc	-

	lda	runningscore
	ldx	runningscore+1
        ldy     string
        jsr     div
        sta     tmp
	lda	runningscore
	ldx	runningscore+1
        ldy     word
        jsr     div
        clc
        adc     tmp
        lsr
        ldx     word+1
        cpx     string+1
        bne     +
        cmp     #85
        bcs     +
        adc     #15
+	rts

tolower
	cmp	#$41
	bcc	+
	cmp	#$5b
	bcs	+
	ora	#$20
+	rts

div
        sta num1
        stx num1+1
        sty num2

        lda #0
        sta rem
        sta rem+1
        ldx #16
-       asl num1
        rol num1+1
        rol rem
        rol rem+1
        lda rem
        sec
        sbc num2
        bcc +
        sta rem
        dec rem+1
        inc num1
+       dex
        bne -
        lda num1
        rts

rem !byte 0,0
num1 !byte 0,0
num2 !byte 0

word	!byte word_e-word_b
word_b
	!text "HE"
word_e
string	!byte string_e-string_b
string_b
	!text "HELLO WORLD"
string_e
