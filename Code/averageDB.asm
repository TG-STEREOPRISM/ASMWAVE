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

;; use ESI

;; Swap 'blockAmt' and 'blockCount'

     ;;current issues:
        
        ;large files not doing DFT properly. Negativve number after |||| ? see VoyDyn16s.  
            ;first block somehow messes stuff up / decides everything
                ;SUB band is the only one that isn't 'stuck' in place...
            
            ;also MAKE SURE STEREO dft WORKS - THEORETICALLY
            
            
            
            
section .data
    %define OPEN_EXISTING 3
    %define NULL 0
    %define SHARE_READ 1
    %define GENERIC_READ 31
    %define INPUT_SIZE 64
    %define CONSOLE_TEXTMODE 1
    %define MAX_SIZE 104857600
    %define BLOCK_SIZE_16 44100
    %define BLOCK_SIZE_24 250
    %define CUT_TOP_8 0x00FFFFFF
    %define DFT_SIZE 4096 * 4
       
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
    FIVE dd 5.0
    formatM db "%.1f dB-FS", 10, 0
    formatS db "%.1f", 0
    formatL db "L %.1f dB-FS", 10, 0
    formatR db "R %.1f dB-FS", 10, 0
    BASE dd 10.0
    temp dd 0
    bruh dq 0
    
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
    numerator dq 0
    denominator dq 0
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
    
    iter dd 0
    k dd 0
    TWO_TIMES_PI dd 6.28318531
    realResult TIMES 256 dd 0.0
    imagiResult TIMES 256 dd 0.0
    hold_calc dd 0
    format db "%.1f", 10, 0
    Re dd 0
    Im dd 0
    calc dd 0
    TEN dd 10.0
    finalDFT TIMES 8 dd 0
    
    subBand dd 0
    bassBand dd 0
    midBand dd 0
    highBand dd 0
    vhBand dd 0
    
    dftResult TIMES 256 dd 0
    lookUp1 dd 0.0, 0.031416, 0.062832, 0.094248, 0.125664, 0.15708, 0.188496, 0.219911, 0.251327, 0.282743, 0.314159, 0.345575, 0.376991, 0.408407, 0.439823, 0.471239, 0.502655, 0.534071, 0.565487, 0.596903, 0.628319, 0.659734, 0.69115, 0.722566, 0.753982, 0.785398, 0.816814, 0.84823, 0.879646, 0.911062, 0.942478, 0.973894, 1.00531, 1.036726, 1.068142, 1.099557, 1.130973, 1.162389, 1.193805, 1.225221, 1.256637, 1.288053, 1.319469, 1.350885, 1.382301, 1.413717, 1.445133, 1.476549, 1.507964, 1.53938, 1.570796, 1.602212, 1.633628, 1.665044, 1.69646, 1.727876, 1.759292, 1.790708, 1.822124, 1.85354, 1.884956, 1.916372, 1.947787, 1.979203, 2.010619, 2.042035, 2.073451, 2.104867, 2.136283, 2.167699, 2.199115, 2.230531, 2.261947, 2.293363, 2.324779, 2.356194, 2.38761, 2.419026, 2.450442, 2.481858, 2.513274, 2.54469, 2.576106, 2.607522, 2.638938, 2.670354, 2.70177, 2.733186, 2.764602, 2.796017, 2.827433, 2.858849, 2.890265, 2.921681, 2.953097, 2.984513, 3.015929, 3.047345, 3.078761, 3.110177, 3.141593, 3.173009, 3.204425, 3.23584, 3.267256, 3.298672, 3.330088, 3.361504, 3.39292, 3.424336, 3.455752, 3.487168, 3.518584, 3.55, 3.581416, 3.612832, 3.644247, 3.675663, 3.707079, 3.738495, 3.769911, 3.801327, 3.832743, 3.864159, 3.895575, 3.926991, 3.958407, 3.989823, 4.021239, 4.052655, 4.08407, 4.115486, 4.146902, 4.178318, 4.209734, 4.24115, 4.272566, 4.303982, 4.335398, 4.366814, 4.39823, 4.429646, 4.461062, 4.492477, 4.523893, 4.555309, 4.586725, 4.618141, 4.649557, 4.680973, 4.712389, 4.743805, 4.775221, 4.806637, 4.838053, 4.869469, 4.900885, 4.9323, 4.963716, 4.995132, 5.026548, 5.057964, 5.08938, 5.120796, 5.152212, 5.183628, 5.215044, 5.24646, 5.277876, 5.309292, 5.340708, 5.372123, 5.403539, 5.434955, 5.466371, 5.497787, 5.529203, 5.560619, 5.592035, 5.623451, 5.654867, 5.686283, 5.717699, 5.749115, 5.78053, 5.811946, 5.843362, 5.874778, 5.906194, 5.93761, 5.969026, 6.000442, 6.031858, 6.063274, 6.09469, 6.126106, 6.157522, 6.188938, 6.220353, 6.251769
    lookUpPtr dd 0
    sample dd 0
    LU dd 0
    offset dd 0
    sampleAmt dd 0
    greatest dd 0
    band_label db 'SU', 0, 'BA', 0, 'MI', 0, 'HI', 0, 'VH', 0

    
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
    painAndSuffering resd 6

    
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
    
    ;error check
    
    cmp eax, 0
    jle fileNotFound
    
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
     
    
    ; ALLOCATE
    add dword [fileSize], 16 ;a bit of padding :)
    push dword [fileSize]
    call _malloc
    mov [readBuffer], eax
    
    PRINT_DEC 4, [readBuffer]
    NEWLINE
    
    
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
    mov [blockCount], eax
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
        PRINT_DEC 4, [remainderBlock]
        PRINT_STRING ' rem'
        NEWLINE
        
        jmp finalBlock16m
        retFinalBlock16m:
        
        call DFT_16
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
            cmp ebx, 0
            jg finalBlock16m
            jmp actualFinalBlock16m
            
            retActualFinalBlock16m:
            
            jmp retFinalBlock16m
            
            actualFinalBlock16m:
            
                PRINT_STRING ' yo '
                
                or dword [remainderBlock], 0x00000001
                or eax, 0x00000001 ;make not zero
                push dword 32767 ;16 bit depth
                push dword [remainderBlock]
                push eax
                call FPUfunc1
                
                push dword BLOCK_SIZE_16
                push eax
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
    mov [blockCount], eax
    
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
        shl ebx, 1
        jmp finalBlock16s
        retFinalBlock16s:
        
        PRINT_DEC 4, [final_L]
        NEWLINE
        
        call DFT_16
        jmp retLoop16s
        
        setRight16s:
            add dword [channel_R], edx
            mov al, 0
            jmp retSetRight16s
            
              
        block16s:

            add dword [statusbarC], 1

            mov [hold_value4], ecx
            
            sub dword [blockAmt], 1
            
            
            
            ;Left first
            or dword [channel_L], 0x00000001 ;make not zero
            push dword 32767 ;16 bit depth
            push dword BLOCK_SIZE_16
            push dword [channel_L]
            call FPUfunc1
            
            
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
                ;left
                or dword [remainderBlock], 0x00000001
                or dword [channel_L], 0x00000001 ;make not zero
                push dword 32767 ;16 bit depth
                push dword [remainderBlock]
                push dword [channel_L]
                call FPUfunc1
                
                push dword BLOCK_SIZE_16
                push eax
                push dword [heap_L]
                call FPUfunc3
                
                mov [final_L], eax
                
                ;right
                or dword [channel_R], 0x00000001 ;make not zero
                push dword 32767 ;16 bit depth
                push dword [remainderBlock]
                push dword [channel_R]
                call FPUfunc1
                
                push dword BLOCK_SIZE_16
                push eax
                push dword [heap_R]
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
    mov [blockCount], eax
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
        shl ebx, 1
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
                
                PRINT_DEC 4, eax
                NEWLINE
                
                or dword [remainderBlock], 0x00000001
                or eax, 0x00000001 ;make not zero
                push dword 8388607 ;24 bit depth
                push dword [remainderBlock]
                push eax
                call FPUfunc1
                
                ;PRINT_HEX 4, eax
                ;NEWLINE
                
                push dword BLOCK_SIZE_24
                push eax
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
    mov [blockCount], eax
    
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
        shl ebx, 1
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
            
            
                or dword [remainderBlock], 0x00000001
                or dword [channel_L], 0x00000001 ;make not zero
                push dword 8388607 ;24 bit depth
                push dword [remainderBlock]
                push dword [channel_L]
                call FPUfunc1
                
                push dword BLOCK_SIZE_24
                push eax
                push dword [heap_L]
                call FPUfunc3
                
                mov [final_L], eax
                
                ;right
                or dword [channel_R], 0x00000001 ;make not zero
                push dword 8388607 ;24 bit depth
                push dword [remainderBlock]
                push dword [channel_R]
                call FPUfunc1
                
                push dword BLOCK_SIZE_24
                push eax
                push dword [heap_R]
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
    
    
fileNotFound: ;error message

    PRINT_STRING "ERROR: File not found, or invalid path."
    NEWLINE
    
    PRINT_STRING 'Goodbye...'
    
    ;wait for a sec
    mov ecx, 1700000000
    mov eax, 1
    .lopp:
        mul ecx
        dec ecx
        jnz .lopp
        
    push NULL 
    call _ExitProcess@4
    
