{*      MIDAS.PAS
 *
 * Simplified MIDAS Sound System API
 *
 * Copyright 1995 Petteri Kangaslampi and Jarno Paananen
 *
 * This file is part of the MIDAS Sound System, and may only be
 * used, modified and distributed under the terms of the MIDAS
 * Sound System license, LICENSE.TXT. By continuing to use,
 * modify or distribute this file you indicate that you have
 * read the license and understand and accept it fully.
*}
{$define NOLOADERS}
{$define CUTDOWN}


unit MIDAS;


interface


{****************************************************************************\
*      MIDAS version defines
\****************************************************************************}

const
    MVERSTR : Pchar = '0.40a';
    MVERNUM : word = $0040;



{****************************************************************************\
*      MIDAS global variables:
\****************************************************************************}

const
    NUMSDEVICES = 3;                    { total number of Sound Devices }
    NUMMPLAYERS = 1;                    { total number of Module Players }

var
    midasSD : pointer;                  { pointer to current Sound Device }
    midasMP : pointer;                  { pointer to current Module Player }

var
    midasDisableEMS : integer;          { 1 if EMS usage is disabled
                                          (default 0) }
    midasSDNumber : integer;            { Sound Device number (-1 for
                                          autodetect, default -1) }
    midasSDPort : integer;              { Sound Device I/O port number
                                          (-1 for autodetect or SD default,
                                          default -1) }
    midasSDIRQ : integer;               { Sound Device IRQ number (-1 for
                                          autodetect or SD default,
                                          default -1) }
    midasSDDMA : integer;               { Sound Device DMA channel number
                                          (-1 for autodetect or SD default,
                                          default -1) }
    midasSDCard : integer;              { Sound Device sound card type
                                          (-1 for autodetect or SD default,
                                          default -1) }
    midasMixRate : word;                { Sound Device mixing rate }
    midasOutputMode : word;             { Sound Device output mode force
                                          bits, default 0 (SD default) }
    midasAmplification : integer;       { Forced amplification level or -1
                                          for SD default (default -1) }
    midasChannels : integer;            { number of channels open or 0 if no
                                          channels have been opened using
                                          midasOpenChannels() }
    midasPlayerNum : integer;           { timer music player number }

    midasEMSInit : integer;             { is EMS heap manager initialized? }
    midasTMRInit : integer;             { is TempoTimer initialized? }
    midasTMRPlay : integer;             { is sound being played with timer? }
    midasSDInit : integer;              { is Sound Device initialized? }
    midasSDChans : integer;             { are Sound Device channels open? }
    midasMPInit : integer;              { is Module Player initialized? }
    midasMPPlay : integer;              { is Module Player playing? }
    midasTMRMusic : integer;            { is music being player with timer? }





{****************************************************************************\
*      MIDAS global functions:
\****************************************************************************}


{****************************************************************************\
*
* Function:     midasError(errNum : integer);
*
* Description:  Prints a MIDAS error message to stderr, uninitializes MIDAS
*               and exits to DOS
*
* Input:        errNum : integer        MIDAS error code
*
\****************************************************************************}

procedure midasError(errNum : integer);




{****************************************************************************\
*
* Function:     midasUninitError(errNum : integer);
*
* Description:  Prints an error message to stderr and exits to DOS without
*               uninitializing MIDAS. This function should only be used
*               from midasClose();
*
* Input:        errNum : integer        MIDAS error code
*
\****************************************************************************}

procedure midasUninitError(errNum : integer);



{****************************************************************************\
*
* Function:     midasDetectSD;
*
* Description:  Attempts to detect a Sound Device. Sets the global variable
*               midasSD to point to the detected Sound Device or NIL if no
*               Sound Device was detected
*
\****************************************************************************}

procedure midasDetectSD;



{****************************************************************************\
*
* Function:     midasInit;
*
* Description:  Initializes MIDAS Sound System
*
\****************************************************************************}

procedure midasInit;



{****************************************************************************\
*
* Function:     midasClose;
*
* Description:  Uninitializes MIDAS Sound System
*
\****************************************************************************}

procedure midasClose;



{****************************************************************************\
*
* Function:     midasSetDefaults;
*
* Description:  Initializes MIDAS Sound System variables to their default
*               states. MUST be the first MIDAS function to be called.
*
\****************************************************************************}

procedure midasSetDefaults;


{$IFNDEF NOLOADERS}


