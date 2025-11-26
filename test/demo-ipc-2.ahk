
#SingleInstance force
#include ..\src\FileMapping.ahk

; Run both this script and test\demo-ipc-1.ahk. Input a name or leave the default "\" and click
; "Open file mapping object". This will populate the name field with the actual name. Copy-paste the
; name to the other window and also click "Open file mapping object". Then try writing to one then
; reading from the other.

Demo_FileMapping()

class Demo_FileMapping {
    static Call() {
        width := 800
        rows := 10
        g := this.g := Gui('+Resize', , this)
        g.SetFont('s11 q5', 'Segoe Ui')
        g.Add('Edit', 'w' width ' r' rows ' Section vEdtInput')
        g.Add('Text', 'xs Section', 'File mapping name:')
        g.Add('Edit', 'ys w300 r1 vEdtName', '\')
        g.Add('Button', 'ys vBtnOpen', 'Open file mapping object').OnEvent('Click', 'HClickOpenFileMappingObject')
        g['BtnOpen'].Focus()
        g.Add('Button', 'ys', 'Copy name').OnEvent('Click', 'HClickButtonCopyName')
        g.Add('Text', 'xs w100 vTxtStatus', 'Status: closed')
        g.Add('Text', 'xs Section', 'Pos:')
        g.Add('Edit', 'ys w150 r1 vEdtPos', 0)
        g.Add('Button', 'ys', 'Set position').OnEvent('Click', 'HClickButtonSetPosition')
        g.Add('Button', 'ys', 'Read').OnEvent('Click', 'HClickButtonRead')
        g.Add('Button', 'ys', 'Write').OnEvent('Click', 'HClickButtonWrite')
        g.Add('Button', 'ys', 'Exit').OnEvent('Click', (*) => ExitApp())
        g.Add('Button', 'ys', 'Reload').OnEvent('Click', (*) => Reload())
        g.Show('x' (100 + width + 50))
        OnError(_OnError, 1)
        g.GetPos(, , &w, &h)
        g.initial_w := w
        g.initial_h := h
        for ctrl in g {
            ctrl.GetPos(&x, &y, &w, &h)
            ctrl.initial_x := x
            ctrl.initial_y := y
            ctrl.initial_w := w
            ctrl.initial_h := h
        }
        g.OnEvent('Size', 'OnSize')

        return

        _OnError(thrown, *) {
            if InStr(thrown.Message, 'This value of type "Class" has no property named "fm".') {
                MsgBox('Click "Open file mapping" first.')
                return 1
            }
        }
    }
    static HClickOpenFileMappingObject(*) {
        g := this.g
        ; We can leave most options as the default values, and just set the max size and name
        options := { MaxSize: FileMapping_VirtualMemoryGranularity, Name: g['EdtName'].Text }
        try {
            ; Create the object
            fm := this.fm := FileMapping(options)
            ; Open a view, and that's it. We can now call read/write.
            fm.OpenP(0, 1)
            g['TxtStatus'].Text := 'Status: opened'
            A_Clipboard := g['EdtName'].Text := fm.Name
            ShowTooltip('Copied name to clipboard')
        } catch Error as err {
            g['EdtInput'].Text := 'There was an error opening the file mapping object.`r`n' err.Message
        }
    }
    static HClickButtonSetPosition(*) {
        this.fm.Pos := Number(this.g['EdtPos'].Text)
        ShowTooltip('Position set to ' this.fm.Pos ' successfully')
    }
    static HClickButtonRead(*) {
        this.g['EdtInput'].Text := this.fm.Read()
        this.g['EdtPos'].Text := this.fm.Pos
        ShowTooltip('Read content successfully')
    }
    static HClickButtonWrite(*) {
        this.fm.Write(this.g['EdtInput'].Text)
        this.g['EdtPos'].Text := this.fm.Pos
        ShowTooltip('Wrote content successfully')
    }
    static HClickButtonCopyName(*) {
        A_Clipboard := this.g['EdtName'].Text
        ShowTooltip('Copied name successfully')
    }
    static OnSize(GuiObj, *) {
        GuiObj.OnEvent('Size', 'OnSize', 0)
        GuiObj.GetPos(, , &W, &H)
        diff_w := W - GuiObj.initial_w
        diff_h := H - GuiObj.initial_h
        for ctrl in GuiObj {
            if ctrl.Name = 'EdtInput' {
                ctrl.Move(, , ctrl.initial_w + diff_w, ctrl.initial_h + diff_h)
            } else {
                ctrl.Move(, ctrl.initial_y + diff_h)
            }
        }
        GuiObj.OnEvent('Size', 'OnSize', 1)
    }
}
ShowTooltip(Str) {
    static N := [1,2,3,4,5,6,7]
    Z := N.Pop()
    OM := CoordMode('Mouse', 'Screen')
    OT := CoordMode('Tooltip', 'Screen')
    MouseGetPos(&x, &y)
    Tooltip(Str, x, y, Z)
    SetTimer(_End.Bind(Z), -2000)
    CoordMode('Mouse', OM)
    CoordMode('Tooltip', OT)

    _End(Z) {
        ToolTip(,,,Z)
        N.Push(Z)
    }
}
