/*
                              *******************
******************************* C SOURCE FILE *****************************
**                            *******************                          
**                                                                         
** project  : X-HEEP                                                       
** filename : dma.c                                                      
** version  : 1                                                            
** date     : 13/02/23                                                     
**                                                                         
***************************************************************************
**                                                                         
** Copyright (c) EPFL contributors.                                        
** All rights reserved.                                                    
**                                                                         
***************************************************************************
	 
VERSION HISTORY:
----------------
Version     : 1
Date        : 13/02/2023
Revised by  : Juan Sapriza
Description : Original version.

*/

/***************************************************************************/
/***************************************************************************/

/**
* @file   dma.c
* @date   13/02/23
* @brief  The Direct Memory Access (DMA) driver to set up and use the DMA peripheral
*
* 
* 
*/


/****************************************************************************/
/**                                                                        **/
/*                             MODULES USED                                 */
/**                                                                        **/
/****************************************************************************/

#include "dma.h"

/****************************************************************************/
/**                                                                        **/
/*                        DEFINITIONS AND MACROS                            */
/**                                                                        **/
/****************************************************************************/

/****************************************************************************/
/**                                                                        **/
/*                        TYPEDEFS AND STRUCTURES                           */
/**                                                                        **/
/****************************************************************************/


/****************************************************************************/
/**                                                                        **/
/*                      PROTOTYPES OF LOCAL FUNCTIONS                       */
/**                                                                        **/
/****************************************************************************/

/****************************************************************************/
/**                                                                        **/
/*                           EXPORTED VARIABLES                             */
/**                                                                        **/
/****************************************************************************/

/****************************************************************************/
/**                                                                        **/
/*                            GLOBAL VARIABLES                              */
/**                                                                        **/
/****************************************************************************/

dma_cb_t dma_cb;

/****************************************************************************/
/**                                                                        **/
/*                           EXPORTED FUNCTIONS                             */
/**                                                                        **/
/****************************************************************************/

void dma_init()
{
  // @ToDo: This should be deprecated. base address should be obtained from.....
  dma_cb.baseAdd = mmio_region_from_addr((uintptr_t)DMA_START_ADDRESS);
  // juan: prob some more stuff should go here.
  // e.g. this function could return something
}


/****************************************************************************/
/**                                                                        **/
/*                            LOCAL FUNCTIONS                               */
/**                                                                        **/
/****************************************************************************/

/****************************************************************************/
/**                                                                        **/
/*                                 EOF                                      */
/**                                                                        **/
/****************************************************************************/