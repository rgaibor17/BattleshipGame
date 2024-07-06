;Prompt: Assembly code that simulates a battleship game emu8086

.model small
.stack 100h

.data
    ; Game board and ship location
    board_size equ 5
    board dw board_size*board_size dup('_\n')  ; Game board (5x5)
    ship_x db ?     ; Ship X coordinate (0-4)
    ship_y db ?     ; Ship Y coordinate (0-4)
    ship_sunk db 0  ; Flag to track if ship is sunk (0 = not sunk, 1 = sunk)
    
    ; Messages
    prompt db 'Enter your guess (e.g., A1): $'
    hit_msg db 'Hit!$'
    miss_msg db 'Miss!$'
    already_guessed_msg db 'You already guessed that!$'
    game_over_msg db 'Congratulations! You sank the battleship.$'
    
.code
main:
    mov ax, @data       ; Initialize DS
    mov ds, ax
    
    ; Initialize game board
    call init_board
    
    ; Place ship randomly
    call place_ship
    
    ; Game loop
game_loop:
    call display_board
    
    ; Prompt user for guess
    mov ah, 09h         ; DOS function to print string
    lea dx, prompt      ; Load offset of prompt into DX
    int 21h             ; Call DOS to print string
    
    ; Read user input
    mov ah, 01h         ; DOS function to read character
    int 21h             ; Call DOS to read character
    sub al, 'A'         ; Convert letter to column index (0=A, 1=B, ..., 4=E)
    mov bh, al          ; Save column index
    
    mov ah, 01h         ; DOS function to read character
    int 21h             ; Call DOS to read character
    sub al, '1'         ; Convert digit to row index (0=1, 1=2, ..., 4=5)
    mov bl, al          ; Save row index
    
    ; Check if already guessed
    mov cl, board_size  ; CL = board_size (5)
    mul cl              ; AX = AL * CL (AL = row index, CL = board_size)
    add al, bh          ; AL = AL + BH (BH = column index)
    mov dl, OFFSET board[ax]   ; DL = board[AL] (board[row_index * board_size + column_index])
    cmp dl, 'X'         ; Compare with 'X' (already guessed)
    je already_guessed ; Jump if already guessed
    
    ; Check if hit or miss
    mov ah, 0            ; Clear AH for flag setting
    mov bh, ship_y       ; BH = ship_y (y-coordinate of ship)
    cmp bl, bh           ; Compare row index with ship's y-coordinate
    jne miss             ; Jump if not equal (miss)
    
    mov bh, ship_x       ; BH = ship_x (x-coordinate of ship)
    cmp bh, al           ; Compare column index with ship's x-coordinate
    jne miss             ; Jump if not equal (miss)
    
    ; If reaches here, it's a hit
    mov ah, 1            ; Set AH to 1 (hit)
    mov ship_sunk, 1     ; Set ship_sunk flag to 1 (sunk)
    jmp display_result   ; Jump to display result
    
miss:
    ; If reaches here, it's a miss
    mov ah, 2            ; Set AH to 2 (miss)
    
display_result:
    ; Update board with result
    mov cl, board_size   ; CL = board_size (5)
    mul cl               ; AX = AL * CL (AL = row index, CL = board_size)
    add al, bh           ; AL = AL + BH (BH = column index)
    
    cmp ah, 1            ; Compare AH (result flag)
    je hit               ; Jump if hit
    mov OFFSET byte ptr board[ax], 'O'  ; Set board[AL] = 'O' (miss)
    jmp game_loop        ; Jump back to game loop
    
hit:
    ; If reaches here, it's a hit
    mov OFFSET byte ptr board[ax], 'X'  ; Set board[AL] = 'X' (hit)
    
    ; Check if all ships are sunk
    cmp ship_sunk, 1
    jne game_loop        ; Jump back to game loop if ship is not sunk
    
    ; If reaches here, game is over
    mov ah, 09h          ; DOS function to print string
    lea dx, game_over_msg  ; Load offset of game_over_msg into DX
    int 21h              ; Call DOS to print string
    
    ; Exit program
    mov ah, 4Ch          ; DOS function to terminate program
    int 21h              ; Call DOS to terminate program
    
already_guessed:
    ; If reaches here, position was already guessed
    mov ah, 09h          ; DOS function to print string
    lea dx, already_guessed_msg  ; Load offset of already_guessed_msg into DX
    int 21h              ; Call DOS to print string
    jmp game_loop        ; Jump back to game loop
    
init_board:
    ; Initialize game board with spaces (' ')
    mov cx, board_size * board_size  ; CX = board_size * board_size (25)
    lea di, board       ; Load offset of board into DI
    mov al, ' '         ; AL = ' ' (space)
    rep stosb           ; Fill board with AL (spaces)
    ret
    
place_ship:
    ; Place ship randomly on the board
    mov ah, 2           ; Initialize random seed (DOS function)
    int 21h             ; Call DOS to get random number (AH=2)
    mov ship_y, dl      ; DL = random number (y-coordinate)
    
    mov ah, 2           ; Initialize random seed (DOS function)
    int 21h             ; Call DOS to get random number (AH=2)
    mov ship_x, dl      ; DL = random number (x-coordinate)
    
    ret
    
display_board:
    ; Display game board
    mov cx, board_size   ; CX = board_size (5)
    mov dx, cx           ; DX = board_size (5)
    mov ah, 02h          ; DOS function to print character
    lea di, board        ; Load offset of board into DI
    
print_board_loop:
    mov cl, cl           ; CL = CX (board_size)
    
print_row_loop:
    mov al, [di]         ; AL = value at DI (board[row * board_size + column])
    mov dl, al           ; DL = AL (character to print)
    int 21h              ; Call DOS to print character
    
    inc di               ; Move to next column
    loop print_row_loop  ; Loop through row
    
    mov dl, 13           ; DL = 13 (carriage return)
    int 21h              ; Call DOS to print character
    
    mov dl, 10           ; DL = 10 (line feed)
    int 21h              ; Call DOS to print character
    
    dec dx               ; Decrement row counter
    jnz print_board_loop ; Jump if not zero (continue printing rows)
    
    ret
    
end main