loadLibraries:
    pop dword [stamk]
    
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
    
    push dword [stamk]
    
    ret
           
postResults:
    
    pop dword [print2]
    pop dword [print]
    pop ebx
    
    push dword [readBuffer]
    call _free ;begone, o' accursed memory
    
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
    
    call Print_FT
    
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
        
        call Print_FT
        
        GET_DEC 1, al
        
        push NULL
        call _ExitProcess@4
        
FPUfunc1:
    pop dword [hold_value] ;saves the pointer thingy
    pop dword [uab] ;Un-Altered Block 
    pop dword [block_size] ;# of block elements to be averaged
    pop dword [depth]
    
;    PRINT_DEC 4, [uab]
;    NEWLINE
;    PRINT_DEC 4, [block_size]
;    NEWLINE
    
    ;Logarithm using x87 set
    finit 
    
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
    
    
;    PRINT_HEX 4, [log_result]
;    NEWLINE
    
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

    mov eax, [addition_heap]
    
    push dword [hold_value6]
    ret
    
FPUfunc3:
    pop dword [hold_value]
    
    pop dword [preAvg]
    
    pop dword [preAvg2] ;last block
    
    pop dword [depth]
   
    ; Average whole
    finit
    
    ;weighted average ( (x*y + a*b) / (x + a) )
    
    ;new system to prevent overflow:
    ;   
    ;   A = a / blockCount
    ;   q = remainderBlock / blockCount * BLOCK_SIZE
    ;   z = 1 - q
    ;   
    ;example: 4 main blocks of 3, 30 each, remainder block of 2 x 10
    ;   10, 10, 10, 10,   10, 10, 10, 10,   10, 10, 10, 10,   10, 10, 10, 10,   10, 10, -, -,
    ;   
    ;   (z*A + q*b) = avg
    ;   ( (0.83*10 + 0.17*10) )
    ;   
    ; 
    ;
    ;
    ;
    ;
    ;
    ;
    
    fld dword [preAvg] ;/
    fild dword [blockCount] ;*
    fdiv ;A
    
