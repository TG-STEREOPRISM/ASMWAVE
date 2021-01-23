; WELCOME TO ASMWAVE LINUX, sorry, but this version is quite messy, but it should work well on the outside.



%include "io.inc"

extern printf
          
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
    TWO_POINT_FIVE dd 2.5
    ERR_COR_24 dd 0.004
    DEPTH_24 dd 8388608
    THOUSAND dd 1000.0
    formatM db "%.2f dB-FS", 10, 0
    formatL db "L %.2f dB-FS", 10, 0
    formatR db "R %.2f dB-FS", 10, 0
    BASE dd 10.0
    temp dd 0
    bruh dq 0
    channels dw 0
    
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
    
    statusbarDepth dd 0
    statusChar db '/', 0
    statusCount dd 0
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

    filename db "/home/andrew/Desktop/SunTest.wav", 0
              
section .bss
    dftOutput resd 6
    fileBuffer resb 104857600
    dftAlloc resb (200 * DFT_SIZE * 2 * 4) + 4
    inputBuffer resb 256

    
    ;for getInfo
    waveID resb 1
    
    ;for operation
    

section .text
    global CMAIN
    
CMAIN:
    PRINT_STRING "Welcome to ASMWAVE  -  A conceptual x86 audio program."
    NEWLINE
    PRINT_STRING "Please enter the full path and name of a .wav file under 100MB:"
    NEWLINE
    
    
    retFromErr:    
    call getFilePath
    call loadFile
    call getInfo
    ret
    
getFilePath:

    pop dword [stamk]
    
    mov eax , 0x03
    mov ebx, 0
    lea ecx, [inputBuffer]
    mov edx, 255
    int 80h
    
    PRINT_STRING [inputBuffer]
    NEWLINE
    mov ecx, 0
    
    
    .loop:
        cmp byte [inputBuffer+ecx], 0xa   ;fixes bizzare issue
        je .fixInErr
        .retFixInErr:
        inc ecx
        cmp ecx, 255
        jl .loop
        
   
    
    push dword [stamk]
    
    ret
    
    .fixInErr:
        mov byte [inputBuffer+ecx], 0
        jmp .retFixInErr
    
loadFile: ; Loads file into memory
    
    pop dword [stamk]
    
    mov eax, 0x05         ;open file
    lea ebx, [inputBuffer]
    ;lea ebx, [filename]
    mov ecx, 0
    int 80h
    
    cmp eax, 0
    jl .err
    
    
    
    mov ebx, eax          ;read file
    mov eax, 0x03
    lea ecx, [fileBuffer]
    mov edx, 104857600
    int 80h
    
    push dword [stamk]
    
    ret
    
    .err:
        PRINT_STRING "No such file or directory, try again!"
        NEWLINE
        jmp retFromErr
    