{****************************************************************************\
*
* Function:     function midasLoadModule(fileName : Pchar; MPl : pointer;
*                   SaveSampleInfo : pointer) : pointer;
*
* Description:  Loads a module file into memory.
*
* Input:        fileName : Pchar        Pointer to module file name
*               MPl : pointer           Pointer to the Module Player which
*                                       will be used for loading the module
*               int (*SaveSampleInfo)() Pointer to sample information saving
*                                       function. The function must have
*                                       identical calling convention with
*                                       vuPrepare(). NIL if no such function
*                                       is used.
*
* Returns:      Pointer to the loaded module structure
*
* Notes:        The only practical use at this point for SaveSampleInfo() are
*               the real VU-meters. To load a module and add the prepare the
*               VU meter information use:
*                   module := midasLoadModule(fileName, MP, @vuPrepare);
*               Note that the definition of SaveSampleInfo matches exactly
*               the prototype of vuPrepare().
*
\****************************************************************************}

function midasLoadModule(fileName : Pchar; MPl : pointer;
    SaveSampleInfo : pointer) : pointer;




{****************************************************************************\
*
* Function:     midasFreeModule(module : pointer);
*
* Description:  Deallocates a module from memory
*
* Input:        module : pointer        Pointer to module to be deallocated
*
\****************************************************************************}

procedure midasFreeModule(module : pointer);


{$ENDIF}



{****************************************************************************\
*
* Function:     midasOpenChannels(numChans : integer);
*
* Description:  Opens Sound Device channels for sound and music output.
*
* Input:        numChans : integer      Number of channels to open
*
* Notes:        Channels opened with this function can be used for sound
*               playing, and modules played with midasPlayModule() will be
*               played through the last of these channels. This function is
*               provided so that the same number of channels can be open
*               the whole time throughout the execution of the program,
*               keeping the volume level constant. Note that you must ensure
*               that you open enough channels for all modules, otherwise
*               midasPlayModule() will fail.
*
\****************************************************************************}

procedure midasOpenChannels(numChans : integer);



{****************************************************************************\
*
* Function:     midasCloseChannels;
*
* Description:  Closes Sound Device channels opened with midasOpenChannels().
*               Do NOT call this function unless you have opened the sound
*               channels used yourself with midasOpenChannels().
*
\****************************************************************************}

procedure midasCloseChannels;



{****************************************************************************\
*
* Function:     midasPlayModule(module : pointer; numEffectChns : integer);
*
* Description:  Loads a module into memory, points midasMP to the correct
*               Module Player and starts playing it.
*
* Input:        module : pointer        Module loaded with midasLoadModule()
*               numEffectChns : integer Number of channels to open for sound
*                                       effects. Ignored if sound channels
*                                       have already been opened with
*                                       midasOpenChannels().
*
* Returns:      Pointer to module structure. This function can not fail,
*               as it will call midasError() to handle all error cases.
*
* Notes:        The Sound Device channels available for sound effects are the
*               _first_ numEffectChns channels. So, for example, if you use
*               midasPlayModule(module, 3), you can use channels 0-2 for sound
*               effects. If you already have opened channels with
*               midasOpenChannels(), the module will be played with the last
*               possible channels, so that the first channels will be
*               available for sound effects. Note that if not enough channels
*               are open this function will fail.
*
\****************************************************************************}

procedure midasPlayModule(module : pointer; numEffectChns : integer);





{****************************************************************************\
*
* Function:     midasStopModule(module : pointer);
*
* Input:        module : pointer        the module which is being played
*
* Description:  Stops playing a module and uninitializes the Module Player.
*               If sound channels were NOT opened through midasOpenChannels(),
*               but by letting midasPlayModule() open them, they will be
*               closed. Sound channels opened with midasOpenChannels() are NOT
*               closed and must be closed separately.
*
\****************************************************************************}

procedure midasStopModule(module : pointer);





implementation


{$IFNDEF __BPREAL__}
{$DEFINE NOEMS}
{$ENDIF}


uses Errors, mGlobals, mMem, {mFile,} SDevice, MPlayer, S3M,
     Timer, DMA, DSM, mUtils
{$IFNDEF NOEMS}
    ,EMS
{$ENDIF}
    ;




{****************************************************************************\
*      Static variables used by midasXXXX() functions:
\****************************************************************************}

{ pointers to all Sound Devices: }
const
    midasSoundDevices : array[0..(NUMSDEVICES-1)] of PSoundDevice = (
        @GUS, @SB, @NSND );

