;********************************************************************************************************
;                                               uC/OS-III
;                                         The Real-Time Kernel
;
;                                       ATXmega128  Specific code
;                                           GNU AVR Compiler
;
;
; File     : avr_isr.s
; By       : JJL
;          : FT
;          : [with modifications by Nick D'Ademo]
;********************************************************************************************************

#include  <os_cpu_i.h>


;********************************************************************************************************
;                                         PUBLIC DECLARATIONS
;********************************************************************************************************

		.global TickISR
        .global usartc0_rx_isr
        .global usartd0_rx_isr
		.global pushbutton_timer_isr

;********************************************************************************************************
;                                         EXTERNAL DECLARATIONS
;********************************************************************************************************

		.extern OSIntNesting
		.extern OSTCBCur
		.extern OSTimeTick
		.extern OSIntExit

        .extern usartc0_rx_isr_handler
        .extern usartd0_rx_isr_handler
		.extern	pushbutton_timer_isr_handler

        .text

;********************************************************************************************************
;                                           SYSTEM TICK ISR
;
; Description : This function is the Tick ISR.
;
;               The following C-like pseudo-code describe the operation being performed in the code below.
;
;               - Save all registers on the current task's stack:
;                      Use the PUSH_ALL macro
;               - OSIntNesting++;
;               if (OSIntNesting == 1) {
;                  OSTCBCur->OSTCBStkPtr = SP
;               }
;               Clear the interrupt;                  Not needed for the timer we used.
;               OSTimeTick();                         Notify uC/OS-III that a tick has occured
;               OSIntExit();                          Notify uC/OS-III about end of ISR
;               Restore all registers that were save on the current task's stack:
;                      Use the POP_ALL macro to restore the remaining registers
;               Return from interrupt
;********************************************************************************************************

               
TickISR:       
		PUSH_ALL                                                ; Save all registers and status register        	
		LDS     R16,OSIntNestingCtr                             ; Notify uC/OS-III of ISR
        INC     R16                                             ;
        STS     OSIntNestingCtr,R16                             ;

        CPI     R16,1                                           ; if (OSIntNesting == 1) {
        BRNE    TickISR_1

        SAVE_SP				                                    ; X = SP 		
		LDS     R28,OSTCBCurPtr                                 ; OSTCBCur->OSTCBStkPtr = X
        LDS     R29,OSTCBCurPtr+1                               ;    
        
		ST      Y+,R26
        ST      Y+,R27                                          ; }

TickISR_1:
        CALL    OSTimeTick                                  	; Handle the tick ISR

        CALL    OSIntExit                                       ; Notify uC/OS-III about end of ISR
        		
        POP_ALL                                                 ; Restore all registers
        
        RETI

;**********************************************************************************************
;*                                       USARTC0 Rx ISR
;*
;* Description: This function is invoked when USARTC0 receives a character
;*
;* Arguments  : none
;*
;* Note(s)    : 1) Pseudo code:
;*                 Disable Interrupts
;*                 Save all registers
;*                 OSIntNesting++
;*                 if (OSIntNesting == 1) {
;*                     OSTCBCur->OSTCBStkPtr = SP
;*                 }
;*                 usartc0_rx_isr_handler();
;*                 OSIntExit();
;*                 Restore all registers
;*                 Return from interrupt;
;**********************************************************************************************
        
usartc0_rx_isr:        
        PUSH_ALL                                                ; Save all registers and status register        

        LDS     R16,OSIntNestingCtr                             ; Notify uC/OS-III of ISR
        INC     R16                                             ;
        STS     OSIntNestingCtr,R16                             ;

        CPI     R16,1                                           ; if (OSIntNesting == 1) {
        BRNE    usartc0_rx_isr_1

        SAVE_SP				                                    ; X = SP 		
		LDS     R28,OSTCBCurPtr                                 ; OSTCBCur->OSTCBStkPtr = X
        LDS     R29,OSTCBCurPtr+1                               ;    
        
		ST      Y+,R26
        ST      Y+,R27                                          ; }


