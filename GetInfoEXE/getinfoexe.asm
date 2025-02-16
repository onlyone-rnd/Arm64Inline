	include include\masm64rt.inc
	include include\LastError.inc
    include include\onlyone.inc

.code

    include modules\MainProc.asm

start:

Main proc

    invoke MainProc
    invoke ExitProcess,NULL
    
Main endp

end start