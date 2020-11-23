%include "io.inc"
extern _ExitProcess@4 
extern _ReadFile@20
extern _CreateFileA@28
extern _GetFileSize@8
extern _CloseHandle@4
extern _HeapAlloc@12
extern _GetLastError@0
extern _GetForegroundWindow@0
extern _LoadLibraryA@4
extern _GetProcAddress@8
extern _FreeLibrary@4
extern _printf
extern _malloc
extern _free


;TO-DO LIST
; 3. Develop system
;   B. 24 bit stereo
;   C. Frequencys
; 4. Clean and optimize
; 5. Create Commented copy
; 6. Develop Linux ver.

;; MAKE 24 BIT MORE EFFICIENT WITH JUST A MOV AND AN AND

;; fix final block averaging system

;; Remove peaking sys

;; LOCAL LABELS

;; use ESI

;; get rid of MakeNotZero, replace with a simple 'or bit 1'


section .data
    %define STD_INPUT_HANDLE -10
    %define OPEN_EXISTING 3
    %define NULL 0
    %define SHARE_READ 1
    %define GENERIC_READ 31
    %define HEAP_ZERO_MEMORY 8
    %define INPUT_SIZE 64
    %define CONSOLE_TEXTMODE 1
    %define MAX_SIZE 104857600
    %define BLOCK_SIZE_16 41000
    %define BLOCK_SIZE_24 250
    %define CUT_TOP_8 0x00FFFFFF

    hold_value dd 0
    hold_value2 dd 0
    hold_value3 dd 0
    hold_value4 dd 0
    hold_value5 dd 0
    hold_value6 dd 0
    hold_value7 dd 0
    
    tempPath db "C:\Users\PC\Desktop\16stereo.wav", 0
    hold_string TIMES INPUT_SIZE db 0
    len equ $ - hold_string
    libName db 'comdlg32.dll', 0
    procName db 'GetOpenFileNameA', 0
    procName2 db 'CommDlgExtendedError', 0
    filter db 'WAVE files (*.wav *.wave)', 0, '*.wav;*.wave;*.txt', 0, 0
    default_ext db 'wav', 0
    selected_file TIMES 256 db 0
    tooBig dd MAX_SIZE / 1048576
    blockCount dd 0
    ONE dd 1.0
    TWO dd 2.0
    TWENTY dd 20.0
    POINT_FOUR dd 0.4
    HUNDRED dd 100.0
    formatM db "%.1f dB-FS", 10, 0
    formatS db "%.1f", 0
    formatL db "L %.1f dB-FS", 10, 0
    formatR db "R %.1f dB-FS", 10, 0
    BASE dd 10.0
    temp dd 0
    bruh dd 0
    
    readBuffer dd 0
    
    addition_heap dd 0.0
    mpc dd 0
    compare dd 0
    gate db 0
    gate2 db 0
    
    the db 0
    stamk dd 0
    
    remainderBlock dd 0
    blockAmt dd 0
    
    block_size dd 0
    uab dd 0
    div_result dq 0
    log_result dq 0
    depth dd 0
    ab dq 0
    to_be_added dd 0
    final_result dd 0
    preAvg dd 0
    preAvg2 dd 0
    print dd 0
    print2 dd 0
    pile dd 0
    dataChunkSize dd 0
    blogg dd 0
    heap_L dd 0
    heap_R dd 0
    final_L dd 0
    final_R dd 0
    channel_L dd 0
    channel_R dd 0
    ss dd 0
    ssL dd 0
    ssR dd 0
    stereo dd 0
    numerator dd 0
    denominator dd 0
    separation_heap dd 0
    stereo_separation dd 0
    louder dd 0
    quieter dd 0
    N dd 0
    
    pointerMem dd 0
    path dd 0
    handle dd 0
    fileSize dd 0
    fileOut dd 0
    counter dd 0
    valueHold dd 0
    inputHandle dd 0
    consoleHandle dd 0
    userInput dd 0
    GetOpenFileNameA dd 0
    CommDlgExtendedError dd 0
    libHandle dd 0
    cdlgerr dd 0
    
    statusbar1 dd 0
    statusbar2 db '||||', 0
    statusbarC dd 0
    statusbarT dd 0
    

