.model small
.stack 100h

.data
number dw 12345 ; Example number stored in memory

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Load the number's address into SI
    lea si, number

    ; Print a string message before printing the number
    mov ah, 09h ; DOS interrupt for displaying string
    lea dx, message
    int 21h

    ; Print the number
print_number:
    mov al, [si] ; Load the byte at the current address pointed by SI
    cmp al, 0   ; Check if it's the null terminator
    je done     ; If null terminator is found, exit

    add al, 30h ; Convert the number to its ASCII equivalent
    mov ah, 02h ; DOS interrupt for displaying character
    int 21h

    inc si      ; Move to the next byte in memory
    jmp print_number ; Repeat for the next byte

done:
    mov ah, 4Ch ; DOS exit interrupt
    int 21h

message db "The number is: $"

main endp
end main