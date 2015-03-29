/*
*********************************************************************************************************
*                                                uC/OS-III
*                                          The Real-Time Kernel
*
*
*                           (c) Copyright 2009-2010; Micrium, Inc.; Weston, FL
*                    All rights reserved.  Protected by international copyright laws.
*
*                                          ATMEL AVR Xmega Port
*
* File      : OS_CPU_C.C
* Version   : V3.01.2
* By        : JD
*           : [with modifications by Nick D'Ademo]
*
* LICENSING TERMS:
* ---------------
*             uC/OS-III is provided in source form to registered licensees ONLY.  It is 
*             illegal to distribute this source code to any third party unless you receive 
*             written permission by an authorized Micrium representative.  Knowledge of 
*             the source code may NOT be used to develop a similar product.
*
*             Please help us continue to provide the Embedded community with the finest
*             software available.  Your honesty is greatly appreciated.
*
*             You can contact us at www.micrium.com.
*
* Toolchain : GNU AVR
*********************************************************************************************************
*/

#define   OS_CPU_GLOBALS

#ifdef VSC_INCLUDE_SOURCE_FILE_NAMES
const  CPU_CHAR  *os_cpu_c__c = "$Id: $";
#endif

/*$PAGE*/
/*
*********************************************************************************************************
*                                             INCLUDE FILES
*********************************************************************************************************
*/

#include  <os.h>


/*$PAGE*/
/*
*********************************************************************************************************
*                                           IDLE TASK HOOK
*
* Description: This function is called by the idle task.  This hook has been added to allow you to do
*              such things as STOP the CPU to conserve power.
*
* Arguments  : None.
*
* Note(s)    : None.
*********************************************************************************************************
*/

void  OSIdleTaskHook (void)
{
#if OS_CFG_APP_HOOKS_EN > 0u
    if (OS_AppIdleTaskHookPtr != (OS_APP_HOOK_VOID)0) {
        (*OS_AppIdleTaskHookPtr)();
    }
#endif
}


/*$PAGE*/
/*
*********************************************************************************************************
*                                       OS INITIALIZATION HOOK
*
* Description: This function is called by OSInit() at the beginning of OSInit().
*
* Arguments  : None.
*
* Note(s)    : None.
*********************************************************************************************************
*/

void  OSInitHook (void)
{
    CPU_STK_SIZE   i;
    CPU_STK       *p_stk;


    p_stk = OSCfg_ISRStkBasePtr;                            /* Clear the ISR stack                                    */
    for (i = 0u; i < OSCfg_ISRStkSize; i++) {
        *p_stk++ = (CPU_STK)0u;
    }
    OS_CPU_ExceptStkBase = (CPU_STK *)(OSCfg_ISRStkBasePtr + OSCfg_ISRStkSize - 1u);
}


/*$PAGE*/
/*
*********************************************************************************************************
*                                         STATISTIC TASK HOOK
*
* Description: This function is called every second by uC/OS-III's statistics task.  This allows your
*              application to add functionality to the statistics task.
*
* Arguments  : None.
*
* Note(s)    : None.
*********************************************************************************************************
*/

void  OSStatTaskHook (void)
{
#if OS_CFG_APP_HOOKS_EN > 0u
    if (OS_AppStatTaskHookPtr != (OS_APP_HOOK_VOID)0) {
        (*OS_AppStatTaskHookPtr)();
    }
#endif
}


/*$PAGE*/
/*
*********************************************************************************************************
*                                          TASK CREATION HOOK
*
* Description: This function is called when a task is created.
*
* Arguments  : p_tcb        Pointer to the task control block of the task being created.
*
* Note(s)    : None.
*********************************************************************************************************
*/

void  OSTaskCreateHook (OS_TCB  *p_tcb)
{
#if OS_CFG_APP_HOOKS_EN > 0u
    if (OS_AppTaskCreateHookPtr != (OS_APP_HOOK_TCB)0) {
        (*OS_AppTaskCreateHookPtr)(p_tcb);
    }
#else
    (void)p_tcb;                                            /* Prevent compiler warning                               */
#endif
}


/*$PAGE*/
/*
*********************************************************************************************************
*                                           TASK DELETION HOOK
*
* Description: This function is called when a task is deleted.
*
* Arguments  : p_tcb        Pointer to the task control block of the task being deleted.
*
* Note(s)    : None.
*********************************************************************************************************
*/

void  OSTaskDelHook (OS_TCB  *p_tcb)
{
#if OS_CFG_APP_HOOKS_EN > 0u
    if (OS_AppTaskDelHookPtr != (OS_APP_HOOK_TCB)0) {
        (*OS_AppTaskDelHookPtr)(p_tcb);
    }
#else
    (void)p_tcb;                                            /* Prevent compiler warning                               */
#endif
}


/*$PAGE*/
/*
*********************************************************************************************************
*                                            TASK RETURN HOOK
*
* Description: This function is called if a task accidentally returns.  In other words, a task should
*              either be an infinite loop or delete itself when done.
*
* Arguments  : p_tcb        Pointer to the task control block of the task that is returning.
*
* Note(s)    : None.
*********************************************************************************************************
*/

