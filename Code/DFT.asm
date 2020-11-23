%include "io.inc"
extern _printf
extern _ExitProcess@4
extern _CreateFileA@28
extern _GetFileSize@8
extern _ReadFile@20
extern _GetLastError@0
extern _malloc
extern _free

;takes about 2 seconds per 1 minute of audio

section .data
    %define NULL 0
    %define DFT_SIZE 4096 * 4
    %define NULL 0
    %define OPEN_EXISTING 3
    %define SHARE_READ 1
    %define GENERIC_READ 31
    
    N dd 16
    iter dd 0
    k dd 0
    TWO_TIMES_PI dd 6.28318531
    realResult TIMES 202 dd 0.0
    imagiResult TIMES 202 dd 0.0
    hold_calc dd 0
    format db "%.1f", 10, 0
    Re dd 0
    Im dd 0
    calc dd 0
    TEN dd 10
    stamk dd 0
    finalDFT TIMES 8 dd 0
    TWO dd 2
    fileSize dd 0
    readBuffer dd 0
    handle dd 0
    counter dd 0
    selected_file db "C:\Users\PC\Desktop\WAV\WHY.wav", 0 
    lowBand dd 0
    midBand dd 0
    highBand dd 0
    dftResult TIMES 202 dd 0
    lookUp1 dd 0.0, 0.031416, 0.062832, 0.094248, 0.125664, 0.15708, 0.188496, 0.219911, 0.251327, 0.282743, 0.314159, 0.345575, 0.376991, 0.408407, 0.439823, 0.471239, 0.502655, 0.534071, 0.565487, 0.596903, 0.628319, 0.659734, 0.69115, 0.722566, 0.753982, 0.785398, 0.816814, 0.84823, 0.879646, 0.911062, 0.942478, 0.973894, 1.00531, 1.036726, 1.068142, 1.099557, 1.130973, 1.162389, 1.193805, 1.225221, 1.256637, 1.288053, 1.319469, 1.350885, 1.382301, 1.413717, 1.445133, 1.476549, 1.507964, 1.53938, 1.570796, 1.602212, 1.633628, 1.665044, 1.69646, 1.727876, 1.759292, 1.790708, 1.822124, 1.85354, 1.884956, 1.916372, 1.947787, 1.979203, 2.010619, 2.042035, 2.073451, 2.104867, 2.136283, 2.167699, 2.199115, 2.230531, 2.261947, 2.293363, 2.324779, 2.356194, 2.38761, 2.419026, 2.450442, 2.481858, 2.513274, 2.54469, 2.576106, 2.607522, 2.638938, 2.670354, 2.70177, 2.733186, 2.764602, 2.796017, 2.827433, 2.858849, 2.890265, 2.921681, 2.953097, 2.984513, 3.015929, 3.047345, 3.078761, 3.110177, 3.141593, 3.173009, 3.204425, 3.23584, 3.267256, 3.298672, 3.330088, 3.361504, 3.39292, 3.424336, 3.455752, 3.487168, 3.518584, 3.55, 3.581416, 3.612832, 3.644247, 3.675663, 3.707079, 3.738495, 3.769911, 3.801327, 3.832743, 3.864159, 3.895575, 3.926991, 3.958407, 3.989823, 4.021239, 4.052655, 4.08407, 4.115486, 4.146902, 4.178318, 4.209734, 4.24115, 4.272566, 4.303982, 4.335398, 4.366814, 4.39823, 4.429646, 4.461062, 4.492477, 4.523893, 4.555309, 4.586725, 4.618141, 4.649557, 4.680973, 4.712389, 4.743805, 4.775221, 4.806637, 4.838053, 4.869469, 4.900885, 4.9323, 4.963716, 4.995132, 5.026548, 5.057964, 5.08938, 5.120796, 5.152212, 5.183628, 5.215044, 5.24646, 5.277876, 5.309292, 5.340708, 5.372123, 5.403539, 5.434955, 5.466371, 5.497787, 5.529203, 5.560619, 5.592035, 5.623451, 5.654867, 5.686283, 5.717699, 5.749115, 5.78053, 5.811946, 5.843362, 5.874778, 5.906194, 5.93761, 5.969026, 6.000442, 6.031858, 6.063274, 6.09469, 6.126106, 6.157522, 6.188938, 6.220353, 6.251769
    lookUpPtr dd 0
    sample dd 0
    LU dd 0
    
section .bss

section .text
    global _main
    
_main:
    mov ebp, esp; for correct debugging
    PRINT_STRING "Started Discreet Fourier Transform"
    NEWLINE
  
    call preCalc
    
    call file
    call DFT
    call formatDFT
    
    call postFT

end:
    GET_DEC 1, al
       
    push NULL
    call _ExitProcess@4


