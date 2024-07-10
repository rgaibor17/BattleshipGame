.model small

printstr macro msg 
    lea dx, msg
    mov ah, 9h
    int 21h
printstr endm

.stack 100h

.data 
    board_size equ 6 ; gameBoard 6x6
    gameArray db board_size*board_size dup('X') ; Array to handle game logic. A = 0-5, B = 6-11, C = 12-17, D = 18-23, E = 24-29, F = 30-35
    gameRow1 db board_size dup('+---'),'+','$'
    gameRow2 db board_size dup('|   '),'|','$'
    newline db 13,10,'                         ','$'
    gameTitle db '       Batalla Naval$'
    fillRowCounter db 0
    fillBoardCounter db 0
    four db 4     
.code
main proc
    mov ax, @data
    mov ds, ax
    
    ;Print title
    printstr newline
    printstr gameTitle
    printstr newline
    
    ; Print the game board
    printBoard:
        printstr newline
        printstr gameRow1
        mov cl, 0
        printLoop:
            printstr newline
            call fillRow
            printstr gameRow2
            printstr newline
            printstr gameRow1
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

fillRow proc
    fill:
        mov bx, 0
        mov bl, fillRowCounter
        add bl, fillBoardCounter
        mov dl, gameArray[bx]
        mov al, fillRowCounter
        mul four              
        add al, 2
        mov bl, al
        mov gameRow2[bx], dl
        inc fillRowCounter
        cmp fillRowCounter, board_size 
        jl fill
    add fillBoardCounter, board_size
    mov fillRowCounter, 0
    ret   
fillRow endp

end main