; DEFINE STRUCTURE    
struc OPENFILENAMEA
    
        .lStructSize resd 1
        .hwndOwner resd 1
        .hInstance resd 1
        .lpstrFilter resd 1
        .lpstrCustomFilter resd 1
        .nMaxCustFilter resd 1
        .nFilterIndex resd 1
        .lpstrFile resd 1
        .nMaxFile resd 1
        .lpstrFileTitle resd 1
        .nMaxFileTitle resd 1
        .lpstrInitialDir resd 1
        .lpstrTitle resd 1
        .Flags resd 1
        .nFileOffset resw 1
        .nFileExtension resw 1
        .lpstrDefExt resd 1
        .lCustData resd 1
        .lpfnHook resd 1
        .lpTemplateName resd 1
        .lpEditInfo resd 1
        .lpstrPrompt resd 1
        .pvReserved resd 1
        .dwReserved resd 1
        .FlagsEx resd 1
        
    endstruc 

    ; INITIALIZE STRUCTURE
fileStruct istruc OPENFILENAMEA
    
        at OPENFILENAMEA.lStructSize, dd NULL
        at OPENFILENAMEA.hwndOwner, dd NULL
        at OPENFILENAMEA.hInstance, dd NULL
        at OPENFILENAMEA.lpstrFilter, dd NULL
        at OPENFILENAMEA.lpstrCustomFilter, dd NULL
        at OPENFILENAMEA.nMaxCustFilter, dd NULL
        at OPENFILENAMEA.nFilterIndex, dd 1 ;index (1)
        at OPENFILENAMEA.lpstrFile, dd NULL
        at OPENFILENAMEA.nMaxFile, dd NULL
        at OPENFILENAMEA.lpstrFileTitle, dd NULL
        at OPENFILENAMEA.nMaxFileTitle, dd NULL
        at OPENFILENAMEA.lpstrInitialDir, dd NULL
        at OPENFILENAMEA.lpstrTitle, dd NULL
        at OPENFILENAMEA.Flags, dd 0x00021800
        at OPENFILENAMEA.nFileOffset, dw NULL
        at OPENFILENAMEA.nFileExtension, dw NULL
        at OPENFILENAMEA.lpstrDefExt, dd NULL
        at OPENFILENAMEA.lCustData, dd NULL
        at OPENFILENAMEA.lpfnHook, dd NULL
        at OPENFILENAMEA.lpTemplateName, dd NULL
        at OPENFILENAMEA.lpEditInfo, dd NULL
        at OPENFILENAMEA.lpstrPrompt, dd NULL
        at OPENFILENAMEA.pvReserved, dd NULL
        at OPENFILENAMEA.dwReserved, dd NULL
        at OPENFILENAMEA.FlagsEx, dd NULL
    
    iend  
    
            
section .bss
    ;readBuffer2 resb MAX_SIZE
    ;blockBuffer resb MAX_SIZE / 2

    
    ;for getInfo
    waveID resb 1
    
    ;for operation
    

section .text
    global _main
    
_main:
    mov ebp, esp; for correct debugging
    
    call loadLibraries
    PRINT_STRING "Loaded externals"
    NEWLINE
        
    call getFilePath
    PRINT_STRING "Finished getPath"
    NEWLINE
    
    call loadFile
    PRINT_STRING "Finished loadFile"
    NEWLINE
    
    call getInfo
    PRINT_STRING "getInfo finished..."
    NEWLINE
    
    ret
getFilePath:
    
    
    pop edx
    mov [hold_value], edx ;saves the pointer thingy
    
    
    PRINT_STRING "Attempting to show Open File menu"
    NEWLINE
    mov dword [selected_file+0], NULL
    
    mov dword [fileStruct + OPENFILENAMEA.lStructSize], 76 ;OPENFILENAMEA_size
    call _GetForegroundWindow@0
    mov dword [fileStruct + OPENFILENAMEA.hwndOwner], eax
    
    lea eax, [filter]
    mov dword [fileStruct + OPENFILENAMEA.lpstrFilter], eax
    
    lea eax, [selected_file]
    mov dword [fileStruct + OPENFILENAMEA.lpstrFile], eax
    
    mov dword [fileStruct + OPENFILENAMEA.nMaxFile], 256
    
    lea eax, [default_ext]
    mov dword [fileStruct + OPENFILENAMEA.lpstrDefExt], eax
    
    lea eax, [fileStruct]; ?
    push eax
    call [GetOpenFileNameA]
   
    PRINT_STRING "User entered: "
    PRINT_STRING selected_file
    NEWLINE        
        
    ; OPEN FILE HANDLE
    push NULL
    push NULL
    push OPEN_EXISTING
    push NULL
    push SHARE_READ
    push GENERIC_READ
    push selected_file
    call _CreateFileA@28
    mov dword [handle], eax
    
    PRINT_STRING "error check is... "
    ;error check
    
    cmp eax, 0
    jle ErrChk
    PRINT_STRING "none."
    NEWLINE
    
    mov eax, [libHandle]
    push eax
    call _FreeLibrary@4
    
    mov dword edx, [hold_value]
    push edx
    
    ret
    
