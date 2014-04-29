{*      S3M.PAS
 *
 * Scream Tracker 3 Module Player, v1.23
 *
 * Copyright 1995 Petteri Kangaslampi and Jarno Paananen
 *
 * This file is part of the MIDAS Sound System, and may only be
 * used, modified and distributed under the terms of the MIDAS
 * Sound System license, LICENSE.TXT. By continuing to use,
 * modify or distribute this file you indicate that you have
 * read the license and understand and accept it fully.
*}

unit S3M;
{$define NOLOADERS}
{$define CUTDOWN}
interface



{****************************************************************************\
*       struct s3mChannel
*       -----------------
* Description:  S3M player internal channel structure
\****************************************************************************}

type
    s3mChannel = Record
        note : byte;
        int : byte;
        vol : byte;
        cmd : byte;
        info : byte;
        flags : byte;

        sample : byte;
        volume : byte;

        period : word;
        snote : byte;
        preinfo : byte;
        toperi : word;
        notepsp : byte;
        retrigc : byte;

        status : byte;

        vibcmd : byte;
        vibpos : byte;

        volbar : byte;

        trefl : byte;
        trecnt : byte;
    end;




type
    Ppointer = ^pointer;
    Pword = ^word;
    Pinteger = ^integer;




{$IFNDEF NOLOADERS}


{****************************************************************************\
*
* Function:     function s3mLoadModule(fileName : Pchar; SD : pointer;
*                   SaveSampleInfo : pointer; module : Ppointer) : integer;
*
* Description:  Loads a Scream Tracker 3 module into memory
*
* Input:        char *fileName          name of module file to be loaded
*               SoundDevice *SD         Sound Device which will store the
*                                       samples
*               int (*SaveSampleInfo)() Pointer to sample information saving
*                                       function. Must have identical calling
*                                       convention with vuPrepare. NIL if no
*                                       such function is used.
*               mpModule **module       pointer to variable which will store
*                                       the module pointer.
*
* Returns:      MIDAS error code.
*               Pointer to module structure is stored in *module.
*
* Notes:        The only practical use at this point for SaveSampleInfo() are
*               the real VU-meters. To load a module and add the prepare the
*               VU meter information point SaveSampleInfo to vuPrepare().
*
\****************************************************************************}

function s3mLoadModule(fileName : Pchar; SD : pointer;
    SaveSampleInfo : pointer; module : Ppointer) : integer;




{****************************************************************************\
*
* Function:     s3mFreeModule(module : pointer; SD : pointer) : integer;
*
* Description:  Deallocates a Scream Tracker 3 module
*
* Input:        module : pointer        module to be deallocated
*               SD : PSoundDevice       Sound Device that has stored the
*                                       samples
*
* Returns:      MIDAS error code
*
\****************************************************************************}

function s3mFreeModule(module : pointer; SD : pointer) : integer;


{$ENDIF}




{****************************************************************************\
*
* Function:     s3mDetectChannels(module : pointer; numChns : Pword) :
*                   integer;
*
* Description:  Detects the number of channels in a Scream Tracker 3 module
*
* Input:        module : pointer        pointer to module structure
*               numChns : Pword         pointer to channel number variable
*
* Returns:      MIDAS error code.
*               Number of channels in module stored in numChns^.
*
\****************************************************************************}

function s3mDetectChannels(module : pointer; numChns : Pword) : integer;




{***************************************************************************\
*
* Function:     s3mFindUsedInsts(module : pointer; used : pointer) : integer;
*
* Description:  Finds which instruments are used in a Scream Tracker 3 module.
*
* Input:        module : pointer        Pointer to module structure. At least
*                                       the patterns must have been loaded
*               used : pointer          Pointer to instruments used array -
*                                       one byte per instrument. Set to 1 if
*                                       instrument is used, 0 if not.
*
* Returns:      MIDAS error code.
*
\***************************************************************************}

function s3mFindUsedInsts(module : pointer; used : pointer) : integer;


function s3mIdentify(header : pointer; recognized : Pinteger) : integer;
function s3mInit(SD : pointer) : integer;
function s3mClose : integer;
function s3mPlayModule(module : pointer; firstSDChannel, numSDChannels,
    loopStart, loopEnd : word) : integer;
function s3mStopModule : integer;
function s3mSetUpdRateFunct(setUpdRate : pointer) : integer;
function s3mPlay : integer;
function s3mSetPosition(npos : word) : integer;
function s3mGetInformation(info : Ppointer) : integer;



procedure mpS3M;                        { S3M Module Player structure. }



implementation


{$IFNDEF __BPREAL__}
{$DEFINE NOEMS}
{$ENDIF}


USES  Errors, mGlobals, mMem, MPlayer, SDevice, {mFile,} mUtils
{$IFNDEF NOEMS}
    ,EMS
{$ENDIF}
    ;


{$IFNDEF NOLOADERS}

function s3mLoadModule(fileName : Pchar; SD : pointer;
    SaveSampleInfo : pointer; module : Ppointer) : integer; external;
function s3mFreeModule(module : pointer; SD : pointer) : integer; external;
{$L S3MLOAD.OBJ}


{$ENDIF}


function s3mDetectChannels(module : pointer; numChns : Pword) : integer;
    external;
function s3mFindUsedInsts(module : pointer; used : pointer) : integer;
    external;
function s3mIdentify(header : pointer; recognized : Pinteger) : integer;
    external;
function s3mInit(SD : pointer) : integer; external;
function s3mClose : integer; external;
function s3mPlayModule(module : pointer; firstSDChannel, numSDChannels,
    loopStart, loopEnd : word) : integer; external;
function s3mStopModule : integer; external;
function s3mSetUpdRateFunct(setUpdRate : pointer) : integer; external;
function s3mPlay : integer; external;
function s3mSetPosition(npos : word) : integer; external;
function s3mGetInformation(info : Ppointer) : integer; external;
procedure mpS3M; external;
{$L S3M.OBJ}


END.
