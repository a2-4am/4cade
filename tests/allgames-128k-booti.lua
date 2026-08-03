--[[ BEGINCONFIG ========================================

  MODEL="apple2ee"
  MODELARGS="-aux 'ext80' -gameio 'joy' -sl1 '' -sl2 'mockingboard' -sl3 '' -sl4 'mouse' -sl5 '' -sl6 '' -sl7 'booti'"

  ======================================== ENDCONFIG ]]

replay.allgames("^...")

-- configure Booti by putting disk images into MAME's 'share' folder
-- (if it doesn't exist, create one)
-- filenames must be valid 8.3 filenames
-- press 'C' while booting
-- select hard drive image to use on-screen
-- press 'X' to exit and boot the selected disk images
