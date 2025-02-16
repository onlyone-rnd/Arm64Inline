GetModuleHandle64 PROTO :LPCSTR

.code

GetModuleHandle64 proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 lpModuleName:LPCSTR

    local UniModule[64]:word

    .if !lpModuleName
    	mov rax,qword ptr gs:[60h]
    	mov rax,[rax].PEB.ImageBaseAddress
    	ret
    .endif
    xor eax,eax
    xor ebx,ebx
    xor r11,r11
    mov rsi,lpModuleName
    lea rdi,UniModule
    .while TRUE
        lodsb
        .if !al
            stosw
            .break
        .endif
        .if al >= 'A' && al <= 'Z'
            or al,20h
        .endif
        stosw
        inc ebx
    .endw
    mov rax,qword ptr gs:[60h]
    mov r8,[rax].PEB.Ldr
    lea r9,[r8].PEB_LDR_DATA.InLoadOrderModuleList.LIST_ENTRY.Flink
    mov r8,[r8].PEB_LDR_DATA.InLoadOrderModuleList.LIST_ENTRY.Flink
    lea r11,UniModule
    .repeat
        lea r10,[r8].LDR_DATA_TABLE_ENTRY.BaseDllName
        movzx ecx,[r10].UNICODE_STRING.Length_
        shr ecx,1
        .if ecx >= ebx
            mov ecx,ebx
            mov rsi,[r10].UNICODE_STRING.Buffer
            lea rdi,UniModule
            .while TRUE
                lodsw
                .if ax >= 'A' && ax <= 'Z'
                    or ax,20h
                .endif            
                .if ax != word ptr[rdi]
                    .break
                .endif
                add rdi,2
                dec rcx
                .if ZERO?
                    mov r11,[r8].LDR_DATA_TABLE_ENTRY.DllBase
                    jmp @F
                .endif
            .endw
        .endif
        mov r8,[r8]
    .until r9 == r8
    @@:
    return r11

GetModuleHandle64 endp