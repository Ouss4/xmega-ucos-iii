/*
*********************************************************************************************************
*                                               uC/OS-III
*                                          The Real-Time Kernel
*
*                              (c) Copyright 2003-2008, Micrium, Weston, FL
*                                           All Rights Reserved
*
*                                           MASTER INCLUDE FILE
*********************************************************************************************************
*/

// Select USART to print to
#define C0 0
#define D0 1
#define PRINT_TO_USART C0

// CodeVision AVR definitions
/* USART.BAUDCTRLB */
#define USART_BSCALE_gm 0xF0    // Baud Rate Scale group mask
#define USART_BSCALE_bp 4       // Baud Rate Scale group position

// uC/OS-III header files
#include <cpu_def.h>
#include <cpu.h>
#include <app_cfg.h>
#include <os_cfg_app.h>
#include <os.h>
#include <os_app_hooks.h>

// AVR device-specific IO definitions
#include <avr/io.h>

// AVR header files
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>