loadFile: ; Loads file into memory
    
    
    pop edx
    mov [hold_value], edx ;saves the pointer thingy
    
    ; GET SIZE
    mov ecx, [handle]
    push NULL
    push ecx 
    call _GetFileSize@8
    PRINT_DEC 4, eax
    PRINT_STRING " bytes"
    NEWLINE
    mov [fileSize], eax
    
    ;cmp eax, MAX_SIZE
    ;jge fileTooBig
    
    ; ALLOCATE
    add dword [fileSize], 16 ;a bit of padding :)
    push dword [fileSize]
    call _malloc
    mov [readBuffer], eax
    
    PRINT_DEC 4, [readBuffer]
    NEWLINE
    
    ;test
    
    ; READ FILE  
    push NULL ;overlap
    push counter ;pointer to counter
    push dword [fileSize]
    push dword [readBuffer] ;pointer to output
    push dword [handle] ;pointer to handle
    call _ReadFile@20
    
    PRINT_DEC 4, eax
    NEWLINE
    
    ; CLOSE FILE
    mov ecx, [handle]
    push ecx
    call _CloseHandle@4
    
    mov dword edx, [hold_value]
    push edx
    
    ret
    
getInfo: ;Gets samplerate and bit depth, ect

    
    mov eax, [readBuffer]
        
    mov dword ebx, [eax+8]
    cmp ebx, "WAVE"
    jne notAwav
    
    
    mov word bx, [eax+34]
    cmp bx, 16
    je is16
    cmp bx, 24
    je is24
    
    call notAwav
    
    
    notAwav:
        PRINT_STRING "ERROR: The file you selected is not a true .WAV file, or the bit depth is not supported."
        GET_DEC 1, al
        
        push dword [readBuffer]
        call _free
        push NULL
        call _ExitProcess@4
        
    is16:
        PRINT_STRING "16 bit, "
        PRINT_DEC 2, [eax+22]
        PRINT_STRING " channels"
        NEWLINE
        
        mov bx, [eax+22]
        cmp bx, 1
        je mono16
        
        call stereo16
        
    is24:
        PRINT_STRING "24 bit, "
        PRINT_DEC 2, [eax+22]
        PRINT_STRING " channels"
        NEWLINE
        
        mov bx, [eax+22]
        cmp bx, 1
        je mono24
        
        call stereo24
        
mono16:
    
    PRINT_STRING "started MONO 16"
    NEWLINE
    
    mov eax, [readBuffer]
    mov edx, 0
    mov eax, [eax+40]
    mov ecx, 2
    div ecx ;puts # of samples in eax
    
    PRINT_DEC 4, eax
    PRINT_STRING " sample sets"
    NEWLINE
    
    
    mov edx, 0
    ;eax already good
    mov ecx, BLOCK_SIZE_16
    div ecx
    
    mov [blockAmt], eax
    
    PRINT_STRING "# of blocks: "
    PRINT_DEC 4, eax
    NEWLINE
    
    mov [remainderBlock], edx
    
    mov edx, 0
    ;eax good
    mov ecx, 10
    div ecx
    mov [statusbar1], eax
    
    mov eax, 0
    mov ebx, BLOCK_SIZE_16
    mov ecx, 43
    mov edx, 0
    
    PRINT_STRING "========================================"
    NEWLINE
    
    jmp loop16m
    retLoop16m:
    
    push dword 1 ;number of channels
    push dword [final_result]
    push NULL

    jmp postResults
    
    loop16m:
        
        inc ecx
        
        mov edx, [readBuffer]
        mov word dx, [edx+ecx*2]
        and edx, 0x0000FFFF
        
        bt dx, 15
        jc makePos16m
        retMakePos16m:
        
        add eax, edx
        
        dec ebx
        jz block16m
        
        retBlock16m: 
        cmp dword [blockAmt], 0
        jg loop16m
        
        
        mov ecx, [hold_value4]
        mov eax, 0
        mov ebx, [remainderBlock]
        jmp finalBlock16m
        retFinalBlock16m:
        
        jmp retLoop16m
         
        block16m:
            add dword [statusbarC], 1
            
            mov [hold_value4], ecx
            
            sub dword [blockAmt], 1
            
            or eax, 0x00000001 ;make not zero
            push dword 32767 ;16 bit depth
            push dword BLOCK_SIZE_16
            push eax
            call FPUfunc1
            
            ; store block
            push dword [addition_heap]
            push eax
            call FPUfunc2
            add dword [blockCount], 1

            mov eax, 0
            
            mov ebx, [statusbar1]
            cmp [statusbarC], ebx
            je addStatus16m 
            retAddStatus16m:
            
            mov ebx, BLOCK_SIZE_16
            
            jmp retBlock16m
            
            addStatus16m:
                cmp dword [statusbarT], 10
                je retAddStatus16m
                
                PRINT_STRING [statusbar2]
                mov dword [statusbarC], 0
                add dword [statusbarT], 1
                jmp retAddStatus16m
                
        finalBlock16m:
               
            inc ecx
            
            mov edx, [readBuffer]
            mov word dx, [edx+ecx*2]
            and edx, 0x0000FFFF
        
            bt dx, 15
            jc makePos16m2
            retMakePos16m2:
            
            add eax, edx
            
            dec ebx
            jnz finalBlock16m
            jz actualFinalBlock16m
            
            retActualFinalBlock16m:
            
            jmp retFinalBlock16m
            
            actualFinalBlock16m:
                ;PRINT_STRING "Actual final"
                ;NEWLINE
                add dword [blockCount], 1
                
                or eax, 0x00000001 ;make not zero
                push dword 32767 ;16 bit depth
                push dword [remainderBlock]
                push eax
                call FPUfunc1
                
                push dword [addition_heap]
                push eax
                call FPUfunc2
                
                push dword [addition_heap]
                call FPUfunc3
                
                call finishStatusBar16m
                
                jmp retActualFinalBlock16m
                
                finishStatusBar16m:
                    cmp dword [statusbarT], 10
                    jl fSB16m
                    
                    ret
                    
                    fSB16m:
                        PRINT_STRING [statusbar2]
                        add dword [statusbarT], 1
                        cmp dword [statusbarT], 10
                        jl fSB16m
                        ret
                
            makePos16m2: 
                neg dx
    
                jmp retMakePos16m2
                

        makePos16m: 
               
            neg dx
            
            add dword [mpc], 1
            jmp retMakePos16m
        
    
