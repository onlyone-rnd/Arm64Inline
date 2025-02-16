MainProc proto

.code

    include modules\SaveToFile.asm
    include modules\ExtractModule.asm
    include modules\GetTypeFile.asm
    include modules\GetDynamicInfo.asm
    include modules\InlinePatch.asm
    include modules\DialogProc.asm

MainProc proc

    invoke DialogBoxParam,FUNC(GetModuleHandle,NULL),MAIN_DLG,NULL,addr MainDlgProc,NULL
    ret
    invoke InitCommonControls

MainProc endp