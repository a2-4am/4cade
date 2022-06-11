;license:MIT
;(c) 2022 by qkumba

!cpu 6502
!to "res/DEMO/SPCARTOON.22",plain
*=$200

         !source "src/constants.a"   ; no code in these
         !source "src/macros.a"

         +READ_RAM2_WRITE_RAM2
         jsr   EnableAccelerator
         +LOAD_FILE_KEEP_DIR spare_change, spare_change_dir_e-spare_change_dir_b
         lda   #$60
         sta   $277B
         jsr   $2700     ; decompress
         lda   #1
         sta   $19C7
         lda   #$4C
         sta   $182F
         jsr   $2000
         lda   #$44
         sta   $7A34
         lda   #$B0
         sta   $963B
         lda   #$6C
         sta   $963C
         +DISABLE_ACCEL
         jsr   $9600
         jmp   $100

spare_change
         !byte spare_change_e-spare_change_b
spare_change_b
spare_change_dir_b
         !text "X/SPARE.CHANGE"
spare_change_dir_e
         !text "/SPARE.CHANGE"
spare_change_e

!if * > $3F0 {
  !error "code is too large, ends at ", *
}
