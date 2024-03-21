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
        ; stdin - дескриптор вводу (стандартний ввід)
        ; mov ah, 02h
        ; mov dl, ds:[si]
        ; int 21h
        dec cl
        jmp write_char
    step_2: 
        mov si, 0
        jmp read_next
    read_next:
        mov ah, 3Fh       ; Функція 3Fh - зчитування з файлу або пристрою
        mov bx, 0         ; stdin - дескриптор вводу (стандартний ввід)
        mov cx, 1         ; Читати 1 байт
        mov dx, offset oneChar ; Покажчик на змінну для зберігання одного символу
        int 21h           ; Виклик системного переривання для читання
        ; Перевірка чи досягнуто кінця файлу (EOF)
        or ax, ax         ; Перевірка на те, чи рівне ax нулю (кінець файлу)
        jz read_end    ; Якщо ax = 0, це означає, що був досягнутий кінець файлу

        ; Вивід символу, який було прочитано
        mov ah, 02h       ; Функція 02h - виведення символу
        mov dl, [oneChar] ; Завантаження символу для виводу
        int 21h           ; Виклик системного переривання для виводу

        cmp byte ptr [oneChar], 0Ah  ; Compare oneChar with ASCII code for newline
        jz new_line

        ; Повторення циклу читання
        jmp read_next
    new_line:
        ; New line 
        jmp read_next
    read_end:
    
        mov ah, 4Ch       ; Функція 4Ch - вихід з програми
        int 21h
main ENDP
END main