var
    SD : PSoundDevice;                  { current Sound Device }
    MP : PModulePlayer;                 { current Module Player }




{****************************************************************************\
*
* Function:     midasError(errNum : integer);
*
* Description:  Prints a MIDAS error message to stderr, uninitializes MIDAS
*               and exits to DOS
*
* Input:        errNum : integer        MIDAS error code
*
\****************************************************************************}

procedure midasError(errNum : integer);
var
    errmsg : array[0..59] of char;
begin
    midasClose;
    mStrCopy(@errmsg[0], 'MIDAS Error: ');
    mStrAppend(@errmsg[0], errorMsg[errNum]);
    errErrorExit(@errmsg[0]);
end;




{****************************************************************************\
*
* Function:     midasUninitError(errNum : integer);
*
* Description:  Prints an error message to stderr and exits to DOS without
*               uninitializing MIDAS. This function should only be used
*               from midasClose();
*
* Input:        errNum : integer        MIDAS error code
*
\****************************************************************************}

procedure midasUninitError(errNum : integer);
var
    errmsg : array[0..84] of char;
begin
    mStrCopy(@errmsg[0], 'FATAL MIDAS uninitialization failure: ');
    mStrAppend(@errmsg[0], errorMsg[errNum]);
    errErrorExit(@errmsg[0]);           { print error message and exit }
end;




{****************************************************************************\
*
* Function:     midasDetectSD;
*
* Description:  Attempts to detect a Sound Device. Sets the global variable
*               midasSD to point to the detected Sound Device or NIL if no
*               Sound Device was detected
*
\****************************************************************************}

procedure midasDetectSD;
var
    dsd, dResult, error : integer;
    sdev : PSoundDevice;
begin
    midasSD := NIL;                     { nothing detected yet }
    SD := NIL;
    dsd := 0;                           { start from first Sound Device }

    { search through Sound Devices until a Sound Device is detected: }
    while (midasSD = NIL) and (dsd < NUMSDEVICES) do
    begin
        { attempt to detect current SD: }
        sdev := midasSoundDevices[dsd];
        error := sdev^.Detect(@dResult);
        if error <> OK then
            midasError(error);
        if dResult = 1 then
        begin
            midasSDNumber := dsd;       { Sound Device detected }
            { point midasSD to this Sound Device: }
            midasSD := sdev;
            SD := sdev;
        end;
        dsd := dsd + 1;                 { try next Sound Device }
    end;
end;




{****************************************************************************\
*
* Function:     midasInit;
*
* Description:  Initializes MIDAS Sound System
*
\****************************************************************************}

procedure midasInit;
var
    result, error : integer;
begin
{$IFNDEF NOEMS}
    if midasDisableEMS = 0 then         { is EMS usage disabled? }
    begin
        { Initialize EMS Heap Manager: }
        error := emsInit(@midasEMSInit);
        if error <> OK then
            midasError(error);

        { was EMS Heap Manager initialized? }
        if midasEMSInit = 1 then
        begin
            useEMS := 1;                { yes, use EMS memory }
        end
        else
        begin
            useEMS := 0;                { no, do not use EMS memory }
        end;
    end
    else
    begin
        midasEMSInit := 0;
        useEMS := 0;                    { EMS disabled - do not use it }
    end;
{$ELSE}
    midasEMSInit := 0;
    useEMS := 0;
{$ENDIF}

    if midasSDNumber = -1 then          { has a Sound Device been selected? }
    begin
        midasDetectSD;                  { attempt to detect Sound Device }
        if SD = NIL then
            midasError(errSDFailure);
    end
    else
    begin
        { Use selected Sound Device: }
        midasSD := midasSoundDevices[midasSDNumber];
        SD := midasSD;

        { Sound Device number was forced, but if no I/O port, IRQ or DMA
          number has been set, try to autodetect the values for this Sound
          Device. If detection fails, use default values: }

        if (midasSDPort = -1) and (midasSDIRQ = -1) and (midasSDDMA = -1) then
        begin
            error := SD^.Detect(@result);
            if error <> OK then
                midasError(error);
        end;
    end;

    if midasSDPort <> -1 then           { has an I/O port been selected? }
        SD^.port := midasSDPort;        { if yes, set it to Sound Device }
    if midasSDIRQ <> -1 then            { SD IRQ number? }
        SD^.IRQ := midasSDIRQ;          { if yes, set it to Sound Device }
    if midasSDDMA <> -1 then            { SD DMA channel number? }
        SD^.DMA := midasSDDMA;
    if midasSDCard <> -1 then           { sound card type? }
        SD^.cardType := midasSDCard;

