.model small
.stack 100h
.data
    

.code
main PROC
   mov ah, 02h
    mov dl, 'H'
    int 21h
    mov ah, 02h
    mov dl, 'i'
    int 21h
    mov ah, 02h
    mov dl, '!'
    int 21h
main ENDP
END main
