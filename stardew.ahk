#SingleInstance Force
DetectHiddenWindows true
SetTitleMatchMode "RegEx"


W := 100
H := 100
X := 100
Y := 100

SVPROC := "ahk_exe Stardew"


suspendnoti(susstate) {
	if (susstate==0) {
		colour := "cGreen"
		state := "script on"
	} else {
		colour := "cRed"
		state := "script off"
	}
	MyGui := Gui("AlwaysOnTop Disabled ToolWindow", "runtime notification")
	MyGui.SetFont(colour  " s20")
	MyGui.Add("Text", "Center W200 R1.5 Y30", state)
	KeyWait "Space"
	MyGui.Show("NoActivate")
	sleep 400
	MyGui.Destroy()
}


#SuspendExempt
^space::
{
	global pausestate
	Suspend
	suspendnoti(A_IsSuspended)
	if A_IsSuspended == 0 {
		MasterLoop()
		SetTimer MasterLoop, 1000
	} else {
		SetTimer MasterLoop, 0
		SetTimer UpdateClientRes, 0
		UpdateClientRes()
		SetTimer InventoryPixelCheck, 0
		SetTimer HealthCheck, 0
		pausestate := 0
	}
}
#SuspendExempt False


ProcessSetPriority "R"
funcstate := 0


LBdown() {
	SendInput "{LButton Down}"
}

LBup() {
	SendInput "{LButton Up}"
}

Anidown() {
	SendInput "{r Down}{Delete Down}{RShift Down}"
}

Aniup() {
	SendInput "{r Up}{Delete Up}{RShift Up}"
}




HotIfWinActive SVPROC
Hotkey "LButton", sdfunc

sdfunc(ThisHotkey) {
	Critical
	if (funcstate == 0) {
		while GetKeyState("vk1", "P") {
			SendInput "{LButton Down}"
			sleep 10
			SendInput "{LButton Up}"
			sleep 140
			SendInput "{r Down}{Delete Down}{RShift Down}"
			sleep 30
			SendInput "{r Up}{Delete Up}{RShift Up}"
			sleep 10
		}
		Exit
	} else if (funcstate == 1) {
		while GetKeyState("vk1", "P") {
			SendInput "{LButton Down}"
			sleep 70
			SendInput "{LButton Up}"
			sleep 140
			SendInput "{r Down}{Delete Down}{RShift Down}"
			sleep 30
			SendInput "{r Up}{Delete Up}{RShift Up}"
			sleep 10
		}
		Exit
	} else if (funcstate == 2) {
		if !(GetKeyState("vk2", "P")) {
			Critical
			SendInput "{LButton Down}"
			sleep 1
			SendInput "{LButton Up}"
			KeyWait "vk1"
			
		} else {
			SendInput "{LButton Down}"
			sleep 1015
			SendInput "{LButton Up}"
			KeyWait "vk1", "D"
			SendInput "{LButton Down}"
			sleep 1
			SendInput "{LButton Up}"
			KeyWait "vk1"
		}
	}
}


modenoti(newmode, instruction?) {
	MyGui := Gui("AlwaysOnTop Disabled ToolWindow", "Mode")
	MyGui.SetFont("s15")
	MyGui.Add("Text", "Center W300 R2 Y30", newmode)
	MyGui.SetFont("s10")
	try MyGui.Add("Text", "Center W300 R3 Y+-20", instruction)
	MyGui.SetFont("underline")
	MyGui.Add("Text", "Center W300 R1.5 Y+5", "spacebar to dismiss")
	KeyWait "Space"
	MyGui.Show("NoActivate")
	try WinActivate SVPROC
	KeyWait "Space", "D"
	MyGui.Destroy()
	try WinActivate SVPROC
}



HotIfWinActive SVPROC
Hotkey "+Space", changestate


changestate(ThisHotkey) {
	global funcstate
	if (funcstate > 1) {
		funcstate := 0
	} else {
		funcstate++
	}

	if (funcstate == 0) {
		modenoti("simple attack mode")
	} else if (funcstate == 1) {
		modenoti("clay farming mode", "place hoe and pickaxe next to each other in inventory and select the one on the right")
	} else if (funcstate == 2) {
		modenoti("max fishing mode", "hold right mouse button then left-click (sorry only works on L10 fishing)")
	}
}




UpdateClientRes() {
	Thread "Interrupt", 0
	global W
	global H
	global X
	global Y
	global InvPix1x
	global InvPix1y
	global InvPix2x
	global InvPix2y
	global HealPix1x
	global HealPix1y
	global HealPix2x
	global HealPix2y
	try {
		WinGetClientPos &X, &Y, &W, &H, SVPROC
		InvPix1x := W/2+394
		InvPix1y := H-66
		InvPix2x := W/2+388
		InvPix2y := H-66
		HealPix1x := W-85
		HealPix1y := H-30
		HealPix2x := W-85
		HealPix2y := H-100
	}
}




InventoryPixelCheck() {
	Thread "Interrupt", 0
	try {
		Pix1Colour := PixelGetColor(InvPix1x, InvPix1y)
		Pix2Colour := PixelGetColor(InvPix2x, InvPix2y)
		if (((Pix1Colour == "0xDC7B05") && (Pix2Colour == "0xB14E05")) || ((Pix1Colour == "0x4A444D") && (Pix2Colour == "0x302C33"))) {
			Hotkey "LButton", "On"
		} else {
			Hotkey "LButton", "Off"
		}
	}
}


HealthCheck() {
	Thread "Interrupt", 0
	if ( WinActive(SVPROC) && PixelGetColor(W-70, H-60) == "0xDC7B05" && PixelGetColor(W-70, H-120) == "0xDC7B05" ) {
		pixel1 := PixelGetColor(HealPix1x, HealPix1y)
		pixel2 := PixelGetColor(HealPix2x, HealPix2y)
		if (pixel1 !== pixel2) {
			MyGui := Gui("AlwaysOnTop Disabled ToolWindow", "alert")
			MyGui.SetFont("cRed s20 w700")
			MyGui.Add("Text", "Center W200 R2 Y5", "HEALTH ALERT!!!")
			count := 0
			SetTimer alertshow, 350
			alertshow() {
				count++
				if (count == 5) {
					SetTimer , 0
					count := 0
				} else {
					MyGui.Show("NoActivate X" X+W/2 " Y" Y+H/3)
					SetTimer alerthide, -200
					alerthide() {
						MyGui.Hide()
						if (count == 0) {
							MyGui.Destroy()
						}
					}
				}
			}
		}
	}
}


pausestate := 0
SetTimer MasterLoop, 1000
MasterLoop() {
	Thread "Interrupt", 0
	global pausestate
	if WinActive(SVPROC) {
		newstate := 1
	} else {
		if !WinExist(SVPROC) {
			ExitApp
		}
		newstate := 0
	}
	
	if (newstate == pausestate) {
		return
	} else if ( (newstate == 0) | A_IsSuspended ) {
		Critical
		pausestate := newstate
		SetTimer UpdateClientRes, 0
		SetTimer InventoryPixelCheck, 0
		UpdateClientRes()
		SetTimer HealthCheck, 0
	} else if (newstate == 1) {
		Critical
		pausestate := newstate
		UpdateClientRes()
		InventoryPixelCheck()
		HealthCheck()
		SetTimer UpdateClientRes, 5000
		SetTimer InventoryPixelCheck, 500
		SetTimer HealthCheck, 3000
	}
}


MsgBox "Ctrl+Space to suspend hotkeys, Shift+Space to switch modes, check taskbar for application menu"