stereo16:
    
    ; AL is stereo switch
    ; EBX is counting for buffer
    ; ECX is counting/read point
    ; EDX is read
    
    PRINT_STRING "started STEREO 16"
    NEWLINE
    
    mov eax, [readBuffer]
    mov edx, 0
    mov eax, [eax+40]
    mov ecx, 4
    div ecx ;puts # of sample sets in eax
    
    PRINT_DEC 4, eax
    PRINT_STRING " sample sets"
    NEWLINE
    
    mov edx, 0
    ;eax already good
    mov ecx, BLOCK_SIZE_16
    div ecx
    
    mov [blockAmt], eax
    
    PRINT_DEC 4, eax
    NEWLINE
    
    mov [remainderBlock], edx
    
    mov edx, 0
    ;eax good
    mov ecx, 10
    div ecx
    mov [statusbar1], eax
    
    mov eax, 0
    mov ebx, BLOCK_SIZE_16 * 2
    mov ecx, 43
    mov edx, 0
    
    PRINT_STRING "========================================"
    NEWLINE
    
    jmp loop16s
    retLoop16s:
    
    push dword 2 ;number of channels
    push dword [final_L]
    push dword [final_R]
    jmp postResults
    loop16s:

        inc ecx
        
        mov edx, [readBuffer]
        mov word dx, [edx+ecx*2]
        and edx, 0x0000FFFF
        
       
        bt edx, 15
        jc makePos16s
        retMakePos16s:
        
        
        cmp al, 1
        je setRight16s
        mov al, 1
        add dword [channel_L], edx
        retSetRight16s:
        
        dec ebx
        jz block16s
        retBlock16s:
        
        cmp dword [blockAmt], 0
        jg loop16s
        
        mov dword [channel_L], 0
        mov dword [channel_R], 0
        mov ecx, [hold_value4]
        mov eax, 0
        mov ebx, [remainderBlock]
        
        jmp finalBlock16s
        retFinalBlock16s:
        
        jmp retLoop16s
        
        setRight16s:
            add dword [channel_R], edx
            mov al, 0
            jmp retSetRight16s
            
              
        block16s:
            add dword [statusbarC], 1

            mov [hold_value4], ecx
            
            sub dword [blockAmt], 1
            
            add dword [blockCount], 1
            
            
            ;Left first
            or dword [channel_L], 0x00000001 ;make not zero
            push dword 32767 ;16 bit depth
            push dword BLOCK_SIZE_16
            push dword [channel_L]
            call FPUfunc1
            
            ;PRINT_STRING "L tbadd "
            
            push dword [heap_L]
            push eax
            call FPUfunc2
            
            mov [heap_L], eax
            
            
            mov dword [channel_L], 0
            
            ;now right
            or dword [channel_R], 0x00000001 ;make not zero
            push dword 32767 ;16 bit depth
            push dword BLOCK_SIZE_16
            push dword [channel_R]
            call FPUfunc1
            
            push dword [heap_R]
            push eax
            call FPUfunc2
            
            mov [heap_R], eax
           
            mov dword [channel_R], 0
            
            mov ebx, [statusbar1]
            cmp [statusbarC], ebx
            je addStatus16s 
            retAddStatus16s:
            
            mov ebx, BLOCK_SIZE_16 * 2
            mov al, 0
              
            jmp retBlock16s
            
            addStatus16s:
                cmp dword [statusbarT], 10
                je retAddStatus16s
                
                PRINT_STRING [statusbar2]
                mov dword [statusbarC], 0
                add dword [statusbarT], 1
                jmp retAddStatus16s
                
        finalBlock16s:
            inc ecx
        
            mov edx, [readBuffer]
            mov word dx, [edx+ecx*2]
            and edx, 0x0000FFFF
            
            bt dx, 15
            jc makePos16s2
            retMakePos16s2:
        
        
            cmp al, 1
            je setRight16s2
            mov al, 1
            add dword [channel_L], edx
            retSetRight16s2:
            
            dec ebx
            cmp ebx, 0
            jg finalBlock16s
            jmp actualFinalBlock16s
            retActualFinalBlock16s:
            
            jmp retFinalBlock16s
            
            setRight16s2:
                add dword [channel_R], edx
                mov al, 0
                jmp retSetRight16s2
                
            actualFinalBlock16s:
                PRINT_STRING "Final"
                NEWLINE
                add dword [blockCount], 1
                
                ;left
                or dword [channel_L], 0x00000001 ;make not zero
                push dword 32767 ;16 bit depth
                push dword [remainderBlock]
                push dword [channel_L]
                call FPUfunc1
                
                push dword [heap_L]
                push eax
                call FPUfunc2
                
                push eax
                call FPUfunc3
                
                mov [final_L], eax
                
                ;right
                
                or dword [channel_R], 0x00000001 ;make not zero
                push dword 32767 ;16 bit depth
                push dword [remainderBlock]
                push dword [channel_R]
                call FPUfunc1
                
                push dword [heap_R]
                push eax
                call FPUfunc2
                
                push eax
                call FPUfunc3
                
                mov [final_R], eax
                
                call finishStatusBar16s
                
                jmp retActualFinalBlock16s
                
                finishStatusBar16s:
                    cmp dword [statusbarT], 10
                    jl fSB16s
                    
                    ret
                    
                    fSB16s:
                        PRINT_STRING [statusbar2]
                        add dword [statusbarT], 1
                        cmp dword [statusbarT], 10
                        jl fSB16s
                        ret
                
            makePos16s2: 
                neg dx
                add dword [mpc], 1
                jmp retMakePos16s2
                

        makePos16s: 
            neg dx
            jmp retMakePos16s
            
