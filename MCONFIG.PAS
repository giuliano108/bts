{*      MCONFIG.PAS
 *
 * MIDAS Sound System configuration. Meant to be used with the simplified
 * MIDAS API, MIDAS.C
 *
 * Copyright 1995 Petteri Kangaslampi and Jarno Paananen
 *
 * This file is part of the MIDAS Sound System, and may only be
 * used, modified and distributed under the terms of the MIDAS
 * Sound System license, LICENSE.TXT. By continuing to use,
 * modify or distribute this file you indicate that you have
 * read the license and understand and accept it fully.
*}


unit mConfig;


interface
{$define NOLOADERS}
{$define CUTDOWN}



{****************************************************************************\
*
* Function:     midasConfig : integer;
*
* Description:  MIDAS Sound System configuration. Prompts the user for all
*               configuration information and sets the MIDAS variables
*               accordingly. Call before midasInit() but after
*               midasSetDefaults().
*
* Returns:      1 if configuration was successful, 0 if not (Esc was pressed)
*
\****************************************************************************}

function midasConfig : integer;



{$IFNDEF NOLOADERS}


{****************************************************************************\
*
* Function:     midasLoadConfig(fileName : Pchar);
*
* Description:  Loads configuration from file saved using midasSaveConfig().
*
* Input:        fileName : Pchar        configuration file name, ASCIIZ
*
\****************************************************************************}

procedure midasLoadConfig(fileName : Pchar);




{****************************************************************************\
*
* Function:     midasSaveConfig(fileName : Pchar);
*
* Description:  Saves configuration to a file
*
* Input:        fileName : Pchar        configuration file name, ASCIIZ
*
\****************************************************************************}

procedure midasSaveConfig(fileName : Pchar);


{$ENDIF}



implementation


uses MIDAS, SDevice, mUtils, vgaText, {mFile,} mMem;


{ Pointers to all Sound Devices: (This should come from MIDAS.PAS but
  again due to the infinite stupidity of Borland Pascal it is
  impossible) }
const
    midasSoundDevices : array[0..(NUMSDEVICES-1)] of PSoundDevice = (
        @GUS, @SB, @NSND );





function midasConfig : integer; external;
{$IFNDEF NOLOADERS}
procedure midasLoadConfig(fileName : Pchar); external;
procedure midasSaveConfig(fileName : Pchar); external;
{$ENDIF}
{$L MCONFIG.OBJ}



END.