;    PRINT_STRING 'A '
;    fst dword [bruh]
;    PRINT_HEX 4, [bruh]
;    NEWLINE
    
    fld dword [ONE]
    fild dword [remainderBlock] ;/
    fild dword [blockCount] ;*
    fild dword [depth]
    fmul
    fdiv ;q
    fst dword [calc]
    
;    PRINT_STRING 'q '
;    fst dword [bruh]
;    PRINT_HEX 4, [bruh]
;    NEWLINE
    
    fsub ;1-q
    
;    PRINT_STRING 'z '
;    fst dword [bruh]
;    PRINT_HEX 4, [bruh]
;    NEWLINE
    
    fmul ;A * z
    
    fld dword [calc] ;*
    fld dword [preAvg2]
    fmul ;q*b
    
;    PRINT_STRING 'b '
;    PRINT_HEX 4, [preAvg2]
;    NEWLINE 
    
;    PRINT_STRING 'q*b '
;    fst dword [bruh]
;    PRINT_HEX 4, [bruh]
;    NEWLINE  
     
    fadd
    
    fstp dword [final_result]
    
    mov eax, [final_result]
    
    push dword [hold_value]
    ret
    
DFT_16:
    
    pop dword [stamk]
    ;will get all on mono, every other on stereo, naturally
    .preCalc:
        
        PRINT_STRING "precalc started"
        NEWLINE
        
        push dword (200 * DFT_SIZE * 2 * 4) + 4
        call _malloc
        mov [lookUpPtr], eax
        
        ;loops 200 by DFT_SIZE times
        mov ecx, 0
        mov dword [iter], 0
        .freqPre:   
            mov ebx, 0
            mov dword [sample], 0
            .samplePre:
                fld dword [lookUp1+ecx*4]
                fild dword [sample]
                fmul
                fst dword [calc]
                
                fcos 
                fstp dword [eax+edx*4]
                
                add edx, (DFT_SIZE * 200) + 2
                fld dword [calc]
                fsin
                fstp dword [eax+edx*4]
                sub edx, (DFT_SIZE * 200) + 2
                
                inc dword [sample]
                inc ebx
                inc edx
                cmp ebx, DFT_SIZE
                jl .samplePre
                    
            inc ecx
            inc dword [iter]
            cmp ecx, 200
            jl .freqPre
    
    mov dword [iter], 0
    mov dword [N], 200
    mov dword [LU], 0
    
    mov ebx, [readBuffer]
    mov edx, 0
    mov eax, [ebx+40]
    
    mov ecx, 2 ;16bit
    div ecx 
    mov edx, 0
    div word [ebx+22] ;eax has # of samples
    
    mov edx, 0
    mov ecx, DFT_SIZE
    div ecx
    
    mov [blockAmt], eax
    
    PRINT_STRING "DFT BLOCKS AMT: "
    PRINT_DEC 4, [blockAmt]
    NEWLINE
    mov [blockCount], eax
    
    mov [remainderBlock], edx
   
    
    mov eax, [readBuffer]
    add eax, 44
    mov ecx, 0
    mov edx, [lookUpPtr]
    mov esi, 0
    
    .blocks:
        PRINT_STRING 'blocks started! (DFT)'
        NEWLINE
        .dftBlock:
            
            ;PRINT_STRING 'b'
            ;NEWLINE
            mov dword [Re], 0
            mov dword [Im], 0
            mov ebx, 0
            push ecx
            mov ecx, [LU]
            mov esi, [offset]
            mov edx, [lookUpPtr]
            finit
            .dftMath:
                fld dword [Im]
                
                ;real 
                fld dword [edx+ecx*4]
                fild word [eax+esi*2]
                fmul
                fld dword [Re]
                fadd
                fstp dword [Re]
                
                ;imaginary
                add ecx, (DFT_SIZE * 200) + 2
                
                fld dword [edx+ecx*4]
                fild word [eax+esi*2]
                fmul
                ;fstp dword [hold_calc]
                
                sub ecx, (DFT_SIZE * 200) + 2
                
                ;fld dword [Im]                     (up top)<<<
                ;fld dword [hold_calc]
                fsub
                fstp dword [Im]      
                
                inc ebx
                inc ecx
                inc esi
                cmp ebx, DFT_SIZE
                jl .dftMath
                mov [LU], ecx  
                                       ;<    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;PRINT_DEC 4, [offset]
            ;NEWLINE    
            pop ecx  
            mov ebx, [Re]
            mov [realResult+ecx*4], ebx
            mov ebx, [Im]
            mov [imagiResult+ecx*4], ebx
            
            inc ecx
            
            inc dword [iter]
            cmp dword [iter], 200
            jl .dftBlock
            
        .finishDFT:
            mov dword [N], DFT_SIZE
            mov ecx, 0
            
            PRINT_STRING '============= '
            PRINT_DEC 4, [blockCount]
            NEWLINE
            
            .dftLoop:
                ; sqrt(Im^2 + Re^2)
                finit 
                TIMES 2 fld dword [realResult+ecx*4]
                fmul
                fstp dword [hold_calc]
                TIMES 2 fld dword [imagiResult+ecx*4]
                fmul 
                fld dword [hold_calc]
                fadd
                fsqrt
                fild dword [N]
                fdiv
                
