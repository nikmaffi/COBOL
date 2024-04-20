       IDENTIFICATION DIVISION.
       PROGRAM-ID.             COBOL-SDL2.
       AUTHOR.                 NIK MAFFI.
       INSTALLATION.           HOME.
       DATE-WRITTEN.           19/04/2024.
       DATE-COMPILED.          19/04/2024.
       SECURITY.               NORMAL.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER.        NIK-WORKSTATION.
       OBJECT-COMPUTER.        NIK-WORKSTATION
           MEMORY SIZE 17179869184 CHARACTERS.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           77 SDL-INIT-VIDEO     PIC 99    VALUE IS 32.
           77 SDL-QUIT           PIC 9(3)  VALUE IS 256.
           77 SDL-KEYDOWN        PIC 9(3)  VALUE IS 768.
           77 SDL-KUP            PIC 9(10) VALUE IS 1073741906.
           77 SDL-KDOWN          PIC 9(10) VALUE IS 1073741905.
           77 SDL-KLEFT          PIC 9(10) VALUE IS 1073741904.
           77 SDL-KRIGHT         PIC 9(10) VALUE IS 1073741903.
           77 SDL-WINDOW-SHOWN   PIC 9     VALUE IS 4.
           77 SDL-ERROR          POINTER.
           77 DONE               PIC 9     VALUE IS ZERO.
           77 UNIT-SIZE          PIC 99    VALUE IS 10.
           01 GAME-TIME.
               02 TSTART         PIC 9(9)  USAGE IS COMP-5.
               02 TEND           PIC 9(9)  USAGE IS COMP-5.
               02 DELTA          PIC 9(9)  VALUE IS ZEROES.
           77 SDL-POLL-EVENT     PIC 9     VALUE IS ZERO.
           01 SDL-EVENT.
               02 EVENT-TYPE     PIC 9(9)  USAGE IS COMP-5.
               02 EVENT-KEY.
                   03 FILLER     PIC X(12) VALUE IS SPACES.
                   03 KEYSYM.
                       04 FILLER PIC X(4)  VALUE IS SPACES.
                       04 SYM    PIC S9(9) USAGE IS COMP-5.
                       04 FILLER PIC X(8)  VALUE IS SPACES.
               02 FILLER         PIC X(20) VALUE IS SPACES.
           01 BACKGROUND.
               02 BACK-RED      PIC 9(3)  VALUE IS ZERO.
               02 BACK-GREEN    PIC 9(3)  VALUE IS ZERO.
               02 BACK-BLUE     PIC 9(3)  VALUE IS 255.
               02 BACK-ALPHA    PIC 9(3)  VALUE IS 255.
           01 PLAYER.
               02 PL-STEP        PIC 99    VALUE IS 5.
               02 PL-DIR         PIC 9     VALUE IS 1.
               02 PL-COLOR.
                   03 PL-COL-R   PIC 9(3)  VALUE IS ZERO.
                   03 PL-COL-G   PIC 9(3)  VALUE IS 255.
                   03 PL-COL-B   PIC 9(3)  VALUE IS ZERO.
                   03 PL-COL-A   PIC 9(3)  VALUE IS 255.
               02 PL-RECT.
                   03 PL-RECT-X  PIC S9(9) USAGE IS COMP-5.
                   03 PL-RECT-Y  PIC S9(9) USAGE IS COMP-5.
                   03 PL-RECT-W  PIC S9(9) USAGE IS COMP-5.
                   03 PL-RECT-H  PIC S9(9) USAGE IS COMP-5.
           01 FOOD.
               02 FD-COLOR.
                   03 FD-COL-R   PIC 9(3)  VALUE IS 255.
                   03 FD-COL-G   PIC 9(3)  VALUE IS ZERO.
                   03 FD-COL-B   PIC 9(3)  VALUE IS ZERO.
                   03 FD-COL-A   PIC 9(3)  VALUE IS 255.
               02 FD-RECT.
                   03 FD-RECT-X  PIC S9(9) USAGE IS COMP-5.
                   03 FD-RECT-Y  PIC S9(9) USAGE IS COMP-5.
                   03 FD-RECT-W  PIC S9(9) USAGE IS COMP-5.
                   03 FD-RECT-H  PIC S9(9) USAGE IS COMP-5.
           01 MAIN-WINDOW.
               02 WIN-POINTER    POINTER.
               02 WIN-TITLE.
                   03 WT-TEXT    PIC X(15) VALUE IS "SDL2 with COBOL".
                   03 WT-END     PIC 9     USAGE IS BINARY.
               02 WIN-X          PIC 9(3)  VALUE IS 100.
               02 WIN-Y          PIC 9(3)  VALUE IS 100.
               02 WIN-WIDTH      PIC 9(3)  VALUE IS 800.
               02 WIN-HEIGHT     PIC 9(3)  VALUE IS 600.
           01 RENDERER.
               02 REND-POINTER   POINTER.
               02 REND-INDEX     PIC S9    VALUE IS -1.
               02 REND-FLAGS     PIC 9     VALUE IS 6.
       PROCEDURE DIVISION.
       MAIN SECTION.
      *    SDL2 INITIALIZATION
           CALL STATIC "SDL_Init" USING
               BY VALUE SDL-INIT-VIDEO
               RETURNING SDL-ERROR
           END-CALL

           IF SDL-ERROR IS NOT EQUALS TO NULL THEN
               DISPLAY "Error: Cannot initialize SDL2!"
               STOP RUN
           END-IF

      *    MAIN WINDOW INITIALIZATION
           SET WT-END TO ZERO

           CALL STATIC "SDL_CreateWindow" USING
               BY REFERENCE WIN-TITLE
               BY VALUE WIN-X
               BY VALUE WIN-Y
               BY VALUE WIN-WIDTH
               BY VALUE WIN-HEIGHT
               BY VALUE SDL-WINDOW-SHOWN
               RETURNING WIN-POINTER
           END-CALL

           IF WIN-POINTER IS EQUALS TO NULL THEN
               DISPLAY "Error: Cannot create main window!"
               PERFORM KILL-SDL2
           END-IF

      *    MAIN WINDOW RENDERER INITIALIZATION
           CALL STATIC "SDL_CreateRenderer" USING
               BY VALUE WIN-POINTER
               BY VALUE REND-INDEX
               BY VALUE REND-FLAGS
               RETURNING REND-POINTER
           END-CALL

           IF REND-POINTER IS EQUALS TO NULL THEN
               DISPLAY "Error: Cannot create renderer!"
               PERFORM KILL-WINDOW
           END-IF.

      *    PLAYER RECT SETUP
           MOVE UNIT-SIZE TO PL-RECT-X
           MOVE UNIT-SIZE TO PL-RECT-Y
           MOVE UNIT-SIZE TO PL-RECT-W
           MOVE UNIT-SIZE TO PL-RECT-H

      *    FOOD RECT SETUP
           MOVE UNIT-SIZE TO FD-RECT-X
           MOVE UNIT-SIZE TO FD-RECT-Y
           MOVE UNIT-SIZE TO FD-RECT-W
           MOVE UNIT-SIZE TO FD-RECT-H

      *    SET START TIME
           CALL STATIC "SDL_GetTicks" RETURNING TSTART

      *    GAME LOOP
           PERFORM WITH TEST BEFORE UNTIL DONE IS EQUALS TO 1
      *        DELTA TIME
               CALL STATIC "SDL_GetTicks" RETURNING TEND
               SUBTRACT TSTART FROM TEND GIVING DELTA

               IF DELTA IS GREATER THAN 16.66 THEN
                   MOVE TEND TO TSTART

                   PERFORM EVENT-HANDLER

                   PERFORM UPDATE-GAME
                   PERFORM DRAW-GAME
               END-IF
           END-PERFORM

           CALL STATIC "SDL_DestroyRenderer" USING
               BY VALUE REND-POINTER
           END-CALL.
       KILL-WINDOW.
           CALL STATIC "SDL_DestroyWindow" USING
               BY VALUE WIN-POINTER
           END-CALL.
       KILL-SDL2.
           CALL STATIC "SDL_Quit"
           STOP RUN.

       EVENT-HANDLER SECTION.
           PERFORM WITH TEST AFTER UNTIL SDL-POLL-EVENT = 0
               CALL STATIC "SDL_PollEvent" USING
                   BY REFERENCE SDL-EVENT
                   RETURNING SDL-POLL-EVENT
               END-CALL
    
               IF EVENT-TYPE IS EQUALS TO SDL-QUIT THEN
                   SET DONE TO 1
               ELSE IF EVENT-TYPE IS EQUALS TO SDL-KEYDOWN THEN
      *            KEY HANDLER
                   IF SYM = SDL-KUP AND PL-DIR <> 2 THEN
                       MOVE ZERO TO PL-DIR
                   END-IF
    
                   IF SYM = SDL-KDOWN AND PL-DIR <> ZERO THEN
                       MOVE 2 TO PL-DIR
                   END-IF
    
                   IF SYM = SDL-KLEFT AND PL-DIR <> 1 THEN
                       MOVE 3 TO PL-DIR
                   END-IF
    
                   IF SYM = SDL-KRIGHT AND PL-DIR <> 3 THEN
                       MOVE 1 TO PL-DIR
                   END-IF
               END-IF
           END-PERFORM.

       UPDATE-GAME SECTION.
      *    PLAYER
           EVALUATE PL-DIR
               WHEN ZERO SUBTRACT PL-STEP FROM PL-RECT-Y
               WHEN 1 ADD PL-STEP TO PL-RECT-X
               WHEN 2 ADD PL-STEP TO PL-RECT-Y
               WHEN 3 SUBTRACT PL-STEP FROM PL-RECT-X
           END-EVALUATE.

      *    FOOD

       DRAW-GAME SECTION.
      *    BACKGROUND
           CALL STATIC "SDL_SetRenderDrawColor" USING
               BY VALUE REND-POINTER
               BY VALUE BACK-RED
               BY VALUE BACK-GREEN
               BY VALUE BACK-BLUE
               BY VALUE BACK-ALPHA
           END-CALL
    
           CALL STATIC "SDL_RenderClear" USING
               BY VALUE REND-POINTER
           END-CALL

      *    FOOD
           CALL STATIC "SDL_SetRenderDrawColor" USING
               BY VALUE REND-POINTER
               BY VALUE FD-COL-R
               BY VALUE FD-COL-G
               BY VALUE FD-COL-B
               BY VALUE FD-COL-A
           END-CALL
    
           CALL STATIC "SDL_RenderFillRect" USING
               BY VALUE REND-POINTER
               BY REFERENCE FD-RECT
           END-CALL

      *    PLAYER
           CALL STATIC "SDL_SetRenderDrawColor" USING
               BY VALUE REND-POINTER
               BY VALUE PL-COL-R
               BY VALUE PL-COL-G
               BY VALUE PL-COL-B
               BY VALUE PL-COL-A
           END-CALL
    
           CALL STATIC "SDL_RenderFillRect" USING
               BY VALUE REND-POINTER
               BY REFERENCE PL-RECT
           END-CALL
    
           CALL STATIC "SDL_RenderPresent" USING
               BY VALUE REND-POINTER
           END-CALL.
       END PROGRAM COBOL-SDL2.