mono24:
    
    PRINT_STRING "started MONO 24"
    NEWLINE
    
    mov eax, [readBuffer]
    mov edx, 0
    mov eax, [eax+40]
    mov ecx, 3
    div ecx ;puts # of samples in eax
    PRINT_DEC 4, eax
    NEWLINE
    
    mov edx, 0
    ;eax already good
    mov ecx, BLOCK_SIZE_24
    div ecx
    
    mov [blockAmt], eax
    mov [remainderBlock], edx
    
    PRINT_DEC 4, [blockAmt]
    NEWLINE
    PRINT_DEC 4, [remainderBlock]
    NEWLINE
    
    mov edx, 0
    ;eax good
    mov ecx, 10
    div ecx
    mov [statusbar1], eax
    
    mov eax, 0
    mov ebx, BLOCK_SIZE_24
    mov ecx, 41
    mov edx, 0
    
    PRINT_STRING "===================="
    NEWLINE
    
    jmp loop24m
    retLoop24m:
    
    PRINT_STRING "Left loop"
    NEWLINE
    
    push dword 1 ;number of channels
    push dword [final_result]
    push dword NULL
    
    jmp postResults
    
    loop24m:
        add ecx, 3
        
        mov edx, [readBuffer]
        mov edx, [edx+ecx]
        and edx, CUT_TOP_8
        
        bt edx, 23
        jc makePos24m
        retMakePos24m:
        

        add eax, edx
        
        dec ebx
        jz block24m
        retBlock24m: 
        
        cmp dword [blockAmt], 0
        jg loop24m
        
        mov ecx, [hold_value4]
        mov eax, 0
        mov ebx, [remainderBlock]
        jmp finalBlock24m
        retFinalBlock24m:
        
        jmp retLoop24m

                 
        block24m:
            
            add dword [statusbarC], 1
            
            mov [hold_value4], ecx
            
            sub dword [blockAmt], 1
            
            or eax, 0x00000001 ;make not zero
            push dword 8388607 ;24 bit depth
            push dword BLOCK_SIZE_24
            push eax
            call FPUfunc1
            
            ; store block
            push dword [addition_heap]
            push eax
            call FPUfunc2
            add dword [blockCount], 1

            mov eax, 0
            
            mov ebx, [statusbar1]
            cmp [statusbarC], ebx
            je addStatus24m 
            retAddStatus24m:
            
            mov ebx, BLOCK_SIZE_24
            mov ecx, [hold_value4]
              
            jmp retBlock24m
            
            addStatus24m:
                cmp dword [statusbarT], 10
                je retAddStatus24m
                
                PRINT_STRING [statusbar2]
                mov dword [statusbarC], 0
                add dword [statusbarT], 1
                jmp retAddStatus24m
            
        finalBlock24m:
            add ecx, 3
            
            mov edx, [readBuffer]
            mov edx, [edx+ecx]
            and edx, CUT_TOP_8
            
            bt edx, 23
            jc makePos24m2
            retMakePos24m2:
            
            
            add eax, edx
            
            dec ebx
            cmp ebx, 0
            jg finalBlock24m
            jmp actualFinalBlock24m
            retActualFinalBlock24m:
            
            jmp retFinalBlock24m
            
            actualFinalBlock24m:
                PRINT_STRING "Actual final"
                NEWLINE
                PRINT_DEC 4, eax
                NEWLINE
                
                add dword [blockCount], 1
                
                or eax, 0x00000001 ;make not zero
                push dword 8388607 ;24 bit depth
                push dword [remainderBlock]
                push eax
                call FPUfunc1
             
                push dword [addition_heap]
                push dword [log_result]
                call FPUfunc2
                
                
                push dword [addition_heap]
                call FPUfunc3
                
                
                call finishStatusBar24m
                
                jmp retActualFinalBlock24m
                
                finishStatusBar24m:
                    cmp dword [statusbarT], 10
                    jl fSB24m
                    
                    ret
                    
                    fSB24m:
                        PRINT_STRING [statusbar2]
                        add dword [statusbarT], 1
                        cmp dword [statusbarT], 10
                        jl fSB24m
                        ret
                
            makePos24m2: 
                not edx
                inc edx
                and edx, CUT_TOP_8
                
                jmp retMakePos24m2
                


        makePos24m:
            not edx
            inc edx
            and edx, CUT_TOP_8
            
            add dword [mpc], 1
            jmp retMakePos24m