;                fist dword [bruh]
;                PRINT_DEC 4, [bruh]
;                NEWLINE
                
                fld dword [dftResult+ecx*4]
                fadd
                fstp dword [dftResult+ecx*4]
               
                
                
                inc ecx
                cmp ecx, 200 / 2
                jl .dftLoop
;# # # TESTING ZONE # # # # # # # # # # # # # # # # # # # # # # # # #
;the goal of this area is to print the averages of each band for each dft block to help analyze what is going wrong.
        
        finit 
        fld dword [dftResult+0*4];/      
        fld dword [TEN]
        fmul
        fistp dword [subBand]
        
        MOV DWORD [dftResult+0*4], 0
        
        ;2 and 3
        mov dword [N], 2
        finit
        fld dword [dftResult+1*4]
        
        MOV DWORD [dftResult+1*4], 0
        
        fstp dword [bassBand]
        
        mov ecx, 2
        .TESTband2:                                                     ;TEST ZONE
            finit
            fld dword [bassBand]
            fld dword [dftResult+ecx*4]
            fadd
            fstp dword [bassBand]
            
            MOV DWORD [dftResult+ecx*4], 0
            
            inc ecx
            cmp ecx, 2
            jle .TESTband2  
        
        finit
        fld dword [bassBand]
        
        
        fild dword [N]
        fdiv
        fld dword [TEN]
        fmul
        fistp dword [bassBand]
        
        ;4 through 15
        mov dword [N], 12
        finit
        fld dword [dftResult+4*4]
        
        MOV DWORD [dftResult+4*4], 0
            
        fstp dword [midBand]
        mov ecx, 5
        .TESTband3:                                                         ;TEST ZONE
            finit
            fld dword [midBand]
            fld dword [dftResult+ecx*4]
            fadd
            fstp dword [midBand]
            
            MOV DWORD [dftResult+ecx*4], 0
            
            inc ecx
            cmp ecx, 14
            jle .TESTband3  
            
        finit
        fld dword [midBand]
        
        
        fild dword [N]
        fdiv
        fld dword [TEN]
        fmul
        fistp dword [midBand]
        
        ;16 through 32 
        mov dword [N], 17
        finit
        fld dword [dftResult+15*4]
        
        MOV DWORD [dftResult+15*4], 0
            
        fstp dword [highBand]
        mov ecx, 16
        .TESTband4:                                                 ;TEST ZONE
            finit
            fld dword [highBand]
            fld dword [dftResult+ecx*4]
            fadd
            fstp dword [highBand]
            
            MOV DWORD [dftResult+ecx*4], 0
            
            inc ecx
            cmp ecx, 31
            jle .TESTband4  
            
        finit
        fld dword [highBand]
        

        
        fild dword [N]
        fdiv
        fld dword [TEN]
        fmul
        fistp dword [highBand]
        
        ;33 through 96
        mov dword [N], 64
        finit
        fld dword [dftResult+32*4]

        MOV DWORD [dftResult+32*4], 0
            
        fstp dword [vhBand]
        mov ecx, 33
        .TESTband5:                                                     ;TEST ZONE
            finit
            fld dword [vhBand]
            fld dword [dftResult+ecx*4]
            fadd
            fstp dword [vhBand]
            
            MOV DWORD [dftResult+ecx*4], 0
            
            inc ecx
            cmp ecx, 95
            jle .TESTband5 
            
        finit
        fld dword [vhBand]
        
        
        fild dword [N]
        fdiv
        fld dword [TEN]
        fmul
        fistp dword [vhBand]
        
        PRINT_STRING 'SU '
        PRINT_DEC 4, [subBand]
        NEWLINE
        PRINT_STRING 'BA '
        PRINT_DEC 4, [bassBand]
        NEWLINE
        PRINT_STRING 'MI '
        PRINT_DEC 4, [midBand]
        NEWLINE
        PRINT_STRING 'HI '
        PRINT_DEC 4, [highBand]
        NEWLINE
        PRINT_STRING 'VH '
        PRINT_DEC 4, [vhBand]
        NEWLINE