getInfo:

    NEWLINE
    lea eax, [fileBuffer]

    PRINT_HEX 4, [eax+8]
    NEWLINE
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
        
        mov eax, 0x01
        int 80h
        
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
    
    
    mov eax, fileBuffer
    mov edx, 0
    mov eax, [eax+40]
    mov ecx, 2
    div ecx ;puts # of samples in eax
    
    
    mov edx, 0
    ;eax already good
    mov ecx, BLOCK_SIZE_16
    div ecx
    
    mov [blockAmt], eax
    mov [blockCount], eax
    
    mov [remainderBlock], edx
    
    
    mov eax, 0
    mov ebx, BLOCK_SIZE_16
    mov ecx, 43
    mov edx, 0
    
    PRINT_STRING "=========================================="
    NEWLINE
    
    jmp loop16m
    retLoop16m:
    
    push dword 1 ;number of channels
    push dword [final_result]
    push NULL
    
    jmp postResults
    
    loop16m:
        
        inc ecx
        
        mov edx, fileBuffer
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
        
        call DFT_16
        jmp retLoop16m
        
        block16m:
            
            
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
            
            
            mov ebx, BLOCK_SIZE_16
            
            jmp retBlock16m
            
                
        finalBlock16m:
               
            inc ecx
            
            mov edx, fileBuffer
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
                
        
                
                jmp retActualFinalBlock16m
                
                
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

    
    mov eax, fileBuffer
    mov edx, 0
    mov eax, [eax+40]
    mov ecx, 4
    div ecx ;puts # of sample sets in eax
    

    
    mov edx, 0
    ;eax already good
    mov ecx, BLOCK_SIZE_16
    div ecx
    
    mov [blockAmt], eax
    mov [blockCount], eax
    

    
    mov [remainderBlock], edx
    
    
    mov eax, 0
    mov ebx, BLOCK_SIZE_16 * 2
    mov ecx, 43
    mov edx, 0
    
    PRINT_STRING "=========================================="
    NEWLINE
    
    jmp loop16s
    retLoop16s:
    
    push dword 2 ;number of channels
    push dword [final_L]
    push dword [final_R]
    jmp postResults
    loop16s:

        inc ecx
        
        mov edx, fileBuffer
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
        
        call DFT_16
        jmp retLoop16s
        
        setRight16s:
            add dword [channel_R], edx
            mov al, 0
            jmp retSetRight16s
            
              
        block16s:


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
            
            
            mov ebx, BLOCK_SIZE_16 * 2
            mov al, 0
              
            jmp retBlock16s
               
        finalBlock16s:
            
            inc ecx
            
            mov edx, fileBuffer
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
                
     
                      
                jmp retActualFinalBlock16s
                
            makePos16s2: 
                neg dx
                jmp retMakePos16s2
                
        makePos16s: 
            neg dx
            jmp retMakePos16s
            
mono24:

    
    mov eax, fileBuffer
    mov edx, 0
    mov eax, [eax+40]
    mov ecx, 3
    div ecx ;puts # of samples in eax

    mov edx, 0
    ;eax already good
    mov ecx, BLOCK_SIZE_24
    div ecx
    
    mov [blockAmt], eax
    mov [blockCount], eax
    mov [remainderBlock], edx
    
    

    
    mov eax, 0
    mov ebx, BLOCK_SIZE_24
    mov ecx, 41
    mov edx, 0
    
    PRINT_STRING "=========================================="
    NEWLINE
    
    jmp loop24m
    retLoop24m:
   
    
    push dword 1 ;number of channels
    push dword [final_result]
    push dword NULL
    
    jmp postResults
    
    loop24m:
        add ecx, 3
        
        mov edx, fileBuffer
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
        
        call DFT_24
        jmp retLoop24m

                 
        block24m:
            
            
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
           
            
            mov ebx, BLOCK_SIZE_24
            mov ecx, [hold_value4]
              
            jmp retBlock24m
            
                
        finalBlock24m:
            add ecx, 3
            
            mov edx, fileBuffer
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
                
      
                
                or dword [remainderBlock], 0x00000001
                or eax, 0x00000001 ;make not zero
                push dword 8388607 ;24 bit depth
                push dword [remainderBlock]
                push eax
                call FPUfunc1
                
                push dword BLOCK_SIZE_24
                push eax
                push dword [addition_heap]
                call FPUfunc3
                
                jmp retActualFinalBlock24m
               
                
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
    
    
    mov eax, fileBuffer
    mov edx, 0
    mov eax, [eax+40]
    mov ecx, 6
    div ecx ;puts # of sample sets in eax
    
    
    mov edx, 0
    ;eax already good
    mov ecx, BLOCK_SIZE_24
    div ecx
    
    mov [blockAmt], eax
    mov [blockCount], eax
    
    
    mov [remainderBlock], edx
    
    
    mov eax, 0
    mov ebx, BLOCK_SIZE_24 * 2
    mov ecx, 41
    mov edx, 0
    
    PRINT_STRING "=========================================="
    NEWLINE
    
    jmp loop24s
    retLoop24s:
    
    push dword 2 ;number of channels
    push dword [final_L]
    push dword [final_R]
    jmp postResults
    loop24s:
        add ecx, 3
        
        mov edx, fileBuffer
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
        
        call DFT_24
        jmp retLoop24s
        
        setRight24s:
            add dword [channel_R], edx
            mov al, 0
            jmp retSetRight24s

        block24s:
            
            mov [hold_value4], ecx
            
            sub dword [blockAmt], 1

            ;Left first
            or dword [channel_L], 0x00000001 ;make not zero
            push dword 8388607 ;24 bit depth
            push dword BLOCK_SIZE_24
            push dword [channel_L]
            call FPUfunc1
            
            
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
            
            
            mov ebx, BLOCK_SIZE_24 * 2
            mov al, 0
              
            jmp retBlock24s
           
                
        finalBlock24s:
            
            add ecx, 3
            
            mov edx, fileBuffer
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
                
                jmp retActualFinalBlock24s
                
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
        
    mov eax, 0x01
    int 80h
    
           