stereo24:
    
    ; AL is stereo switch
    ; EBX is counting for buffer
    ; ECX is counting/read point
    ; EDX is read
    
    PRINT_STRING "started STEREO 24"
    NEWLINE
    
    mov eax, [readBuffer]
    mov edx, 0
    mov eax, [eax+40]
    mov ecx, 6
    div ecx ;puts # of sample sets in eax
    
    PRINT_DEC 4, eax
    PRINT_STRING " sample sets"
    NEWLINE
    
    mov edx, 0
    ;eax already good
    mov ecx, BLOCK_SIZE_24
    div ecx
    
    mov [blockAmt], eax
    
    PRINT_DEC 4, eax
    NEWLINE
    
    mov [remainderBlock], edx
    
    PRINT_DEC 4, edx
    NEWLINE
    
    mov edx, 0
    ;eax good
    mov ecx, 10
    div ecx
    mov [statusbar1], eax
    
    mov eax, 0
    mov ebx, BLOCK_SIZE_24 * 2
    mov ecx, 41
    mov edx, 0
    
    PRINT_STRING "========================================"
    NEWLINE
    
    jmp loop24s
    retLoop24s:
    
    push dword 2 ;number of channels
    push dword [final_L]
    push dword [final_R]
    jmp postResults
    loop24s:
        add ecx, 3
        
        mov edx, [readBuffer]
        mov edx, [edx+ecx]
        and edx, CUT_TOP_8
        
        bt edx, 23
        jc makePos24s
        retMakePos24s:
        
        
        cmp al, 1
        je setRight24s
        mov al, 1
        add dword [channel_L], edx
        retSetRight24s:
        
        dec ebx
        jz block24s
        
        retBlock24s:
        
        cmp dword [blockAmt], 0
        jg loop24s
        
        mov dword [channel_L], 0
        mov dword [channel_R], 0
        mov ecx, [hold_value4]
        mov eax, 0
        mov ebx, [remainderBlock]
        PRINT_DEC 4, ebx
        NEWLINE
        ;sub ebx, 1
        
        PRINT_STRING 't'
        NEWLINE
        jmp finalBlock24s
        retFinalBlock24s:
        
        jmp retLoop24s
        
        setRight24s:
            add dword [channel_R], edx
            mov al, 0
            jmp retSetRight24s
            
              
        block24s:
            
            add dword [statusbarC], 1
            
            mov [hold_value4], ecx
            
            sub dword [blockAmt], 1
            
            add dword [blockCount], 1
            
            
            ;Left first
            or dword [channel_L], 0x00000001 ;make not zero
            push dword 8388607 ;24 bit depth
            push dword BLOCK_SIZE_24
            push dword [channel_L]
            call FPUfunc1
            
            ;PRINT_STRING "L tbadd "
            
            push dword [heap_L]
            push eax
            call FPUfunc2
            
            mov [heap_L], eax
            
            
            mov dword [channel_L], 0
            
            ;now right
            or dword [channel_R], 0x00000001 ;make not zero
            push dword 8388607 ;24 bit depth
            push dword BLOCK_SIZE_24
            push dword [channel_R]
            call FPUfunc1
            
            push dword [heap_R]
            push eax
            call FPUfunc2
            
            mov [heap_R], eax
           
            mov dword [channel_R], 0
            
            mov ebx, [statusbar1]
            cmp [statusbarC], ebx
            je addStatus24s 
            retAddStatus24s:
            
            mov ebx, BLOCK_SIZE_24 * 2
            mov al, 0
              
            jmp retBlock24s
            
            addStatus24s:
                cmp dword [statusbarT], 10
                je retAddStatus24s
                
                PRINT_STRING [statusbar2]
                mov dword [statusbarC], 0
                add dword [statusbarT], 1
                jmp retAddStatus24s
                
        finalBlock24s:
            
            add ecx, 3
            
            mov edx, [readBuffer]
            mov edx, [edx+ecx]
            and edx, CUT_TOP_8
            
            bt dx, 23
            jc makePos24s2
            retMakePos24s2:
            
            or edx, 0x00000001 ;make not zero
            
            cmp al, 1
            je setRight24s2
            mov al, 1
            add dword [channel_L], edx
            retSetRight24s2:
            
            dec ebx
            cmp ebx, 0
            jg finalBlock24s
            jmp actualFinalBlock24s
            retActualFinalBlock24s:
            
            jmp retFinalBlock24s
            
            setRight24s2:
                add dword [channel_R], edx
                mov al, 0
                jmp retSetRight24s2
                
            actualFinalBlock24s:
                PRINT_STRING 'final'
                NEWLINE
                
                add dword [blockCount], 1
                
                ;left
                
                or dword [remainderBlock], 0x00000001 ;ensure that it is not 0
                
                or dword [channel_L], 0x00000001 ;final check
                push dword 8388607 ;24 bit depth
                push dword [remainderBlock]
                push dword [channel_L]
                call FPUfunc1
                
                push dword [heap_L]
                push eax
                call FPUfunc2
                
                push eax
                call FPUfunc3
                
                mov [final_L], eax
                
                ;right
                
                or dword [channel_R], 0x00000001 ;final check
                
                push dword 8388607 ;24 bit depth
                push dword [remainderBlock]
                push dword [channel_R]
                call FPUfunc1
                
                push dword [heap_R]
                push eax
                call FPUfunc2
                
                push eax
                call FPUfunc3
                
                mov [final_R], eax
                
                call finishStatusBar24s
                
                jmp retActualFinalBlock24s
                
                finishStatusBar24s:
                    cmp dword [statusbarT], 10
                    jl fSB24s
                    
                    ret
                    
                    fSB24s:
                        PRINT_STRING [statusbar2]
                        add dword [statusbarT], 1
                        cmp dword [statusbarT], 10
                        jl fSB24s
                        ret
                
            makePos24s2: 
                not edx
                inc edx
                and edx, CUT_TOP_8

                jmp retMakePos24s2
                
                

        makePos24s: 
            not edx
            inc edx
            and edx, CUT_TOP_8
            jmp retMakePos24s
    