;# # # END TESTING ZONE # # # # # # # # # # # # # # # # # # # # # # #


                
    add dword [offset], DFT_SIZE
    mov ecx, 0
    mov dword [LU], 0
    
        
    ;pop ebx
    dec dword [blockCount]
    
    cmp dword [blockCount], 0
    jg .dftBlock
    
    PRINT_STRING '---------'
    NEWLINE
    finit
    push ecx
    mov ecx, 0
    .debug_loop:
        fld dword [dftResult+ecx*4]
        fistp dword [bruh]
        PRINT_DEC 4, [bruh]
        NEWLINE
        inc ecx
        cmp ecx, 200 / 2
        jl .debug_loop
    pop ecx
    
    PRINT_STRING 'amt '
    PRINT_DEC 4, [blockAmt]
    NEWLINE            
    .formatDFT:

        ;1
        finit 
        fld dword [dftResult+0*4];/

        PRINT_STRING 'subband before getting averaged: '
        PRINT_HEX 4, [dftResult+0*4]
        NEWLINE
        
;        fild dword [blockAmt]
;        fdiv
        fld dword [TEN]
        fmul
        fistp dword [subBand]
        
        ;2 and 3
        mov dword [N], 2
        finit
        fld dword [dftResult+1*4]
        fstp dword [bassBand]
        mov ecx, 2
        .band2:
            finit
            fld dword [bassBand]
            fld dword [dftResult+ecx*4]
            fadd
            fstp dword [bassBand]
            
            inc ecx
            cmp ecx, 2
            jle .band2  
        
        finit
        fld dword [bassBand]
        
        PRINT_STRING 'bassband before getting averaged: '
        PRINT_HEX 4, [bassBand]
        NEWLINE
        
        fild dword [N]
        fdiv