postResults:
    
    pop dword [print2]
    pop dword [print]
    pop ebx
    
    
    NEWLINE
    PRINT_STRING "=========================================="
    cmp ebx, 1
    je postMono
    
    NEWLINE
    NEWLINE
    PRINT_STRING "Stereo results:"
    NEWLINE
    fld dword [print]
    fstp qword [esp-8]
    sub esp, 8
    push formatL
    call printf
    add esp, 12
    
    fld dword [print2]
    fstp qword [esp-8]
    sub esp, 8
    push formatR
    call printf
    add esp, 12
    
    call Print_FT
    
    
    mov eax, 0x01
    int 80h
    
    postMono:
        
        NEWLINE
        NEWLINE
        PRINT_STRING "Mono results: "
        NEWLINE

        fld dword [print]
        fstp qword [esp-8]
        sub esp, 8
        push formatM
        call printf
        add esp, 12
        
        call Print_FT
        
 
        
        mov eax, 0x01
        int 80h
        
FPUfunc1:
    pop dword [hold_value] ;saves the pointer thingy
    pop dword [uab] ;Un-Altered Block 
    pop dword [block_size] ;# of block elements to be averaged
    pop dword [depth]
    
    
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
    
    
    fld dword [preAvg] ;/
    fild dword [blockCount] ;*
    fdiv ;A
    
    
    fld dword [ONE]
    fild dword [remainderBlock] ;/
    fild dword [blockCount] ;*
    fild dword [depth]
    fmul
    fdiv ;q
    fst dword [calc]
    
    
    fsub ;1-q
    
    
    fmul ;A * z
    
    fld dword [calc] ;*
    fld dword [preAvg2]
    fmul ;q*b
     
     
    fadd
    
    fstp dword [final_result]
    
    mov eax, [final_result]
    
    push dword [hold_value]
    ret
    
