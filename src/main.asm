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

        mov ah, 02h
        mov dl, [searchParam + si]
        int 21h
        
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
    
    
    new_line:
        ; New line 
        jmp read_next


    read_end:
    
        mov ah, 4Ch       ; Функція 4Ch - вихід з програми
        int 21h
main ENDP
END main
