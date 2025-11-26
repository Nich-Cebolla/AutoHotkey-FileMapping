
#SingleInstance force
#include ..\src\FileMapping.ahk

if !A_IsCompiled && A_ScriptFullPath == A_LineFile {
    test_FileMapping()
    OutputDebug(A_ScriptFullPath ' : complete`n')
}

class test_FileMapping {
    static __New() {
        this.DeleteProp('__New')
        this.Encodings := [ 'cp1200', 'cp65001' ]
    }
    static Call() {
        this.path := this.GetPath()
        this.onexit := OnExitCallback(this.path)
        OnExit(this.onexit, 1)
        this.OpenAndReadSmall()
        this.WriteSmall()
        this.WriteAndExpandSmall()
        this.AdjustMaxSizeSmallFile()
        this.GeneralMethods()
        this.LoopReadLarge()
        this.WriteSmall_Pagefile()
        this.WriteLarge_Pagefile()
        this.LoopReadSmall()
        this.ExtendViewOrEndOfMapping()
        this.ToFile()
    }
    static AdjustMaxSizeSmallFile() {
        path := this.path
        test_txt := this.GetSmallContent()
        for encoding in this.Encodings {
            f := FileOpen(path, 'w', encoding)
            f.Write(test_txt)
            sz := DllCall(g_kernel32_GetFileSize, 'ptr', f.Handle, 'ptr', 0, 'Int')
            f.Close()
            options := {
                path: path
              , encoding: encoding
              , MaxSize: sz
            }
            fm := FileMapping(options)
            fm.Open()
            fm.Pos := fm.Size
            _txt := '1234567890'
            ; This should fail and return 0
            if fm.Write(_txt, false) {
                throw Error('Expected return value of 0.')
            }
            ; the object should auto-expand the file mapping object to twice the current size, then
            ; write the text
            fm.Write(_txt, true)
            if fm.MaxSize != sz * 2 {
                throw Error('Expected double the size.', , fm.MaxSize)
            }
            test_pos := StrLen(_txt) * fm.BytesPerChar + StrLen(test_txt) * fm.BytesPerChar + fm.StartByte
            if fm.Pos != test_pos {
                throw Error('Invalid position.')
            }
            ; The view's size should have been rounded up along with the max size
            if fm.Size != fm.MaxSize {
                throw Error('Invalid view size.')
            }
            fm.Terminate()
            if fm.Pos != test_pos + fm.BytesPerChar {
                throw Error('Invalid position.')
            }
            fm.Pos := fm.StartByte
            str := fm.Read()
            if str != test_txt _txt {
                throw Error('Invalid read content.')
            }
            ; The position will be at the end of the string, before the null terminator.
            if fm.Pos != test_pos {
                throw Error('Invalid position.')
            }
            fm.Flush()
            fm.FlushFileBuffers()
            str := FileRead(path, encoding)
            if str != test_txt _txt {
                throw Error('Invalid read content.')
            }
            fm.Close()
        }
    }
    static ExtendViewOrEndOfMapping() {
        ; This tests method ExtendView passing true to `OrEndOfMapping` parameter.
        test_txt := this.GetSmallContent()
        for encoding in this.Encodings {
            test_maxSize := StrLen(test_txt) * 2 * (encoding = 'cp1200' ? 2 : 1)
            options := { encoding: encoding, MaxSize: test_maxSize }
            fm := FileMapping(options)
            test_size := test_maxSize / 2
            fm.Open(0, test_size)
            if fm.Size != test_size {
                throw Error('Invalid size.')
            }
            ; Should be 0
            if fm.Pos {
                throw Error('Invalid pos.')
            }
            fm.ExtendView(FileMapping_VirtualMemoryGranularity, true)
            if fm.Size != fm.MaxSize {
                throw Error('Invalid size.')
            }
            if fm.Pos {
                throw Error('Invalid pos')
            }
            fm.Close()
            ; Essentially same as above but also writes text
            fm.Open(0, test_size)
            if fm.Size != test_size {
                throw Error('Invalid size.')
            }
            ; Should be 0
            if fm.Pos {
                throw Error('Invalid pos.')
            }
            fm.Write(test_txt)
            test_pos := fm.Pos
            fm.ExtendView(FileMapping_VirtualMemoryGranularity, true)
            if fm.Size != fm.MaxSize {
                throw Error('Invalid size.')
            }
            if fm.Pos != test_pos {
                throw Error('Invalid pos')
            }
            fm.Write(test_txt)
            fm.Pos := 0
            str := fm.Read()
            if str != test_txt test_txt {
                throw Error('Invalid read content.')
            }
        }
    }
    static GeneralMethods() {
        path := this.GetPath()
        options := { path: path }
        for encoding in this.Encodings {
            f := FileOpen(path, 'w', encoding)
            f.Write(this.GetSmallContent())
            f.Close()
            fm := FileMapping(options)
            fm.SetEncoding(encoding)
            fm.Open()
            if !fm.hFile || !fm.hMapping || !fm.Size || !fm.Ptr {
                throw Error('Expected completely open view.')
            }
            if fm.GetEncoding() != encoding {
                throw Error('Invalid encoding.')
            }
            fm.CloseView()
            if fm.Size || fm.Ptr {
                throw Error('Expected no size or ptr.')
            }
            fm.CloseMapping()
            if fm.hMapping {
                throw Error('Expected no hMapping.')
            }
            fm.CloseFile()
            if fm.hFile {
                throw Error('Expected no hFile.')
            }
            fm.OpenFile()
            if !fm.hFile {
                throw Error('Expected hFile.')
            }
            fm.OpenMapping()
            if !fm.hMapping {
                throw Error('Expected hMapping.')
            }
            fm.OpenView()
            if !fm.Ptr || !fm.Size {
                throw Error('Expected ptr and size.')
            }
            fm.Close()
            if fm.hFile || fm.hMapping || fm.Size || fm.Ptr {
                throw Error('Expected completely closed object.')
            }
        }
        ; SetFileTime
        fm.OpenFile()
        st := FileMapping_SystemTime()
        st.wYear -= 4
        fts := [ st.ToFileTime() ]
        st.wYear += 1
        fts.Push(st.ToFileTime())
        st.wYear += 1
        fts.Push(st.ToFileTime())
        fm.SetFileTime(fts[1], fts[2], fts[3])
        ; The file time resolution is not perfect. Also, AHK returns the value in local time.
        ; So we do not expect exactly the same value to be reflected in the metadata. We just check
        ; the year to make sure the year was updated.
        t := FileGetTime(fm.Path, 'C')
        t2 := fts[1].ToSystemTime().Timestamp
        if SubStr(t, 1, 4) != SubStr(t2, 1, 4) {
            throw Error('Invalid timestamp.')
        }
        t := FileGetTime(fm.Path, 'A')
        t2 := fts[2].ToSystemTime().Timestamp
        if SubStr(t, 1, 4) != SubStr(t2, 1, 4) {
            throw Error('Invalid timestamp.')
        }
        t := FileGetTime(fm.Path, 'M')
        t2 := fts[3].ToSystemTime().Timestamp
        if SubStr(t, 1, 4) != SubStr(t2, 1, 4) {
            throw Error('Invalid timestamp.')
        }
        ; UpdateFileTime
        ft := fm.UpdateFileTime()
        t := FileGetTime(fm.Path, 'A')
        t2 := ft.ToSystemTime().Timestamp
        if SubStr(t, 1, 4) != SubStr(t2, 1, 4) {
            throw Error('Invalid timestamp.')
        }
        t := FileGetTime(fm.Path, 'M')
        if SubStr(t, 1, 4) != SubStr(t2, 1, 4) {
            throw Error('Invalid timestamp.')
        }
        ; SetName
        name := fm.SetName('\')
        if StrLen(name) != 16 {
            throw Error('Invalid strlen.')
        }
        test_txt := 'Global\'
        test_len := 20
        name := fm.SetName(test_txt '\' test_len)
        if SubStr(name, 1, StrLen(test_txt)) != test_txt {
            throw Error('Invalid name.')
        }
        if StrLen(name) != test_len + StrLen(test_txt) {
            throw Error('Invalid strlen.')
        }
        test_txt := 'Local\'
        test_len := 19
        name := fm.SetName(test_txt '\' test_len)
        if SubStr(name, 1, StrLen(test_txt)) != test_txt {
            throw Error('Invalid name.')
        }
        if StrLen(name) != test_len + StrLen(test_txt) {
            throw Error('Invalid strlen.')
        }
    }
    static GetLargeContent(&OutStr, quotient := 5) {
        bytes := DllCall('GetLargePageMinimum', 'uint') * quotient
        len := bytes / 2
        line := '{:06} 0123456789'
        loop 26 {
            line .= Chr(64 + A_Index)
        }
        lines := Ceil(len / StrLen(line))
        OutStr := ''
        VarSetStrCapacity(&OutStr, bytes)
        loop lines - 1 {
            OutStr .= Format(line, A_Index) '`n'
        }
        OutStr .= Format(line, lines)
    }
    static GetPath() {
        loop 100 {
            path := A_Temp '\'
            loop 16 {
                path .= Chr(Random(65, 90))
            }
            if !FileExist(path '.txt') {
                return path '.txt'
            }
        }
        throw Error('Failed to produce a file path.')
    }
    static GetSmallContent() {
        s := ''
        loop 10 {
            loop 10 {
                s .= (A_Index - 1)
            }
        }
        return s
    }
    static LoopReadLarge() {
        path := this.path
        this.GetLargeContent(&test_txt)
        for encoding in this.Encodings {
            f := FileOpen(path, 'w', encoding)
            f.Write(test_txt)
            sz := DllCall(g_kernel32_GetFileSize, 'ptr', f.Handle, 'ptr', 0, 'Int')
            f.Close()
            options := {
                path: path
              , encoding: encoding
            }
            fm := FileMapping(options)
            ; We're going to open a view at an arbitrary size and begin the loop, concatenating a
            ; string as we read the content. We should be able to simply call Read() and it should
            ; correctly manage the file pointer and pages for us, so the resulting string should
            ; match the original.
            str := ''
            VarSetStrCapacity(&str, StrLen(test_txt))
            fm.Open(0, Random(1000, FileMapping_VirtualMemoryGranularity))
            for pg, offset, len, isLastIteration in fm {
                str .= fm.Read()
            }
            if str != test_txt {
                _path := this.GetPath()
                f := FileOpen(_path, 'w')
                f.Write('original:`n' test_txt '`n`nread:`n' str)
                f.Close()
                SplitPath(_path, , &dir)
                Run('"' dir '"')
                throw Error('Invalid read content.')
            }
            ; We're going to do the same thing but this time using a large view
            fm.Close()
            str := ''
            VarSetStrCapacity(&str, StrLen(test_txt))
            fm.Open(0, Round(FileMapping_LargePageMinimum * 1.5, 0))
            for pg, offset, len, isLastIteration in fm {
                str .= fm.Read()
            }
            if str != test_txt {
                _path := this.GetPath()
                f := FileOpen(_path, 'w')
                f.Write('original:`n' test_txt '`n`nread:`n' str)
                f.Close()
                SplitPath(_path, , &dir)
                Run('"' dir '"')
                throw Error('Invalid read content.')
            }
            fm.Close()
        }
    }
    static LoopReadSmall() {
        ; This tests to make sure there aren't any off-by-1 errors when reading and writing to
        ; the same view repeatedly. It also loops multiple views using NextPage (as opposed to using
        ; the enumerator). NextPage should correctly set the file pointer's position when calling
        ; NextPage with a current view that does not end on a page boundary.
        this.GetLargeContent(&test_txt)
        test_len := StrLen(test_txt)
        for encoding in this.Encodings {
            test_maxSize := test_len * (encoding = 'cp1200' ? 2 : 1)
            options := { encoding: encoding, MaxSize: test_maxSize }
            fm := FileMapping(options)
            fm.Open()
            ; We expect 0 because there is no BOM
            if fm.StartByte {
                throw Error('Invalid StartByte.')
            }
            fm.Write(test_txt)
            ; Position should now be same as max size
            if fm.Pos != fm.MaxSize {
                throw Error('Invalid pos.')
            }
            initial_size := 500
            fm.CloseView()
            fm.OpenView(0, initial_size)
            str := ''
            VarSetStrCapacity(&str, test_len)
            loop {
                str .= fm.Read()
                if !fm.NextPage(3) {
                    break
                }
            }
            if str != test_txt {
                throw Error('Invalid read content.')
            }
            if fm.Pos != fm.Size {
                throw Error('Invalid pos.')
            }
            if fm.ViewEnd != fm.MaxSize {
                throw Error('Invalid ViewEnd.')
            }
            if !fm.AtEoV {
                throw Error('Expected true.')
            }
            if !fm.AtEoF {
                throw Error('Expected true.')
            }
            if !fm.OnLastPage {
                throw Error('Expected true.')
            }
            ; Same thing but now we're going end the initial view more than half way through the
            ; first page.
            fm.CloseView()
            fm.OpenView(0, FileMapping_VirtualMemoryGranularity * 0.7)
            str := ''
            VarSetStrCapacity(&str, test_len)
            loop {
                str .= fm.Read()
                if !fm.NextPage(3) {
                    break
                }
            }
            if str != test_txt {
                throw Error('Invalid read content.')
            }
            if fm.Pos != fm.Size {
                throw Error('Invalid pos.')
            }
            ; Check for off-by-1 errors, reading
            fm.CloseView()
            fm.OpenViewP(0, 1)
            str := ''
            VarSetStrCapacity(&str, FileMapping_VirtualMemoryGranularity * 2)
            total := 0
            for qty in [ 100, 150, 300, 912, 18, 29, 1000, 1999, FileMapping_VirtualMemoryGranularity ] {
                str .= fm.Read(qty)
                total += qty
            }
            test_str := SubStr(test_txt, 1, total)
            if str != test_str {
                throw Error('Invalid read content.')
            }
            ; Check for off-by-1 errors, writing
            test_pos := fm.Pos
            fm.CloseView()
            fm.OpenP(0, 1)
            total := 1
            for qty in [ 100, 150, 300, 912, 18, 29, 1000, 1999, FileMapping_VirtualMemoryGranularity ] {
                fm.Write(SubStr(test_str, total, qty))
                total += qty
            }
            if fm.Pos != test_pos {
                throw Error('Invalid pos')
            }
            fm.Terminate()
            fm.Pos := 0
            fm.ExtendView(total * fm.BytesPerChar)
            str := fm.Read()
            if str != test_str {
                throw Error('Invalid cumulative write content')
            }
            fm.Close()
        }
    }
    static OpenAndReadSmall() {
        path := this.path
        test_txt := this.GetSmallContent()
        for encoding in this.Encodings {
            f := FileOpen(path, 'w', encoding)
            f.Write(test_txt)
            sz := DllCall(g_kernel32_GetFileSize, 'ptr', f.Handle, 'ptr', 0, 'Int')
            f.Close()
            options := {
                path: path
              , encoding: encoding
            }
            fm := FileMapping(options)
            fm.Open()
            if fm.Pos != FileMapping_HasBom(fm.Ptr, encoding) {
                throw Error('Invalid position.')
            }
            if fm.MaxSize != sz {
                throw Error('Invalid max size.')
            }
            str := fm.Read()
            if str != test_txt {
                throw Error('Invalid read content.')
            }
            if fm.Pos != fm.Size {
                throw Error('Invalid position.')
            }
            if fm.Pos != fm.MaxSize {
                throw Error('Invalid position.')
            }
            fm.Pos -= 2 * fm.BytesPerChar
            str := fm.Read()
            if str != SubStr(test_txt, -2, 2) {
                throw Error('Invalid read content.')
            }
            fm.Pos := fm.StartByte
            p1 := Ceil(StrLen(test_txt) / 2)
            p2 := StrLen(test_txt) - p1
            str := fm.Read(p1) fm.Read(p2)
            if str != test_txt {
                throw Error('Invalid read content.')
            }
            if fm.Pos != fm.Size {
                throw Error('Invalid position.')
            }
            if fm.Pos != fm.MaxSize {
                throw Error('Invalid position.')
            }
            fm.Close()
        }
    }
    static ToFile() {
        path := this.GetPath()
        this.GetLargeContent(&test_txt)
        test_len := StrLen(test_txt)
        for encoding in this.Encodings {
            options := { Encoding: encoding, MaxSize: test_len * (encoding = 'cp1200' ? 2 : 1) }
            fm := FileMapping(options)
            fm.OpenP(0, 1)
            fm.Write2(&test_txt)
            ; Write2 should extend the view to the maximum size
            if fm.Size != fm.MaxSize {
                throw Error('Invalid size.')
            }
            fm.ToFile(path, 'w')
            f := FileOpen(path, 'r')
            str := f.Read()
            if str != test_txt {
                throw Error('Invalid read content.')
            }
            f.Close()
        }
    }
    static WriteAndExpandSmall() {
        path := this.path
        test_txt := this.GetSmallContent()
        for encoding in this.Encodings {
            f := FileOpen(path, 'w', encoding)
            f.Write(test_txt)
            sz := DllCall(g_kernel32_GetFileSize, 'ptr', f.Handle, 'ptr', 0, 'Int')
            f.Close()
            options := {
                path: path
              , encoding: encoding
              , MaxSize: sz + 100
            }
            fm := FileMapping(options)
            fm.OpenFile()
            fm.OpenMapping()
            ; open the view up to the end of the content
            fm.OpenView(0, sz)
            ; max size should still be sz + 100
            if fm.MaxSize != sz + 100 {
                throw Error('Invalid max size.')
            }
            ; we should still get all of the text
            str := fm.Read()
            if str != test_txt {
                throw Error('Invalid read content.')
            }
            ; the position should be at the end of the view
            if !fm.AtEoV {
                throw Error('Expected AtEoV.')
            }
            ; writing to the view should auto-expand the view
            _txt := '1234567890'
            fm.Write(_txt)
            test_pos := StrLen(_txt) * fm.BytesPerChar + StrLen(test_txt) * fm.BytesPerChar + fm.StartByte
            if fm.Pos != test_pos {
                throw Error('Invalid position.')
            }
            ; The view's size should have been rounded up to the max size
            if fm.Size != fm.MaxSize {
                throw Error('Invalid view size.')
            }
            fm.Terminate()
            if fm.Pos != test_pos + fm.BytesPerChar {
                throw Error('Invalid position.')
            }
            fm.Pos := fm.StartByte
            str := fm.Read()
            if str != test_txt _txt {
                throw Error('Invalid read content.')
            }
            ; The position will be at the end of the string, before the null terminator.
            if fm.Pos != test_pos {
                throw Error('Invalid position.')
            }
            fm.Flush()
            fm.FlushFileBuffers()
            str := FileRead(path, encoding)
            if str != test_txt _txt {
                throw Error('Invalid read content.')
            }
            fm.Close()
        }
    }
    static WriteLarge_Pagefile() {
        this.GetLargeContent(&test_txt)
        test_len := StrLen(test_txt)
        this.GetLargeContent(&_txt)
        _len := StrLen(_txt)
        for encoding in this.Encodings {
            test_maxSize := test_len * (encoding = 'cp1200' ? 2 : 1)
            options := { encoding: encoding, MaxSize: test_maxSize }
            fm := FileMapping(options)
            fm.Open()
            ; We expect 0 because there is no BOM
            if fm.StartByte {
                throw Error('Invalid StartByte.')
            }
            fm.Write(test_txt)
            ; Position should now be same as max size
            if fm.Pos != fm.MaxSize {
                throw Error('Invalid pos.')
            }
            ; Test to make sure Terminate fails (returns 0) correctly
            if fm.Terminate() {
                throw Error('Expected 0.')
            }
            ; Test to make sure Read correctly stops at the end of the file mapping object when
            ; there is no null terminator
            fm.Pos := fm.StartByte
            str := fm.Read()
            if str != test_txt {
                throw Error('Invalid read content.')
            }
            if fm.Pos != fm.MaxSize {
                throw Error('Invalid pos.')
            }
            ; Test to make sure Write correctly auto-expands the file mapping object when AdjustMaxSize
            ; is true
            fm.Write(_txt, true)
            test_size := test_maxSize * 2
            if fm.MaxSize != test_size {
                throw Error('Expected test_maxSize * 2')
            }
            test_pos := test_maxSize + _len * fm.BytesPerChar
            if fm.Pos != test_pos {
                throw Error('Invalid pos.')
            }
            ; The string should take up the entire max size, so Terminate should fail (return 0)
            if fm.Terminate() {
                throw Error('Expected 0.')
            }
            fm.SeekToBeginning()
            str := fm.Read()
            if str != test_txt _txt {
                throw Error('Invalid read content.')
            }
            test_pos := test_maxSize + _len * fm.BytesPerChar
            if fm.Pos != test_pos {
                throw Error('Invalid pos.')
            }
            fm.Close()
        }
    }
    static WriteSmall() {
        path := this.path
        test_txt := this.GetSmallContent()
        for encoding in this.Encodings {
            f := FileOpen(path, 'w', encoding)
            f.Write(test_txt)
            sz := DllCall(g_kernel32_GetFileSize, 'ptr', f.Handle, 'ptr', 0, 'Int')
            f.Close()
            options := {
                path: path
              , encoding: encoding
              , MaxSize: sz + 100
            }
            fm := FileMapping(options)
            fm.Open()
            if fm.MaxSize != sz + 100 {
                throw Error('Invalid max size.')
            }
            ; Though the size of the file mapping should be sz + 100, the read string should terminate
            ; at the correct spot due to the null terminator.
            str := fm.Read()
            if str != test_txt {
                throw Error('Invalid read content.')
            }
            test_pos := StrLen(test_txt) * fm.BytesPerChar + fm.StartByte
            if fm.Pos != test_pos {
                throw Error('Invalid position.')
            }
            _txt := '1234567890'
            fm.Write(_txt)
            test_pos := StrLen(_txt) * fm.BytesPerChar + StrLen(test_txt) * fm.BytesPerChar + fm.StartByte
            if fm.Pos != test_pos {
                throw Error('Invalid position.')
            }
            fm.Terminate()
            if fm.Pos != test_pos + fm.BytesPerChar {
                throw Error('Invalid position.')
            }
            fm.Pos := fm.StartByte
            str := fm.Read()
            if str != test_txt _txt {
                throw Error('Invalid read content.')
            }
            ; The position will be at the end of the string, before the null terminator.
            if fm.Pos != test_pos {
                throw Error('Invalid position.')
            }
            fm.Flush()
            fm.FlushFileBuffers()
            str := FileRead(path, encoding)
            if str != test_txt _txt {
                throw Error('Invalid read content.')
            }
            fm.Close()
        }
    }
    static WriteSmall_Pagefile() {
        test_txt := this.GetSmallContent()
        test_len := StrLen(test_txt)
        _txt := '1234567890'
        _len := StrLen(_txt)
        for encoding in this.Encodings {
            test_maxSize := test_len * (encoding = 'cp1200' ? 2 : 1)
            options := { encoding: encoding, MaxSize: test_maxSize }
            fm := FileMapping(options)
            fm.Open()
            ; We expect 0 because there is no BOM
            if fm.StartByte {
                throw Error('Invalid StartByte.')
            }
            fm.Write(test_txt)
            ; Position should now be same as max size
            if fm.Pos != fm.MaxSize {
                throw Error('Invalid pos.')
            }
            ; Test to make sure Terminate fails (returns 0) correctly
            if fm.Terminate() {
                throw Error('Expected 0.')
            }
            ; Test to make sure Read correctly stops at the end of the file mapping object when
            ; there is no null terminator
            fm.Pos := fm.StartByte
            str := fm.Read()
            if str != test_txt {
                throw Error('Invalid read content.')
            }
            if fm.Pos != fm.MaxSize {
                throw Error('Invalid pos.')
            }
            ; Test to make sure Write correctly auto-expands the file mapping object when AdjustMaxSize
            ; is true
            fm.Write(_txt, true)
            test_size := test_maxSize * 2
            if fm.MaxSize != test_size {
                throw Error('Expected test_maxSize * 2')
            }
            test_pos := test_maxSize + _len * fm.BytesPerChar
            if fm.Pos != test_pos {
                throw Error('Invalid pos.')
            }
            fm.Terminate()
            test_pos := test_maxSize + (_len + 1) * fm.BytesPerChar
            if fm.Pos != test_pos {
                throw Error('Invalid pos.')
            }
            fm.SeekToBeginning()
            str := fm.Read()
            if str != test_txt _txt {
                throw Error('Invalid read content.')
            }
            test_pos := test_maxSize + _len * fm.BytesPerChar
            if fm.Pos != test_pos {
                throw Error('Invalid pos.')
            }
            fm.Close()
        }
    }
}

class OnExitCallback {
    __New(path) {
        this.path := path
    }
    Call(*) {
        if FileExist(this.path) {
            try {
                FileDelete(this.path)
            }
        }
    }
}
