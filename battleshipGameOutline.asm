.model small
.stack 100h

.data
gameBoard db '+---+---+---+---+', 13, 10   ; "+---+---+---+---+\r\n"
          db '|   |   |   |   |', 13, 10   ; "|   |   |   |   |\r\n"
          db '+---+---+---+---+', 13, 10   ; "+---+---+---+---+\r\n"
          db '|   |   |   |   |', 13, 10   ; "|   |   |   |   |\r\n"
          db '+---+---+---+---+', 13, 10   ; "+---+---+---+---+\r\n"
          db '|   |   |   |   |', 13, 10   ; "|   |   |   |   |\r\n"
          db '+---+---+---+---+', 13, 10   ; "+---+---+---+---+\r\n"
          db '|   |   |   |   |', 13, 10   ; "|   |   |   |   |\r\n"
          db '+---+---+---+---+', 13, 10   ; "+---+---+---+---+\r\n"
          db '$'                          ; Null terminator

shipRow db 2        ; Row position of the ship (0-based index)
shipCol db 1        ; Column position of the ship (0-based index)
shipSunk db 0       ; Flag to indicate if the ship has been sunk (0 = not sunk, 1 = sunk)
msg_prompt db 'Enter row and column (e.g., 00): $'
msg_miss db 'Miss!$'
msg_hit db 'Hit!$'
msg_game_over db 'Congratulations! You sunk the battleship.$'

.code
main proc
    mov ax, @data
    mov ds, ax
    
    ; Initialize game board
    call DisplayGameBoard
    
    ; Game loop
game_loop:
    call GetUserGuess   ; Get user's guess
    
    ; Check if user hit the ship
    mov al, shipRow
    cmp al, bl          ; Compare guessed row with ship row
    jne not_hit
    
    mov al, shipCol
    cmp al, cl          ; Compare guessed column with ship column
    je ship_hit
    
not_hit:
    mov ah, 9
    lea dx, msg_miss
    int 21h             ; Print "Miss!" message
    jmp game_loop       ; Repeat game loop
    
ship_hit:
    mov ah, 9
    lea dx, msg_hit
    int 21h             ; Print "Hit!" message
    
    mov shipSunk, 1     ; Set shipSunk flag to indicate ship is sunk
    
    ; Display updated game board with ship sunk
    call DisplayGameBoard
    
    ; Game over check
    cmp shipSunk, 1
    jne game_loop       ; If ship not sunk, continue game loop
    
    ; Print game over message
    mov ah, 9
    lea dx, msg_game_over
    int 21h
    
    ; Wait for key press to exit
    mov ah, 0
    int 16h
    
    mov ax, 4c00h       ; Exit program
    int 21h

main endp

; Procedure to display the game board
DisplayGameBoard proc
    mov ah, 9
    lea dx, gameBoard
    int 21h
    ret
DisplayGameBoard endp

; Procedure to get user's guess
GetUserGuess proc
    ; Print prompt
    mov ah, 9
    lea dx, msg_prompt
    int 21h
    
    ; Get row input
    mov ah, 1
    int 21h
    sub al, '0'         ; Convert ASCII digit to numeric value
    mov bl, al          ; Store row guess in bl
    
    ; Get column input
    mov ah, 1
    int 21h
    sub al, '0'         ; Convert ASCII digit to numeric value
    mov cl, al          ; Store column guess in cl
    
    ret
GetUserGuess endp

end main
