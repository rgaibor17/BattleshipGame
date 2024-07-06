.model small
.stack 100h

.data
; Define your game board here
gameBoard db '+---+---+---+---+---+---+', 13, 10   ; "+---+---+---+---+---+---+\r\n"
         db '|   |   |   |   |   |   |', 13, 10   ; "|   |   |   |   |   |   |\r\n"
         db '+---+---+---+---+---+---+', 13, 10   ; "+---+---+---+---+---+---+\r\n"
         db '|   |   |   |   |   |   |', 13, 10   ; "|   |   |   |   |   |   |\r\n"
         db '+---+---+---+---+---+---+', 13, 10   ; "+---+---+---+---+---+---+\r\n"
         db '|   |   |   |   |   |   |', 13, 10   ; "|   |   |   |   |   |   |\r\n"
         db '+---+---+---+---+---+---+', 13, 10   ; "+---+---+---+---+---+---+\r\n"
         db '|   |   |   |   |   |   |', 13, 10   ; "|   |   |   |   |   |   |\r\n"
         db '+---+---+---+---+---+---+', 13, 10   ; "+---+---+---+---+---+---+\r\n"
         db '|   |   |   |   |   |   |', 13, 10   ; "|   |   |   |   |   |   |\r\n"
         db '+---+---+---+---+---+---+', 13, 10   ; "+---+---+---+---+---+---+\r\n"
         db '|   |   |   |   |   |   |', 13, 10   ; "|   |   |   |   |   |   |\r\n"
         db '+---+---+---+---+---+---+', 13, 10   ; "+---+---+---+---+---+---+\r\n"
         db '$'                      ; Null terminator

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Print the game board
    lea dx, gameBoard
    mov ah, 9        ; AH = 9 indicates print string
    int 21h          ; Call DOS interrupt to print string

    ; Wait for a key press to exit (optional)
    mov ah, 0
    int 16h          ; Wait for key press

    mov ax, 4c00h    ; Exit program
    int 21h

main endp
end main
