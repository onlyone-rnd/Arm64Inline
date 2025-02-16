GetProcAddress64 PROTO :HMODULE,:LPCSTR

.code

GetProcAddress64 proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15 hModule:HMODULE,lpProcName:LPCSTR

    local Buffer[10]:BYTE

    memalign rsp,16

    xor r14,r14
    .if hModule && lpProcName
        xor al,al
        mov ecx,sizeof Buffer
        lea rdi,Buffer
        rep stosb
        mov rbx,hModule
        movsxd rax,dword ptr[rbx+3Ch]
        add rax,rbx
        mov edx,[rax].IMAGE_NT_HEADERS.OptionalHeader.DataDirectoryExport.VirtualAddress
        add rdx,rbx
        mov rdi,lpProcName
        .if rdi > 65535
            mov r8d,[rdx].IMAGE_EXPORT_DIRECTORY.NumberOfNames
            mov esi,[rdx].IMAGE_EXPORT_DIRECTORY.AddressOfNames
            mov r10d,[rdx].IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals
            add rsi,rbx
            add r10,rbx
            .repeat
                lodsd
                add rax,rbx
                xchg rax,rsi
                mov rdi,lpProcName
                xor ecx,ecx
                .if rsi & 0FFFFFF00h
                    .while byte ptr[rdi]
                        inc ecx
                        inc rdi
                    .endw
                    inc ecx
                .endif
                mov rdi,lpProcName
                repe cmpsb
                xchg rax,rsi
                .if ZERO?
                    movzx esi,word ptr[r10]
                    shl esi,2
                    add esi,[rdx].IMAGE_EXPORT_DIRECTORY.AddressOfFunctions
                    add rsi,rbx
                    lodsd
                    add rax,rbx
                    mov r14,rax
                    mov rdi,rax
                    mov al,'.'
                    mov ecx,sizeof Buffer
                    repne scasb
                    .if !ZERO?
                        .break
                    .endif
                    movzx eax,byte ptr[r14]
                    .if al == 6Ah || al == 8Bh
                        .break
                    .endif
                    sub ecx,sizeof Buffer
                    not ecx
                    lea rsi,Buffer
                    .repeat
                        movzx eax,byte ptr[r14+rcx-1]
                        mov byte ptr[rsi+rcx-1],al
                        dec ecx
                    .until !ecx
                    invoke GetModuleHandle64,addr Buffer
                    .if !rax
                        int 3
                    .endif
                    mov r14,FUNC(GetProcAddress64,rax,rdi)
                    .break
                .endif
                add r10,sizeof WORD
                dec r8d
            .until !r8d
        .else
            sub edi,[rdx].IMAGE_EXPORT_DIRECTORY.nBase
            shl edi,2
            add edi,[rdx].IMAGE_EXPORT_DIRECTORY.AddressOfFunctions
            add rdi,rbx
            mov r14d,dword ptr[rdi]
            add r14,rbx
        .endif
    .endif
    return r14

GetProcAddress64 endp