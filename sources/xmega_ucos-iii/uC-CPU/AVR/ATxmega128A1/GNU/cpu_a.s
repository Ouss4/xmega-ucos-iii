;********************************************************************************************************
;                                                uC/CPU
;                                    CPU CONFIGURATION & PORT LAYER
;
;                          (c) Copyright 2004-2011; Micrium, Inc.; Weston, FL
;
;               All rights reserved.  Protected by international copyright laws.
;
;               uC/CPU is provided in source form to registered licensees ONLY.  It is 
;               illegal to distribute this source code to any third party unless you receive 
;               written permission by an authorized Micrium representative.  Knowledge of 
;               the source code may NOT be used to develop a similar product.
;
;               Please help us continue to provide the Embedded community with the finest 
;               software available.  Your honesty is greatly appreciated.
;
;               You can contact us at www.micrium.com.
;********************************************************************************************************

;********************************************************************************************************
;
;                                            CPU PORT FILE
;
;                                            Atmel Xmega128
;                                           GNU AVR Compiler
;
; Filename      : cpu_a.s
; Version       : V1.29.00.00
; Programmer(s) : FGK
; 				: [with modifications by Nick D'Ademo]
;********************************************************************************************************

;********************************************************************************************************
;                                              DEFINES
;********************************************************************************************************

SREG    = 0x3F                                     	            ; Status  Register


;********************************************************************************************************
;                                         PUBLIC DECLARATIONS
;********************************************************************************************************

        .global  CPU_SR_Save
        .global  CPU_SR_Restore
        .global  CPU_IntDis

		.text

;********************************************************************************************************
;                            DISABLE/ENABLE INTERRUPTS USING OS_CRITICAL_METHOD #3
;
; Description : These functions are used to disable and enable interrupts using OS_CRITICAL_METHOD #3.
;
;               OS_CPU_SR  OSCPUSaveSR (void)
;                     Get current value of SREG
;                     Disable interrupts
;                     Return original value of SREG
;
;               void  OSCPURestoreSR (OS_CPU_SR cpu_sr)
;                     Set SREG to cpu_sr
;                     Return
;********************************************************************************************************

CPU_SR_Save:
        IN      R24,SREG                                        ; Get current state of interrupts disable flag
        CLI                                                     ; Disable interrupts
        RET                                                     ; Return original SREG value in R24


CPU_SR_Restore:
        OUT     SREG,R24                                        ; Restore SREG
        RET                                                     ; Return

;********************************************************************************************************
;                                             DISABLE INTERRUPTS
;
; Description : This function is used to disable interrupts.
;
;               void  CPU_IntDis (void)
;                     Disable interrupts
;                     Return
;********************************************************************************************************

CPU_IntDis:
        CLI                                                     ; Disable interrupts
        RET                                                     ; Return

;********************************************************************************************************
;                                    CPU ASSEMBLY PORT FILE END
;********************************************************************************************************
