BackUp proto :LPSTR

.code

BackUp proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15 lpFileName:LPSTR

    local BackUpName[260]:byte
    
    memalign rsp,16
    
    invoke strcpy,addr BackUpName,lpFileName
    invoke strcat,addr BackUpName,chr$(".BAK")
    invoke CopyFile,lpFileName,addr BackUpName,FALSE
    ret

BackUp endp