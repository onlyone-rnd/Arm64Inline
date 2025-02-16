MainProc proto

.code

    include modules\GetDynamicInfo.asm

MainProc proc

    invoke SetHookToOutputDebugStringA
    invoke SetHookVirtualProtect
    ret

MainProc endp