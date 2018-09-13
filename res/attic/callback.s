!cpu 6502
!to "callback#061000",plain
*=$1000

WILDCARD =     $97
BASEPAGE =     $D0

         lda   $c08b
         lda   $c08b
         ldy   #$0D
         jsr   SearchTrack
         !byte $BD,$10,$BF           ;LDA $BF10,X
         !byte $8D,WILDCARD,WILDCARD ;STA $xxxx,X
         !byte $BD,$11,$BF           ;LDA $BF11,X
         !byte $8D,WILDCARD,WILDCARD ;STA $xxxx,X
         !byte $6C
         bcs   .exit
         adc   #BASEPAGE
         sta   patch1+2
         sta   patch2+2

         ldy   #(callback_e-callback_b)-1
-        lda   callback_b,y
         sta   callback,y
         dey
         bpl   -         

         txa
         adc   #$0E
         tax

         ldy   #2
-
patch1   lda   $d100,x
         sta   jmpback,y
         lda   hookme,y
patch2   sta   $d100,x
         dex
         dey
         bpl   -
.exit
         lda   $c082
         bcs   ++
         ldy   #0
         beq   +
-        jsr   $FDED
         iny
+        lda   installed,y
         bne   -
++       rts

hookme   jmp   callback

installed
         !text "INSTALLED"
         !byte $8D,00

callback_b
!pseudopc $300 {
callback lda   $c081
         lda   #$D2
         jsr   $FDED
         lda   $c08b
         lda   $c000
         bpl   +
         sec ;error is pressed key
         rts
+
jmpback  ;!byte $d1,$d1,$d1
}
callback_e

SearchTrack
;set end point for the search

         lda   #$E0
         sta   .endvalue+1
         lda   #$D0

; set high part of initial search position

         sta   search+2
         pla
         sta   match_buffer1+1
         sta   match_all+1
         pla
         sta   match_buffer1+2
         sta   match_all+2
         tax
         sty   match_size1+1
         sty   match_size2+1

; fetch last byte to improve search speed

match_buffer1
         lda   $d1d1,y    ; modified at runtime
         sta   check_byte1+1
         sta   check_byte2+1

; set low part of initial search position

         tya
         dey
         sty   cont_search+1

; set return address

         clc
         adc   match_buffer1+1
         tay
         bcc   plus01
         inx
plus01
         txa
         pha
         tya
         pha

; set match position

         inc   match_all+1
         bne   plus02
         inc   match_all+2
plus02

         lda   #<cont_search-branch_cont-2
         sta   branch_cont+1

; search...

cont_search
         ldy   #$d1       ; modified at runtime

search
         lda   $d100,y    ; modified at runtime
         iny
         beq   check_end

check_byte1
         cmp   #$d1       ; modified at runtime
         bne   search

; point to first byte

         sty   cont_search+1

check_match
         tya

match_size1
         sbc   #$d1       ; modified at runtime
         sta   match_buffer2+1
         ldx   search+2
         bcs   plus03
         dex
plus03
         stx   match_buffer2+2
         ldy   #$00

match_all
         lda   $d1d1,y    ; modified at runtime
         cmp   #WILDCARD
         beq   found_wild

match_buffer2
         cmp   $d1d1,y    ; modified at runtime

branch_cont
         bne   cont_search

found_wild
         iny

match_size2
         cpy   #$d1       ; modified at runtime
         bne   match_all

; point to start of match

         ldx   match_buffer2+1
         lda   match_buffer2+2
         sec
         sbc   #BASEPAGE
         clc
         rts

; cold path

check_end
         inc   search+2
         ldx   search+2
.endvalue
         cpx   #$D1
         bne   check_byte1
         ldx   #<all_done_set-branch_cont-2
         stx   branch_cont+1

check_byte2
         cmp   #$d1       ; modified at runtime
         beq   check_match

all_done_set
         sec
         rts