DFT_16:
    
    pop dword [stamk]
    .preCalc: 
        
        lea eax, [dftAlloc]
        mov [lookUpPtr], eax
        
        ;loops 200 by DFT_SIZE times
        mov ecx, 0
        mov edx, 0
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
    
    mov ebx, fileBuffer
    mov edx, 0
    mov eax, [ebx+40]
    
    push word [ebx+22]
    pop word [channels]
    
    mov ebx, 0
    mov bx, [channels]
    mov ecx, 2 ;16bit
    div ecx 
    mov edx, 0
    div ebx ;eax has # of samples
    
    mov edx, 0
    mov ecx, DFT_SIZE
    div ecx
    
    mov [blockAmt], eax
   
    mov [blockCount], eax
    
    
    mov edx, 0
    ;eax good
    mov ecx, 40
    div ecx
    mov [statusbarDepth], eax ;gets # of blocks required to draw 1/40 part of status bar
    
    cmp dword [blockAmt], 0
    jg .pass
    PRINT_STRING "Selected Audio is too short, sorry!"
    mov eax, 0x01
    int 80h
    .pass:
    
    mov eax, fileBuffer
    add eax, 44
    mov ecx, 0
    mov edx, [lookUpPtr]
    mov esi, 0
    
    .blocks:
        
        .dftBlock:

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
                
                
                ;RECTANGULAR WINDOW
                cmp ebx, 256
                jle .firstWindow
                jmp .retFirstWindow
                .firstWindow:
                    fldz
                    fmul
                
                .retFirstWindow:
                cmp ebx, DFT_SIZE - 256
                jge .lastWindow
                jmp .retLastWindow
                .lastWindow:
                    fldz
                    fmul
                    
                .retLastWindow:
                
                fld dword [Re]
                fadd
 
                fstp dword [Re]
                
                ;imaginary
                add ecx, (DFT_SIZE * 200) + 2
                
                fld dword [edx+ecx*4]
                fild word [eax+esi*2]
                fmul
                
                sub ecx, (DFT_SIZE * 200) + 2
                
                ;RECTANGULAR WINDOW 2
                cmp ebx, 256
                jle .firstWindow2
                jmp .retFirstWindow2
                .firstWindow2:
                    fldz
                    fmul
                
                .retFirstWindow2:
                cmp ebx, DFT_SIZE - 256
                jge .lastWindow2
                jmp .retLastWindow2
                .lastWindow2:
                    fldz
                    fmul
                    
                .retLastWindow2:
               
                fsub
                fstp dword [Im]      
                
                inc ebx
                inc ecx
                
                inc esi
                
                cmp word [channels], 2
                jne .skip
                inc esi
                .skip:
                
                cmp ebx, DFT_SIZE
                jl .dftMath
                mov [LU], ecx  
            
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
            mov dword [N], DFT_SIZE * 200
            mov ecx, 0
            
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
                
                
                fld dword [dftResult+ecx*4]
                fadd
                fstp dword [dftResult+ecx*4]
                
                inc ecx
                cmp ecx, 200 / 2
                jl .dftLoop
                
          
    add dword [offset], DFT_SIZE
    mov ecx, 0
    mov dword [LU], 0
            
    inc dword [statusCount]
    push ebx
    mov ebx, [statusbarDepth]
    cmp dword [statusCount], ebx
    je .drawStatus16
    pop ebx
    .retDrawStatus16:
    
    mov dword [iter], 0
    dec dword [blockCount]
    cmp dword [blockCount], 0
    jg .dftBlock
    
             
    .formatDFT:
        
        ;1
        finit 
        fld dword [dftResult+0*4]
        
        fld dword [TEN]
        fmul
        fistp dword [subBand]
        
        ;2
        finit 
        fld dword [dftResult+1*4]

        
        fld dword [TEN]
        fmul
        fistp dword [bassBand]
        
        ;3 through 11
        mov dword [N], 9
        finit
        fld dword [dftResult+3*4]
        fstp dword [midBand]
        mov ecx, 3
        .band3:
            finit
            fld dword [midBand]
            fld dword [dftResult+ecx*4]
            fadd
            fstp dword [midBand]
            
            inc ecx
            cmp ecx, 10
            jle .band3  
            
        finit
        fld dword [midBand]
        
        fild dword [N]
        fdiv
        fld dword [TEN]
        fmul
        fistp dword [midBand]
        
        ;12 through 32 
        mov dword [N], 21
        finit
        fld dword [dftResult+15*4]
        fstp dword [highBand]
        mov ecx, 12
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
        
        fild dword [N]
        fdiv
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
        
        fild dword [N]
        fdiv
        fld dword [TEN]
        fmul
        fistp dword [vhBand]
        
        ;wraps up status bar:
        cmp dword [statusbarT], 10
        jl .finishBar16
        .retFinishBar16:
        
        push dword [stamk]
        
        ret
        
    .drawStatus16:
        inc dword [statusbarT]
        PRINT_STRING [statusChar]
        mov dword [statusCount], 0
        jmp .retDrawStatus16
        
    .finishBar16:
        PRINT_STRING [statusChar]
        NEWLINE
        jmp .retFinishBar16
    
