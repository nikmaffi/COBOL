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
           77 SDL-INIT-VIDEO   PIC 99     VALUE IS 32.
           77 SDL-WINDOW-SHOWN PIC 9      VALUE IS 4.
           77 SDL-ERROR        POINTER.
           01 COLOR-BLACK.
               02 BLACK-RED    PIC 9(3)   VALUE IS ZERO.
               02 BLACK-GREEN  PIC 9(3)   VALUE IS ZERO.
               02 BLACK-BLUE   PIC 9(3)   VALUE IS ZERO.
               02 BLACK-ALPHA  PIC 9(3)   VALUE IS 255.
           01 COLOR-RED.
               02 RED-RED      PIC 9(3)   VALUE IS 255.
               02 RED-GREEN    PIC 9(3)   VALUE IS ZERO.
               02 RED-BLUE     PIC 9(3)   VALUE IS ZERO.
               02 RED-ALPHA    PIC 9(3)   VALUE IS 255.
           01 RECT.
               02 RECT-X       PIC S9(9)  USAGE IS COMP-5.
               02 RECT-Y       PIC S9(9)  USAGE IS COMP-5.
               02 RECT-WIDTH   PIC S9(9)  USAGE IS COMP-5.
               02 RECT-HEIGHT  PIC S9(9)  USAGE IS COMP-5.
           01 MAIN-WINDOW.
               02 WIN-POINTER  POINTER.
               02 WIN-TITLE.
                   03 WT-TEXT  PIC X(15)  VALUE IS "SDL2 with COBOL".
                   03 WT-END   PIC 9      USAGE IS BINARY.
               02 WIN-X        PIC 9(3)   VALUE IS 100.
               02 WIN-Y        PIC 9(3)   VALUE IS 100.
               02 WIN-WIDTH    PIC 9(3)   VALUE IS 640.
               02 WIN-HEIGHT   PIC 9(3)   VALUE IS 480.
           01 RENDERER.
               02 REND-POINTER POINTER.
               02 REND-INDEX   PIC S9     VALUE IS -1.
               02 REND-FLAGS   PIC 9      VALUE IS 6.
       PROCEDURE DIVISION.
       MAIN SECTION.
           CALL STATIC "SDL_Init" USING
               BY VALUE SDL-INIT-VIDEO
               RETURNING SDL-ERROR
           END-CALL

           IF SDL-ERROR IS NOT EQUALS TO NULL THEN
               DISPLAY "Error: Cannot initialize SDL2!"
               STOP RUN
           END-IF

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

           MOVE 100 TO RECT-X
           MOVE 100 TO RECT-Y
           MOVE 200 TO RECT-WIDTH
           MOVE 200 TO RECT-HEIGHT

           PERFORM 250 TIMES
               CALL STATIC "SDL_SetRenderDrawColor" USING
                   BY VALUE REND-POINTER
                   BY VALUE BLACK-RED
                   BY VALUE BLACK-GREEN
                   BY VALUE BLACK-BLUE
                   BY VALUE BLACK-ALPHA
               END-CALL

               CALL STATIC "SDL_RenderClear" USING
                   BY VALUE REND-POINTER
               END-CALL

               CALL STATIC "SDL_SetRenderDrawColor" USING
                   BY VALUE REND-POINTER
                   BY VALUE RED-RED
                   BY VALUE RED-GREEN
                   BY VALUE RED-BLUE
                   BY VALUE RED-ALPHA
               END-CALL

               CALL STATIC "SDL_RenderFillRect" USING
                   BY VALUE REND-POINTER
                   BY REFERENCE RECT
               END-CALL

               CALL STATIC "SDL_RenderPresent" USING
                   BY VALUE REND-POINTER
               END-CALL
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
       END PROGRAM COBOL-SDL2.