DFT:
    pop dword [stamk]
    mov dword [iter], 0
    mov dword [N], 200
    mov dword [LU], 0
    
    mov eax, [readBuffer]
    add eax, 44
    mov ecx, 0
    mov edx, [lookUpPtr]
    dftBlock:
   
        mov dword [Re], 0
        mov dword [Im], 0
        mov ebx, 0
        push ecx
        mov ecx, [LU]
        mov edx, [lookUpPtr]
        finit
        dftMath:
             
            ;real 
            fld dword [edx+ecx*4]
            fild word [eax+ebx*2]
            fmul
            fld dword [Re]
            fadd
            fstp dword [Re]
            
            ;imaginary
            
            add ecx, (DFT_SIZE * 200) + 2
           
            fld dword [edx+ecx*4]
            fild word [eax+ebx*2]
            fmul
            fstp dword [hold_calc]
            
            sub ecx, (DFT_SIZE * 200) + 2
        
            fld dword [Im]
            fld dword [hold_calc]
            fsub
            fstp dword [Im]      
            
            inc ebx
            inc ecx
            cmp ebx, DFT_SIZE
            jl dftMath
            mov [LU], ecx                         ;<    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        pop ecx  
        mov ebx, [Re]
        mov [realResult+ecx*4], ebx
        mov ebx, [Im]
        mov [imagiResult+ecx*4], ebx
        
        inc ecx
        inc dword [iter]
        cmp dword [iter], 200
        jl dftBlock

    finishDFT:
        mov dword [N], DFT_SIZE
        mov ecx, 0
        dftLoop:
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
            fstp dword [dftResult+ecx*4]
            
            inc ecx
            cmp ecx, 200 / 2
            jl dftLoop

    push dword [stamk]
    ret
    
file:
    pop dword [stamk]

    push NULL
    push NULL
    push OPEN_EXISTING
    push NULL
    push SHARE_READ
    push GENERIC_READ
    push selected_file
    call _CreateFileA@28
    mov dword [handle], eax
    
    PRINT_DEC 4, eax
    NEWLINE
    
    mov ecx, [handle]
    push NULL
    push ecx 
    call _GetFileSize@8
    PRINT_DEC 4, eax
    PRINT_STRING " bytes"
    NEWLINE
    mov [fileSize], eax
    
    push dword [fileSize]
    call _malloc
    mov [readBuffer], eax
    
    push NULL ;overlap
    push counter ;pointer to counter
    push dword [fileSize]
    push dword [readBuffer] ;pointer to output
    push dword [handle] ;pointer to handle
    call _ReadFile@20
    
    PRINT_STRING "rfile: "
    PRINT_DEC 4, eax
    NEWLINE
    mov eax, [readBuffer]
    PRINT_DEC 2, [eax+22]
    PRINT_STRING " CHANNELS"
    NEWLINE
    
    push dword [stamk]
    ret
    
preCalc:

    PRINT_STRING "precalc started"
    NEWLINE
    
;;;ABSOLUTE DISASTER CURRENTLY
    pop dword [stamk]
    push dword (200 * DFT_SIZE * 2 * 4) + 4
    call _malloc
    mov [lookUpPtr], eax
    
    ;loops 200 by DFT_SIZE times
    mov ecx, 0
    mov dword [iter], 0
    freqPre:
            
            
        mov ebx, 0
        mov dword [sample], 0
        samplePre:
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
            jl samplePre
                
            
        inc ecx
        inc dword [iter]
        cmp ecx, 200
        jl freqPre
        
    push dword [stamk]    
    ret
    
    
;SYSTEM FOR 16 BIT INPUT             
formatDFT:
    pop dword [stamk]
    
    mov dword [N], 2
    finit 
    ;1
    fld dword [dftResult+0*4]
    fistp dword [lowBand]
    
    mov dword [N], 10
    ;2 through 11
    finit
    fld dword [dftResult+1*4]
    fstp dword [midBand]
    mov ecx, 2
    band2:
        finit
        fld dword [midBand]
        fld dword [dftResult+ecx*4]
        fadd
        fstp dword [midBand]
        
        inc ecx
        cmp ecx, 10
        jle band2  
        
    finit
    fld dword [midBand]
    fild dword [N]
    fdiv
    fistp dword [midBand]
    
    ;12 through 96
    mov dword [N], 85
    finit
    fld dword [dftResult+11*4]
    fstp dword [highBand]
    mov ecx, 12
    band3:
        finit
        fld dword [highBand]
        fld dword [dftResult+ecx*4]
        fadd
        fstp dword [highBand]
        
        inc ecx
        cmp ecx, 95
        jle band3  
    finit
    fld dword [highBand]
    fild dword [N]
    fdiv
    fistp dword [highBand]
    
    push dword [stamk]
    ret       
postFT:
    pop dword [stamk]
    
     
    PRINT_DEC 4, [lowBand]
    NEWLINE
    PRINT_DEC 4, [midBand]
    NEWLINE
    PRINT_DEC 4, [highBand]
    NEWLINE
    
    mov eax, [lowBand]
    mov edx, 0
    mov ecx, 10
    div ecx
    mov ecx, eax
    inc ecx
    lowBar:
        PRINT_STRING "|"
        dec ecx
        jnz lowBar
    NEWLINE
    
    mov eax, [midBand]
    mov edx, 0
    mov ecx, 10
    div ecx
    mov ecx, eax
    inc ecx
    midBar:
        PRINT_STRING "|"
        dec ecx
        jnz midBar
    NEWLINE
    
    mov eax, [highBand]
    mov edx, 0
    mov ecx, 10
    div ecx
    mov ecx, eax
    inc ecx
    highBar:
        PRINT_STRING "|"
        dec ecx
        jnz highBar
    NEWLINE
        
    push dword [readBuffer]
    call _free
    
    push dword [lookUpPtr]
    call _free
    call end      
    push dword [stamk]
    ret        
            
            
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        