{$IFNDEF NOTIMER}
    { initialize TempoTimer: }
    error := tmrInit;
    if error <> OK then
        midasError(error);
    midasTMRInit := 1;                  { TempoTimer initialized }
{$ENDIF}

    { initialize Sound Device: }
    error := SD^.Init(midasMixRate, midasOutputMode);
    if error <> OK then
        midasError(error);
    midasSDInit := 1;                   { Sound Device initialized }

{$IFNDEF NOTIMER}
    { start playing sound using the timer: }
    error := tmrPlaySD(midasSD);
    if error <> OK then
        midasError(error);
    midasTMRPlay := 1;
{$ENDIF}
end;




{****************************************************************************\
*
* Function:     midasClose;
*
* Description:  Uninitializes MIDAS Sound System
*
\****************************************************************************}

procedure midasClose;
var
    error : integer;
begin
{$IFNDEF NOTIMER}
    { if music is being played with timer, stop it: }
    if midasTMRMusic <> 0 then
    begin
        error := MP^.SetUpdRateFunct(NIL);
        if error <> OK then
            midasUninitError(error);
        error := tmrStopMusic(midasPlayerNum);
        if error <> OK then
            midasUninitError(error);

        midasTMRMusic := 0;
    end;
{$ENDIF}

    { if Module Player is playing, stop it: }
    if midasMPPlay <> 0 then
    begin
        error := MP^.StopModule;
        if error <> OK then
            midasUninitError(error);
        midasMPPlay := 0;
    end;

    { if Module Player has been initialized, uninitialize it: }
    if midasMPInit <> 0 then
    begin
        error := MP^.Close;
        if error <> OK then
            midasUninitError(error);
        midasMPInit := 0;
        MP := NIL;
        midasMP := NIL;
    end;

    { if Sound Device channels are open, close them: }
    if midasSDChans <> 0 then
    begin
        error := SD^.CloseChannels;
        if error <> OK then
            midasUninitError(error);
        midasSDChans := 0;
        midasChannels := 0;
    end;

{$IFNDEF NOTIMER}
    { if sound is being played, stop it: }
    if midasTMRPlay <> 0 then
    begin
        error := tmrStopSD;
        if error <> OK then
            midasUninitError(error);
        midasTMRPlay := 0;
    end;
{$ENDIF}

    { if Sound Device is initialized, uninitialize it: }
    if midasSDInit <> 0 then
    begin
        error := SD^.Close;
        if error <> OK then
            midasUninitError(error);
        midasSDInit := 0;
        SD := NIL;
        midasMP := NIL;
    end;

{$IFNDEF NOTIMER}
    { if TempoTimer is initialized, uninitialize it: }
    if midasTMRInit <> 0 then
    begin
        error := tmrClose;
        if error <> OK then
            midasUninitError(error);
        midasTMRInit := 0;
    end;
{$ENDIF}

{$IFNDEF NOEMS}
    { if EMS Heap Manager is initialized, uninitialize it: }
    if midasEMSInit <> 0 then
    begin
        error := emsClose;
        if error <> OK then
            midasUninitError(error);
        midasEMSInit := 0;
    end;
{$ENDIF}
end;




{****************************************************************************\
*
* Function:     midasSetDefaults;
*
* Description:  Initializes MIDAS Sound System variables to their default
*               states. MUST be the first MIDAS function to be called.
*
\****************************************************************************}

procedure midasSetDefaults;
begin
    midasEMSInit := 0;                  { EMS heap manager is not
                                           initialized yet }
    midasTMRInit := 0;                  { TempoTimer is not initialized }
    midasTMRPlay := 0;                  { Sound is not being played }
    midasSDInit := 0;                   { Sound Device is not initialized }
    midasSDChans := 0;                  { Sound Device channels are not
                                           open }
    midasMPInit := 0;                   { Module Player is not initialized }
    midasMPPlay := 0;                   { Module Player is not playing }
    midasTMRMusic := 0;                 { Music is not being played with
                                           timer }
    midasChannels := 0;                 { No channels opened }

    ptTempo := 1;                       { enable ProTracker BPM tempos }
    usePanning := 1;                    { enable ProTracker panning cmds }
    surround := 0;                      { disable surround to save GUS mem }
    extendedOctaves := 0;               { Disable extended octaves }
    useVDS := 1;                        { use VDS if found }

    midasDisableEMS := 0;               { do not disable EMS usage }
    midasSDNumber := -1;                { no Sound Device forced }
    midasSDPort := -1;                  { no I/O port forced }
    midasSDIRQ := -1;                   { no IRQ number forced }
    midasSDDMA := -1;                   { no DMA channel number forced }
    midasSDCard := -1;                  { no sound card type forced }
    midasOutputMode := 0;               { no output mode forced }
    midasMixRate := 44100;              { attempt to use 44100Hz mixing
                                          rate }
    midasAmplification := -1;           { use default amplification level }

    SD := NIL;                          { point SD and MP to NULL for }
    midasSD := NIL;                     { safety }
    MP := NIL;
    midasMP := NIL;