DFT_24:
    
    pop dword [stamk]
    .preCalc: 

        lea eax, [dftAlloc]
        mov [lookUpPtr], eax
        
        
        
        ;loops 200 by DFT_SIZE times
        mov ecx, 0
        mov edx, 0
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
    
    mov ebx, fileBuffer
    mov edx, 0
    mov eax, [ebx+40]
    
    push word [ebx+22]
    pop word [channels]
    
    mov ebx, 0
    mov bx, [channels]
    mov ecx, 3 ;24bit
    div ecx 
    mov edx, 0
    div ebx ;eax has # of samples
    
    mov edx, 0
    mov ecx, DFT_SIZE
    div ecx
    
    mov [blockAmt], eax
   
    mov [blockCount], eax

    
    mov edx, 0
    ;eax good
    mov ecx, 40
    div ecx
    mov [statusbarDepth], eax ;gets # of blocks required to draw 1/40 part of status bar
    
    cmp dword [blockAmt], 0
    jg .pass
    PRINT_STRING "Selected Audio is too short, sorry!"

    mov eax, 0x01
    int 80h
    .pass:
    
    mov eax, fileBuffer
    add eax, 44
    mov ecx, 0
    mov edx, [lookUpPtr]
    mov esi, 0
    
    .blocks:
        
        .dftBlock:

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
                mov edi, [eax+esi]
                and edi, CUT_TOP_8
                push edi
                fild dword [esp]
                fmul
                
                add esp, 4
                
                
                ;RECTANGULAR WINDOW
                cmp ebx, 256
                jle .firstWindow
                jmp .retFirstWindow
                .firstWindow:
                    fldz
                    fmul
                
                .retFirstWindow:
                cmp ebx, DFT_SIZE - 256
                jge .lastWindow
                jmp .retLastWindow
                .lastWindow:
                    fldz
                    fmul
                    
                .retLastWindow:
                
                fld dword [Re]
                fadd
 
                fstp dword [Re]
                
                ;imaginary
                add ecx, (DFT_SIZE * 200) + 2
                
                fld dword [edx+ecx*4]
                mov edi, [eax+esi]
                and edi, CUT_TOP_8
                push edi
                fild dword [esp]
                fmul
                
                add esp, 4
                
                sub ecx, (DFT_SIZE * 200) + 2
                
                ;RECTANGULAR WINDOW 2
                cmp ebx, 256
                jle .firstWindow2
                jmp .retFirstWindow2
                .firstWindow2:
                    fldz
                    fmul
                
                .retFirstWindow2:
                cmp ebx, DFT_SIZE - 256
                jge .lastWindow2
                jmp .retLastWindow2
                .lastWindow2:
                    fldz
                    fmul
                    
                .retLastWindow2:
               
                fsub
                fstp dword [Im]      
                
                inc ebx
                inc ecx
                
                TIMES 3 inc esi
                
                cmp word [channels], 2
                jne .skip
                TIMES 3 inc esi
                .skip:
                
                cmp ebx, DFT_SIZE
                jl .dftMath
                mov [LU], ecx  
            
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
            mov dword [N], DFT_SIZE * 200
            mov ecx, 0
            
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
                
                
                fld dword [dftResult+ecx*4]
                fadd
                fstp dword [dftResult+ecx*4]
                
                inc ecx
                cmp ecx, 200 / 2
                jl .dftLoop
                
          
    add dword [offset], DFT_SIZE
    mov ecx, 0
    mov dword [LU], 0
            
    inc dword [statusCount]
    push ebx
    mov ebx, [statusbarDepth]
    cmp dword [statusCount], ebx
    je .drawStatus24
    pop ebx
    .retDrawStatus24:
    
    mov dword [iter], 0
    dec dword [blockCount]
    cmp dword [blockCount], 0
    jg .dftBlock
    
             
    .formatDFT:
        
        ;1
        finit 
        fld dword [dftResult+0*4]
        
        fld dword [TEN]
        fmul
        fistp dword [subBand]
        
        ;2
        finit 
        fld dword [dftResult+1*4]

        
        fld dword [TEN]
        fmul
        fistp dword [bassBand]
        
        ;3 through 11
        mov dword [N], 9
        finit
        fld dword [dftResult+3*4]
        fstp dword [midBand]
        mov ecx, 3
        .band3:
            finit
            fld dword [midBand]
            fld dword [dftResult+ecx*4]
            fadd
            fstp dword [midBand]
            
            inc ecx
            cmp ecx, 10
            jle .band3  
            
        finit
        fld dword [midBand]
        
        fild dword [N]
        fdiv
        fld dword [TEN]
        fmul
        fistp dword [midBand]
        
        ;12 through 32 
        mov dword [N], 21
        finit
        fld dword [dftResult+15*4]
        fstp dword [highBand]
        mov ecx, 12
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
        
        fild dword [N]
        fdiv
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
        
        fild dword [N]
        fdiv
        fld dword [TEN]
        fmul
        fistp dword [vhBand]
        
        ;wraps up status bar:
        cmp dword [statusbarT], 10
        jl .finishBar24
        .retFinishBar24:
        
        mov edi, 24
        push dword [stamk]
        
        ret
        
    .drawStatus24:
        inc dword [statusbarT]
        PRINT_STRING [statusChar]
        mov dword [statusCount], 0
        jmp .retDrawStatus24
        
    .finishBar24:
        PRINT_STRING [statusChar]
        NEWLINE
        jmp .retFinishBar24