ErrChk:
    call _GetLastError@0
    PRINT_DEC 4, eax
    NEWLINE
    cmp eax, 3
    je fileNotFound
    cmp eax, 2
    je fileNotFound
    cmp eax, 123
    je fileNotFound
    
    PRINT_STRING "An unknown error occured, would you like to try again? (y/N) "
    
    call yesORno
    cmp al, 1
    je getFilePath
    
    push  NULL
    call  _ExitProcess@4
    
fileNotFound: ;error message

    PRINT_STRING "ERROR: File not found, or invalid path"
    NEWLINE
    
    GET_DEC 1, al
    
    push  NULL
    call  _ExitProcess@4
    

    
loadLibraries:
    pop edx
    mov [hold_value], edx ;saves the pointer thingy
    
    lea eax, [libName]
    push eax
    call _LoadLibraryA@4
    mov ebx, eax
    mov dword [libHandle], eax
    
    lea eax, [procName]
    push eax
    push ebx
    call _GetProcAddress@8
    mov dword [GetOpenFileNameA], eax
    
    mov dword edx, [hold_value]
    push edx
    
    ret
    
yesORno:
    mov al, 0
    GET_CHAR ah
    cmp ah, 'y'
    je yes
    cmp ah, 'Y'
    je yes
    cmp ah, 'n'
    je no
    cmp ah, 'N'
    je no
   
    ret
    
    yes:
        PRINT_STRING 'Trying again!'
        NEWLINE
        mov al, 1
        ret
    no:
        mov al, 0
        ret
        
