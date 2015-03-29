;********************************************************************************************************
;                                                uC/OS-III
;                                          The Real-Time Kernel
;
;
;                           (c) Copyright 2009-2010; Micrium, Inc.; Weston, FL
;                    All rights reserved.  Protected by international copyright laws.
;
;                                          ATMEL AVR Xmega Port
;
; File      : OS_CPU_A.S
; Version   : V3.01.2
; By        : JD
; 			: [with modifications by Nick D'Ademo]
;********************************************************************************************************

#include  <os_cpu_i.h>

;********************************************************************************************************
;                                         PUBLIC DECLARATIONS
;********************************************************************************************************

        .global  OSStartHighRdy
        .global  OSCtxSw
        .global  OSIntCtxSw

        .extern  OSIntExit
        .extern  OSIntNestingCtr
        .extern  OSPrioCur
        .extern  OSPrioHighRdy
        .extern  OSTaskSwHook
        .extern  OSTCBCurPtr
        .extern  OSTCBHighRdyPtr

;********************************************************************************************************
;                               START HIGHEST PRIORITY TASK READY-TO-RUN
;
; Description : This function is called by OSStart() to start the highest priority task that was created
;               by your application before calling OSStart().
;
; Note(s)     : 1) The (data)stack frame is assumed to look as follows:
;                                                +======+
;                  OSTCBHighRdy->OSTCBStkPtr --> |RAMPZ |
;                                                |RAMPY |
;                                                |RAMPX |
;                                                |RAMPD |
;                                                |EIND  |
;                                                |R31   |
;                                                |R30   |
;                                                |R27   |
;                                                |.     |
;                                                |SREG  |
;                                                |R0    |
;                                                |PCH   |-|
;                                                |PCM   | |--> PC address (3 bytes)                     
;                                                |PCL   |-|                         (High memory)
;                                                +======+
;                  where the stack pointer points to the task start address.
;
;
;               2) OSStartHighRdy() MUST:
;                      a) Call OSTaskSwHook() then,
;                      b) Switch to the highest priority task.
;********************************************************************************************************

OSStartHighRdy:
        CALL    OSTaskSwHook                                    ; Invoke user defined context switch hook                            ;

        LDS     R26,OSTCBHighRdyPtr                             ; Let X point to TCB of highest priority task
        LDS     R27,OSTCBHighRdyPtr+1                           ; ready to run

        RESTORE_SP                                              ; SP = MEM[X];	
        POP_ALL                                                 ; Restore all registers
        RETI                                                    ; Start task

;********************************************************************************************************
;                                       TASK LEVEL CONTEXT SWITCH
;
; Description : This function is called when a task makes a higher priority task ready-to-run.
;
; Note(s)     : (1) (A) Upon entry,
;                       OSTCBCur     points to the OS_TCB of the task to suspend
;                       OSTCBHighRdy points to the OS_TCB of the task to resume
;
;                   (B) The stack frame of the task to suspend looks as follows:
; 
;                                            SP+0 --> LSB of task code address
;                                              +2     MSB of task code address            (High memory)
;
;                   (C) The saved context of the task to resume looks as follows:
;
;                                                      +======+
;                        OSTCBHighRdy->OSTCBStkPtr --> |SPL   | ->stack pointer           (Low memory)                                             
;                                                      |SPH   | 
;                                                      |RAMPZ |
;                                                      |RAMPY |
;                                                      |RAMPX |
;                                                      |RAMPD |
;                                                      |EIND  |
;                                                      |R31   |
;                                                      |R30   |
;                                                      |R27   |
;                                                      |.     |
;                                                      |SREG  |
;                                                      |R0    |
;                                                      |PCH   |-|
;                                                      |PCM   | |--> PC address (3 bytes)                     
;                                                      |PCL   |-|                          (High memory)
;                                                      +======+
;                 (2) The OSCtxSW() MUST:
;                     - Save all register in the current task task. 
;                     - Make OSTCBCur->OSTCBStkPtr = SP.                     
;                     - Call user defined task swith hook.
;                     - OSPrioCur                  = OSPrioHighRdy
;                     - OSTCBCur                   = OSTCBHihgRdy 
;                     - SP                         = OSTCBHighRdy->OSTCBStrkPtr
;                     - Pop all the register from the new stack
;********************************************************************************************************

OSCtxSw:
        PUSH_ALL                                                ; Save current task's context   				
		      
		IN      R26,  SPL                                       ; X = SP
		IN      R27,  SPH                                       ;              
		
		LDS     R28,OSTCBCurPtr                                 ; Y = OSTCBCur->OSTCBStkPtr
        LDS     R29,OSTCBCurPtr+1                                  ;        		
        ST      Y+,R26                                          ; Y = SP
        ST      Y+,R27                                          ;

        CALL    OSTaskSwHook                                    ; Call user defined task switch hook

        LDS     R16,OSPrioHighRdy                               ; OSPrioCur = OSPrioHighRdy
        STS     OSPrioCur,R16

        LDS     R26,OSTCBHighRdyPtr                             ; Let X point to TCB of highest priority task
        LDS     R27,OSTCBHighRdyPtr+1                           ; ready to run
        STS     OSTCBCurPtr,R26                                 ; OSTCBCur = OSTCBHighRdy
        STS     OSTCBCurPtr+1,R27                                  
     
	    RESTORE_SP                                              ; SP = MEM[X];						        
		POP_ALL
		RET

;*********************************************************************************************************
;                                INTERRUPT LEVEL CONTEXT SWITCH
;
; Description : This function is called by OSIntExit() to perform a context switch to a task that has
;               been made ready-to-run by an ISR.
;
; Note(s)     : 1) Upon entry,
;                  OSTCBCur     points to the OS_TCB of the task to suspend
;                  OSTCBHighRdy points to the OS_TCB of the task to resume
;
;               2) The stack frame of the task to suspend looks as follows:
;
;                  OSTCBCur->OSTCBStkPtr ------> SPL of (return) stack pointer           (Low memory)
;                                                SPH of (return) stack pointer
;                                                Flags to load in status register
;                                                RAMPZ
;                                                R31
;                                                R30
;                                                R27
;                                                .
;                                                .
;                                                R0
;                                                PCH
;                                                PCL                                     (High memory)
;
;               3) The saved context of the task to resume looks as follows:
;
;                  OSTCBHighRdy->OSTCBStkPtr --> SPL of (return) stack pointer           (Low memory)
;                                                SPH of (return) stack pointer
;                                                Flags to load in status register
;                                                RAMPZ
;                                                R31
;                                                R30
;                                                R27
;                                                .
;                                                .
;                                                R0
;                                                PCH
;                                                PCL                                     (High memory)
;*********************************************************************************************************

OSIntCtxSw:
        CALL    OSTaskSwHook                                    ; Call user defined task switch hook

        LDS     R16,OSPrioHighRdy                               ; OSPrioCur = OSPrioHighRdy
        STS     OSPrioCur,R16                                   ;

        LDS     R26,OSTCBHighRdyPtr                             ; X = OSTCBHighRdy->OSTCBStkPtr
        LDS     R27,OSTCBHighRdyPtr+1                           ;
        STS     OSTCBCurPtr,R26                                 ; OSTCBCur = OSTCBHighRdy
        STS     OSTCBCurPtr+1,R27                               ;

        RESTORE_SP                                              ; SP = MEM[X];					     
		POP_ALL                                                 ; Restore all registers
        RETI

;********************************************************************************************************
;                                    OS_CPU ASSEMBLY PORT FILE END
;********************************************************************************************************