;        fild dword [blockAmt]
;        fdiv
        fld dword [TEN]
        fmul
        fistp dword [bassBand]
        
        ;4 through 15
        mov dword [N], 12
        finit
        fld dword [dftResult+3*4]
        fstp dword [midBand]
        mov ecx, 4
        .band3:
            finit
            fld dword [midBand]
            fld dword [dftResult+ecx*4]
            fadd
            fstp dword [midBand]
            
            inc ecx
            cmp ecx, 14
            jle .band3  
            
        finit
        fld dword [midBand]
        
        PRINT_STRING 'midband before getting averaged: '
        PRINT_HEX 4, [midBand]
        NEWLINE
        
        fild dword [N]
        fdiv
;        fild dword [blockAmt]
;        fdiv
        fld dword [TEN]
        fmul
        fistp dword [midBand]
        
        ;16 through 32 
        mov dword [N], 17
        finit
        fld dword [dftResult+15*4]
        fstp dword [highBand]
        mov ecx, 16
        .band4:
            finit
            fld dword [highBand]
            fld dword [dftResult+ecx*4]
            fadd
            fstp dword [highBand]
            
            inc ecx
            cmp ecx, 31
            jle .band4  
            
        finit
        fld dword [highBand]
        
        PRINT_STRING 'highband before getting averaged: '
        PRINT_HEX 4, [highBand]
        NEWLINE
        
        fild dword [N]
        fdiv
