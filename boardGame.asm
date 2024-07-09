.model small
.stack 100h

.data 
    board_size equ 6 ; gameBoard 6x6
    gameArray db board_size*board_size dup('A') ; Array to handle game logic. A = 0-5, B = 6-11, C = 12-17, D = 18, 23, E = 24,29, F = 30, 35 
    gameGrid board_size dup('+---+---+---+---+---+---+',13,10,'|   |   |   |   |   |   |',13,10),   ; "+---+---+---+---+---+---+\r\n"
                          db '+---+---+---+---+---+---+',13,10,                                     ; "|   |   |   |   |   |   |\r\n"
                          db '$' ; Null terminator                                                  ; "+---+---+---+---+---+---+\r\n"
    gameRow1 db '+---+---+---+---+---+---+$'
    gameRow2 db '|   |   |   |   |   |   |$'
    newline db 13,10,'                         ','$'
    gameTitle db '       Batalla Naval$'
    fillRowCounter dw 0
    fillBoardCounter dw 0
    four db 4     
.code
main proc
    mov ax, @data
    mov ds, ax
    
    ;Print title
    call line
        lea dx, gameTitle
        mov  ah, 09h     ; DOS.PrintString
        int  21h
    call line
    
    ; Print the game board
    printBoard:
        call line
            lea dx, gameRow1
            mov  ah, 09h     ; DOS.PrintString
            int  21h
        mov cl, 0
        printLoop:
            call line
            call fillRow
                lea dx, gameRow2
                mov  ah, 09h     ; DOS.PrintString
                int  21h
            call line
                lea dx, gameRow1
                mov  ah, 09h     ; DOS.PrintString
                int  21h
            inc  cl
            mov ch, board_size
            cmp cl, ch
            jl printLoop
    
    option:
    ; Wait for a key press to exit (optional)
    mov ah, 0
    int 16h          ; Wait for key press

    mov ax, 4c00h    ; Exit program
    int 21h

main endp

line proc
    lea dx, newline
    mov ah,9h
    int 21h
    ret
line endp

fillRow proc
    fill:
        mov SI, fillRowCounter
        add SI, fillBoardCounter
        mov al, gameArray[SI]
        mov SI, fillRowCounter
        mov ax, SI
        mul four
        mov SI, ax
        add SI, 2
        mov gameRow2[SI], al
        inc fillRowCounter
        cmp fillRowCounter, board_size 
        jl fill
    add fillBoardCounter, board_size
    mov fillRowCounter, 0
    ret   
fillRow endp

end main
