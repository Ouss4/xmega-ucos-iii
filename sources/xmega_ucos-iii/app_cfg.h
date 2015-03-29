/*
*********************************************************************************************************
*                                                uC/OS-III
*                                          The Real-Time Kernel
*                             Atmel Xmega128A1 Application Configuration File
*
*                                 (c) Copyright 2008; Micrium; Weston, FL
*                                           All Rights Reserved
*
* Filename      : app_cfg.c
* Version       : V1.00
* Programmer(s) : FK
*                 FT
*********************************************************************************************************
*/

#ifndef _APP_CFG_H_
#define _APP_CFG_H_

/*
*********************************************************************************************************
*                                             TASK PRIORITIES
*********************************************************************************************************
*/

#define  APP_TASK_START_PRIO                1
#define  APP_TASK_1_PRIO                    2
#define  APP_TASK_2_PRIO                    3
#define  APP_TASK_3_PRIO                    4
#define  APP_TASK_4_PRIO                    5
#define  APP_TASK_5_PRIO                    6

/*
*********************************************************************************************************
*                                               STACK SIZES
*********************************************************************************************************
*/

#define  APP_TASK_START_STK_SIZE            128
#define  APP_TASK_1_STK_SIZE                128
#define  APP_TASK_2_STK_SIZE                128
#define  APP_TASK_3_STK_SIZE                128
#define  APP_TASK_4_STK_SIZE                128
#define  APP_TASK_5_STK_SIZE                128

#define  OS_TASK_STK_SIZE_HARD              96

/*
*********************************************************************************************************
*                                            TASK STACK SIZES LIMIT
*********************************************************************************************************
*/

#define  APP_TASK_START_STK_SIZE_PCT_FULL   90u
#define  APP_TASK_START_STK_SIZE_LIMIT      (APP_TASK_START_STK_SIZE * (100u - APP_TASK_START_STK_SIZE_PCT_FULL)) / 100u

#endif
