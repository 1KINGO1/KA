.model small
.stack 100h

.data
    oneChar db ?
    searchParam db 255 dup(?)
    currentLine db 255 dup(?)
.code   
ORG 0100h
start:

    xor ch,ch ; Встановлюємо ch (верхній регістр) нулем
    mov cl, ds:[80h] ; Завантажуємо значення росташоване в пам'яті за адресую (це і є командний аргумент)
    mov si, 0 ; Задаєм початковий індекс

    ; Читаємо командний аргумент
    write_char:
        push si ; Зберігаємо індекс (бо він буде використовуватись далі в коді і нам не треба втратити значення)
        test cl, cl ; Перевіряємо чи cl = 0
        jz step_2 ; Якщо так, переходим на наступну фазу
        mov si, 81h ; Записуємо в si адресу 81h (перша після 80h)
        add si, cx
        mov dl, ds:[si]
        pop si ; Повертаємо з стеку індекс
        mov [searchParam + si], dl ; Записуємо в масив searchParam значення з командного аргументу

        ; mov ah, 02h
        ; mov dl, [searchParam + si]
        ; int 21h
        
        ; dec si 
        ;  mov ah, 02h
        ; mov dl, [searchParam + si]
        ; int 21h
        ; inc si

        inc si ; Збільшуємо індекс 
        dec cl ; Зменшуємо лічильник аргументів
        jmp write_char

        
    step_2: 
        mov si, 0 

        mov ah, 02h
        mov dl, 0Ah ; Виводимо розділитель (перенос строки)
        int 21h

        jmp read_next


    read_next:
        mov ah, 3Fh ; Функція 3Fh - читання з файлу
        mov bx, 0 ; stdin - input descriptor (standard input)
        mov cx, 1 ; Читання 1 байту
        mov dx, offset oneChar ; Вказівник на змінну для зберігання прочитаного байту
        int 21h ; Виклик системного переривання для читання
        
        ; Check if the end of the file (EOF) has been reached
        or ax, ax         ; Check if ax is zero (end of file)
        jz read_end       ; If ax = 0, it means the end of the file was reached

        mov al, [oneChar] ; Записуємо прочитаний символ в AL
        mov [currentLine + si], al ; Додаємо його в масив 

        mov dl, [currentLine + si]  
        mov ah, 02h ; Виводимо цей елемент масиву      
        int 21h                           

        inc si

        cmp al, 0Ah ; Порівнюємо символ з символом переносу строки
        jz find_string_count_preparation ; Перепригуємо на наступну фазу, якщо в нас кінець строки

        jmp read_next ; Повторюємо цикл читання, якщо ні

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
        xor  ah, ah ; ah = 0
        div  bl ; Ділимо значення в ax на bl (на 10) і записуємо результат в al, а остачу в ah
        push ax
        test al, al ; Перевіряємо чи дорівнює частка 0, якщо вона 0, значить число розкладено повністю
        jnz  loop_count
    loop_print:
        pop  ax
        mov  dl, ah ; dl = остача від ділення
        add  dl, '0' ; Додає асіі код символу 0 щоб отримати код цифри
        mov  ah, 02h ; виводимо і повторюємо
        int  21h
        cmp  sp, cx
        jb   loop_print
    ret
print_number ENDP

end start