end;



{$IFNDEF NOLOADERS}



{****************************************************************************\
*
* Function:     function midasLoadModule(fileName : Pchar; MPl : pointer;
*                   SaveSampleInfo : pointer) : pointer;
*
* Description:  Loads a module file into memory.
*
* Input:        fileName : Pchar        Pointer to module file name
*               MPl : pointer           Pointer to the Module Player which
*                                       will be used for loading the module
*               int (*SaveSampleInfo)() Pointer to sample information saving
*                                       function. The function must have
*                                       identical calling convention with
*                                       vuPrepare(). NIL if no such function
*                                       is used.
*
* Returns:      Pointer to the loaded module structure
*
* Notes:        The only practical use at this point for SaveSampleInfo() are
*               the real VU-meters. To load a module and add the prepare the
*               VU meter information use:
*                   module = midasLoadModule(fileName, MP, &vuPrepare);
*               Note that the definition of SaveSampleInfo matches exactly
*               the prototype of vuPrepare().
*
\****************************************************************************}

function midasLoadModule(fileName : Pchar; MPl : pointer;
    SaveSampleInfo : pointer) : pointer;
var
    module : PmpModule;
    error : integer;
    MPlayr : PModulePlayer;
begin
    { load module: }
    MPlayr := MPl;
    error := MPlayr^.LoadModule(fileName, midasSD, SaveSampleInfo, @module);
    if error <> OK then
        midasError(error);

    midasLoadModule := module
end;




{****************************************************************************\
*
* Function:     midasFreeModule(module : pointer);
*
* Description:  Deallocates a module from memory
*
* Input:        module : pointer        Pointer to module to be deallocated
*
\****************************************************************************}

procedure midasFreeModule(module : pointer);
var
    MPlayr : PModulePlayer;
    error : integer;
    mpmod : PmpModule;
begin
    mpmod := module;
    MPlayr := mpmod^.MP;

    error := MPlayr^.FreeModule(module, midasSD);
    if error <> OK then
        midasError(error);
end;


{$ENDIF}



{****************************************************************************\
*
* Function:     midasOpenChannels(numChans : integer);
*
* Description:  Opens Sound Device channels for sound and music output.
*
* Input:        numChans : integer      Number of channels to open
*
* Notes:        Channels opened with this function can be used for sound
*               playing, and modules played with midasPlayModule() will be
*               played through the last of these channels. This function is
*               provided so that the same number of channels can be open
*               the whole time throughout the execution of the program,
*               keeping the volume level constant. Note that you must ensure
*               that you open enough channels for all modules, otherwise
*               midasPlayModule() will fail.
*
\****************************************************************************}

procedure midasOpenChannels(numChans : integer);
var
    error : integer;
begin
    midasChannels := numChans;

    { open Sound Device channels: }
    error := SD^.OpenChannels(numChans);
    if error <> OK then
        midasError(error);
    midasSDChans := 1;

    { set amplification level if forced: }
    if midasAmplification <> -1 then
    begin
        error := SD^.SetAmplification(midasAmplification);
        if error <> OK then
            midasError(error);
    end;
end;




{****************************************************************************\
*
* Function:     midasCloseChannels;
*
* Description:  Closes Sound Device channels opened with midasOpenChannels().
*               Do NOT call this function unless you have opened the sound
*               channels used yourself with midasOpenChannels().
*
\****************************************************************************}

procedure midasCloseChannels;
var
    error : integer;
begin
    { Close Sound Device channels: }
    error := SD^.CloseChannels;
    if error <> OK then
        midasError(error);
    midasSDChans := 0;
    midasChannels := 0;
end;




