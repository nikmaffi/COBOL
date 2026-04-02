       IDENTIFICATION DIVISION.
       PROGRAM-ID. COLOR-TEST.
       AUTHOR.     Nicolo' Maffi.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       77 FG-COLOR PIC 9 VALUE IS ZERO.
       77 BG-COLOR PIC 9 VALUE IS ZERO.
       77 TEST-STR PIC X VALUE IS "@".
       77 Y-VAL    PIC 9 VALUE IS 1.
       77 X-VAL    PIC 9 VALUE IS 1.
       PROCEDURE DIVISION.
           PERFORM VARYING BG-COLOR FROM 0 BY 1 UNTIL BG-COLOR > 7
               MOVE 1 TO Y-VAL

               PERFORM VARYING FG-COLOR FROM 0 BY 1 UNTIL FG-COLOR > 7
                   DISPLAY TEST-STR LINE Y-VAL COLUMN X-VAL
                       BACKGROUND-COLOR BG-COLOR
                       FOREGROUND-COLOR FG-COLOR
                   ADD 1 TO Y-VAL
               END-PERFORM
               ADD 1 TO X-VAL

               IF X-VAL IS GREATER THAN 41 THEN
                   MOVE 1 TO X-VAL
               END-IF
           END-PERFORM
           STOP RUN.
       END PROGRAM COLOR-TEST.