void  OSTaskReturnHook (OS_TCB  *p_tcb)
{
#if OS_CFG_APP_HOOKS_EN > 0u
    if (OS_AppTaskReturnHookPtr != (OS_APP_HOOK_TCB)0) {
        (*OS_AppTaskReturnHookPtr)(p_tcb);
    }
#else
    (void)p_tcb;                                            /* Prevent compiler warning                               */
#endif
}

/*$PAGE*/
/*
**********************************************************************************************************
*                                       INITIALIZE A TASK'S STACK
*
* Description: This function is called by OS_Task_Create() or OSTaskCreateExt() to initialize the stack
*              frame of the task being created. This function is highly processor specific.
*
* Arguments  : p_task       Pointer to the task entry point address.
*
*              p_arg        Pointer to a user supplied data area that will be passed to the task
*                               when the task first executes.
*
*              p_stk_base   Pointer to the base address of the stack.
*
*              stk_size     Size of the stack, in number of CPU_STK elements.
*
*              opt          Options used to alter the behavior of OS_Task_StkInit().
*                            (see OS.H for OS_TASK_OPT_xxx).
*
* Returns    : Always returns the location of the new top-of-stack' once the processor registers have
*              been placed on the stack in the proper order.
*
* Note(s)    : Interrupts are enabled when your task starts executing. You can change this by setting the
*              SREG to 0x00 instead. In this case, interrupts would be disabled upon task startup. The
*              application code would be responsible for enabling interrupts at the beginning of the task
*              code. You will need to modify OSTaskIdle() and OSTaskStat() so that they enable interrupts.
*              Failure to do this will make your system crash!
*
**********************************************************************************************************
*/

CPU_STK  *OSTaskStkInit (OS_TASK_PTR    p_task,
                         void          *p_arg,
                         CPU_STK       *p_stk_base,
                         CPU_STK       *p_stk_limit,
                         CPU_STK_SIZE   stk_size,
                         OS_OPT         opt)
{
    CPU_STK     *psoft_stk;
    CPU_INT32U   tmp;

    (void)opt;                                              /* Prevent compiler warning                               */
    (void)p_stk_limit;

    psoft_stk     = (CPU_STK *)&p_stk_base[stk_size - 1u];

	tmp           = (CPU_INT32U)((int)p_task);				/* Cast task to "int" to prevent warning (Nick D'Ademo)		*/
                                                            /* Put task start address on top of "hardware stack"        */
    *psoft_stk--  = (CPU_STK)(tmp & 0xFF);    		        /* Save PC return address                                   */
    tmp    >>= 8;
    *psoft_stk--  = (CPU_STK)(tmp & 0xFF);
    tmp    >>= 8;
    *psoft_stk--  = (CPU_STK)(tmp & 0xFF);

    *psoft_stk--  = (CPU_STK)0x00;            		        /* R0    = 0x00                                             */
    *psoft_stk--  = (CPU_STK)0x80;            		        /* SREG  = Interrupts enabled                               */

    *psoft_stk--  = (CPU_STK)0x00;            	        	/* R1    = 0x00                                             */
    *psoft_stk--  = (CPU_STK)0x02;            	        	/* R2    = 0x02                                             */
    *psoft_stk--  = (CPU_STK)0x03;            	        	/* R3    = 0x03                                             */
    *psoft_stk--  = (CPU_STK)0x04;            	        	/* R4    = 0x04                                             */
    *psoft_stk--  = (CPU_STK)0x05;            	        	/* R5    = 0x05                                             */
    *psoft_stk--  = (CPU_STK)0x06;            	        	/* R6    = 0x06                                             */
    *psoft_stk--  = (CPU_STK)0x07;            	        	/* R7    = 0x07                                             */
    *psoft_stk--  = (CPU_STK)0x08;            	        	/* R8    = 0x08                                             */
    *psoft_stk--  = (CPU_STK)0x09;            	        	/* R9    = 0x09                                             */
    *psoft_stk--  = (CPU_STK)0x10;            	        	/* R10   = 0x10                                             */
    *psoft_stk--  = (CPU_STK)0x11;           	        	/* R11   = 0x11                                             */
    *psoft_stk--  = (CPU_STK)0x12;            	        	/* R12   = 0x12                                             */
    *psoft_stk--  = (CPU_STK)0x13;            	        	/* R13   = 0x13                                             */
    *psoft_stk--  = (CPU_STK)0x14;            	        	/* R14   = 0x14                                             */
    *psoft_stk--  = (CPU_STK)0x15;            	        	/* R15   = 0x15                                             */
    *psoft_stk--  = (CPU_STK)0x16;            	        	/* R16   = 0x16                                             */
    *psoft_stk--  = (CPU_STK)0x17;            	        	/* R17   = 0x17                                             */
    *psoft_stk--  = (CPU_STK)0x18;            	        	/* R18   = 0x18                                             */
    *psoft_stk--  = (CPU_STK)0x19;            	        	/* R19   = 0x19                                             */
    *psoft_stk--  = (CPU_STK)0x20;            	        	/* R20   = 0x20                                             */
    *psoft_stk--  = (CPU_STK)0x21;            	        	/* R21   = 0x21                                             */
    *psoft_stk--  = (CPU_STK)0x22;            		        /* R22   = 0x22                                             */
    *psoft_stk--  = (CPU_STK)0x23;            		        /* R23   = 0x23                                             */
    tmp      = (CPU_INT16U)p_arg;
    *psoft_stk--  = (CPU_STK)tmp;             	        	/* 'p_arg' passed in R24:R25                                */
    *psoft_stk--  = (CPU_STK)(tmp >> 8);
    *psoft_stk--  = (CPU_STK)0x26;            		        /* R26 X = 0x26                                             */
    *psoft_stk--  = (CPU_STK)0x27;            		        /* R27   = 0x27                                             */
    *psoft_stk--  = (CPU_STK)0x28;            		        /* R28 Y = 0x28                                             */
    *psoft_stk--  = (CPU_STK)0x29;            		        /* R29   = 0x29                                             */
    *psoft_stk--  = (CPU_STK)0x30;            		        /* R30 Z = 0x30                                             */
    *psoft_stk--  = (CPU_STK)0x31;            		        /* R31   = 0x31                                             */
    *psoft_stk--  = (CPU_STK)0x00;            		        /* EIND  = 0x00                                             */
    *psoft_stk--  = (CPU_STK)0x00;            		        /* RAMPD = 0x00                                             */    
	*psoft_stk--  = (CPU_STK)0x00;            		        /* RAMPX = 0x00                                             */
    *psoft_stk--  = (CPU_STK)0x00;            		        /* RAMPY = 0x00                                             */
    *psoft_stk--  = (CPU_STK)0x00;            		        /* RAMPZ = 0x00                                             */

    return (psoft_stk);
}

