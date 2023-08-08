       IDENTIFICATION DIVISION.
       PROGRAM-ID. COBOL-SQLITE-TEST.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           77 SQLITE           POINTER.
           77 ERROR-CODE       PIC S9(005) COMP-5.
           77 DATABASE-NAME    PIC X(015).
           77 SQL-QUERY        PIC X(100).
           77 CALLBACK-FUNC    USAGE PROCEDURE-POINTER.
           77 COMMAND          PIC 9.
           01 DATA-RECORD.
               02 ID-FIELD     PIC 99.
               02 NAME-FIELD   PIC X(30).
       PROCEDURE DIVISION.
           SET SQLITE TO NULL.

           MOVE "DATA.DB" TO DATABASE-NAME

           PERFORM WITH TEST AFTER UNTIL COMMAND IS EQUAL TO 3
               MOVE LOW-VALUES TO SQL-QUERY

               DISPLAY "1.ADD RECORD"
               DISPLAY "2.LIST DATA"
               DISPLAY "3.EXIT"
               DISPLAY " "

               DISPLAY "COMMAND> " WITH NO ADVANCING
               ACCEPT COMMAND

               EVALUATE COMMAND
                   WHEN 1 PERFORM ADD-RECORD
                   WHEN 2 PERFORM LIST-DATA
                   WHEN 3 PERFORM EXIT-TEST
               END-EVALUATE
           END-PERFORM
           STOP RUN.

       ADD-RECORD.
           DISPLAY "ID:   " WITH NO ADVANCING
           ACCEPT ID-FIELD
           DISPLAY "NAME: " WITH NO ADVANCING
           ACCEPT NAME-FIELD

           CALL STATIC "sqlite3_open" USING
               BY REFERENCE DATABASE-NAME
               BY REFERENCE SQLITE
               RETURNING ERROR-CODE
           END-CALL

           IF ERROR-CODE IS NOT EQUAL TO ZERO THEN
               DISPLAY "OPENING ERROR"
               EXIT PARAGRAPH
           END-IF

           STRING "INSERT INTO PEOPLE VALUES (" DELIMITED BY SIZE
               ID-FIELD DELIMITED BY SIZE
               ",'"
               NAME-FIELD DELIMITED BY SIZE
               "');"
               INTO SQL-QUERY
           END-STRING

           CALL STATIC "sqlite3_exec" USING
               BY VALUE SQLITE
               BY REFERENCE SQL-QUERY
               BY VALUE 0
               BY VALUE 0
               BY VALUE 0
               RETURNING ERROR-CODE
           END-CALL

           IF ERROR-CODE IS NOT EQUAL TO ZERO THEN
               DISPLAY "INSERTING ERROR"
               EXIT PARAGRAPH
           END-IF

           CALL STATIC "sqlite3_close" USING
               BY REFERENCE SQLITE
           END-CALL.
       
       LIST-DATA.
           CALL STATIC "sqlite3_open" USING
               BY REFERENCE DATABASE-NAME
               BY REFERENCE SQLITE
               RETURNING ERROR-CODE
           END-CALL

           IF ERROR-CODE IS NOT EQUAL TO ZERO THEN
               DISPLAY "OPENING ERROR"
               EXIT PARAGRAPH
           END-IF

           SET CALLBACK-FUNC TO ADDRESS
               OF ENTRY "COBOL-SQLITE-TEST-CALLBACK"

           MOVE "SELECT * FROM PEOPLE;" TO SQL-QUERY

           CALL STATIC "sqlite3_exec" USING
               BY VALUE SQLITE
               BY REFERENCE SQL-QUERY
               BY VALUE CALLBACK-FUNC
               BY VALUE 0
               BY VALUE 0
               RETURNING ERROR-CODE
           END-CALL

           CALL STATIC "sqlite3_close" USING
               BY REFERENCE SQLITE
           END-CALL.

       EXIT-TEST.
       END PROGRAM COBOL-SQLITE-TEST.