usartc0_rx_isr_1:
        CALL    usartc0_rx_isr_handler                          ; Call Handler written in C

        CALL    OSIntExit                                       ; Notify uC/OS-III about end of ISR

        LDS     R26,OSTCBCurPtr                                 ; OSTCBCur->OSTCBStkPtr = X
        LDS     R27,OSTCBCurPtr+1                               ;                         X = Y = SP
        
        POP_ALL                                                 ; Restore all registers
        
		RETI

;**********************************************************************************************
;*                                       USARTD0 Rx ISR
;*
;* Description: This function is invoked when USARTD0 receives a character
;*
;* Arguments  : none
;*
;* Note(s)    : 1) Pseudo code:
;*                 Disable Interrupts
;*                 Save all registers
;*                 OSIntNesting++
;*                 if (OSIntNesting == 1) {
;*                     OSTCBCur->OSTCBStkPtr = SP
;*                 }
;*                 usartd0_rx_isr_handler();
;*                 OSIntExit();
;*                 Restore all registers
;*                 Return from interrupt;
;**********************************************************************************************
        
usartd0_rx_isr:        
        PUSH_ALL                                                ; Save all registers and status register        

        LDS     R16,OSIntNestingCtr                             ; Notify uC/OS-III of ISR
        INC     R16                                             ;
        STS     OSIntNestingCtr,R16                             ;

        CPI     R16,1                                           ; if (OSIntNesting == 1) {
        BRNE    usartd0_rx_isr_1

        SAVE_SP				                                    ; X = SP 		
		LDS     R28,OSTCBCurPtr                                 ; OSTCBCur->OSTCBStkPtr = X
        LDS     R29,OSTCBCurPtr+1                               ;    
        
		ST      Y+,R26
        ST      Y+,R27                                          ; }


usartd0_rx_isr_1:
        CALL    usartd0_rx_isr_handler                          ; Call Handler written in C

        CALL    OSIntExit                                       ; Notify uC/OS-III about end of ISR

        LDS     R26,OSTCBCurPtr                                 ; OSTCBCur->OSTCBStkPtr = X
        LDS     R27,OSTCBCurPtr+1                               ;                         X = Y = SP
        
        POP_ALL                                                 ; Restore all registers
        
		RETI

;**********************************************************************************************
;*                                       Push-Button Timer ISR
;*
;* Description: This function is called every 20ms and reads the state of the PORTF push-buttons.
;*
;* Arguments  : none
;*
;* Note(s)    : 1) Pseudo code:
;*                 Disable Interrupts
;*                 Save all registers
;*                 OSIntNesting++
;*                 if (OSIntNesting == 1) {
;*                     OSTCBCur->OSTCBStkPtr = SP
;*                 }
;*                 pushbutton_timer_isr_handler();
;*                 OSIntExit();
;*                 Restore all registers
;*                 Return from interrupt;
;**********************************************************************************************
        
pushbutton_timer_isr:        
        PUSH_ALL                                                ; Save all registers and status register        

        LDS     R16,OSIntNestingCtr                             ; Notify uC/OS-III of ISR
        INC     R16                                             ;
        STS     OSIntNestingCtr,R16                             ;

        CPI     R16,1                                           ; if (OSIntNesting == 1) {
        BRNE    pushbutton_timer_isr_1

        SAVE_SP				                                    ; X = SP 		
		LDS     R28,OSTCBCurPtr                                 ; OSTCBCur->OSTCBStkPtr = X
        LDS     R29,OSTCBCurPtr+1                               ;    
        
		ST      Y+,R26
        ST      Y+,R27                                          ; }


pushbutton_timer_isr_1:
        CALL    pushbutton_timer_isr_handler                    ; Call Handler written in C

        CALL    OSIntExit                                       ; Notify uC/OS-III about end of ISR

        LDS     R26,OSTCBCurPtr                                 ;     OSTCBCur->OSTCBStkPtr = X
        LDS     R27,OSTCBCurPtr+1                               ;                         X = Y = SP
        
        POP_ALL                                                 ; Restore all registers
        
		RETI