Print_FT:
    pop dword [stamk]
    
    or dword [subBand], 0x00000001
    cmp edi, 24
    jne .skipFix
    mov dword [subBand], 1
    .skipFix:
    or dword [bassBand], 0x00000001
    or dword [midBand], 0x00000001
    or dword [highBand], 0x00000001    
    or dword [vhBand], 0x00000001
    
    
    mov eax, [subBand]
    mov dword [dftOutput+0*4], eax
    mov eax, [bassBand]
    mov dword [dftOutput+1*4], eax
    mov eax, [midBand]
    mov dword [dftOutput+2*4], eax
    mov eax, [highBand]
    mov dword [dftOutput+3*4], eax
    mov eax, [vhBand]
    mov dword [dftOutput+4*4], eax
    
    mov ecx, 4 ;# of bands -1
    mov eax, 0
    .lop:
        cmp dword [dftOutput+ecx*4], eax
        jg .greater
        .ret:
        dec ecx
        cmp ecx, 0
        jge .lop
        jmp .retLop
        .greater:
            mov eax, [dftOutput+ecx*4]
            jmp .ret
    .retLop:
    
    mov [greatest], eax
    mov ecx, 0
    
    PRINT_STRING "=========================================="
    NEWLINE
    NEWLINE
    PRINT_STRING "Frequency comparison:"
    NEWLINE
    .lop2:
        fild dword [dftOutput+ecx*4] ;/
        fild dword [greatest]
        fdiv
        
        fld dword [HUNDRED]
        fmul ;/
        
        fld dword [TWO_POINT_FIVE]
        fdiv
        fistp dword [calc]
        
        PRINT_STRING [band_label+ecx*3]
        PRINT_STRING " "
        mov ebx, [calc]
        
        cmp edi, 24
        jne .lop3
        
        cmp ecx, 0
        jne .lop3
        PRINT_STRING "[Band Not Available]"
        NEWLINE
        jmp .skip
        .lop3:
            PRINT_STRING "|"
            dec ebx
            
            cmp ebx, 0
            jg .lop3
            NEWLINE
        
        .skip:   
        inc ecx
        cmp ecx, 5
        jl .lop2
    
                
    push dword [stamk]
    ret