{****************************************************************************\
*
* Function:     midasPlayModule(module : pointer; numEffectChns : integer);
*
* Description:  Loads a module into memory, points midasMP to the correct
*               Module Player and starts playing it.
*
* Input:        module : pointer        Module loaded with midasLoadModule()
*               numEffectChns : integer Number of channels to open for sound
*                                       effects. Ignored if sound channels
*                                       have already been opened with
*                                       midasOpenChannels().
*
* Returns:      Pointer to module structure. This function can not fail,
*               as it will call midasError() to handle all error cases.
*
* Notes:        The Sound Device channels available for sound effects are the
*               _first_ numEffectChns channels. So, for example, if you use
*               midasPlayModule(module, 3), you can use channels 0-2 for sound
*               effects. If you already have opened channels with
*               midasOpenChannels(), the module will be played with the last
*               possible channels, so that the first channels will be
*               available for sound effects. Note that if not enough channels
*               are open this function will fail.
*
\****************************************************************************}

procedure midasPlayModule(module : pointer; numEffectChns : integer);
var
    numChans, error, firstChannel : integer;
    mpmod : PmpModule;
begin
    mpmod := module;
    midasMP := mpmod^.MP;
    MP := midasMP;

    { initialize module player: }
    error := MP^.Init(midasSD);
    if error <> OK then
        midasError(error);
    midasMPInit := 1;

    numChans := mpmod^.numChans;

    { Open Sound Device channels if not already open: }
    if midasChannels = 0 then
    begin
        error := SD^.OpenChannels(numChans + numEffectChns);
        if error <> OK then
            midasError(error);
        midasSDChans := 1;
        firstChannel := numEffectChns;

        { set amplification level if forced: }
        if midasAmplification <> -1 then
        begin
            error := SD^.SetAmplification(midasAmplification);
            if error <> OK then
                midasError(error);
        end;
    end
    else
    begin
        if midasChannels < numChans then
            midasError(errNoChannels);
        firstChannel := midasChannels - numChans;
    end;

    { Start playing the module using the last Sound Device channels and
      looping the whole song: }
    error := MP^.PlayModule(module, firstChannel, numChans, 0, 32767);
    if error <> OK then
        midasError(error);
    midasMPPlay := 1;

{$IFNDEF NOTIMER}
    { start playing using the timer: }
    error := tmrPlayMusic(@MP^.Play, @midasPlayerNum);
    if error <> OK then
        midasError(error);
    error := MP^.SetUpdRateFunct(@tmrSetUpdRate);
    if error <> OK then
        midasError(error);

    midasTMRMusic := 1;
{$ENDIF}
end;





{****************************************************************************\
*
* Function:     midasStopModule(module : pointer);
*
* Input:        module : pointer        the module which is being played
*
* Description:  Stops playing a module and uninitializes the Module Player.
*               If sound channels were NOT opened through midasOpenChannels(),
*               but by letting midasPlayModule() open them, they will be
*               closed. Sound channels opened with midasOpenChannels() are NOT
*               closed and must be closed separately.
*
\****************************************************************************}

procedure midasStopModule(module : pointer);
var
    error, i : integer;
    mpmod : PmpModule;
begin
    mpmod := module;
    midasMP := mpmod^.MP;
    MP := mpmod^.MP;

{$IFNDEF NOTIMER}
    { Stop playing music with timer: }
    error := MP^.SetUpdRateFunct(NIL);
    if error <> OK then
        midasError(error);
    error := tmrStopMusic(midasPlayerNum);
    if error <> OK then
        midasError(error);

    midasTMRMusic := 0;
{$ENDIF}

    { stop playing the module: }
    error := MP^.StopModule;
    if error <> OK then
        midasError(error);
    midasMPPlay := 0;

    { uninitialize Module Player: }
    error := MP^.Close;
    if error <> OK then
        midasError(error);
    midasMPInit := 0;
    midasMP := NIL;                     { point midasMP to NULL for safety }

    { If Sound Device channels were not opened with midasOpenChannels(),
      close them: }
    if midasChannels = 0 then
    begin
        error := SD^.CloseChannels;
        if error <> OK then
            midasError(error);
        midasSDChans := 0;
    end
    else
    begin
        { Sound Device channels were originally opened with
          midasOpenChannels(). Now stop sounds from the channels used by
          the Module Player: }
        for i := (midasChannels - mpmod^.numChans) to (midasChannels - 1) do
        begin
            error := SD^.StopSound(i);
            if error <> OK then
                midasError(error);
            error := SD^.SetVolume(i, 0);
            if error <> OK then
                midasError(error);
        end;
    end;
end;



END.
