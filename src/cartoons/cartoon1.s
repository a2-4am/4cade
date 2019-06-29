!cpu 65c02
!to "cartoon.1#0602d0",plain
*=$2d0

cartoon=1

load=$2700
buffer=$2000

	jsr	$bf00
	!byte	$c8		;open file
	!word	c8_parms	;->bd5d
;	lda	c8_parms+5
;	sta	ca_parms+1
	jsr	$bf00
	!byte	$ca		;read file
	!word	ca_parms
	jsr	$bf00
	!byte	$cc		;close
	!word	cc_parms
lda #$60
sta $277b
jsr $2700
lda #cartoon-1
sta $19c7
lda #$4c
sta $1832
jsr $2000
jmp $100


c8_parms			;bd5d
	!byte	3
	!word	filename
	!word	buffer		;somewhere
	!byte	0

ca_parms			;bd68
	!byte	4
cc_parms			;bd70
	!byte	1
	!word	$2700
	!word	$ffff
	!word	$ffff

filename
	!byte	(filename_e-filename)-1
	!text	"SPARE.CHANGE"
filename_e
