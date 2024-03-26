;; Щоб запустити, змінити settings.json два рази

.model small
.stack 100h
.data
    oneChar db ?
    searchParam db 255 dup(?)
    currentLine db 255 dup(?)
.code
main PROC
    ; ds = PSP
    ; copy param
    xor ch,ch
    mov cl, ds:[80h]   ; at offset 80h length of "args"
    mov si, 0

    write_char:
        push si
        test cl, cl
        jz step_2
        mov si, 81h        ; at offest 81h first char of "args"
        add si, cx
        mov dl, ds:[si]
        pop si
        mov [searchParam + si], dl

        ; mov ah, 02h
        ; mov dl, [searchParam + si]
        ; int 21h
        
        inc si
        dec cl
        jmp write_char

        
    step_2: 
        mov si, 0
        jmp read_next


    read_next:
        mov ah, 3Fh       ; Function 3Fh - read from a file or device
        mov bx, 0         ; stdin - input descriptor (standard input)
        mov cx, 1         ; Read 1 byte
        mov dx, offset oneChar ; Pointer to variable for storing one character
        int 21h           ; Call system interrupt for reading
        
        ; Check if the end of the file (EOF) has been reached
        or ax, ax         ; Check if ax is zero (end of file)
        jz read_end       ; If ax = 0, it means the end of the file was reached

        mov al, [oneChar] ; Load the read character into AL
        mov [currentLine + si], al ; Save AL (the character) into the buffer at [currentLine + si]

        mov dl, [currentLine + si]        ; Move the character into DL for printing
        mov ah, 02h                       ; Function 02h - output of a character
        int 21h                           ; Call system interrupt for output

        inc si ; Move to the next position in the buffer for the next character

        cmp al, 0Ah       ; Compare the character with ASCII code for newline
        jz new_line       ; If it's a newline, handle accordingly (new_line code not shown here)

        jmp read_next     ; Repeat the read loop
    
    show_line_info:
        mov di, offset currentLine
        call str_length
        mov ax, cx
        call print_number
        ret

    new_line:
        call show_line_info
        mov si, 0
        jmp read_next

    read_end:
        call show_line_info
        mov ah, 4Ch       ; Функція 4Ch - вихід з програми
        int 21h
main ENDP




str_length PROC
    push    ax              ; Save modified registers
    push    di

    xor     al, al          ; al <- search char (null)
    mov     cx, 0ffffh      ; cx <- maximum search depth
    cld                     ; Auto-increment di
    repnz   scasb           ; Scan for al while [di]<>null & cx<>0
    not     cx              ; Ones complement of cx
    dec     cx              ;  minus 1 equals string length

    pop     di              ; Restore registers
    pop     ax
    ret                     ; Return to caller    
str_length ENDP



print_number PROC
    mov  bl, 10
    mov  cx, sp
    loop_count:
        xor  ah, ah
        div  bl
        push ax           ; Remainder is in AH, don't care about AL
        test al, al
        jnz  loop_count
    loop_print:
        pop  ax           ; Remainder is in AH, don't care about AL
        mov  dl, ah
        add  dl, '0'
        mov  ah, 02h
        int  21h
        cmp  sp, cx
        jb   loop_print
    ret
print_number ENDP



END main
