Option Explicit

Dim shell
Dim scriptPath
Dim command

Set shell = CreateObject("WScript.Shell")
scriptPath = Replace(WScript.ScriptFullName, "rhwp_launcher.vbs", "rhwp_launcher.ps1")
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & scriptPath & """"

shell.Run command, 0, False
