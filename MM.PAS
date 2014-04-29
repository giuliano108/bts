{*      MM.PAS
 *
 * Routines for .MM module playing using the simplified MIDAS API
 *
 * Copyright 1995 Petteri Kangaslampi and Jarno Paananen
 *
 * This file is part of the MIDAS Sound System, and may only be
 * used, modified and distributed under the terms of the MIDAS
 * Sound System license, LICENSE.TXT. By continuing to use,
 * modify or distribute this file you indicate that you have
 * read the license and understand and accept it fully.
*}


unit mm;


interface


{****************************************************************************\
*
* Function:     midasPrepareMM(mm : pointer; MP : pointer) : pointer;
*
* Description:  Prepares a .MM module for playing using Module Player *MP.
*
* Input:        mm : pointer            Pointer to the .MM module
*               MP : pointer            Pointer to the Module Player which
*                                       will be used for playing the module
*
* Returns:      Pointer to the prepared module structure, which can be
*               played with midasPlayModule().
*
* Note:         This function should be used with the simple MIDAS
*               programming interface, MIDAS.C.
*               This function modifies the start of the .MM module in
*               memory, and may thus be called ONLY ONCE for each module.
*
\****************************************************************************}

function midasPrepareMM(mm : pointer; MP : pointer) : pointer;




{****************************************************************************\
*
* Function:     midasFreeMM(module : pointer);
*
* Description:  Deallocates a module that has been prepared for playing with
*               midasPrepareMM(). Deallocates allocated structures and
*               removes the instruments from the Sound Device. Note that
*               the .MM module in memory will NOT be deallocated.
*
* Input:        module : pointer        module to be deallocated.
*
\****************************************************************************}

procedure midasFreeMM(module : pointer);


implementation


uses MIDAS, mMem;


function midasPrepareMM(mm : pointer; MP : pointer) : pointer; external;
procedure midasFreeMM(module : pointer); external;
{$L mm.obj}


END.