/*$PAGE*/
/*
*********************************************************************************************************
*                                           TASK SWITCH HOOK
*
* Description: This function is called when a task switch is performed.  This allows you to perform other
*              operations during a context switch.
*
* Arguments  : None.
*
* Note(s)    : 1) Interrupts are disabled during this call.
*              2) It is assumed that the global pointer 'OSTCBHighRdyPtr' points to the TCB of the task
*                 that will be 'switched in' (i.e. the highest priority task) and, 'OSTCBCurPtr' points
*                 to the task being switched out (i.e. the preempted task).
*********************************************************************************************************
*/

void  OSTaskSwHook (void)
{
#if OS_CFG_TASK_PROFILE_EN > 0u
    CPU_TS  ts;
#endif
#ifdef  CPU_CFG_INT_DIS_MEAS_EN
    CPU_TS  int_dis_time;
#endif



#if OS_CFG_APP_HOOKS_EN > 0u
    if (OS_AppTaskSwHookPtr != (OS_APP_HOOK_VOID)0) {
        (*OS_AppTaskSwHookPtr)();
    }
#endif

#if OS_CFG_TASK_PROFILE_EN > 0u
    ts = OS_TS_GET();
    if (OSTCBCurPtr != OSTCBHighRdyPtr) {
        OSTCBCurPtr->CyclesDelta  = ts - OSTCBCurPtr->CyclesStart;
        OSTCBCurPtr->CyclesTotal += (OS_CYCLES)OSTCBCurPtr->CyclesDelta;
    }

    OSTCBHighRdyPtr->CyclesStart = ts;
#endif

#ifdef  CPU_CFG_INT_DIS_MEAS_EN
    int_dis_time = CPU_IntDisMeasMaxCurReset();             /* Keep track of per-task interrupt disable time          */
    if (OSTCBCurPtr->IntDisTimeMax < int_dis_time) {
        OSTCBCurPtr->IntDisTimeMax = int_dis_time;
    }
#endif

#if OS_CFG_SCHED_LOCK_TIME_MEAS_EN > 0u
                                                            /* Keep track of per-task scheduler lock time             */
    if (OSTCBCurPtr->SchedLockTimeMax < OSSchedLockTimeMaxCur) {
        OSTCBCurPtr->SchedLockTimeMax = OSSchedLockTimeMaxCur;
    }
    OSSchedLockTimeMaxCur = (CPU_TS)0;                      /* Reset the per-task value                               */
#endif
}


/*$PAGE*/
/*
*********************************************************************************************************
*                                              TICK HOOK
*
* Description: This function is called every tick.
*
* Arguments  : None.
*
* Note(s)    : 1) This function is assumed to be called from the Tick ISR.
*********************************************************************************************************
*/

void  OSTimeTickHook (void)
{
#if OS_CFG_APP_HOOKS_EN > 0u
    if (OS_AppTimeTickHookPtr != (OS_APP_HOOK_VOID)0) {
        (*OS_AppTimeTickHookPtr)();
    }
#endif
}
