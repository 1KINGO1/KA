.model small
.stack 100h

.data
    oneChar db ?
    searchParam db 255 dup(?)
    currentLine db 255 dup(?)
.code   
ORG 0100h
start:

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
        
        ; dec si 
        ;  mov ah, 02h
        ; mov dl, [searchParam + si]
        ; int 21h
        ; inc si

        inc si
        dec cl
        jmp write_char

        
    step_2: 
        mov si, 0
        mov ah, 02h
        mov dl, 0Ah
        int 21h
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
        jz find_string_count_preparation       ; If it's a newline, handle accordingly (new_line code not shown here)

        jmp read_next     ; Repeat the read loop

    find_string_count_preparation:
        mov ax, 0
        mov si, 0
        jmp find_string_count

    find_string_count:
        mov bx, si
        push si

        lea si, searchParam 
        lea di, [currentLine + bx]
        call debug_1
        call str_pos
        pop si
        jz not_found
        jmp found        

    found: 
        call debug_2

        inc ax
    
        push ax
        mov ax, dx
        call print_number
        pop ax

        add si, dx
        ; add si, 1

        lea di, [currentLine + si]
        call str_length

        ; mov ah, 02h
        ; mov dx, cx
        ; int 21h

        ; push ax
        ; mov ax, cx
        ; call print_number
        ; call debug_4
        ; pop ax

        cmp cx, 0
        jz not_found
        jmp find_string_count
        ret

    not_found:
        call debug_3
        call print_number

        call cleanup

        jnc step_2
        ret

    cleanup:
        call clear_line_array
        mov si, 0

    ; new_line:
    ;     ;call show_line_info
    ;     call find_string_count_preparation
    ;     call cleanup
    ;     jmp read_next

    clear_line_array:
        mov si, 0
        mov cx, 255
        clear_loop:
            mov [currentLine + si], 0
            inc si
            loop clear_loop
        ret

    read_end:
       

        mov ah, 02h
        mov dl, 0Ah
        int 21h

        call find_string_count_preparationE

        mov ah, 4Ch       ; Функція 4Ch - вихід з програми
        int 21h





    find_string_count_preparationE:
        mov ax, 0
        mov si, 0
        jmp find_string_countE

    find_string_countE:
        mov bx, si
        push si

        lea si, searchParam 
        lea di, [currentLine + bx]
        call debug_1
        call str_pos
        pop si
        jz not_foundE
        jmp foundE      

    foundE: 
        call debug_2

        inc ax
    
        push ax
        mov ax, dx
        call print_number
        pop ax

        add si, dx
        ; add si, 1

        lea di, [currentLine + si]
        call str_length

        ; mov ah, 02h
        ; mov dx, cx
        ; int 21h

        ; push ax
        ; mov ax, cx
        ; call print_number
        ; call debug_4
        ; pop ax

        cmp cx, 0
        jz not_foundE
        jmp find_string_countE
        ret

    not_foundE:
        call debug_3
        call print_number

        call cleanup

        ; jnc read_next
        ret

    mov ax, 4C00h
    int 21h


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

str_compare PROC
    push    ax              ; Save modified registers
        push    di
        push    si
        cld                     ; Auto-increment si
@@10:
        lodsb                   ; al <- [si], si <- si + 1
        scasb                   ; Compare al and [di]; di <- di + 1
        jne     @@20            ; Exit if non-equal chars found
        or      al, al          ; Is al=0? (i.e. at end of s1)
        jne     @@10            ; If no jump, else exit
@@20:
        pop     si              ; Restore registers
        pop     di
        pop     ax
        ret        
str_compare ENDP

str_pos PROC
 push    ax              ; Save modified registers
        push    bx
        push    cx
        push    di

        call    str_length       ; Find length of target string
        mov     ax, cx          ; Save length(s2) in ax
        xchg    si, di          ; Swap si and di
        call    str_length       ; Find length of substring
        mov     bx, cx          ; Save length(s1) in bx
        xchg    si, di          ; Restore si and di
        sub     ax, bx          ; ax = last possible index
        jb      @@40            ; Exit if len target < len substring
        mov     dx, 0ffffh      ; Initialize dx to -1
@@30:
        inc     dx              ; For i = 0 TO last possible index
        mov     cl, byte ptr [bx + di]      ; Save char at s[bx] in cl
        mov     byte ptr [bx + di], 0 ; Replace char with null
        call    str_compare              ; Compare si to altered di
        mov     byte ptr [bx + di], cl      ; Restore replaced char
        je      @@40            ; Jump if match found, dx=index, zf=1
        inc     di              ; Else advance target string index
        cmp     dx, ax          ; When equal, all positions checked
        jne     @@30            ; Continue search unless not found

        xor     cx, cx          ; Substring not found.  Reset zf = 0
        inc     cx              ;  to indicate no match
@@40:
        pop     di              ; Restore registers
        pop     cx
        pop     bx
        pop     ax
        ret                     ; Return to caller  
str_pos ENDP

debug_1 PROC
    push ax
    push dx

    mov ah, 02h
    mov dx, "A"
    int 21h

    pop dx
    pop ax
    ret
debug_1 ENDP

debug_2 PROC
    push ax
    push dx

    mov ah, 02h
    mov dx, "B"
    int 21h

    pop dx
    pop ax
    ret
debug_2 ENDP

debug_3 PROC
    push ax
    push dx

    mov ah, 02h
    mov dx, "C"
    int 21h

    pop dx
    pop ax
    ret
debug_3 ENDP

debug_4 PROC
    push ax
    push dx

    mov ah, 02h
    mov dx, "D"
    int 21h

    pop dx
    pop ax
    ret
debug_4 ENDP

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

end start

