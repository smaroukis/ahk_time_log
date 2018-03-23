#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; ---------------------------------------------------------------------
; Stop watch. Start it with F11, stop it with F12. Reset by deleting the 
; LogFile.
; Writes Starttime, stoptime, actual intervall and cumulated time in a 
; logfile
; ---------------------------------------------------------------------

; ---------------------------------------------------------------------
; -- Configuration: ---------------------------------------------------
; ---------------------------------------------------------------------
LogFile=C:\Users\sqmx\Desktop\Time_log.txt	  ;path and name of the Logfile
;OnIcon=timerA.ico					;name and path of the taskbar icon when timer on
;OffIcon=timerB.ico					;name and path of the taskbar icon when timer of
OnTooltip=Timer On					;Tooltip with clock running
OffTooltip=TimerOff					;Tooltip with clock off

; ---------------------------------------------------------------------
; -- Initialize: ------------------------------------------------------
; ---------------------------------------------------------------------
State=TimerOff
Menu, tray, Icon,%OffIcon%
Menu, Tray, Tip,%OffTooltip%		;ToolTip: Timer Status

; ---------------------------------------------------------------------
; -- Autoexecute ------------------------------------------------------
; ---------------------------------------------------------------------

F11::
MsgBox, , , Started Timer, 1	
LogType:=GetLogType()
StartTime=
StopTime=
StartTime=%A_Now%
State=TimerOn
Menu, tray, Icon,%OnIcon% 
Menu, Tray, Tip,%OnTooltip%
return

F12::
if state=TimerOff					;checks if Timer is running before shutting it down
	return
State=TimerOff
StopTime=%A_Now%
TimeDiff=%StopTime%
EnvSub TimeDiff, %StartTime%, seconds			
Last=
IfExist %Logfile% 
	{
	Last:=LastFieldInFile(LogFile)
	}
Actual=%Last%
EnvAdd Actual,%TimeDiff%, 
TimeLog(StartTime,LogType, StopTime,TimeDiff,Actual,LogFile)
StartTime=
StopTime=	
Menu, tray, Icon,%OffIcon% 
Menu, Tray, Tip,%OffTooltip%
MsgBox, , , Stopped Timer, 1	
return


	
; ---------------------------------------------------------------------
; -- Functions --------------------------------------------------------
; ---------------------------------------------------------------------
TimeLog(T1,LogType, T2,Sek,CumSek,File)			
;Formats Time values and appends them to the logfile 
;T1:StartTime (as YYYYMMDDhhmmss) T2:StopTime (as YYYYMMDDhhmmss) 
;Sek: Duration this session (in seconds),, CumSek: Duration all sessions (in seconds)
;File: Name and path of the logfile
{
	Stringmid, Y1,T1,1,4	;Year
	Stringmid, M1,T1,5,2	;Month
	Stringmid, D1,T1,7,2	;Day
	Stringmid, h1,T1,9,2	;hour
	Stringmid, min1,T1,11,2	;minute
	Stringmid, s1, T1,13,2	;second
	
	Stringmid, Y2,T2,1,4	;Year
	Stringmid, M2,T2,5,2	;Month
	Stringmid, D2,T2,7,2	;Day
	Stringmid, h2,T2,9,2	;hour
	Stringmid, min2,T2,11,2	;minute
	Stringmid, s2, T2,13,2	;second
	
	T1_Format=%D1%.%M1%.%Y1%  %h1%:%min1%:%s1%
	T2_Format=%h2%:%min2%:%s2%
	Sek_Format:=FormatSeconds(Sek)			;This session (in seconds)
	CumSek_Format:=FormatSeconds(CumSek)	;All sessions (in seconds)
	
	
	;Modify this string to change the log-appearance. CumSek must alway be last, separated by a tab.:
	Fileappend, %T1_Format%%A_Tab%%LogType%%A_Tab%%T2_Format%%A_Tab%%Sek_Format%%A_Tab%%Sek%%A_Tab%%CumSek_Format%%a_Tab%%CumSek%`n,%File%
}
; ---------------------------------------------------------------------

FormatSeconds(Z1)
;converts seconds to hh:mm:ss  
;Z1: Time in seconds
{
	transform,S,MOD,Z1,60 
	stringlen,L1,S 
	if L1 =1 
	S=0%S% 
	if S=0 
	S=00 

	M1 :=(Z1/60) 
	transform,M2,MOD,M1,60 
	transform,M3,Floor,M2 
	stringlen,L2,M3 
	if L2 =1 
	M3=0%M3% 
	if M3=0 
	M3=00 
	
	H1 :=(M1/60) 
	transform,H2,Floor,H1 
	stringlen,L2,H2 
	if L2=1 
	H2=0%H2% 
	if H2=0 
	H2=00 
	result= %H2%:%M3%:%S%
	return result
}

;----------------------------------------------------------------------
LastFieldInFile(Filename)
;Returns the content of the last tab-delimited field in the last line of a file.
{
	loop,read,%Filename%					;Number of lines in file
	{ 
		++LastLineNumber 
	} 
	FileReadLine, LastLine, %Filename%, %LastLineNumber%
	Loop, parse, LastLine, %A_Tab%			;Number of fields in last line
	{
		++LastFieldNumber	
	}
	Loop, parse, LastLine, %A_Tab%			;Content of last field in last line
	{
		if A_Index = %LastFieldNumber%
			{
			LastFieldContent=%A_LoopField%
			}
	}
	return %LastFieldContent%
	
}

;---------------------------------------------------------------------
GetLogType()
;Returns 'SNEM' for 1, 'NEM-MT' for 2 pressed.
{
	Input, InputKey, L1, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}
	if (InputKey = 1)
	{
		LT:="SNEM"
	}
	else if (InputKey = 2)
	{
		LT:="NEM-MT"
	}
	else
	{
		Msgbox, Please press [1] for SNEM or [2] for NEMMT
		return GetLogType()
	}
	Msgbox, , ,Selected LogType is %LT%, 1
	return LT
}

Quit:
   ExitApp
Return