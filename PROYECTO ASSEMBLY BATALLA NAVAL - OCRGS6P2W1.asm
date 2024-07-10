;Prompt: Assembly code that simulates a battleship game emu8086

.model small

printstr macro msg 
    lea dx, msg          ; Load offset of msg into DX
    mov ah, 9h           ; DOS function to print string
    int 21h              ; Call DOS to print string              
printstr endm

.stack 100h

.data
    ; Game board location
    board_size equ 6 ; Game board (6x6) 
    board db board_size*board_size dup('-'),'$' ; Array to handle game logic. A = 0-5, B = 6-11, C = 12-17, D = 18-23, E = 24-29, F = 30-35
    gameRow1 db board_size dup('+---'),'+','$'
    gameRow2 db board_size dup('|   '),'|','$'
    rowIndex db ?
    columnIndex db ?
    
    ;Ship location
    ship_x db ?     ; Ship X coordinate (0-5)
    ship_y db ?     ; Ship Y coordinate (0-5)
    ship_sunk db 0  ; Flag to track if ship is sunk (0 = not sunk, 1 = sunk)
    ship_hit db ?
    
    ; Messages
    prompt db 'Enter your guess (e.g., A1, F6): $'
    hit_msg db 'Hit!$'
    miss_msg db 'Miss!$'
    already_guessed_msg db 'You already guessed that!$'
    game_over_msg db 'CONGRATULATIONS! You sank the battleship.$'
    newline db 13,10,'                         ','$'
    gameTitle db '       BATALLA NAVAL$'
    
    ; Extra counters and additional variables
    fillRowCounter db 0
    fillBoardCounter db 0
    four db 4
    
.code
main:
    mov ax, @data        ; Initialize DS
    mov ds, ax
    call init_board      ; Initialize game board
    call place_ship      ; Place ship randomly
     
game_loop:               ; Game loop
    call display_board   ; Display board on screen
    
    printstr newline
    printstr newline
    printstr prompt      ; Prompt user for guess
    call scan_cell       ; Scan user's prompt (Ejemplos: A1, F6, etc.)
    
check_guess:             
    mov cl, board_size   ; CL = board_size (6)
    mul cl               ; AX = AL * CL (AL = row index, CL = board_size)
    add al, columnIndex  ; AL = AL + column index
    mov bx, 0
    mov bl, al
    mov dl, board[bx]    ; DL = board[BX] (board[row_index * board_size + column_index])
    cmp dl, 'X'          ; Compare with 'X' (already guessed)
    je already_guessed   ; Jump if already guessed

    
    ; Check if hit or miss
    mov ah, 0            ; Clear AH for flag setting
    mov bh, ship_y       ; BH = ship_y (y-coordinate of ship)
    cmp rowIndex, bh     ; Compare row index with ship's y-coordinate
    jne miss             ; Jump if not equal (miss)
    
    mov bh, ship_x       ; BH = ship_x (x-coordinate of ship)
    cmp bh, columnIndex  ; Compare column index with ship's x-coordinate
    jne miss             ; Jump if not equal (miss)
    
    ; If reaches here, it's a hit
    mov ship_hit, 1      ; Set ship_hit to 1 (hit)
    mov ship_sunk, 1     ; Set ship_sunk flag to 1 (sunk)
    jmp display_result   ; Jump to display result
    
miss:
    ; If reaches here, it's a miss
    mov ship_hit, 2      ; Set ship_hit to 2 (miss)
    printstr newline
    printstr newline
    printstr miss_msg
    
display_result:
    ; Update board with result
    mov al, rowIndex
    mov cl, board_size   ; CL = board_size (6)
    mul cl               ; AX = AL * CL (AL = row index, CL = board_size)
    add al, columnIndex  ; AL = AL + column index
    mov bx, 0
    mov bl, al
    cmp ship_hit, 1      ; Compare ship_hit (result flag)
    je hit               ; Jump if hit
    mov b. board[bx], 'O'  ; Set board[BX] = 'O' (miss)
    jmp game_loop        ; Jump back to game loop
    
hit:
    ; If reaches here, it's a hit
    mov b. board[bx], 'X'  ; Set board[BX] = 'X' (hit)
    
    ; Check if all ships are sunk
    cmp ship_sunk, 1
    jne game_loop        ; Jump back to game loop if ship is not sunk
    
    ; If reaches here, game is over
    call display_board   ; Display board on screen
    printstr newline
    printstr newline
    printstr game_over_msg
    
    ; Exit program
    mov ah, 4Ch          ; DOS function to terminate program
    int 21h              ; Call DOS to terminate program
    
already_guessed:
    ; If reaches here, position was already guessed
    printstr newline
    printstr already_guessed_msg
    jmp game_loop        ; Jump back to game loop
    

    
place_ship:
    ; Place ship randomly on the board
    mov ah, 2           ; Initialize random seed (DOS function)
    int 21h             ; Call DOS to get random number (AH=2)
    mov ship_y, 3      ; DL = random number (y-coordinate)
    
    mov ah, 2           ; Initialize random seed (DOS function)
    int 21h             ; Call DOS to get random number (AH=2)
    mov ship_x, 3      ; DL = random number (x-coordinate)
    
    ret

;-----------------------------------------------------------------------------------------UserInput

scan_cell proc    
    ; Read user input
    mov ah, 01h         ; DOS function to read character
    int 21h             ; Call DOS to read character
    sub al, 'A'         ; Convert letter to row index (0=A, 1=B, ..., 5=F)
    mov rowIndex, al    ; Save row index
    
    mov ah, 01h         ; DOS function to read character
    int 21h             ; Call DOS to read character
    sub al, '1'         ; Convert digit to column index (0=1, 1=2, ..., 5=6)
    mov columnIndex, al ; Save column index
    ret
scan_cell endp

reset proc
    mov ax, 0
    mov bx, 0
    mov dx, 0
reset endp

;-----------------------------------------------------------------------------------------BoardDisplay

init_board proc
    ; Initialize game board with spaces (' ')
    mov cx, board_size * board_size  ; CX = board_size * board_size (36)
    lea di, board       ; Load offset of board into DI
    mov al, ' '         ; AL = ' ' (space)
    rep stosb           ; Fill board with AL (spaces)
    ret
init_board endp

display_board proc
        
    ;Print title
    printstr newline
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
            call fill_row
            printstr gameRow2
            printstr newline
            printstr gameRow1
            inc  cl
            mov ch, board_size
            cmp cl, ch
            jl printLoop
    mov fillBoardCounter, 0
    ret
display_board endp

fill_row proc
    ; fill each row with the corresponding values inside the Game Board
    fill:
        mov bx, 0
        mov bl, fillRowCounter
        add bl, fillBoardCounter
        mov dl, board[bx]
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
fill_row endp

end main