;        fild dword [blockAmt]
;        fdiv
        fld dword [TEN]
        fmul
        fistp dword [highBand]
        
        ;33 through 96
        mov dword [N], 64
        finit
        fld dword [dftResult+32*4]
        fstp dword [vhBand]
        mov ecx, 33
        .band5:
            finit
            fld dword [vhBand]
            fld dword [dftResult+ecx*4]
            fadd
            fstp dword [vhBand]
            
            inc ecx
            cmp ecx, 95
            jle .band5 
            
        finit
        fld dword [vhBand]
        
        PRINT_STRING 'vhband before getting averaged: '
        PRINT_HEX 4, [vhBand]
        NEWLINE
        
        fild dword [N]
        fdiv
;       fild dword [blockAmt]
;       fdiv
        fld dword [TEN]
        fmul
        fistp dword [vhBand]
        
        push dword [stamk]

        ret






DFT_24:








Print_FT:
    pop dword [stamk]
    PRINT_STRING "Frequency Bands:"
    NEWLINE
    
    PRINT_STRING "SKIPPING POSTING FT BECAUSE OF TEST"
    NEWLINE
    jmp .skip
    
    PRINT_DEC 4, [subBand]
    NEWLINE
    PRINT_DEC 4, [bassBand]
    NEWLINE
    PRINT_DEC 4, [midBand]
    NEWLINE
    PRINT_DEC 4, [highBand]
    NEWLINE
    PRINT_DEC 4, [vhBand]
    NEWLINE
    
    mov eax, [subBand]
    mov dword [painAndSuffering+0*4], eax
    mov eax, [bassBand]
    mov dword [painAndSuffering+1*4], eax
    mov eax, [midBand]
    mov dword [painAndSuffering+2*4], eax
    mov eax, [highBand]
    mov dword [painAndSuffering+3*4], eax
    mov eax, [vhBand]
    mov dword [painAndSuffering+4*4], eax
    
    mov ecx, 4 ;# of bands -1
    mov eax, 0
    .lop:
        cmp dword [painAndSuffering+ecx*4], eax
        jg .greater
        .ret:
        dec ecx
        cmp ecx, 0
        jge .lop
        jmp .retLop
        .greater:
            mov eax, [painAndSuffering+ecx*4]
            jmp .ret
    .retLop:
    
    mov [greatest], eax
    mov ecx, 0
    
    PRINT_STRING "chopped:"
    NEWLINE
    .lop2:
        fild dword [painAndSuffering+ecx*4] ;/
        fild dword [greatest]
        fdiv
        fld dword [HUNDRED]
        fmul ;/
        fld dword [FIVE]
        fdiv
        fistp dword [calc]
        
        PRINT_STRING [band_label+ecx*3]
        PRINT_STRING " "
        mov ebx, [calc]
        .lop3:
            PRINT_STRING "|"
            dec ebx
            cmp ebx, 0
            jg .lop3
            NEWLINE
            
        inc ecx
        cmp ecx, 5
        jl .lop2
    
    .skip:
                
    push dword [stamk]
    ret
    
    
    
   
    
    

       
    
    
    
  

            
            
        
        
        
        
        
        
        
        
 
    