postResults:
   
    pop dword [print2]
    pop dword [print]
    pop ebx
    
    push dword [readBuffer]
    call _free
    
    NEWLINE
    PRINT_STRING "========================================"
    cmp ebx, 1
    je postMono
    
    NEWLINE
    PRINT_STRING "Stereo results:"
    NEWLINE
    fld dword [print]
    fstp qword [esp-8]
    sub esp, 8
    push formatL
    call _printf
    add esp, 12
    
    fld dword [print2]
    fstp qword [esp-8]
    sub esp, 8
    push formatR
    call _printf
    add esp, 12
    
    
    GET_DEC 1, al
    
    push NULL
    call _ExitProcess@4
    
    postMono:
        
        NEWLINE
        PRINT_STRING "Mono results: "
        NEWLINE
        fld dword [print]
        fstp qword [esp-8]
        sub esp, 8
        push formatM
        call _printf
        add esp, 12
        
        
        
        
        PRINT_STRING "largest num: "
        PRINT_DEC 4, [compare]
        NEWLINE
        PRINT_STRING "Neg# "
        PRINT_DEC 4, [mpc]
        NEWLINE
        
        GET_DEC 1, al
        
        push NULL
        call _ExitProcess@4
        
FPUfunc1:
    pop dword [hold_value] ;saves the pointer thingy
    
    pop dword [uab] ;Un-Altered Block 
    pop dword [block_size] ;# of block elements to be averaged
    pop dword [depth]
    
    ;Logarithm using x87 set
    finit 
    
    PRINT_STRING '1 '
    PRINT_HEX 4, [uab]
    NEWLINE
    
    ;avg ssample height
    fild dword [uab] ;/
    fild dword [block_size]
    fdiv 
    
    fstp dword [ab]
    
    
    ;Float divide 
    fild dword [depth]
    fld dword [ab]
    fdiv st1
    fstp dword [div_result]
    
    
    ;Log2 10
    fld dword [ONE]  
    fld dword [BASE]    
    fyl2x 
    
    ;Log2 sample value
    fld dword [ONE]
    fld dword [div_result] ;num
    fyl2x
    
    ;Get Log10(value) * 20
    fdiv st1
    fld dword [TWENTY]
    fmul st1
    
    fstp dword [log_result]
    
    mov eax, [log_result] ;return value
    

    push dword [hold_value]
    ret
    
FPUfunc2: 
    pop dword [hold_value6]
    
    ; Addition
    pop dword [to_be_added]
    pop dword [addition_heap]
    
    
    finit
    
    fld dword [to_be_added]
    fld dword [addition_heap]
    fadd 
    
    fstp dword [addition_heap]
    
    PRINT_HEX 4, [addition_heap]
    NEWLINE
    
    mov eax, [addition_heap]
    
    push dword [hold_value6]
    ret
    
FPUfunc3:
    pop dword [hold_value]
    
    pop dword [preAvg]
    
    ; Average whole
    finit
    
    fld dword [preAvg] ;/
    fild dword [blockCount]
    fdiv 
    
    fstp dword [final_result]
    
    
    mov eax, [final_result] ;for 2 channel ops
    
    push dword [hold_value]
    ret
   
    
    
    
    
    
    
  

            
            
        
        
        
        
        
        
        
        
 
    
