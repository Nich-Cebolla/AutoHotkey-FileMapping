
/**
 * @class
 * @description - This creates a file mapping object and maps a view of the file.
 *
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-createfilemappingw}
 *
 * {@link https://www.autohotkey.com/boards/viewtopic.php?f=96&t=124720}
 *
 * To use a file mapping object for reading from and writing to a file, follow these guidelines:
 * - Set `Options.Path` to the file path.
 * - Set `Options.Encoding` to the file encoding.
 * - You can leave everything else the default.
 *
 * To use a file mapping object for inter-process communication, follow these guidelines:
 * - Leave `Options.Path` unset.
 * - Set `Options.Name` parameter with "Local\" prefix, e.g. "Local\\" to generate a random name.
 * - Set encoding "utf-16".
 * - Set `Options.flProtect := PAGE_READWRITE`.
 * - Set `Options.MaxSize` to any maximum size in bytes.
 * - Set `Options.dwDesiredAccess_file := FILE_MAP_ALL_ACCESS | PAGE_READ_WRITE`.
 * - Set `Options.dwDesiredAccess_view := FILE_MAP_ALL_ACCESS | PAGE_READ_WRITE`.
 */
class FileMapping {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.Ptr :=
        proto.hMapping :=
        proto.OnExit :=
        ''
        proto.Page :=
        proto.__Pos :=
        proto.Size :=
        proto.EnumPageCount :=
        proto.__OnExitActive :=
        proto.hFile :=
        proto.BytesPerChar :=
        proto.StartByte :=
        0
        this.Collection := Map()
    }
    static __Add(FileMappingObj) {
        if this.Collection.Has(FileMappingObj.idFileMapping) {
            throw Error('The collection already has an item with that id.', , FileMappingObj.idFileMapping)
        } else {
            this.Collection.Set(FileMappingObj.idFileMapping, FileMappingObj)
        }
        ObjRelease(ObjPtr(FileMappingObj))
    }
    static _Get(idFileMapping) {
        return this.Collection.Get(idFileMapping)
    }
    static __GetUid() {
        loop 100 {
            n := Random(1, 4294967295)
            if !this.Collection.Has(n) {
                return n
            }
        }
        throw Error('Failed to produce a unique id.')
    }

    /**
     * @classdesc -
     * - File object: {@link https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilew}
     * - File Mapping object: {@link https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-createfilemappingw}
     * - Map view of file: {@link https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-mapviewoffile}
     *
     * See Descolada's post for more information
     * {@link https://www.autohotkey.com/boards/viewtopic.php?f=96&t=124720}.
     *
     * @param {Object|FileMapping.Options} [Options] - Either a {@link FileMapping.Options} object,
     * or an object with zero or more options as property : value pairs.
     *
     * @param {Integer} [Options.dwCreationDisposition = OPEN_EXISTING] - The action to take on a file
     * or device that exists or doesn't exist.
     * - CREATE_ALWAYS
     * - CREATE_NEW
     * - OPEN_ALWAYS
     * - OPEN_EXISTING
     * - TRUNCATE_EXISTING
     *
     * @param {Integer} [Options.dwDesiredAccess_file = GENERIC_READWRITE] - The access to the file.
     *  One or more of:
     * - GENERIC_ALL
     * - GENERIC_EXECUTE
     * - GENERIC_WRITE
     * - GENERIC_READ
     * - GENERIC_READWRITE
     * - {@link https://learn.microsoft.com/en-us/windows/win32/secauthz/generic-access-rights}
     *
     * @param {Integer} [Options.dwDesiredAccess_view = FILE_MAP_ALL_ACCESS] - The page protection for the
     * file mapping object.
     * - One or more of these:
     *   - FILE_MAP_ALL_ACCESS
     *   - FILE_MAP_READ
     *   - FILE_MAP_WRITE
     * - Can be combined with these using bit-wise or ( | )
     *   - FILE_MAP_COPY
     *   - FILE_MAP_EXECUTE
     *   - FILE_MAP_LARGE_PAGES
     *   - FILE_MAP_TARGETS_INVALID
     *
     * @param {Integer} [Options.dwFlagsAndAttributes = FILE_ATTRIBUTE_NORMAL] - The file or device
     * attributes and flags. One or more of:
     * - FILE_ATTRIBUTE_ARCHIVE
     * - FILE_ATTRIBUTE_ENCRYPTED
     * - FILE_ATTRIBUTE_HIDDEN
     * - FILE_ATTRIBUTE_NORMAL
     * - FILE_ATTRIBUTE_OFFLINE
     * - FILE_ATTRIBUTE_READONLY
     * - FILE_ATTRIBUTE_SYSTEM
     * - FILE_ATTRIBUTE_TEMPORARY
     * - FILE_FLAG_BACKUP_SEMANTICS
     * - FILE_FLAG_DELETE_ON_CLOSE
     * - FILE_FLAG_NO_BUFFERING
     * - FILE_FLAG_OPEN_NO_RECALL
     * - FILE_FLAG_OPEN_REPARSE_POINT
     * - FILE_FLAG_OVERLAPPED
     * - FILE_FLAG_POSIX_SEMANTICS
     * - FILE_FLAG_RANDOM_ACCESS
     * - FILE_FLAG_SESSION_AWARE
     * - FILE_FLAG_SEQUENTIAL_SCAN
     * - FILE_FLAG_WRITE_THROUGH
     *
     * @param {Integer} [Options.dwShareMode = FILE_SHARE_WRITE | FILE_SHARE_READ] - The share mode
     * of the file. One or more of:
     * - FILE_SHARE_DELETE
     * - FILE_SHARE_READ
     * - FILE_SHARE_WRITE
     *
     * @param {String} [Options.Encoding = "utf-16"] - The file encoding used when reading from and
     * writing to a view.
     *
     * @param {Integer} [Options.flProtect = PAGE_READWRITE] - The protection to apply to the file mapping object.
     * - One of the following:
     *   - PAGE_EXECUTE_READ
     *   - PAGE_EXECUTE_READWRITE
     *   - PAGE_EXECUTE_WRITECOPY
     *   - PAGE_READONLY
     *   - PAGE_READWRITE
     *   - PAGE_WRITECOPY
     * - Combined with one or more of:
     *   - SEC_COMMIT
     *   - SEC_IMAGE
     *   - SEC_IMAGE_NO_EXECUTE
     *   - SEC_LARGE_PAGES
     *   - SEC_NOCACHE
     *   - SEC_RESERVE
     *   - SEC_WRITECOMBINE
     *
     * @param {Integer} [Options.hTemplateFile = 0] - A handle to a template file with the same attributes as the file
     * mapping object. The file mapping object is created with the same attributes as the template file.
     *
     * @param {Integer} [Options.lpFileMappingAttributes = 0] - A pointer to a SECURITY_ATTRIBUTES structure
     * that contains the security descriptor for the file mapping object.
     *
     * @param {Integer} [Options.lpSecurityAttributes = 0] - A pointer to a SECURITY_ATTRIBUTES
     * structure that contains the security descriptor for the file object.
     *
     * @param {Integer} [Options.MaxSize = 0] - Use `Options.MaxSize` to specify the maximum size of
     * the file mapping object. If `Options.Path` is used, `Options.MaxSize` should be greater than
     * or equal to the size of the file. If `Options.MaxSize` is 0 and if `Options.Path` is used, the
     * maximum size of the file mapping object is equal to the current size of the file. If
     * `Options.MaxSize` is 0 and if `Options.Path` is not used, the libary sets the maximum size to
     * `FileMapping_VirtualMemoryGranularity` (1 page).
     *
     * @param {String} [Options.Name] - The name of the file mapping object. Set `Options.Name` when
     * using {@link FileMapping} for inter-process communication.
     *
     * When creating a file mapping object, the name must be unique across the system. If the name is
     * already in use, and the name is associated with an existing file mapping object,
     * `CreateFileMapping` requests a handle to the existing file mapping object instead of creating
     * a new object. If the name exists but is some other type of object, the function fails.
     *
     * <!-- Note: If you are reading this from the source file, the backslashes below are escaped so the
     * markdown renderer displays them correctly. Treat each backslash pair as a single backslash. -->
     *
     * To direct {@link FileMapping.Prototype.__New} to generate a random name, set `Options.Name`
     * with any string that ends with a backslash optionally followed by a number representing the
     * number of characters to include in the name. Your code can begin the string with any valid
     * string to use as a prefix, and the random characters will be appended to the prefix. For
     * example, each of the following are valid for producing a random name:
     * - "\\" - generates a random name of 16 characters.
     * - "\\20" - generates a random name of 20 characters.
     * - "Global\\\\22" - generates a random name of 22 characters and appends it to "Global\\".
     * - "Local\\\\" - generates a random name of 16 characters and appends it to "Local\\".
     * - "Local\\MyAppName_\\" - generates a random name of 16 characters and appends it to
     *   "Local\\MyAppName_".
     * - "MyAppName\\14" - generates a random name of 14 characters and appends it to "MyAppName".
     * - "Global\\Ajmz(eOO\\10" - generates a random name of 10 characters and appends it to
     *   "Global\\Ajmz(eOO".
     *
     * The random characters fall between code points 33 - 91, inclusive. If your application requires
     * a different set of characters to be used, leave `Options.Name` unset and call
     * {@link FileMapping.Prototype.SetName} before opening the file mapping object.
     *
     * When {@link FileMapping.Prototype.SetName} generates the random name, it overwrites the
     * value of the property "Name" on the options object. Accessing {@link FileMapping.Prototype.Name}
     * will return the new name.
     *
     * Using a random name has the benefit of preventing a scenario where a bad-actor blocks your
     * application from functioning intentionally by preemptively creating an object with a name
     * known to be used by your application. It is also helpful for avoiding a scenario where
     * your application attempts to use the same name as another application coincidentally.
     *
     * @param {String} [Options.Path] - If the {@link FileMapping} object is being used to map a file,
     * the path to the file.
     *
     * @param {Boolean} [Options.SetOnExit = true] - This option determines whether or not the
     * built-in `OnExit` callback, which safely closes an opened file object and/or file mapping
     * object, is toggled whenever a file / file mapping object is opened and closed.
     *
     * The value of `Options.SetOnExit` is passed to the `AddRemove` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/OnExit.htm `OnExit`}.
     *
     * When `Options.SetOnExit` is nonzero, {@link FileMapping.Prototype.SetOnExitCallback} is called
     * within the body of the following methods:
     * - {@link FileMapping.Prototype.Open}
     * - {@link FileMapping.Prototype.OpenFile}
     * - {@link FileMapping.Prototype.OpenMapping}
     * - {@link FileMapping.Prototype.OpenP}
     *
     * When this option is nonzero, an `OnExit` callback is set whenever a file object is created
     * and whenever a file mapping object is created. The callback closes the objects safely before
     * the script exits. The `OnExit` callback is automatically disabled when both the file object
     * and file mapping object handles have been closed. This occurs within the body of:
     * - {@link FileMapping.Prototype.Close}
     * - {@link FileMapping.Prototype.CloseFile}
     * - {@link FileMapping.Prototype.CloseMapping}
     *
     * @param {Boolean} [SkipOptions = false] - If true, `Options` must be set with a
     * {@link FileMapping.Options} object. When true, {@link FileMapping.Prototype.__New} does not
     * pass `Options` to {@link FileMapping.Options.Prototype.__New}. Set this to true if using
     * an existing options object.
     *
     * @returns {FileMapping}
     */
    __New(Options?, SkipOptions := false) {
        this.idFileMapping := FileMapping.__GetUid()
        FileMapping.__Add(this)
        if SkipOptions {
            this.Options := Options
        } else {
            Options := this.Options := FileMapping.Options(Options ?? unset)
        }
        if Options.Name {
            this.SetName(Options.Name)
        }
        this.SetEncoding(Options.Encoding)
    }
    /**
     * @description - Adjusts the maximum size of the file mapping object to accommodate a specified
     * number of bytes from the current position. See {@link FileMapping.Prototype.Reload} for more
     * information.
     *
     * Note that `Bytes` is not expected to receive the new maximum size. It is expected to receive
     * the number of bytes past the current position that must be available in the new maximum size.
     * @param {Integer} Bytes - The number of bytes that must be available past the current position.
     * @returns {Integer} - If the maximum size of the file mapping object was adjusted, the new maximum
     * size. Else, 0.
     */
    AdjustMaxSize(Bytes) {
        offset := this.__Pos
        sz := this.MaxSize
        diff := this.ViewStart + offset + Bytes - this.MaxSize
        while diff > 0 {
            diff -= sz
            sz *= 2
        }
        if sz > this.MaxSize {
            n := FileMapping_RoundUpToPage(this.ViewStart + offset + Bytes) - this.Page
            this.Reload(sz, this.Page, n)
            return sz
        }
        return 0
    }
    /**
     * @description - Evaluates and (if appropriate) adjusts a set of input parameters to adhere
     * to the requirement that a file mapping view is opened to a start offset that is a multiple of
     * the system's virtual memory allocation granularity.
     *
     * @param {VarRef} [Offset = 0] - If your code sets `Offset`, it is the desired start offset
     * for the file mapping view. The variable's value is adjusted to reflect the actual offset
     * that must be used to align the view with the system's virtual memory allocation granularity.
     * Upon the function's return, `Offset` will less than or equal to its original value.
     *
     * @param {VarRef} [Bytes] - If your code sets `Bytes`, and if `Bytes` is a positive number, it
     * is the number of bytes from `Offset` to end the view. If `Bytes` is a negative number, it
     * is the number of bytes right-to-left from the end of the file mapping object to end the view.
     * The variable's value is adjusted to reflect the final size of the view in bytes. Upon the
     * function's return, `Bytes` will be greater than or equal to its original value.
     *
     * @param {Boolean} [AdjustMaxSize = false] - Understand that if the file mapping object is opened
     * in more than one process, setting `AdjustMaxSize` unless all other processes
     * call `CloseHandle` to close their handle.
     *
     * If true, and if `Bytes` is set with a value that would cause the view's size to exceed the
     * current maximum size of the file mapping object, the file mapping object is closed and
     * re-opened with a new maximum size to accommodate `Bytes` (the original maximum size is
     * doubled until a sufficient size is reached).
     *
     * If false, and if `Bytes` is set with a value that would cause the view's size to exceed the
     * current maximum size of the file mapping object, the function returns 0 and none of the
     * variables are adjusted.
     *
     * @param {VarRef} [OutPage] - A variable that will receive the page number for a view opened to
     * start at `Offset`. Page indices are 0-based.
     *
     * @returns {Boolean} - If the calculation was successful, returns 1. If unsuccessful, returns 0.
     */
    CalculateViewSize(&Offset := 0, &Bytes?, AdjustMaxSize := false, &OutPage?) {
        OutPage := Floor(Offset / FileMapping_VirtualMemoryGranularity)
        _offset := OutPage * FileMapping_VirtualMemoryGranularity
        if IsSet(Bytes) {
            if Bytes < 0 {
                diff := Offset - this.MaxSize - Bytes
            } else {
                diff := Offset + Bytes - this.MaxSize
            }
            if diff > 0 {
                if AdjustMaxSize {
                    sz := this.MaxSize
                    while diff > 0 {
                        diff -= sz
                        sz *= 2
                    }
                    this.Reload(sz)
                    Bytes += Offset - _offset
                } else {
                    return 0
                }
            } else {
                Bytes += Offset - _offset
            }
        } else {
            Bytes := this.MaxSize - _offset
        }
        Offset := _offset
        return 1
    }
    /**
     * @description - Handles the cleanup of the file mapping object. This is called automatically
     * when the object is destroyed. Specifically:
     * - If property {@link FileMapping#hFile} is a file handle, calls {@link FileMapping.Prototype.Flush}.
     * - If there is an active view, calls `UnmapViewOfFile` and deletes the ptr cached on property
     *   {@link FileMapping#Ptr}.
     * - If property {@link FileMapping#hMapping} is set, calls `CloseHandle` with it and deletes the
     *   handle from property {@link FileMapping#hMapping}.
     * - If property {@link FileMapping#hFile} is set, calls `CloseHandle` with it and deletes the
     *   handle from property {@link FileMapping#hFile}.
     * - Deletes the following properties if they are set:
     *   - {@link FileMapping#__Pos}.
     *   - {@link FileMapping#Page}.
     *   - {@link FileMapping#Size}.
     */
    Close(*) {
        if this.Ptr {
            DllCall(g_kernel32_UnmapViewOfFile, 'ptr', this.Ptr)
            this.DeleteProp('Ptr')
        }
        if this.hMapping {
            DllCall(g_kernel32_CloseHandle, 'ptr', this.hMapping)
            this.DeleteProp('hMapping')
        }
        if this.hFile {
            if this.hFile != INVALID_HANDLE_VALUE {
                DllCall(g_kernel32_CloseHandle, 'ptr', this.hFile)
            }
            this.DeleteProp('hFile')
        }
        if this.__OnExitActive {
            this.SetOnExitCallback(0)
        }
        if this.HasOwnProp('__Pos') {
            this.DeleteProp('__Pos')
        }
        if this.HasOwnProp('Page') {
            this.DeleteProp('Page')
        }
        if this.HasOwnProp('Size') {
            this.DeleteProp('Size')
        }
    }
    /**
     * @description - Closes the file, and deletes property {@link FileMapping#hFile}.
     */
    CloseFile() {
        if this.hFile && this.hFile != INVALID_HANDLE_VALUE {
            DllCall(g_kernel32_CloseHandle, 'ptr', this.hFile)
        }
        if this.HasOwnProp('hFile') {
            this.DeleteProp('hFile')
        }
        if !this.hMapping && this.__OnExitActive {
            this.SetOnExitCallback(0)
        }
    }
    /**
     * @description - Closes the file mapping, and deletes property {@link FileMapping#hMapping}.
     */
    CloseMapping() {
        if this.hMapping {
            DllCall(g_kernel32_CloseHandle, 'ptr', this.hMapping)
            this.DeleteProp('hMapping')
        }
        if this.hFile <= 0 && this.__OnExitActive {
            this.SetOnExitCallback(0)
        }
    }
    /**
     * @description - Closes the current view if one exists. Specifically:
     * - If there is an active view, calls `UnmapViewOfFile` and deletes the ptr cached on property
     *   {@link FileMapping#Ptr}.
     * - Deletes the following properties if they are set:
     *   - {@link FileMapping#__Pos}.
     *   - {@link FileMapping#Page}.
     *   - {@link FileMapping#Size}.
     *
     * See {@link https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-unmapviewoffile}.
     */
    CloseView() {
        if this.Ptr {
            DllCall(g_kernel32_UnmapViewOfFile, 'ptr', this.Ptr)
            this.DeleteProp('Ptr')
        }
        if this.HasOwnProp('Size') {
            this.DeleteProp('Size')
        }
        if this.HasOwnProp('__Pos') {
            this.DeleteProp('__Pos')
        }
        if this.HasOwnProp('Page') {
            this.DeleteProp('Page')
        }
    }
    /**
     * @description - Makes a copy of a string from the file mapping object begining at the file
     * pointer's current position, then overwrites the bytes by shifting the data that is to the
     * right of the copied string leftward, effectively "removing" the string from the data.
     * The file pointer's position does not change. Returns the copied string.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * In the below example, `str` would contain the data starting at `fm.Pos` and ending after 105
     * characters, or at the first null terminator, whichever is first. All of the data after the end
     * of `str` would then be moved to the left, overwriting the entirety of `str`. Since the below
     * file mapping object would be blank, nothing would change because file mapping objects are
     * initialized filled with 0s.
     * @example
     * fm := FileMapping({ MaxSize: 250 })
     * fm.Open()
     * ; Set the file pointer
     * fm.Pos := 20
     * ; length in characters to remove from the data, beginning at fm.Pos
     * length := 105
     * ; specifies the end of the data range that will be shifted left
     * endOffset := fm.MaxSize
     * str := fm.Cut(length, endOffset)
     * OutputDebug(str "`n") ; <empty>
     * OutputDebug(fm.Pos "`n") ; 20
     * @
     *
     * In the below example, `str` would contain the data starting at `fm.Pos` and ending after 15
     * characters. All of the data after the end of `str` would then be moved to the left, overwriting
     * the entirety of `str`. `str2` would contain the data that was to the left of `str` and the data
     * that was to the right of `str`. `str2` would be 235 characters because the 15 characters
     * were "removed from" `str` (more accurately, 15 characters were overwritten by the data to the
     * right of `str`).
     * @example
     * fm := FileMapping({ MaxSize: 500 })
     * fm.Open()
     * s := ''
     * VarSetStrCapacity(&s, 250)
     * ; Remember that default encoding is UTF-16
     * ; so there are 2 bytes per 1 character.
     * loop 25 {
     *     s .= '0123456789'
     * }
     * OutputDebug(fm.Write2(&s) "`n") ; 500
     * ; Set the file pointer
     * fm.Pos := 20
     * ; length in characters to remove
     * ; from the data, beginning at fm.Pos
     * length := 15
     * ; Specifying `EndOffset` is
     * ; usually not necessary.
     * str := fm.Cut(length)
     * OutputDebug(str "`n") ; 012345678901234
     * OutputDebug(fm.Pos "`n") ; 20
     * fm.Pos := 0
     * str2 := fm.Read()
     * OutputDebug(StrLen(str2) "`n") ; 235
     * OutputDebug(fm.Pos "`n") ; 470
     * @
     *
     * @param {Integer} [Length] - The maximum number of characters to read.
     *
     * If `Length` is set:
     * - If `EndOffset` is set, and if `Length` would cause the string to exceed `EndOffset`, `Length`
     *   is truncated to `EndOffset`.
     * - If `EndOffset` is unset, and if `Length` would cause the string to exceed the end of the
     *   current view, `Length` is truncated to the end of the file mapping object's maximum size.
     *
     * In all cases, if a null terminator is encountered when reading the string, the string that is
     * cut will include the data between the file pointer's position and the null terminator.
     *
     * @param {Integer} [EndOffset] - If set, `EndOffset` indicates the last byte that will be shifted
     * left by this function. The offset is relative to the start of the file mapping object. If the
     * current view does not include `EndOffset` in its range, {@link FileMapping.Prototype.Cut} caches
     * the current view size and opens a view up to `EndOffset`. After {@link FileMapping.Prototype.Cut}
     * makes a copy of the target string, it moves the data between the end of the copied string
     * and `EndOffset` to the file pointer's current position.
     *
     * If `EndOffset` is greater than the maximum size of the file mapping object
     * ({@link FileMapping.Prototype.MaxSize}), `EndOffset` is set to the maximum size of the file
     * mapping object.
     *
     * If {@link FileMapping.Prototype.Cut} opened a larger view, it closes the view and opens a view
     * with the original size.
     *
     * If unset, after {@link FileMapping.Prototype.Cut} makes a copy of the target string, it moves
     * all data that follows the end of the copied string to the file pointer's current position.
     *
     * @param {Boolean} [Terminate = true] - If true, {@link FileMapping.Prototype.Cut} inserts a
     * null terminator at the end of the data that was moved.
     *
     * @returns {String} - The string read from the view.
     *
     * @throws {ValueError} - "`EndOffset` is greater than the file mapping object`'s maximum size."
     */
    Cut(Length?, EndOffset?, Terminate := true) {
        offset := this.__Pos
        if IsSet(EndOffset) {
            if EndOffset > this.MaxSize {
                    EndOffset := this.MaxSize
            }
        } else {
            EndOffset := this.MaxSize
        }
        if this.ViewEnd < EndOffset {
            sz := this.Size
            page := this.Page
            this.CloseView()
            this.OpenView(page * FileMapping_VirtualMemoryGranularity, EndOffset - Page * FileMapping_VirtualMemoryGranularity)
        }
        if IsSet(Length) {
            bytes := Length * this.BytesPerChar
        } else {
            bytes := EndOffset - this.ViewStart - offset
            Length := Floor(bytes / this.BytesPerChar)
        }
        str := StrGet(this.Ptr + offset, Length, this.Encoding)
        endOfStringOffset := offset + StrLen(str) * this.BytesPerChar
        DllCall(
            g_msvcrt_memmove
          , 'ptr', this.Ptr + offset
          , 'ptr', this.Ptr + endOfStringOffset
          , 'uint', EndOffset - endOfStringOffset
          , 'cdecl'
        )
        if Terminate {
            this.TerminateEx(EndOffset - endOfStringOffset + offset)
        }
        if IsSet(sz) {
            this.CloseView()
            this.OpenView(page * FileMapping_VirtualMemoryGranularity, sz)
        }
        this.__Pos := offset
        return str
    }
    /**
     * @description - This is the same as {@link FileMapping.Prototype.Cut2} except the cut string
     * is returned by the VarRef parameter.
     *
     * Makes a copy of a string from the file mapping object begining at the file
     * pointer's current position, then overwrites the bytes by shifting the data that is to the
     * right of the copied string leftward, effectively "removing" the string from the data.
     * The file pointer's position does not change. Returns the copied string.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * @param {VarRef} OutStr - A variable that will receive the cut string.
     *
     * @param {Integer} [Length] - The maximum number of characters to read.
     *
     * If `Length` is set:
     * - If `EndOffset` is set, and if `Length` would cause the string to exceed `EndOffset`, `Length`
     *   is truncated to `EndOffset`.
     * - If `EndOffset` is unset, and if `Length` would cause the string to exceed the end of the
     *   current view, `Length` is truncated to the end of the file mapping object's maximum size.
     *
     * In all cases, if a null terminator is encountered when reading the string, the string that is
     * cut will include the data between the file pointer's position and the null terminator.
     *
     * @param {Integer} [EndOffset] - If set, `EndOffset` indicates the last byte that will be shifted
     * left by this function. The offset is relative to the start of the file mapping object. If the
     * current view does not include `EndOffset` in its range, {@link FileMapping.Prototype.Cut2} caches
     * the current view size and opens a view up to `EndOffset`. After {@link FileMapping.Prototype.Cut2}
     * makes a copy of the target string, it moves the data between the end of the copied string
     * and `EndOffset` to the file pointer's current position.
     *
     * If `EndOffset` is greater than the maximum size of the file mapping object
     * ({@link FileMapping.Prototype.MaxSize}), `EndOffset` is set to the maximum size of the file
     * mapping object.
     *
     * If {@link FileMapping.Prototype.Cut2} opened a larger view, it closes the view and opens a view
     * with the original size.
     *
     * If unset, after {@link FileMapping.Prototype.Cut2} makes a copy of the target string, it moves
     * all data that follows the end of the copied string to the file pointer's current position.
     *
     * If `EndOffset` is greater than the file mapping object's maximum size
     * ({@link FileMapping.Prototype.MaxSize}), the function fails and returns 0.
     *
     * @param {Boolean} [Terminate = true] - If true, {@link FileMapping.Prototype.Cut2} inserts a
     * null terminator at the end of the data that was moved.
     *
     * @returns {Integer} - If successful, the offset of the end of the data that was moved left
     * relative to the start of the file mapping object (before the null terminator if `Terminate`
     * is true). If unsuccessful, 0.
     */
    Cut2(&OutStr, Length?, EndOffset?, Terminate := true) {
        offset := this.__Pos
        if IsSet(EndOffset) {
            if EndOffset > this.MaxSize {
                EndOffset := this.MaxSize
            }
        } else {
            EndOffset := this.MaxSize
        }
        if this.ViewEnd < EndOffset {
            sz := this.Size
            page := this.Page
            this.CloseView()
            this.OpenView(page * FileMapping_VirtualMemoryGranularity, EndOffset - Page * FileMapping_VirtualMemoryGranularity)
        }
        if IsSet(Length) {
            bytes := Length * this.BytesPerChar
        } else {
            bytes := EndOffset - this.ViewStart - offset
            Length := Floor(bytes / this.BytesPerChar)
        }
        OutStr := StrGet(this.Ptr + offset, Length, this.Encoding)
        endOfStringOffset := offset + StrLen(OutStr) * this.BytesPerChar
        DllCall(
            g_msvcrt_memmove
          , 'ptr', this.Ptr + offset
          , 'ptr', this.Ptr + endOfStringOffset
          , 'uint', EndOffset - endOfStringOffset
          , 'cdecl'
        )
        if Terminate {
            this.TerminateEx(EndOffset - endOfStringOffset + offset)
        }
        if IsSet(sz) {
            this.CloseView()
            this.OpenView(page * FileMapping_VirtualMemoryGranularity, sz)
        }
        this.__Pos := offset
        return EndOffset - endOfStringOffset + offset
    }
    /**
     * @description - Makes a copy of a string from the file mapping object begining at the file
     * pointer's current position. The end of the string is identified by a regular expression pattern.
     * After copying the string, overwrites the bytes by shifting the data that is to the right of
     * the copied string leftward, effectively "removing" the string from the data. The file pointer's
     * position does not change. Returns the copied string.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * In the below example, `str` would contain the data starting at `fm.Pos` and ending after 15
     * characters. All of the data after the end of `str` would then be moved to the left, overwriting
     * the entirety of `str`. `str2` would contain the data that was to the left of `str` and the data
     * that was to the right of `str`. `str2` would be 235 characters because the 15 characters
     * were "removed from" `str` (more accurately, 15 characters were overwritten by the data to the
     * right of `str`).
     * @example
     * fm := FileMapping({ MaxSize: 150 })
     * fm.Open()
     * OutputDebug(fm.Write('ABC01DEF23GHI45JKL67MNO89PQR01STU23VWX45YZ[67\]^89_') "`n") ; 102
     * ; Set the file pointer
     * fm.Pos := 20
     * ; The pattern will cause CutEx to stop
     * ; at two consecutive integers that are
     * ; 7, 8, or 9.
     * str := fm.CutEx("[789]{2}")
     * ; By default, the match is included
     * ; in the output.
     * OutputDebug(str "`n") ; GHI45JKL67MNO89
     * OutputDebug(fm.Pos "`n") ; 20
     * fm.Pos := 0
     * str2 := fm.Read()
     * ; The output string was removed
     * ; from the file mapping object.
     * OutputDebug(str2 "`n") ; ABC01DEF23PQR01STU23VWX45YZ[67\]^89_
     * OutputDebug(fm.Pos "`n") ; 72
     * fm.Pos := 30
     * str3 := fm.CutEx("[789]{2}", , , false)
     * OutputDebug(str3 "`n") ; STU23VWX45YZ[67\]^
     * fm.Pos := 0
     * str4 := fm.Read()
     * OutputDebug(str4 "`n") ; ABC01DEF23PQR0189_
     * OutputDebug(fm.Pos "`n") ; 36
     * @
     *
     * @param {String} Pattern - `Pattern` is expected to be a regular expression.
     * {@link FileMapping.Prototype.CutEx} calls `RegExMatch` in a loop until a match is found,
     * increasing the size of the view if necessary. If a match is found,
     * {@link FileMapping.Prototype.CutEx} makes a copy of the file mapping object's contents
     * beginning at the current file pointer position and ending at the end of the matched text. To
     * instead direct {@link FileMapping.Prototype.CutEx} to make a copy of the contents ending just
     * before the matched text, set parameter `IncludeMatch` to false.
     *
     * When {@link FileMapping.Prototype.CutEx} is looping through its contents, if it encounters
     * a null terminator, the loop ends and if `RegExMatch` returns 0, the function fails and returns
     * an empty string.
     *
     * After successfully finding a match and copying the string, {@link FileMapping.Prototype.CutEx}
     * shifts the remaining data to the left, overwriting the string. If
     * {@link FileMapping.Prototype.CutEx} increased the size of the view, it reverts the view
     * to the original size. {@link FileMapping.Prototype.CutEx} returns the string.
     *
     * If no match is found, {@link FileMapping.Prototype.CutEx} returns an empty string and does
     * not alter the data.
     *
     * If {@link FileMapping.Prototype.CutEx} increased the size of the view, it closes the view
     * and opens a new view with the same start page and size as the original view.
     *
     * @param {Integer} [EndOffset] - If set, `EndOffset` indicates the last byte that will be shifted
     * left by this function. The offset is relative to the start of the file mapping object. If the
     * current view does not include `EndOffset` in its range, {@link FileMapping.Prototype.CutEx} caches
     * the current view size and opens a view up to `EndOffset`. After {@link FileMapping.Prototype.CutEx}
     * makes a copy of the target string, it moves the data between the end of the target string
     * and `EndOffset` to the file pointer's current position.
     *
     * If `EndOffset` is greater than the maximum size of the file mapping object
     * ({@link FileMapping.Prototype.MaxSize}), `EndOffset` is set to the maximum size of the file
     * mapping object.
     *
     * If {@link FileMapping.Prototype.CutEx} opened a larger view, it closes the view and opens a view
     * with the original size.
     *
     * If unset, after {@link FileMapping.Prototype.CutEx} makes a copy of the target string, it moves
     * the data between the end of the target string and the end of the view to the file pointer's
     * current position.
     *
     * @param {Boolean} [Terminate = true] - If true, {@link FileMapping.Prototype.CutEx} inserts a
     * null terminator at the end of the data that was moved.
     *
     * @param {Boolean} [IncludeMatch = true] - If true, {@link FileMapping.Prototype.CutEx} includes
     * the matched text with the target string. If false, {@link FileMapping.Prototype.CutEx} does
     * not include the matched text with the target string.
     *
     * @returns {String} - The string read from the view.
     */
    CutEx(Pattern, EndOffset?, Terminate := true, IncludeMatch := true) {
        offset := this.__Pos
        str := this.Read()
        if !RegExMatch(str, Pattern, &match) {
            page := this.Page
            sz := this.Size
            while this.AtEoV {
                if this.ExtendView(FileMapping_VirtualMemoryGranularity) {
                    this.Read3(&str)
                    if RegExMatch(str, Pattern, &match) {
                        break
                    }
                } else {
                    if this.AtEoV && this.Size != this.MaxSize {
                        this.ExtendView(FileMapping_VirtualMemoryGranularity, true)
                        this.Read3(&str)
                    }
                    RegExMatch(str, Pattern, &match)
                    break
                }
            }
        }
        if match {
            if IncludeMatch {
                bytes := (match.Pos + match.Len - 1) * this.BytesPerChar
            } else {
                bytes := (match.Pos - 1) * this.BytesPerChar
            }
        } else {
            if IsSet(sz) && sz != this.Size {
                this.CloseView()
                this.OpenView(page * FileMapping_VirtualMemoryGranularity, sz)
            }
            return
        }
        if IsSet(EndOffset) {
            if EndOffset > this.MaxSize {
                EndOffset := this.MaxSize
            }
        } else {
            EndOffset := this.MaxSize
        }
        if this.ViewEnd < EndOffset {
            sz := this.Size
            page := this.Page
            this.CloseView()
            this.OpenView(page * FileMapping_VirtualMemoryGranularity, EndOffset - Page * FileMapping_VirtualMemoryGranularity)
        }
        str := StrGet(this.Ptr + offset, Floor(bytes / this.BytesPerChar), this.Encoding)
        endOfStringOffset := offset + StrLen(str) * this.BytesPerChar
        DllCall(
            g_msvcrt_memmove
          , 'ptr', this.Ptr + offset
          , 'ptr', this.Ptr + endOfStringOffset
          , 'uint', EndOffset - endOfStringOffset
          , 'cdecl'
        )
        if Terminate {
            this.TerminateEx(EndOffset - endOfStringOffset + offset)
        }
        if IsSet(sz) {
            this.CloseView()
            this.OpenView(page * FileMapping_VirtualMemoryGranularity, sz)
        }
        this.__Pos := offset
        return str
    }
    /**
     * @description - Closes the current view and reopens a larger view to the same page. The end
     * of the view is rounded up to the next page or to the end of the file mapping object, whichever
     * is lesser.
     *
     * The file mapping object's position ({@link FileMapping.Prototype.Pos}) is the same before and
     * after calling {@link FileMapping.Prototype.ExtendView}.
     *
     * @param {Integer} [Bytes] - If set, the number of bytes from the current position that must
     * be available within the view. If unset, the view is opened to the end of the file mapping object.
     *
     * @param {Boolean} [OrEndOfMapping = false] - If true, and if `Bytes` exceeds the remaining data
     * from {@link FileMapping.Prototype.Pos}, the view is opened to the end of the file mapping
     * object. If false, and if `Bytes` exceeds the remaining data from {@link FileMapping.Prototype.Pos},
     * the view is not changed and the function returns 0.
     *
     * @returns {Integer} - If successful, the size of the new view. If unsuccessful, 0.
     */
    ExtendView(Bytes?, OrEndOfMapping := false) {
        page := this.Page
        offset := this.__Pos
        if IsSet(Bytes) {
            amount := Bytes + offset + this.ViewStart
            if amount > this.MaxSize {
                if OrEndOfMapping {
                    amount := this.MaxSize
                } else {
                    return 0
                }
            }
            this.CloseView()
            this.OpenViewP(page, FileMapping_RoundUpToPage(amount) - page)
        } else {
            this.CloseView()
            this.OpenViewP(page)
        }
        this.__Pos := Integer(offset)
        return this.Size
    }
    /**
     * @description - Calls `FlushViewOfFile`, writing the view's current contents to file if the
     * file mapping object is backed by a file. This requires the property {@link FileMapping#hFile}
     * to be set with a valid file handle, which is done automatically when creating the file
     * mapping object if {@link FileMapping.Options#Path `Options.Path`} is set.
     *
     * See {@link https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-flushviewoffile}.
     *
     * @param {Integer} [Start] - If set, a pointer to the base address of the byte range to be
     * flushed to the file on disk. If unset, the address of the current view is used.
     * @param {Integer} [Bytes] - If set, the number of bytes to be flushed. If `Bytes`
     * is zero, the file is flushed from the base address to the end of the mapping. If unset, the
     * value of {@link FileMapping.Prototype.Pos} is used.
     * @throws {Error} - "The `FileMapping` object is not associated with a file."
     * @throws {OSError} - If `FlushViewOfFile` results in an error, `OSError()` is called.
     */
    Flush(Start?, Bytes?) {
        if this.hFile <= 0 {
            throw Error('The ``FileMapping`` object is not associated with a file.')
        }
        if !DllCall(
            g_kernel32_FlushViewOfFile
          , 'ptr', Start ?? this.Ptr
          , 'uint', Bytes ?? this.__Pos
          , 'int'
        ) {
            throw OSError()
        }
    }
    /**
     * @description - Calls `FlushFileBuffers`, which causes all buffered data to be written to the file.
     *
     * See {@link https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-flushfilebuffers}.
     *
     * @throws {Error} - "The `FileMapping` object is not associated with a file."
     * @throws {OSError} - If `FlushFileBuffers` results in an error, `OSError()` is called.
     */
    FlushFileBuffers() {
        if this.hFile <= 0 {
            throw Error('The ``FileMapping`` object is not associated with a file.')
        }
        if !DllCall(g_kernel32_FlushFileBuffers, 'ptr', this.hFile, 'int') {
            throw OSError()
        }
    }
    /**
     * @description - Attempts to get the file encoding. Only supports UTF-16LE, UTF-16BE, and UTF-8.
     * If successful, and if the BOM is UTF-16LE or UTF-8, sets the property {@link FileMapping#Encoding}
     * with the string code page identifier, and returns the code page identifier.
     *
     * If the BOM appears to be UTF-16BE, this will not set the {@link FileMapping#Encoding}
     * property because AHK functions like StrPut and FileOpen are incompatible with cp1201;
     * The function will just return "cp1201".
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/intl/code-page-identifiers}
     *
     * @returns {String} - If the BOM for UTF-16 or UTF-8 are present, the associated code page
     * identifier. Else, an empty string.
     */
    GetEncoding() {
        if !this.Ptr || this.ViewStart {
            throw Error('A view must be opened to the beginning of the file to get the encoding.')
        }
        b1 := NumGet(this.Ptr, 0, 'uchar')
        b2 := NumGet(this.Ptr, 1, 'uchar')
        b3 := NumGet(this.Ptr, 2, 'uchar')
        ; UTF-16
        if b1 = FILEMAPPING_UTF16LE_BOM[1] && b2 = FILEMAPPING_UTF16LE_BOM[2] {
            return 'cp1200'
        }
        ; UTF-8
        if b1 = FILEMAPPING_UTF8_BOM[1] && b2 = FILEMAPPING_UTF8_BOM[2] && b3 = FILEMAPPING_UTF8_BOM[3] {
            return 'cp65001'
        }
        ; UTF-16, big endian byte order, AHK doesn't seem to be compatible with it but an external
        ; file could possibly have this encoding.
        if (b1 == 0xFE && b2 == 0xFF) {
            return 'cp1201'
        }
    }
    /**
     * @description - Inserts a string at the current position, shifting the existing content to
     * the right and moving the file pointer.
     *
     * If the current view is insufficient to receive the entire string, and if the size of the file
     * mapping object is sufficient to receive the entire string, {@link FileMapping.Prototype.Insert}
     * closes the current view and opens a view large enough to receive the string, rounded up to the
     * next page or to the end of the file mapping object, whichever is lesser.
     *
     * If the size of the file mapping object is insufficient to receive the entire data, the behavior
     * of {@link FileMapping.Prototype.Insert} is determined by parameter `AdjustMaxSize`.
     *
     * If there is data near the end of the view, that data is overwritten. Specifically, any data
     * that is within `StrLen(Str) * FileMappingObj.BytesPerChar` bytes from the end of the view
     * is overwritten. If {@link FileMapping.Prototype.Insert} opens a larger view due to the size of
     * `Str`, then it is the data near the end of the newly opened view that is ovewritten.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * @example
     * fm := FileMapping({ MaxSize: 1000 })
     * fm.Open()
     * ; Fills 200 bytes with a random string
     * loop 100 {
     *     StrPut(Chr(Random(65, 90)), fm.Ptr + (A_Index - 1) * fm.BytesPerChar, fm.Encoding)
     * }
     * ; Copy bytes 50-89 for demonstration
     * fm.Pos := 50
     * str_original := fm.Read(40 / fm.BytesPerChar)
     * ; String to insert
     * str_insert := ''
     * VarSetStrCapacity(&str_insert, 40 / fm.BytesPerChar)
     * loop 40 / fm.BytesPerChar {
     *     str_insert .= Chr(Random(65, 90))
     * }
     * fm.Pos := 50
     * fm.Insert(str_insert)
     * ; The new file pointer position
     * OutputDebug(fm.Pos "`n") ; 90
     * ; This demonstrates that bytes 50-89 of the
     * ; file mapping object are the same as `str`
     * fm.Pos := 50
     * str_post_insert := fm.Read(40 / fm.BytesPerChar)
     * OutputDebug((str_insert = str_post_insert) "`n") ; 1
     * ; This demonstrates that bytes 90-129 of
     * ; the file mapping object are the same
     * ; as the bytes copied from 50-89 of
     * ; the file mapping object earlier.
     * str_moved := fm.Read(40 / fm.BytesPerChar)
     * OutputDebug((str_moved = str_original) "`n") ; 1
     * @
     *
     * @param {String} Str - The string to insert.
     *
     * @param {Boolean} [AdjustMaxSize = false] - Understand that if the file mapping object is opened
     * in more than one process, you must not set `AdjustMaxSize` to true unless all other processes
     * call `CloseHandle` to close their handle.
     *
     * If true, and if performing the insert operation would exceed the file mapping object's maximum
     * size, the file mapping object is closed and re-opened with a new maximum size to accommodate
     * the data (the original maximum size is doubled until a sufficient size is reached). A view is
     * then opened that is sufficient to receive the entire data, rounded up to the next page or to
     * the end of the file mapping object, whichever is lesser.
     *
     * If false, and if performing the write operation would exceed the file mapping object's maximum
     * size, the data is not copied and the function returns 0.
     *
     * @returns {Integer} - The number of bytes written.
     */
    Insert(Str, AdjustMaxSize := false) {
        offset := this.__Pos
        bytes := StrLen(Str) * this.BytesPerChar
        if bytes + offset > this.Size {
            if this.ViewStart + offset + bytes > this.MaxSize {
                if AdjustMaxSize {
                    this.AdjustMaxSize(bytes)
                } else {
                    return 0
                }
            } else {
                this.ExtendView(bytes)
            }
        }
        DllCall(
            g_msvcrt_memmove
          , 'ptr', this.Ptr + offset + bytes
          , 'ptr', this.Ptr + offset
          , 'uint', this.Size - offset - bytes
          , 'cdecl'
        )
        StrPut(Str, this.Ptr + offset, StrLen(Str), this.Encoding)
        this.__Pos += bytes
        return bytes
    }
    /**
     * @description - This is the same as {@link FileMapping.Prototype.Insert} except `Str` is
     * a VarRef.
     *
     * Inserts a string at the current position, shifting the existing content to the right and
     * moving the file pointer.
     *
     * If the current view is insufficient to receive the entire data, and if the size of the file
     * mapping object is sufficient to receive the entire data, {@link FileMapping.Prototype.Insert}
     * closes the current view and opens a view large enough to receive the data, rounded up to the
     * next page or to the end of the file mapping object, whichever is lesser.
     *
     * If the size of the file mapping object is insufficient to receive the entire data, the behavior
     * of {@link FileMapping.Prototype.Insert} is determined by parameter `AdjustMaxSize`.
     *
     * If there is data near the end of the view, that data is overwritten. Specifically, any data
     * that is within `StrLen(Str) * FileMappingObj.BytesPerChar` bytes from the end of the view
     * is overwritten.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * @example
     * fm := FileMapping({ MaxSize: 1000 })
     * fm.Open()
     * ; Fills 200 bytes with a random string
     * loop 100 {
     *     StrPut(Chr(Random(65, 90)), fm.Ptr + (A_Index - 1) * fm.BytesPerChar, fm.Encoding)
     * }
     * ; Copy bytes 50-89 for demonstration
     * fm.Pos := 50
     * str_original := fm.Read(40 / fm.BytesPerChar)
     * ; String to insert
     * str_insert := ''
     * VarSetStrCapacity(&str_insert, 40 / fm.BytesPerChar)
     * loop 40 / fm.BytesPerChar {
     *     str_insert .= Chr(Random(65, 90))
     * }
     * fm.Pos := 50
     * fm.Insert2(&str_insert)
     * ; The new file pointer position
     * OutputDebug(fm.Pos "`n") ; 90
     * ; This demonstrates that bytes 50-89 of the
     * ; file mapping object are the same as `str`
     * fm.Pos := 50
     * str_post_insert := fm.Read(40 / fm.BytesPerChar)
     * OutputDebug((str_insert = str_post_insert) "`n") ; 1
     * ; This demonstrates that bytes 90-129 of
     * ; the file mapping object are the same
     * ; as the bytes copied from 50-89 of
     * ; the file mapping object earlier.
     * str_moved := fm.Read(40 / fm.BytesPerChar)
     * OutputDebug((str_moved = str_original) "`n") ; 1
     * @
     *
     * @param {VarRef} Str - A variable containing the string to insert.
     *
     * @param {Boolean} [AdjustMaxSize = false] - Understand that if the file mapping object is opened
     * in more than one process, you must not set `AdjustMaxSize` to true unless all other processes
     * call `CloseHandle` to close their handle.
     *
     * If true, and if performing the insert operation would exceed the file mapping object's maximum
     * size, the file mapping object is closed and re-opened with a new maximum size to accommodate
     * the data (the original maximum size is doubled until a sufficient size is reached). A view is
     * then opened that is sufficient to receive the entire data, rounded up to the next page or to
     * the end of the file mapping object, whichever is lesser.
     *
     * If false, and if performing the write operation would exceed the file mapping object's maximum
     * size, the data is not copied and the function returns 0.
     *
     * @returns {Integer} - The number of bytes written.
     */
    Insert2(&Str, AdjustMaxSize := false) {
        offset := this.__Pos
        bytes := StrLen(Str) * this.BytesPerChar
        if bytes + offset > this.Size {
            if this.ViewStart + offset + bytes > this.MaxSize {
                if AdjustMaxSize {
                    this.AdjustMaxSize(bytes)
                } else {
                    return 0
                }
            } else {
                this.ExtendView(bytes)
            }
        }
        DllCall(
            g_msvcrt_memmove
          , 'ptr', this.Ptr + offset + bytes
          , 'ptr', this.Ptr + offset
          , 'uint', this.Size - offset - bytes
          , 'cdecl'
        )
        StrPut(Str, this.Ptr + offset, StrLen(Str), this.Encoding)
        this.__Pos += bytes
        return bytes
    }
    /**
     * @description - Reads from the current position until encountering the first null terminator,
     * opening new pages if necessary, then shifts the data to the right to make room to insert
     * `Str` into the original position. This method always ensures a null terminator exists
     * immediately after the data that was moved, and returns the position of the null terminator
     * as a byte offset from the start of the view.
     *
     * When the method returns, {@link FileMapping.Prototype.Pos} is set to the end of `Str`
     * (the same as if a standard write operation were performed).
     *
     * If the current view is insufficient to receive the entire data, and if the size of the file
     * mapping object is sufficient to receive the entire data, {@link FileMapping.Prototype.InsertEx}
     * closes the current view and opens a view large enough to receive the data, rounded up to the
     * next page or to the end of the file mapping object, whichever is lesser.
     *
     * If the size of the file mapping object is insufficient to receive the entire data, the behavior
     * of {@link FileMapping.Prototype.InsertEx} is determined by parameter `AdjustMaxSize`.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * @param {String} Str - The string to insert.
     *
     * @param {Boolean} [AdjustMaxSize = false] - Understand that if the file mapping object is opened
     * in more than one process, you must not set `AdjustMaxSize` to true unless all other processes
     * call `CloseHandle` to close their handle.
     *
     * If true, and if performing the write operation would exceed the file mapping object's maximum
     * size, the file mapping object is closed and re-opened with a new maximum size to accommodate
     * the data (the original maximum size is doubled until a sufficient size is reached). A view is
     * then opened that is sufficient to receive the entire data, rounded up to the next page or to
     * the end of the file mapping object, whichever is lesser.
     *
     * If false, and if performing the write operation would exceed the file mapping object's maximum
     * size, the data is not copied and the function returns 0.
     *
     * @returns {Integer} - The position of the null terminator as a byte offset from the start of
     * the view.
     */
    InsertEx(Str, AdjustMaxSize := false) {
        offset := this.__Pos
        len := StrLen(Str)
        chars := this.Read3(&Str)
        while this.AtEoV {
            if this.ExtendView(FileMapping_VirtualMemoryGranularity) {
                chars += this.Read3(&Str)
            } else {
                if this.AtEoV && this.Size != this.MaxSize {
                    this.ExtendView(FileMapping_VirtualMemoryGranularity, true)
                    chars += this.Read3(&Str)
                }
                break
            }
        }
        diff := offset + StrLen(Str) * this.BytesPerChar + this.BytesPerChar - this.Size
        if diff > 0 {
            _diff := this.ViewStart + offset + StrLen(Str) * this.BytesPerChar + this.BytesPerChar - this.MaxSize
            if _diff > 0 {
                if AdjustMaxSize {
                    this.AdjustMaxSize(_diff)
                } else {
                    return 0
                }
            } else {
                this.ExtendView(diff)
            }
        }
        bytes := StrPut(Str, this.Ptr + offset, this.Encoding)
        this.__Pos := offset + len * this.BytesPerChar
        return offset + bytes
    }
    /**
     * @description - Closes the current view if opened, then opens the next view. This returns the
     * size of the view in bytes. This does not require a view to already be opened; you can use this
     * to initialize a view at page 0.
     *
     * If there is a currently active view:
     * - If the current view is opened to the end of the file mapping object, nothing is changed and
     *   the function returns 0.
     * - If the size of the currently active view is not a multiple of the system's virtual memory
     *   allocation granularity, the view that is opened has the following characteristics:
     *   - The start page of the new view is rounded down from the last page of the currently opened
     *     view. That is, the remaining bytes of the last page of the currently opened view are
     *     available within the first page of the new view.
     *   - {@link FileMapping.Prototype.Pos} is set to after the last byte of the currently opened
     *     view. That is, after calling {@link FileMapping.Prototype.NextPage}, your code can call
     *     {@link FileMapping.Prototype.Read} to resume reading from the end of the currently active
     *     view.
     *   - The size of the new view is the size of the currently active view rounded up to the next
     *     page or to the end of the file mapping object, whichever is lesser.
     * - If the size of the currently active view is a multiple of the system's virtual memory
     *   allocation granularity, the view that is opened has the following characteristics:
     *   - The start page of the new view is the page after the end of the currently opened view.
     *   - {@link FileMapping.Prototype.Pos} is 0.
     *   - The size of the new view is either the same as the size of the currently active view, or
     *     the new view ends at the end of the file mapping object, whichever is lesser.
     *
     * If there is not a currently active view:
     * - The start page of the new view is 0.
     * - {@link FileMapping.Prototype.Pos} is 0.
     * - If `Pages` is set, the size of the new view is either `Pages` pages, or the new view ends at
     *   the end of the file mapping object, whichever is lesser.
     * - If `Pages` is unset, the size of the new view is either 1, or the new view ends at the end
     *   of the file mapping object, whichever is lesser.
     *
     * @param {Integer} [Pages] - The number of pages to use to open a view. One page is equivalent
     * to the system virtual memory allocation granularity. See the description of this method for
     * more information.
     *
     * @returns {Integer} - If successful, the size of the view in bytes. If unsuccessful, i.e.
     * the current view is at the end of the file mapping object, returns 0.
     */
    NextPage(Pages?) {
        if this.Size {
            if this.OnLastPage {
                return 0
            }
            if Mod(this.Size, FileMapping_VirtualMemoryGranularity) {
                page := this.Page + Floor(this.Pages)
                offset := this.__Pos - Floor(this.Pages) * FileMapping_VirtualMemoryGranularity
            } else {
                page := this.Page + this.Pages
                offset := 0
            }
            bytes := this.OpenViewP(page, pages)
            this.__Pos := Integer(offset)
            return bytes
        } else {
            return this.OpenViewP(0, Pages ?? 1)
        }
    }
    /**
     * @description - This method encapsulates all of the logic needed to ensure a new view is always
     * opened in a single method call, passing the parameters to {@link FileMapping.Prototype.OpenView}.
     *
     * Does the following:
     * - If there is an active view, calls `UnmapViewOfFile` and deletes the properties
     *   {@link FileMapping#Ptr}, {@link FileMapping#Size}, and {@link FileMapping#__Pos}.
     * - If property {@link FileMapping#hFile} is zero, calls {@link FileMapping.Prototype.OpenFile}.
     *   {@link FileMapping#hFile} is set automatically when creating the file mapping object if
     *   {@link FileMapping.Options#Path `Options.Path`} is set.
     * - If property {@link FileMapping#hMapping} is zero, calls {@link FileMapping.Prototype.OpenMapping}.
     *   {@link FileMapping#hMapping} is set automatically when creating the file mapping object.
     * - Calls {@link FileMapping.Prototype.OpenView}.
     *
     * @param {Integer} [Offset = 0] - The offset from the start of the file mapping object at which
     * to open the view. {@link FileMapping.Prototype.OpenView} will adjust this value to conform to
     * the system's virtual memory allocation granularity. The view's actual offset is returned by
     * property {@link FileMapping#ViewStart}.
     *
     * @param {Integer} [Bytes] - The minimum size of the view in bytes. If unset, the remainder of
     * the file starting from `Offset` is mapped. If set to a negative number, the end position of
     * the view is calculated from the end of the file.
     *
     * @param {Boolean} [AdjustMaxSize = false] - Understand that if the file mapping object is opened
     * in more than one process, you must not set `AdjustMaxSize` to true unless all other processes
     * call `CloseHandle` to close their handle.
     *
     * If true, and if `Bytes` is set with a value that would cause the view's size to exceed the
     * current maximum size of the file mapping object, the file mapping object is closed and
     * re-opened with a new maximum size to accommodate `Bytes` (the original maximum size is
     * doubled until a sufficient size is reached).
     *
     * If false, and if `Bytes` is set with a value that would cause the view's size to exceed the
     * current maximum size of the file mapping object, the view is opened to the end of the file
     * mapping object.
     *
     * @returns {Integer} - The size of the view in bytes. This is also set to property
     * {@link FileMapping#Size}.
     */
    Open(Offset := 0, Bytes?, AdjustMaxSize := false) {
        if this.Ptr {
            DllCall(g_kernel32_UnmapViewOfFile, 'ptr', this.Ptr)
            this.DeleteProp('Ptr')
            if this.HasOwnProp('Size') {
                this.DeleteProp('Size')
            }
            if this.HasOwnProp('__Pos') {
                this.DeleteProp('__Pos')
            }
        }
        if !this.hFile {
            this.OpenFile()
        }
        if !this.hMapping {
            this.OpenMapping()
        }
        return this.OpenView(Offset, Bytes ?? unset, AdjustMaxSize)
    }
    /**
     * @description - This method encapsulates all of the logic needed to ensure a new view is always
     * opened in a single method call, passing the parameters to {@link FileMapping.Prototype.OpenViewP}.
     *
     * Does the following:
     * - If there is an active view, calls `UnmapViewOfFile` and deletes the properties
     *   {@link FileMapping#Ptr}, {@link FileMapping#Size}, and {@link FileMapping#__Pos}.
     * - If property {@link FileMapping#hFile} is zero, calls {@link FileMapping.Prototype.OpenFile}.
     *   {@link FileMapping#hFile} is set automatically when creating the file mapping object if
     *   {@link FileMapping.Options#Path `Options.Path`} is set.
     * - If property {@link FileMapping#hMapping} is zero, calls {@link FileMapping.Prototype.OpenMapping}.
     *   {@link FileMapping#hMapping} is set automatically when creating the file mapping object.
     * - Calls {@link FileMapping.Prototype.OpenViewP}.
     *
     * @param {Integer} [Start = 0] - The page number at which to begin the view. If `Start` is
     * greater than or equal to the total number of pages in the file mapping object, the function
     * returns 0 without opening the view.
     *
     * @param {Integer} [Pages] - The number of pages to include in the view.
     * - One page is the size of the system's virtual memory allocation granularity.
     * - If unset, the view will include the remainder of the file mapping object after `Start`.
     * - If the magnitude of `Pages` would cause the view to extend past the end of the file mapping
     *   object, the view is opened to the end of the file mapping object instead.
     * - Negative values are not supported.
     *
     * @returns {Integer} - If successful, the size of the view in bytes. This is also set to property
     * {@link FileMapping#Size}. If unsuccessful, 0.
     */
    OpenP(Start := 0, Pages?) {
        if this.Ptr {
            DllCall(g_kernel32_UnmapViewOfFile, 'ptr', this.Ptr)
            this.DeleteProp('Ptr')
            if this.HasOwnProp('Size') {
                this.DeleteProp('Size')
            }
            if this.HasOwnProp('__Pos') {
                this.DeleteProp('__Pos')
            }
        }
        if !this.hFile {
            this.OpenFile()
        }
        if !this.hMapping {
            this.OpenMapping()
        }
        return this.OpenViewP(Start, Pages ?? unset)
    }
    /**
     * @description - Creates the file object.
     */
    OpenFile() {
        if this.hFile {
            throw Error('The file has already been opened.')
        }
        if this.Path {
            if this.hFile := DllCall(
                g_kernel32_CreateFileW
                , 'Str', this.Path
                , 'uint', this.dwDesiredAccess_file
                , 'uint', this.dwShareMode
                , 'ptr', this.lpSecurityAttributes
                , 'uint', this.dwCreationDisposition
                , 'uint', this.dwFlagsAndAttributes
                , 'ptr', this.hTemplateFile
                , 'ptr'
            ) {
                if !this.MaxSize {
                    if !(this.MaxSize := DllCall(g_kernel32_GetFileSize, 'ptr', this.hFile, 'ptr', 0, 'Int')) {
                        this.CloseFile()
                        throw Error('``CreateFileMapping`` cannot create a file mapping backed by a file that is size 0.')
                    }
                }
                if !this.__OnExitActive && this.SetOnExit {
                    this.SetOnExitCallback(this.SetOnExit)
                }
                return this.hFile
            } else {
                throw OSError()
            }
        } else {
            this.hFile := INVALID_HANDLE_VALUE
        }
    }
    /**
     * @description - Creates the file mapping object. This will also set the `OnExit` callback
     * if `Options.SetOnExit` ({@link FileMapping.Prototype.SetOnExit}) is nonzero.
     */
    OpenMapping() {
        if this.hMapping {
            throw Error('The mapping has already been opened.')
        }
        if !this.MaxSize && this.hFile <= 0 {
            this.MaxSize := FileMapping_VirtualMemoryGranularity
        }
        if this.hMapping := DllCall(
            g_kernel32_CreateFileMappingW
            , 'ptr', this.hFile
            , 'ptr', this.lpFileMappingAttributes
            , 'ptr', this.flProtect
            , 'int', this.dwMaximumSizeHigh
            , 'int', this.dwMaximumSizeLow
            , 'ptr', this.Name ? StrPtr(this.Name) : 0
            , 'ptr'
        ) {
            if !this.__OnExitActive && this.SetOnExit {
                this.SetOnExitCallback(this.SetOnExit)
            }
            return this.hMapping
        } else {
            throw OSError()
        }
    }
    /**
     * @description - Opens the view of the file.
     *
     * If the view is opened to the beginning of the file mapping (page 0), and if the encoding
     * indicates utf-16 or utf-8, the content is checked for a byte order mark. If a byte order mark
     * is present, the file pointer ({@link FileMapping.Prototype.Pos}) is moved to after the byte
     * order mark.
     *
     * `CreateFileMapping` requires the view's starting offset to be aligned to the system's virtual
     * memory allocation granularity. {@link FileMapping.Prototype.OpenView} handles aligning
     * the offset to this for you. Consequently, the view may be opened at a start offset that is
     * different from the value passed to `Offset`. Property {@link FileMapping.Prototype.ViewStart}
     * returns the actual start offset.
     *
     * If {@link FileMapping.Prototype.OpenView} adjusts the start offset, it automatically sets
     * the position of the file pointer ({@link FileMapping.Prototype.Pos}) to be consistent with the
     * original value of `Offset`.
     *
     * The opened view will start at an offset equal to or less than the input offset, such that the
     * requested content will always be within the view. Similarly, the size of the view in bytes
     * can be equal to or greater than the input byte count because
     * {@link FileMapping.Prototype.OpenView} will adjust the byte count to maintain the end
     * position of the view. See the example below for an illustration of this.
     *
     * If your application needs to know exactly how many bytes will be consumed prior to opening the
     * view, call {@link FileMapping.Prototype.CalculateViewSize}.
     *
     * @example
     * f := FileMapping({ Path: "MyContent.json", MaxSize: 20000 + FileMapping_VirtualMemoryGranularity })
     * ; The view is opened at 0 for 100 bytes.
     * Bytes := f.OpenView(0, 100)
     * OutputDebug(f.ViewStart "`n") ; 0
     * OutputDebug(Bytes "`n") ; 100
     * f.CloseView()
     * ; The view is still opened at 0 but for 1100 bytes because
     * ; 1000 does not align with the granularity.
     * offset := 1000
     * Bytes := f.OpenView(offset, 100)
     * OutputDebug(f.ViewStart "`n") ; 0
     * OutputDebug(Bytes "`n") ; 1100
     * ; Move the file pointer to the intended offset
     * f.Pos := offset - f.ViewStart
     * f.CloseView()
     * ; The view is opened at FileMapping_VirtualMemoryGranularity for 20000 bytes.
     * Bytes := f.OpenView(FileMapping_VirtualMemoryGranularity, 20000)
     * OutputDebug(f.ViewStart "`n") ; <FileMapping_VirtualMemoryGranularity>
     * OutputDebug(Bytes "`n") ; 20000
     * f.CloseView()
     * @
     *
     * @param {Integer} [Offset = 0] - The offset from the start of the file mapping object at which
     * to open the view. {@link FileMapping.Prototype.OpenView} will adjust this value to conform to
     * the system's virtual memory allocation granularity. The view's actual offset is returned by
     * property {@link FileMapping#ViewStart}.
     *
     * @param {Integer} [Bytes] - The minimum size of the view in bytes. If unset, the remainder of
     * the file starting from `Offset` is mapped. If set to a negative number, the end position of
     * the view is calculated from the end of the file.
     *
     * @param {Boolean} [AdjustMaxSize = false] - Understand that if the file mapping object is opened
     * in more than one process, you must not set `AdjustMaxSize` to true unless all other processes
     * call `CloseHandle` to close their handle.
     *
     * If true, and if `Bytes` is set with a value that would cause the view's size to exceed the
     * current maximum size of the file mapping object, the file mapping object is closed and
     * re-opened with a new maximum size to accommodate `Bytes` (the original maximum size is
     * doubled until a sufficient size is reached).
     *
     * If false, and if `Bytes` is set with a value that would cause the view's size to exceed the
     * current maximum size of the file mapping object, the view is opened to the end of the file
     * mapping object.
     *
     * @returns {Integer} - The size of the view in bytes. This is also set to property
     * {@link FileMapping#Size}.
     */
    OpenView(Offset := 0, Bytes?, AdjustMaxSize := false) {
        if this.Ptr {
            DllCall(g_kernel32_UnmapViewOfFile, 'ptr', this.Ptr)
            this.DeleteProp('Ptr')
        }
        _offset := Offset
        if !this.CalculateViewSize(&Offset, &Bytes, AdjustMaxSize, &Page) {
            ; Open to the end of the file mapping object
            Page := Floor(_offset / FileMapping_VirtualMemoryGranularity)
            Offset := Page * FileMapping_VirtualMemoryGranularity
            Bytes := this.MaxSize - Offset
        }
        if !(this.Ptr := DllCall(
            g_kernel32_MapViewOfFile
          , 'ptr', this.hMapping
          , 'int', this.dwDesiredAccess_view
          , 'int', Integer(Offset >> 32)
          , 'int', Integer(Offset & 0xFFFFFFFF)
          , 'int', Integer(Bytes)
          , 'ptr'
        )) {
            if this.HasOwnProp('__Pos') {
                this.DeleteProp('__Pos')
            }
            if this.HasOwnProp('Page') {
                this.DeleteProp('Page')
            }
            if this.HasOwnProp('Size') {
                this.DeleteProp('Size')
            }
            throw OSError()
        }
        this.Page := Page
        this.__Pos := Integer(_offset - Offset)
        this.StartByte := FileMapping_HasBom(this.Ptr, this.Encoding)
        ; If at the start of the file, move the position to after the byte order mark (if one is present)
        if !this.__Pos && !Page {
            this.__Pos := Integer(this.StartByte)
        }
        return this.Size := Bytes
    }
    /**
     * @description - Opens the view of the file. This is measured in pages, where 1 page is
     * the system's virtual memory allocation granularity. Page indices are 0-based, such that a view
     * that is opened at byte 0 is on page 0.
     *
     * @param {Integer} [Start = 0] - The page number at which to begin the view. If `Start` is
     * greater than or equal to the total number of pages in the file mapping object, the function
     * returns 0 without opening the view.
     *
     * @param {Integer} [Pages] - The number of pages to include in the view.
     * - One page is the size of the system's virtual memory allocation granularity.
     * - If unset, the view will include the remainder of the file mapping object after `Start`.
     * - If the magnitude of `Pages` would cause the view to extend past the end of the file mapping
     *   object, the view is opened to the end of the file mapping object instead.
     * - Negative values are not supported.
     *
     * @returns {Integer} - If successful, the size of the view in bytes. This is also set to property
     * {@link FileMapping#Size}. If unsuccessful, 0.
     */
    OpenViewP(Start := 0, Pages?) {
        if Start >= Ceil(this.TotalPages) {
            return 0
        }
        if IsSet(Pages) {
            return this.OpenView(Start * FileMapping_VirtualMemoryGranularity, Pages * FileMapping_VirtualMemoryGranularity)
        } else {
            return this.OpenView(Start * FileMapping_VirtualMemoryGranularity)
        }
    }
    /**
     * @description - Makes a copy of data from the file mapping object beginning at the file
     * pointer's current position, then overwrites the bytes by shifting the data that is to the
     * right of the copied data leftward, effectively "removing" the data. The file pointer's
     * position does not change.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * @example
     * fm := FileMapping({ MaxSize: 1000 })
     * fm.Open()
     * ; Fills 200 bytes with random numbers
     * loop 50 {
     *     NumPut("int", Random(1, 99999999), fm, A_Index - 1)
     * }
     * ; Copy bytes 40-79 for demonstration
     * copy_cut := Buffer(40)
     * DllCall("msvcrt.dll\memcpy", "ptr", fm.Ptr + 40, "ptr", copy_cut, "int", 40, "cdecl")
     * ; Copy bytes 80-119 for demonstration
     * copy_moved := Buffer(40)
     * DllCall("msvcrt.dll\memcpy", "ptr", fm.Ptr + 80, "ptr", copy_moved, "int", 40, "cdecl")
     * ; Cut bytes 40-79
     * fm.Pos := 40
     * cut_data := fm.RawCut(40)
     * OutputDebug(fm.Pos "`n") ; 40
     * ; This demonstrates that `cut_data`
     * ; is the same as `copy_cut`.
     * value := DllCall("msvcrt.dll\memcmp", "ptr", cut_data, "ptr", copy_cut, "int", 40, "cdecl")
     * OutputDebug(value "`n") ; 0
     * ; This demonstrates that bytes 40-79 of the
     * ; file mapping object are the same as
     * ; the bytes in `copy_moved`.
     * value2 := DllCall("msvcrt.dll\memcmp", "ptr", fm.Ptr + 40, "ptr", copy_moved, "int", 40, "cdecl")
     * OutputDebug(value2 "`n") ; 0
     * @
     *
     * @param {Integer} Bytes - The number of bytes to copy and remove.
     *
     * If `EndOffset` is set, `Bytes` must be less or equal to the difference between the file pointer's
     * current position and `EndOffset`.
     *
     * If `EndOffset` is unset, `Bytes` must be less than or equal to the difference between the file
     * pointer's current position and the file mapping object's maximum size.
     *
     * If `Dest` is set, and if `Dest` is an object, `Bytes` must be less than or equal to
     * `Dest.Size`.
     *
     * @param {*} [Dest] - If set, a `Buffer` object, an object with properties { Size, Ptr }, or
     * an integer representing a pointer to the buffer to which the data will be copied. If unset,
     * a `Buffer` is created with size `Bytes`.
     *
     * @param {Integer} [EndOffset] - If set, `EndOffset` indicates the last byte that will be shifted
     * left by this function. The offset is relative to the start of the file mapping object. If the
     * current view does not include `EndOffset` in its range, {@link FileMapping.Prototype.RawCut}
     * caches the current view size and opens a view up to `EndOffset`. After
     * {@link FileMapping.Prototype.RawCut} makes a copy of the target data, it shifts the data beginning
     * from the end of the copied data and ending at `EndOffset`, shifting it left to the file
     * pointer's current position, effectively overwriting the copied data.
     *
     * If `EndOffset` is greater than the maximum size of the file mapping object
     * ({@link FileMapping.Prototype.MaxSize}), `EndOffset` is set to the maximum size of the file
     * mapping object.
     *
     * If unset, the end of the file mapping object is used.
     *
     * If {@link FileMapping.Prototype.RawCut} opened a larger view, it closes the view and opens a
     * view with the original size before returning.
     *
     * If unset, after {@link FileMapping.Prototype.RawCut} makes a copy of the target string, it moves
     * the data between the end of the target string and the end of the view to the file pointer's
     * current position.
     *
     * @param {Boolean} [Terminate = true] - If true, {@link FileMapping.Prototype.RawCut} inserts a
     * null terminator at the end of the data that was moved.
     *
     * @returns {String} - The string read from the view.
     *
     * @throws {ValueError} - "`EndOffset` is greater than the file mapping object`'s maximum size."
     * @throws {ValueError} - "'Invalid `Bytes` value."
     * @throws {PropertyError} - "`Dest` must have properties `"Ptr`" and `"Size`"."
     */
    RawCut(Bytes, Dest?, EndOffset?, Terminate := true) {
        offset := this.__Pos
        if IsSet(EndOffset) {
            if EndOffset > this.MaxSize {
                EndOffset := this.MaxSize
            }
            if this.ViewEnd < EndOffset {
                sz := this.Size
                page := this.Page
                this.CloseView()
                this.OpenView(page * FileMapping_VirtualMemoryGranularity, EndOffset - Page * FileMapping_VirtualMemoryGranularity)
            }
        } else {
            EndOffset := this.MaxSize
        }
        if offset + Bytes + this.ViewStart > EndOffset {
            throw ValueError('Invalid ``Bytes`` value.', , Bytes)
        }
        if IsSet(Dest) {
            if IsObject(Dest) {
                if HasProp(Dest, 'Size') && HasProp(Dest, 'Ptr') {
                    if Bytes > Dest.Size {
                        throw Error('``Bytes`` exceeds ``Dest.Size``.', , Bytes)
                    }
                } else {
                    throw PropertyError('``Dest`` must have properties "Ptr" and "Size".')
                }
            }
        } else {
            Dest := Buffer(Bytes)
        }
        DllCall(
            g_msvcrt_memmove
          , 'ptr', Dest
          , 'ptr', this.Ptr + offset
          , 'uint', Bytes
          , 'cdecl'
        )
        DllCall(
            g_msvcrt_memmove
          , 'ptr', this.Ptr + offset
          , 'ptr', this.Ptr + offset + bytes
          , 'uint', EndOffset - bytes
          , 'cdecl'
        )
        if Terminate {
            this.TerminateEx(EndOffset - bytes + offset)
        }
        if IsSet(sz) {
            this.CloseView()
            this.OpenView(page * FileMapping_VirtualMemoryGranularity, sz)
        }
        this.__Pos := Bytes
        return Dest
    }
    /**
     * @description - Inserts data into the current position, shifting the existing content to
     * the right and moving the file pointer.
     *
     * If the current view is insufficient to receive the entire data, and if the size of the file
     * mapping object is sufficient to receive the entire data, {@link FileMapping.Prototype.RawInsert}
     * closes the current view and opens a view large enough to receive the data, rounded up to the
     * next page or to the end of the file mapping object, whichever is lesser.
     *
     * If the size of the file mapping object is insufficient to receive the entire data, the behavior
     * of {@link FileMapping.Prototype.RawInsert} is determined by parameter `AdjustMaxSize`.
     *
     * If there is data near the end of the view, that data is overwritten. Specifically, any data
     * that is within `Bytes` bytes from the end of the view is overwritten.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * @example
     * fm := FileMapping({ MaxSize: 1000 })
     * fm.Open()
     * ; Fills 200 bytes with random numbers
     * loop 50 {
     *     NumPut("int", Random(1, 99999999), fm, A_Index - 1)
     * }
     * ; Copy bytes 50-89 for demonstration
     * copy := Buffer(40)
     * DllCall("msvcrt.dll\memcpy", "ptr", fm.Ptr + 50, "ptr", copy, "int", 40, "cdecl")
     * ; Data to insert
     * data := Buffer(40)
     * ; Fills 40 bytes
     * loop 10 {
     *     NumPut("int", A_Index, data, A_Index - 1)
     * }
     * fm.Pos := 50
     * fm.RawInsert(data)
     * ; The new file pointer position
     * OutputDebug(fm.Pos "`n") ; 90
     * ; This demonstrates that bytes 50-89 of the
     * ; file mapping object are the same as
     * ; the bytes in `data`.
     * value := DllCall("msvcrt.dll\memcmp", "ptr", fm.Ptr + 50, "ptr", data, "int", 40, "cdecl")
     * OutputDebug(value "`n") ; 0
     * ; This demonstrates that bytes 90-129 of
     * ; the file mapping object are the same
     * ; as the bytes copied from 50-89 of
     * ; the file mapping object earlier.
     * value2 := DllCall("msvcrt.dll\memcmp", "ptr", fm.Ptr + 90, "ptr", copy, "int", 40, "cdecl")
     * OutputDebug(value2 "`n") ; 0
     * @
     *
     * @param {*} Data - A pointer to the source of the data, or a Buffer containing the data, or an
     * object with properties "Ptr" and "Size".
     *
     * @param {Integer} [Bytes] - The number of bytes to copy from `Data`. `Bytes` must be less than
     * or equal to the size of `Data`. `Bytes` can be left unset if `Data` is an object; the "Size"
     * property is used to deterine the size of the data.
     *
     * @param {Boolean} [AdjustMaxSize = false] - Understand that if the file mapping object is opened
     * in more than one process, you must not set `AdjustMaxSize` to true unless all other processes
     * call `CloseHandle` to close their handle.
     *
     * If true, and if performing the insert operation would exceed the file mapping object's maximum
     * size, the file mapping object is closed and re-opened with a new maximum size to accommodate
     * the data (the original maximum size is doubled until a sufficient size is reached). A view is
     * then opened that is sufficient to receive the entire data, rounded up to the next page or to
     * the end of the file mapping object, whichever is lesser.
     *
     * If false, and if performing the write operation would exceed the file mapping object's maximum
     * size, the data is not copied and the function returns 0.
     *
     * @returns {Integer} - The number of bytes written.
     *
     * @throws {Error} - "`Bytes` exceeds `Data.Size`."
     * @throws {Error} - "`Data` must have properties `"Ptr`" and `"Size`"."
     * @throws {Error} - "`Bytes` must be set when `Data` is not an object."
     */
    RawInsert(Data, Bytes?, AdjustMaxSize := false) {
        if IsObject(Data) {
            if HasProp(Data, 'Size') && HasProp(Data, 'Ptr') {
                if IsSet(Bytes) {
                    if Bytes > Data.Size {
                        throw Error('``Bytes`` exceeds ``Data.Size``.', , Bytes)
                    }
                } else {
                    Bytes := Data.Size
                }
            } else {
                throw PropertyError('``Data`` must have properties "Ptr" and "Size".')
            }
        } else if !IsSet(Bytes) {
            throw Error('``Bytes`` must be set when ``Data`` is not an object.')
        }
        offset := this.__Pos
        if bytes + offset > this.Size {
            if this.ViewStart + offset + bytes > this.MaxSize {
                if AdjustMaxSize {
                    this.AdjustMaxSize(bytes)
                } else {
                    return 0
                }
            } else {
                this.ExtendView(bytes)
            }
        }
        DllCall(
            g_msvcrt_memmove
          , 'ptr', this.Ptr + offset + bytes
          , 'ptr', this.Ptr + offset
          , 'uint', this.Size - offset - bytes
          , 'cdecl'
        )
        DllCall(
            g_msvcrt_memmove
          , 'ptr', this.Ptr + offset
          , 'ptr', Data
          , 'uint', bytes
          , 'cdecl'
        )
        this.__Pos += bytes
        return Bytes
    }
    /**
     * @description - Copies data from the file mapping object to a buffer, beginning at the file
     * pointer's current position, and advances the file pointer.
     *
     * If the current view is insufficient to retrieve the entire data, and if `Bytes` is less than
     * or equal to the remaining data in the file mapping object, {@link FileMapping.Prototype.RawRead}
     * closes the current view and opens a view large enough to retrieve the data, rounded up to the
     * next page or to the end of the file mapping object, whichever is lesser.
     *
     * If `Bytes` exceeds the actual number of bytes remaining between {@link FileMapping.Prototype.Pos}
     * and {@link FileMapping.Prototype.MaxSize}, an error is thrown.
     *
     * @param {*} Dest - A `Buffer` object, an object with properties { Size, Ptr }, or an integer
     * representing a pointer to the buffer to which the data will be copied. If `Dest` is an object,
     * and if `Bytes` exceeds `Dest.Size`, an error is thrown.
     *
     * @param {Integer} [Bytes] - The number of bytes to copy from the file mapping object. If unset,
     * {@link FileMapping.Prototype.RawRead} copies the data between the file pointer's current
     * position and the end of the current view. If `Dest` and `Bytes` are set, `Bytes` must be less
     * than or equal to the size of `Dest`.
     *
     * @returns {Integer} - The number of bytes copied.
     *
     * @throws {Error} - "`Bytes` exceeds the available remaining data in the file mapping object."
     * @throws {Error} - "`Bytes` exceeds `Dest.Size`."
     * @throws {PropertyError} - "`Dest` must have properties `"Ptr`" and `"Size`"."
     */
    RawRead(Dest, Bytes?) {
        if IsSet(Bytes) {
            if Bytes > this.Size - this.__Pos {
                if !this.ExtendView(Bytes) {
                    throw Error('``Bytes`` exceeds the available remaining data in the file mapping object.', , Bytes)
                }
            }
        } else {
            Bytes := this.Size - this.__Pos
        }
        if IsObject(Dest) {
            if HasProp(Dest, 'Size') && HasProp(Dest, 'Ptr') {
                if Bytes > Dest.Size {
                    throw Error('``Bytes`` exceeds ``Dest.Size``.', , Bytes)
                }
            } else {
                throw PropertyError('``Dest`` must have properties "Ptr" and "Size".')
            }
        }
        this.__Pos += Bytes
        DllCall(
            g_msvcrt_memmove
          , 'ptr', Dest
          , 'ptr', this.Ptr + this.__Pos
          , 'uint', Bytes
          , 'cdecl'
        )
        return Bytes
	}
    /**
     * @description - Writes data at the file pointer's current position, replacing a number
     * of characters in the process. The direction in which data is moved depends on the size of
     * `Data` / the value of `DataSize`, and the value of `Bytes`. The file pointer is moved to the
     * end of the data that was inserted.
     *
     * If the current view is insufficient to receive the entire string, and if the size of the file
     * mapping object is sufficient to receive the entire string, {@link FileMapping.Prototype.Replace}
     * closes the current view and opens a view large enough to receive the string, rounded up to the
     * next page or to the end of the file mapping object, whichever is lesser.
     *
     * If the size of the file mapping object is insufficient to receive the entire string, the behavior
     * of {@link FileMapping.Prototype.Replace} is determined by parameter `AdjustMaxSize`.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * Example with `DataSize > Bytes`:
     * @example
     * fm := FileMapping({ MaxSize: 200 })
     * fm.Open()
     * str := "{ `"prop1`": `"val1`", `"prop2`": `"val2`" }"
     * fm.Write2(&str)
     * toReplace := "val1"
     * ; Set file pointer to just befoe "val1".
     * fm.Pos := (InStr(str, toReplace) - 1) * fm.BytesPerChar
     * bytes := StrLen(toReplace) * fm.BytesPerChar
     * replacementStr := "new_val"
     * replacement := Buffer(StrLen(replacementStr) * fm.BytesPerChar)
     * StrPut(replacementStr, replacement, StrLen(replacementStr), fm.Encoding)
     * ; The difference, in bytes, of
     * ; the data that was written less
     * ; the data that was overwritten.
     * ; i.e. `DataSize - Bytes`.
     * result := fm.RawReplace(replacement, bytes)
     * OutputDebug(result "`n") ; 6
     * OutputDebug(fm.Pos "`n") ; 38
     * fm.Pos := 0
     * OutputDebug(fm.Read() "`n") ; { "prop1": "new_val", "prop2": "val2" }
     * fm.Pos := 0
     * OutputDebug(fm.Read(38 / fm.BytesPerChar) "`n") ; { "prop1": "new_val
     * @
     *
     * Example with `DataSize < Bytes`:
     * @example
     * fm := FileMapping({ MaxSize: 200 })
     * fm.Open()
     * str := "{ `"prop1`": `"longer_val1`", `"prop2`": `"longer_val2`" }"
     * fm.Write2(&str)
     * toReplace := "longer_val1"
     * ; Set file pointer to just before
     * ; "longer_val1".
     * fm.Pos := (InStr(str, toReplace) - 1) * fm.BytesPerChar
     * bytes := StrLen(toReplace) * fm.BytesPerChar
     * replacementStr := "new_val"
     * replacement := Buffer(StrLen(replacementStr) * 2)
     * StrPut(replacementStr, replacement, StrLen(replacementStr), fm.Encoding)
     * ; The difference, in bytes, of
     * ; the data that was written less
     * ; the data that was overwritten.
     * ; i.e. `DataSize - Bytes`.
     * result := fm.RawReplace(replacement, bytes)
     * OutputDebug(result "`n") ; -8
     * OutputDebug(fm.Pos "`n") ; 38
     * fm.Pos := 0
     * OutputDebug(fm.Read() "`n") ; { "prop1": "new_val", "prop2": "longer_val2" }
     * fm.Pos := 0
     * OutputDebug(fm.Read(38 / fm.BytesPerChar) "`n") ; { "prop1": "new_val
     * @
     *
     * Example with `DataSize = Bytes`:
     * @example
     * fm := FileMapping({ MaxSize: 200 })
     * fm.Open()
     * str := "{ `"prop1`": `"val1`", `"prop2`": `"val2`" }"
     * fm.Write2(&str)
     * toReplace := "val1"
     * ; Set file pointer to just before "val1".
     * fm.Pos := (InStr(str, toReplace) - 1) * fm.BytesPerChar
     * bytes := StrLen(toReplace) * fm.BytesPerChar
     * replacementStr := "val0"
     * replacement := Buffer(StrLen(replacementStr) * 2)
     * StrPut(replacementStr, replacement, StrLen(replacementStr), fm.Encoding)
     * ; The difference, in bytes, of
     * ; the data that was written less
     * ; the data that was overwritten.
     * ; i.e. `DataSize - Bytes`.
     * result := fm.RawReplace(replacement, bytes)
     * OutputDebug(result "`n") ; 0
     * OutputDebug(fm.Pos "`n") ; 32
     * fm.Pos := 0
     * OutputDebug(fm.Read() "`n") ; { "prop1": "val0", "prop2": "val2" }
     * fm.Pos := 0
     * OutputDebug(fm.Read(32 / fm.BytesPerChar) "`n") ; { "prop1": "val0
     * @
     *
     * @param {String} Str - The string to insert.
     *
     * @param {Integer} [Length] - The maximum number of characters to replace.
     *
     * If `Length` is unset, all the data between the file pointer's current position and the end
     * of the file mapping object is replaced by `Str`.
     *
     * If `Length` would exceed the file mapping object's maximum size, it is truncated to the
     * file mapping object's end.
     *
     * If `Length` is greater than the length of `Str`, the behavior of this function is similar to
     * {@link FileMapping.Prototype.Cut}. `Str` overwrites data beginning from the file pointer's
     * current position. The remaining characters are overwritten by copying the data that is to
     * the right of the file pointer's current position + `Length` characters to the end of `Str`.
     *
     * If `Length` is less than the length of `Str`, the behavior of this function is similar to
     * {@link FileMapping.Prototype.Insert}. `Str` overwrites the data beginning from the file pointer's
     * current position up to `Length` characters. The data that is to the right of the file
     * pointer's current position + `Length` characters is copied to the right to make room for the
     * rest of `Str`, such that the end of `Str` is immediately followed by the data that was shifted
     * right.
     *
     * @param {Boolean} [AdjustMaxSize = false] - `AdjustMaxSize` is ignored when `Length`
     * is greater than the length of `Str`.
     *
     * Understand that if the file mapping object is opened in more than one process, you must not
     * set `AdjustMaxSize` to true unless all other processes call `CloseHandle` to close their handle.
     *
     * If true, and if performing the write operation would exceed the file mapping object's maximum
     * size, the file mapping object is closed and re-opened with a new maximum size to accommodate
     * the data (the original maximum size is doubled until a sufficient size is reached). A view is
     * then opened that is sufficient to receive the entire data, rounded up to the next page or to
     * the end of the file mapping object, whichever is lesser.
     *
     * If false, and if performing the write operation would exceed the file mapping object's maximum
     * size, the data is not copied and the function returns 0.
     *
     * @param {Integer} [EndOffset] - `EndOffset` is ignored when `Length` is less than the length of
     * `Str`.
     *
     * If set, `EndOffset` indicates the last byte that will be shifted left by this function. The
     * offset is relative to the start of the file mapping object. If the current view does not
     * include `EndOffset` in its range, {@link FileMapping.Prototype.Replace} caches the current
     * view size and opens a view up to `EndOffset`. After {@link FileMapping.Prototype.Replace}
     * makes a copy of the target string, it moves the data between the end of the copied string
     * and `EndOffset` to the file pointer's current position.
     *
     * If {@link FileMapping.Prototype.Replace} opened a larger view, it closes the view and opens a view
     * with the original size.
     *
     * If unset, after {@link FileMapping.Prototype.Replace} makes a copy of the target string, it moves
     * all data that follows the end of the copied string to the file pointer's current position.
     *
     * @param {Boolean} [Terminate = false] - `Terminate` is ignored when `Length` is less than the
     * length of `Str`.
     *
     * If true, {@link FileMapping.Prototype.Cut} inserts a null terminator at the end of the data
     * that was moved.
     *
     * @returns {Integer} - The difference, in characters, between the length of `Str` and `Length`.
     */
    RawReplace(Data, Bytes, DataSize?, AdjustMaxSize := false, EndOffset?, Terminate := true) {
        if IsObject(Data) {
            if HasProp(Data, 'Size') && HasProp(Data, 'Ptr') {
                if IsSet(DataSize) {
                    if DataSize > Data.Size {
                        throw Error('``DataSize`` exceeds ``Data.Size``.', , DataSize)
                    }
                } else {
                    DataSize := Data.Size
                }
            } else {
                throw PropertyError('``Data`` must have properties "Ptr" and "Size".')
            }
        } else if !IsSet(DataSize) {
            throw Error('``DataSize`` must be set when ``Data`` is not an object.')
        }
        offset := this.__Pos
        if DataSize > Bytes {
            diff := DataSize - Bytes
            if diff + offset > this.Size {
                if this.ViewStart + offset + diff > this.MaxSize {
                    if AdjustMaxSize {
                        this.AdjustMaxSize(diff)
                    } else {
                        return 0
                    }
                } else {
                    this.ExtendView(diff)
                }
            }
            DllCall(
                g_msvcrt_memmove
              , 'ptr', this.Ptr + offset + DataSize
              , 'ptr', this.Ptr + offset + bytes
              , 'uint', this.Size - offset - diff
              , 'cdecl'
            )
            DllCall(
                g_msvcrt_memmove
              , 'ptr', this.Ptr + offset
              , 'ptr', Data
              , 'uint', DataSize
              , 'cdecl'
            )
        } else if DataSize < Bytes {
            if IsSet(EndOffset) {
                if EndOffset > this.MaxSize {
                    EndOffset := this.MaxSize
                }
            } else {
                EndOffset := this.MaxSize
            }
            if this.ViewEnd < EndOffset {
                sz := this.Size
                page := this.Page
                this.CloseView()
                this.OpenView(page * FileMapping_VirtualMemoryGranularity, EndOffset - Page * FileMapping_VirtualMemoryGranularity)
            }
            DllCall(
                g_msvcrt_memmove
              , 'ptr', this.Ptr + offset
              , 'ptr', Data
              , 'uint', DataSize
              , 'cdecl'
            )
            pos := offset + DataSize
            start := offset + Bytes
            DllCall(
                g_msvcrt_memmove
              , 'ptr', this.Ptr + pos
              , 'ptr', this.Ptr + start
              , 'uint', EndOffset - start
              , 'cdecl'
            )
            if Terminate {
                this.TerminateEx(EndOffset + pos - start)
            }
            if IsSet(sz) {
                this.CloseView()
                this.OpenView(page * FileMapping_VirtualMemoryGranularity, sz)
            }
        } else {
            DllCall(
                g_msvcrt_memmove
              , 'ptr', this.Ptr + offset
              , 'ptr', Data
              , 'uint', DataSize
              , 'cdecl'
            )
        }
        this.__Pos += DataSize
        return DataSize - Bytes
    }
    /**
     * @description - Copies data into the current position of the file mapping object, and advances
     * the file pointer.
     *
     * If the current view is insufficient to receive the entire data, and if the size of the file
     * mapping object is sufficient to receive the entire data, {@link FileMapping.Prototype.RawWrite}
     * closes the current view and opens a view large enough to receive the data, rounded up to the
     * next page or to the end of the file mapping object, whichever is lesser.
     *
     * If the size of the file mapping object is insufficient to receive the entire data, the behavior
     * of {@link FileMapping.Prototype.RawWrite} is determined by parameter `AdjustMaxSize`.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * @param {*} Data - A pointer to the source of the data, or a Buffer containing the data, or an
     * object with properties "Ptr" and "Size".
     *
     * @param {Integer} [Bytes] - The number of bytes to copy from `Data`. `Bytes` must be less than
     * or equal to the size of `Data`. `Bytes` can be left unset if `Data` is an object; the "Size"
     * property is used to deterine the size of the data.
     *
     * @param {Boolean} [AdjustMaxSize = false] - Understand that if the file mapping object is opened
     * in more than one process, you must not set `AdjustMaxSize` to true unless all other processes
     * call `CloseHandle` to close their handle.
     *
     * If true, and if performing the write operation would exceed the file mapping object's maximum
     * size, the file mapping object is closed and re-opened with a new maximum size to accommodate
     * the data (the original maximum size is doubled until a sufficient size is reached). A view is
     * then opened that is sufficient to receive the entire data, rounded up to the next page or to
     * the end of the file mapping object, whichever is lesser.
     *
     * If false, and if performing the write operation would exceed the file mapping object's maximum
     * size, the data is not copied and the function returns 0.
     *
     * @param {Boolean} [Terminate = false] - If true, {@link FileMapping.Prototype.Write} inserts
     * a null terminator at the end of the written string. The file pointer will be positioned just
     * before the null terminator, so the next write operation overwrites the null terminator.
     *
     * @returns {Integer} - The number of bytes copied.
     *
     * @throws {Error} - "`Bytes` exceeds `Data.Size`."
     * @throws {Error} - "`Data` must have properties `"Ptr`" and `"Size`"."
     * @throws {Error} - "`Bytes` must be set when `Data` is not an object."
     */
    RawWrite(Data, Bytes?, AdjustMaxSize := false, Terminate := false) {
        if IsObject(Data) {
            if HasProp(Data, 'Size') && HasProp(Data, 'Ptr') {
                if IsSet(Bytes) {
                    if Bytes > Data.Size {
                        throw Error('``Bytes`` exceeds ``Data.Size``.', , Bytes)
                    }
                } else {
                    Bytes := Data.Size
                }
            } else {
                throw PropertyError('``Data`` must have properties "Ptr" and "Size".')
            }
        } else if !IsSet(Bytes) {
            throw Error('``Bytes`` must be set when ``Data`` is not an object.')
        }
        offset := this.__Pos
        if bytes + offset > this.Size {
            if this.ViewStart + offset + bytes > this.MaxSize {
                if AdjustMaxSize {
                    this.AdjustMaxSize(bytes)
                } else {
                    return 0
                }
            } else {
                this.ExtendView(bytes)
            }
        }
        this.__Pos += Bytes
        DllCall(
            g_msvcrt_memmove
          , 'ptr', this.Ptr + offset
          , 'ptr', Data
          , 'uint', Bytes
          , 'cdecl'
        )
        if Terminate {
            this.Terminate()
        }
        return Bytes
	}
    /**
     * @description - Reads a string from the view and advances the file pointer. If `StrGet` stops
     * at a null terminator, the file pointer will be set to the position after the final character
     * in the string, before the null terminator.
     *
     * @param {Integer} [Length] - The maximum number of characters to read. `StrGet` automatically
     * ends the string at the first binary zero.
     *
     * If `Length` is set, and if the current view is insufficient to read the entire string,
     * {@link FileMapping.Prototype.Read} closes the current view and opens a view large enough to
     * read the string, rounded up to the next page or to the end of the file mapping object,
     * whichever is lesser.
     *
     * If unset, the remainder of the view is read.
     *
     * @returns {String} - The string read from the view.
     */
    Read(Length?) {
        offset := this.__Pos
        if IsSet(Length) {
            bytes := Length * this.BytesPerChar
            if this.ViewStart + offset + Bytes > this.MaxSize {
                bytes := this.MaxSize - this.ViewStart - offset
                Length := Floor(bytes / this.BytesPerChar)
            }
        } else {
            bytes := this.Size - offset
            Length := Floor(bytes / this.BytesPerChar)
        }
        if bytes > this.Size - offset {
            this.ExtendView(bytes)
        }
        str := StrGet(this.Ptr + offset, Length, this.Encoding)
        this.__Pos += StrLen(str) * this.BytesPerChar
        return str
    }
    /**
     * @description - Reads a string from the view and advances the file pointer. If `StrGet` stops
     * at a null terminator, the file pointer will be set to the position after the final character
     * in the string, before the null terminator.
     *
     * The differences between this and {@link FileMapping.Prototype.Read} are:
     * - The string value is returned using a `VarRef` parameter instead of as the return value.
     * - The function returns the number of characters read.
     *
     * {@link FileMapping.Prototype.Read2} assigns the string to `OutStr`. If you need the string
     * to be appended to `OutStr`, call {@link FileMapping.Prototype.Read3}.
     *
     * If the current view is insufficient to read the entire string, {@link FileMapping.Prototype.Read}
     * closes the current view and opens a view large enough to read the string, rounded up to the
     * next page or to the end of the file mapping object, whichever is lesser.
     *
     * @param {VarRef} OutStr - A variable that receives the string that is read from the view.
     *
     * @param {Integer} [Length] - The maximum number of characters to read. If unset, the remainder
     * of the view is read. `StrGet` automatically ends the string at the first binary zero. If
     * the magnitude of `Length` exceeds the available content, {@link FileMapping.Prototype.Read}
     * stops reading at the end of the current view (or at the first binary zero).
     *
     * @returns {Integer} - The number of characters read.
     */
    Read2(&OutStr, Length?) {
        offset := this.__Pos
        if IsSet(Length) {
            bytes := Length * this.BytesPerChar
            if this.ViewStart + offset + Bytes > this.MaxSize {
                bytes := this.MaxSize - this.ViewStart - offset
                Length := Floor(bytes / this.BytesPerChar)
            }
        } else {
            bytes := this.Size - offset
            Length := Floor(bytes / this.BytesPerChar)
        }
        if bytes > this.Size - offset {
            this.ExtendView(bytes)
        }
        OutStr := StrGet(this.Ptr + offset, Length, this.Encoding)
        this.__Pos += StrLen(OutStr) * this.BytesPerChar
        return StrLen(OutStr)
    }
    /**
     * @description - Reads a string from the view and advances the file pointer. If `StrGet` stops
     * at a null terminator, the file pointer will be set to the position after the final character
     * in the string, before the null terminator.
     *
     * The differences between this and {@link FileMapping.Prototype.Read} are:
     * - The string value is returned using a `VarRef` parameter instead of as the return value.
     * - The function returns the number of characters read.
     *
     * {@link FileMapping.Prototype.Read3} (this method) appends the string to `OutStr`.
     *
     * {@link FileMapping.Prototype.Read2} assigns the string value to `OutStr`.
     *
     * If the current view is insufficient to read the entire string, {@link FileMapping.Prototype.Read}
     * closes the current view and opens a view large enough to read the string, rounded up to the
     * next page or to the end of the file mapping object, whichever is lesser.
     *
     * @param {VarRef} OutStr - The string will be appended to this variable.
     *
     * @param {Integer} [Length] - The maximum number of characters to read. If unset, the remainder
     * of the view is read. `StrGet` automatically ends the string at the first binary zero. If
     * the magnitude of `Length` exceeds the available content, {@link FileMapping.Prototype.Read}
     * stops reading at the end of the current view (or at the first binary zero).
     *
     * @returns {Integer} - The number of characters read.
     */
    Read3(&OutStr, Length?) {
        offset := this.__Pos
        if IsSet(Length) {
            bytes := Length * this.BytesPerChar
            if this.ViewStart + offset + Bytes > this.MaxSize {
                bytes := this.MaxSize - this.ViewStart - offset
                Length := Floor(bytes / this.BytesPerChar)
            }
        } else {
            bytes := this.Size - offset
            Length := Floor(bytes / this.BytesPerChar)
        }
        if bytes > this.Size - offset {
            this.ExtendView(bytes)
        }
        if IsSet(OutStr) {
            len := StrLen(OutStr)
        } else {
            len := 0
            OutStr := ''
        }
        OutStr .= StrGet(this.Ptr + offset, Length, this.Encoding)
        chars := StrLen(OutStr) - len
        this.__Pos += chars * this.BytesPerChar
        return chars
    }
    /**
     * @description -  Your code must not call {@link FileMapping.Prototype.Reload} if the file
     * mapping object is opened in more than one process.
     *
     * To summarize, this method closes and reopens the file mapping object. Its purpose is to provide
     * a simple means for changing the maximum size of the file mapping object, though it is not
     * necessary to supply a new size.
     *
     * {@link FileMapping.Prototype.Reload} records the page number and file pointer position before
     * processing. If it opens a view to the same page as the original, it sets the file pointer
     * position to its original position. If it opens a view to a different page than the original,
     * it sets the file pointer to the beginning of the view. (If the file mapping object is backed
     * by a file (i.e. {@link FileMapping.Prototype.Path} is set), and if the view is opened to page
     * 0, and if the file has a byte order mark, the view is opened to just after the byte order mark).
     *
     * If a file mapping object is backed by the pagefile (and not by a file on disk),
     * {@link FileMapping.Prototype.Reload} copies the entire content of the file mapping object
     * to a temporary file in the %temp% (A_Temp) folder, then creates a new file mapping object and
     * copies the data back in. {@link FileMapping.Prototype.Reload} will delete this temporary file,
     * unless an error occurs in between the time that the file is created and it is deleted. If
     * an error does occur, the file path will be included in the error message text and also set
     * to property "TempPath" on the error object. This should only occur if the thread is interrupted
     * by another thread or if an access issue prevents deleting the temp file.
     *
     * Does the following:
     * - If `NewSize` is set, sets property {@link FileMapping.Prototype.MaxSize} with `NewSize`.
     * - Evaluates the input parameters to ensure they are valid.
     *   - If `NewSize` is greater than or equal to the original {@link FileMapping.Prototype.MaxSize}
     *     - If a file mapping view is currently active
     *       - If `Page` is set, and if `Page` is equivalent to or exceeds the maximum size, an error
     *         is thrown.
     *       - If `Page` is unset, the view is opened to the same page as the previously active view.
     *       - If `Pages` is set, and if opening the number of pages would cause the view to exceed
     *         the maximum size, an error is thrown.
     *       - If `Pages` is unset
     *         - If opening the same number of pages as the previously active view is within the bounds
     *           of the maximum size, the view is opened with the same number of pages as the previously
     *           active view.
     *         - If opening the same number of pages as the previously active view would cause the
     *           view to exceed the maximum size, the view is opened to the end of the file mapping
     *           object.
     *     - If there is not a currently active view
     *       - If `Page` is set, and if `Page` is equivalent to or exceeds the maximum size, an error
     *         is thrown.
     *       - If `Page` is unset, the view is opened to the beginning of the file mapping object.
     *       - If `Pages` is set, and if opening the number of pages would cause the view to exceed
     *         the maximum size, the view is opened to the end of the file mapping object.
     *       - If `Pages` is unset, the view is opened to the end of the file mapping object.
     *   - If `NewSize` is less than the the original {@link FileMapping.Prototype.MaxSize}
     *     - If a file mapping view is currently active
     *       - If `Page` is set, and if `Page` is equivalent to or exceeds the maximum size, an error
     *         is thrown.
     *       - If `Page` is unset
     *         - If the start of the previously active view is greater than or equal to the maximum
     *           size, the view is opened to the beginning of the file mapping object.
     *         - If the start of the previously active view is less than the maximum size, the view
     *           is opened to the same page as the previously active view.
     *       - If `Pages` is set, and if opening the number of pages would cause the view to exceed
     *         the maximum size, the view is opened to the end of the file mapping object.
     *       - If `Pages` is unset
     *         - If opening the same number of pages as the previously active view is within the bounds
     *           of the maximum size, the view is opened with the same number of pages as the previously
     *           active view.
     *         - If opening the same number of pages as the previously active view would cause the
     *           view to exceed the maximum size, the view is opened to the end of the file mapping
     *           object.
     *     - If there is not a currently active view
     *       - If `Page` is set, and if `Page` is equivalent to or exceeds the maximum size, an error is thrown.
     *       - If `Page` is unset, the view is opened to the beginning of the file mapping object.
     *       - If `Pages` is set, and if opening the number of pages would cause the view to exceed
     *         the maximum size, the view is opened to the end of the file mapping object.
     *       - If `Pages` is unset, the view is opened to the end of the file mapping object.
     * - If the file mapping object is backed by a file on disk, calls
     *   {@link FileMapping.Prototype.Flush} and {@link FileMapping.Prototype.FlushFileBuffers}.
     * - If the file mapping object is backed by the pagefile, creates a file in %temp% (`A_Temp`)
     *   and copies the data to the file, opening a view to do so if necessary. If `NewSize` is
     *   smaller than the original, only copies up to `NewSize`.
     * - If a file mapping view is currently active, calls `UnmapViewOfFile`.
     * - Calls `CloseHandle` to close the file mapping object handle.
     * - Calls {@link FileMapping.Prototype.OpenMapping} to get a new file mapping object handle.
     * - Calls {@link FileMapping.Prototype.OpenViewP} to open a view.
     * - If the file mapping object is backed by the pagefile, copies back the data from the temp
     *   file and deletes the temp file.
     *
     * @param {Integer} [NewSize] - If set, the `NewSize` value is set to property
     * {@link FileMapping.Prototype.MaxSize}.
     *
     * @param {Integer} [Page] - If set, the page at which to open the new file mapping view. See
     * the description of this method for details about how the start page is determined when
     * `Page` is unset.
     *
     * @param {Integer} [Pages] - If set, the number of pages to pass to the `Pages` parameter
     * of {@link FileMapping.Prototype.OpenViewP}. See the description of this method for details
     * about how many pages are opened when `Pages` is unset.
     *
     * @returns {Integer} - The return value from {@link FileMapping.Prototype.OpenViewP}.
     *
     * @throws {ValueError} - "`Page` is equivalent to or exceeds the maximum size of the file mapping object."
     */
    Reload(NewSize?, Page?, Pages?) {
        originalOffset := this.__Pos
        originalPage := this.Page
        if IsSet(NewSize) {
            flag_size := NewSize >= this.MaxSize
        } else {
            NewSize := this.MaxSize
            flag_size := true
        }
        if this.Ptr {
            if flag_size {
                if IsSet(Page) {
                    if Page * FileMapping_VirtualMemoryGranularity >= NewSize {
                        _ThrowPage()
                    }
                } else {
                    Page := this.Page
                }
            } else if IsSet(Page) {
                if Page * FileMapping_VirtualMemoryGranularity >= NewSize {
                    _ThrowPage()
                }
            } else if this.Page * FileMapping_VirtualMemoryGranularity >= NewSize {
                Page := 0
            } else {
                Page := this.Page
            }
        } else if IsSet(Page) {
            if Page * FileMapping_VirtualMemoryGranularity >= NewSize {
                _ThrowPage()
            }
        } else {
            Page := 0
        }
        if !IsSet(Pages) {
            Pages := Ceil(this.Pages)
        }
        if this.hFile > 0 {
            this.Flush()
            this.FlushFileBuffers()
        } else {
            loop 100 {
                _GetPath(&path)
                if !FileExist(path) {
                    break
                }
            }
            if this.Ptr {
                DllCall(g_kernel32_UnmapViewOfFile, 'ptr', this.Ptr)
                this.DeleteProp('Ptr')
            }
            this.OpenViewP()
            f := FileOpen(path, 'rw', 'UTF-16-RAW')
            f.RawWrite(this.Ptr, Min(this.Size, NewSize))
            A_Clipboard := path
            OnError(_OnError, 1)
        }
        if this.Ptr {
            DllCall(g_kernel32_UnmapViewOfFile, 'ptr', this.Ptr)
            this.DeleteProp('Ptr')
        }
        if this.hMapping {
            DllCall(g_kernel32_CloseHandle, 'ptr', this.hMapping)
            this.DeleteProp('hMapping')
        }
        this.Options.MaxSize := NewSize
        this.OpenMapping()
        if this.hFile == INVALID_HANDLE_VALUE {
            this.OpenView(0, f.Length)
            f.Pos := 0
            f.RawRead(this.Ptr, f.Length)
            f.Close()
            OnError(_OnError, 0)
            FileDelete(path)
            this.CloseView()
        }
        bytes := this.OpenViewP(Page, Pages)
        if this.Page = originalPage {
            if originalPage {
                this.__Pos := Integer(originalOffset)
            } else {
                this.__Pos := Integer(originalOffset || this.StartByte)
            }
        }

        return bytes

        _Cleanup() {
            if this.HasOwnProp('__Pos') {
                this.DeleteProp('__Pos')
            }
            if this.HasOwnProp('Page') {
                this.DeleteProp('Page')
            }
            if this.HasOwnProp('Size') {
                this.DeleteProp('Size')
            }
        }
        _GetPath(&path) {
            path := A_Temp '\'
            loop 16 {
                path .= Chr(Random(65, 90))
            }
        }
        _OnError(thrown, *) {
            _Cleanup()
            f.Close()
            thrown.Message := ('An error occurred before RawWrite the temporary file back into a file'
            ' mapping object. The path to the temporary file is "' path '". Error: ' thrown.Message)
            thrown.TempPath := path
            throw thrown
        }
        _ThrowPage() {
            _Cleanup()
            throw ValueError('``Page`` is equivalent to or exceeds the maximum size of the file mapping object.', , Page)
        }
    }
    /**
     * @description - Writes a string at the file pointer's current position, replacing a number
     * of characters in the process. The direction in which data is moved depends on the length
     * of `Str` relative to `Length`. The file pointer is moved to the end of the string that was
     * inserted.
     *
     * If the current view is insufficient to receive the entire string, and if the size of the file
     * mapping object is sufficient to receive the entire string, {@link FileMapping.Prototype.Replace}
     * closes the current view and opens a view large enough to receive the string, rounded up to the
     * next page or to the end of the file mapping object, whichever is lesser.
     *
     * If the size of the file mapping object is insufficient to receive the entire string, the behavior
     * of {@link FileMapping.Prototype.Replace} is determined by parameter `AdjustMaxSize`.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * Example with `StrLen(Str) > Length`:
     * @example
     * fm := FileMapping({ MaxSize: 200 })
     * fm.Open()
     * str := "{ `"prop1`": `"val1`", `"prop2`": `"val2`" }"
     * fm.Write2(&str)
     * toReplace := "val1"
     * fm.Pos := (InStr(str, toReplace) - 1) * fm.BytesPerChar
     * len := StrLen(toReplace)
     * replacement := "new_val"
     * result := fm.Replace(replacement, len)
     * ; The difference, in bytes, of
     * ; the data that was written less
     * ; the data that was overwritten.
     * ; i.e. `(StrLen(Str) - Length) * fm.BytesPerChar`.
     * OutputDebug(result "`n") ; 6
     * OutputDebug(fm.Pos "`n") ; 38
     * fm.Pos := 0
     * OutputDebug(fm.Read() "`n") ; { "prop1": "new_val", "prop2": "val2" }
     * fm.Pos := 0
     * OutputDebug(fm.Read(38 / fm.BytesPerChar) "`n") ; { "prop1": "new_val
     * @
     *
     * Example with `StrLen(Str) < Length`:
     * @example
     * fm := FileMapping({ MaxSize: 200 })
     * fm.Open()
     * str := "{ `"prop1`": `"longer_val1`", `"prop2`": `"longer_val2`" }"
     * fm.Write2(&str)
     * toReplace := "longer_val1"
     * fm.Pos := (InStr(str, toReplace) - 1) * fm.BytesPerChar
     * len := StrLen(toReplace)
     * replacement := "new_val"
     * result := fm.Replace(replacement, len)
     * ; The difference, in bytes, of
     * ; the data that was written less
     * ; the data that was overwritten.
     * ; i.e. `(StrLen(Str) - Length) * fm.BytesPerChar`.
     * OutputDebug(result "`n") ; -8
     * OutputDebug(fm.Pos "`n") ; 38
     * fm.Pos := 0
     * OutputDebug(fm.Read() "`n") ; { "prop1": "new_val", "prop2": "longer_val2" }
     * fm.Pos := 0
     * OutputDebug(fm.Read(38 / fm.BytesPerChar) "`n") ; { "prop1": "new_val
     * @
     *
     * Example with `StrLen(Str) = Length`:
     * @example
     * fm := FileMapping({ MaxSize: 200 })
     * fm.Open()
     * str := "{ `"prop1`": `"val1`", `"prop2`": `"val2`" }"
     * fm.Write2(&str)
     * toReplace := "val1"
     * fm.Pos := (InStr(str, toReplace) - 1) * fm.BytesPerChar
     * len := StrLen(toReplace)
     * replacement := "val0"
     * result := fm.Replace(replacement, len)
     * ; The difference, in bytes, of
     * ; the data that was written less
     * ; the data that was overwritten.
     * ; i.e. `(StrLen(Str) - Length) * fm.BytesPerChar`.
     * OutputDebug(result "`n") ; 0
     * OutputDebug(fm.Pos "`n") ; 32
     * fm.Pos := 0
     * OutputDebug(fm.Read() "`n") ; { "prop1": "val0", "prop2": "val2" }
     * fm.Pos := 0
     * OutputDebug(fm.Read(32 / fm.BytesPerChar) "`n") ; { "prop1": "val0
     * @
     *
     * @param {String} Str - The string to insert.
     *
     * @param {Integer} [Length] - The maximum number of characters to replace.
     *
     * If `Length` is unset, all the data between the file pointer's current position and the end
     * of the file mapping object is replaced by `Str`.
     *
     * If `Length` would exceed the file mapping object's maximum size, it is truncated to the
     * file mapping object's end.
     *
     * If `Length` is greater than the length of `Str`, the behavior of this function is similar to
     * {@link FileMapping.Prototype.Cut}. `Str` overwrites data beginning from the file pointer's
     * current position. The remaining characters are overwritten by copying the data that is to
     * the right of the file pointer's current position + `Length` characters to the end of `Str`.
     *
     * If `Length` is less than the length of `Str`, the behavior of this function is similar to
     * {@link FileMapping.Prototype.Insert}. `Str` overwrites the data beginning from the file pointer's
     * current position up to `Length` characters. The data that is to the right of the file
     * pointer's current position + `Length` characters is copied to the right to make room for the
     * rest of `Str`, such that the end of `Str` is immediately followed by the data that was shifted
     * right.
     *
     * @param {Boolean} [AdjustMaxSize = false] - `AdjustMaxSize` is ignored when `Length`
     * is greater than the length of `Str`.
     *
     * Understand that if the file mapping object is opened in more than one process, you must not
     * set `AdjustMaxSize` to true unless all other processes call `CloseHandle` to close their handle.
     *
     * If true, and if performing the write operation would exceed the file mapping object's maximum
     * size, the file mapping object is closed and re-opened with a new maximum size to accommodate
     * the data (the original maximum size is doubled until a sufficient size is reached). A view is
     * then opened that is sufficient to receive the entire data, rounded up to the next page or to
     * the end of the file mapping object, whichever is lesser.
     *
     * If false, and if performing the write operation would exceed the file mapping object's maximum
     * size, the data is not copied and the function returns 0.
     *
     * @param {Integer} [EndOffset] - `EndOffset` is ignored when `Length` is less than the length of
     * `Str`.
     *
     * If set, `EndOffset` indicates the last byte that will be shifted left by this function. The
     * offset is relative to the start of the file mapping object. If the current view does not
     * include `EndOffset` in its range, {@link FileMapping.Prototype.Replace} caches the current
     * view size and opens a view up to `EndOffset`. After {@link FileMapping.Prototype.Replace}
     * makes a copy of the target string, it moves the data between the end of the copied string
     * and `EndOffset` to the file pointer's current position.
     *
     * If {@link FileMapping.Prototype.Replace} opened a larger view, it closes the view and opens a view
     * with the original size.
     *
     * If unset, after {@link FileMapping.Prototype.Replace} makes a copy of the target string, it moves
     * all data that follows the end of the copied string to the file pointer's current position.
     *
     * @param {Boolean} [Terminate = false] - `Terminate` is ignored when `Length` is less than the
     * length of `Str`.
     *
     * If true, {@link FileMapping.Prototype.Cut} inserts a null terminator at the end of the data
     * that was moved.
     *
     * @returns {Integer} - The difference, in characters, between the length of `Str` and `Length`.
     */
    Replace(Str, Length, AdjustMaxSize := false, EndOffset?, Terminate := true) {
        offset := this.__Pos
        if StrLen(Str) > Length {
            strBytes := StrLen(Str) * this.BytesPerChar
            lenBytes := Length * this.BytesPerChar
            diff := strBytes - lenBytes
            if diff + offset > this.Size {
                if this.ViewStart + offset + diff > this.MaxSize {
                    if AdjustMaxSize {
                        this.AdjustMaxSize(diff)
                    } else {
                        return 0
                    }
                } else {
                    this.ExtendView(diff)
                }
            }
            DllCall(
                g_msvcrt_memmove
              , 'ptr', this.Ptr + offset + strBytes
              , 'ptr', this.Ptr + offset + lenBytes
              , 'uint', this.Size - offset - diff
              , 'cdecl'
            )
            StrPut(Str, this.Ptr + offset, StrLen(Str), this.Encoding)
        } else if StrLen(Str) < Length {
            if IsSet(EndOffset) {
                if EndOffset > this.MaxSize {
                    EndOffset := this.MaxSize
                }
            } else {
                EndOffset := this.MaxSize
            }
            if this.ViewEnd < EndOffset {
                sz := this.Size
                page := this.Page
                this.CloseView()
                this.OpenView(page * FileMapping_VirtualMemoryGranularity, EndOffset - Page * FileMapping_VirtualMemoryGranularity)
            }
            StrPut(Str, this.Ptr + offset, StrLen(Str), this.Encoding)
            pos := offset + StrLen(Str) * this.BytesPerChar
            start := offset + Length * this.BytesPerChar
            DllCall(
                g_msvcrt_memmove
              , 'ptr', this.Ptr + pos
              , 'ptr', this.Ptr + start
              , 'uint', EndOffset - start
              , 'cdecl'
            )
            if Terminate {
                this.TerminateEx(EndOffset + pos - start)
            }
            if IsSet(sz) {
                this.CloseView()
                this.OpenView(page * FileMapping_VirtualMemoryGranularity, sz)
            }
        } else {
            StrPut(Str, this.Ptr + offset, StrLen(Str), this.Encoding)
        }
        this.__Pos += StrLen(Str) * this.BytesPerChar
        return StrLen(Str) - Length
    }
    /**
     * @description - Moves the file pointer. This has similar behavior as the AHK native
     * `File.Seek`, except instead of moving the file pointer relative to the start / end of a file,
     * it moves the file pointer relative to the start / end of the current view.
     *
     * @param {Integer} Distance - Distance to move, in bytes. Lower values are closer to the
     * beginning of the view.
     *
     * @param {Integer} [Origin] - One of the following:
     * - 0 : Beginning of the view. Distance must be zero or greater.
     * - 1 : Current position of the view pointer.
     * - 2 : End of the view. Distance should usually be negative.
     *
     * If unset, it defaults to 2 when Distance is negative and 0 otherwise.
     *
     * @returns {Boolean} - If successful, returns 1. Else, 0.
     */
    Seek(Distance, Origin?) {
        if !IsSet(Origin) {
            if Distance >= 0 {
                Origin := 0
            } else {
                Origin := 2
            }
        }
        switch Origin, 0 {
            case 0:
                if Distance < 0 || Distance > this.Size {
                    return 0
                }
                this.__Pos := Integer(Distance)
            case 1:
                if this.__Pos + Distance > this.Size || this.__Pos + Distance < 0 {
                    return 0
                }
                this.__Pos += Distance
            case 2:
                if Distance > 0 || Abs(Distance) > this.Size {
                    return 0
                }
                this.__Pos := Integer(this.Size + Distance)
        }
        return 1
    }
    /**
     * @description - Moves the file pointer to the beginning of the view. If the view is opened
     * to page 0, and if there is a byte order mark, the position is moved to after the byte
     * order mark. In all other cases, the position is moved to 0.
     *
     * @returns {Integer} - The new position.
     */
    SeekToBeginning() {
        return this.__Pos := Integer(this.Page ? 0 : this.StartByte)
    }
    SetEncoding(Encoding) {
        this.Options.Encoding := Encoding
        this.BytesPerChar := Integer(StrPut('A', Encoding) / 2)
    }
    /**
     * Sets the quantity of pages that are mapped during each iteration when processing the enumerator
     * {@link FileMapping.Prototype.__Enum}.
     *
     * @param {Integer} Pages - The number of pages to map at a time.
     */
    SetEnumPageCount(Pages) {
        this.EnumPageCount := Pages
    }
    /**
     * @description - Sets the file time for the file associated with the {@link FileMapping#hFile}
     * handle. If all three parameters are unset, this sets the file's last access time and last
     * write time to the current time. Otherwise, specify one or more of the values using
     * a {@link FileMapping_FileTime} object.
     *
     * See {@link https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-setfiletime}.
     *
     * @param {Integer|FileMapping_FileTime} [lpCreationTime = 0] - A pointer to a FILETIME structure,
     * or a {@link FileMapping_FileTime} object representing the file's creation time.
     *
     * @param {Integer|FileMapping_FileTime} [lpLastAccessTime = 0] - A pointer to a FILETIME structure,
     * or a {@link FileMapping_FileTime} object representing the file's last access time.
     *
     * @param {Integer|FileMapping_FileTime} [lpLastWriteTime = 0] - A pointer to a FILETIME structure,
     * or a {@link FileMapping_FileTime} object representing the file's last write time.
     *
     * @throws {Error} - "The `FileMapping` object is not associated with a file."
     * @throws {OSError} - If `SetFileTime` results in an error, `OSError()` is called.
     */
    SetFileTime(lpCreationTime := 0, lpLastAccessTime := 0, lpLastWriteTime := 0) {
        if this.hFile <= 0 {
            throw Error('The ``FileMapping`` object is not associated with a file.')
        }
        if !DllCall(
            g_kernel32_SetFileTime
          , 'ptr', this.hFile
          , 'ptr', lpCreationTime
          , 'ptr', lpLastAccessTime
          , 'ptr', lpLastWriteTime
          , 'int'
        ) {
            throw OSError()
        }
    }
    /**
     * @description - Sets the name of the file mapping object, updating property
     * {@link FileMapping.Prototype.Name}. If a file mapping object is currently open, it will
     * need to be closed and a new one opened to reflect the change.
     *
     * See the description of option `Options.Name` in the parameter hint above
     * {@link FileMapping.Prototype.__New} for more information about the file mapping name.
     *
     * @param {String} Name - The name to associate with the file mapping object. Set `Name`
     * with a string that ends with a backslash optionally followed by an integer representing
     * the number of characters to include in the randomized portion of the string. See the
     * description of option `Options.Name` in the parameter hint above
     * {@link FileMapping.Prototype.__New} for more information.
     *
     * @param {String[]} [Characters] - If set, an array of strings that are used to generate the
     * randomized portion of the name.
     *
     * @returns {String} - The name.
     */
    SetName(Name, Characters?) {
        if RegExMatch(Name, 'S)\\(\d*)$', &match) {
            Name := SubStr(Name, 1, match.Pos - 1)
            if IsSet(Characters) {
                len := Characters.Length
                loop match[1] || 16 {
                    Name .= Characters[Random(1, len)]
                }
            } else {
                loop match[1] || 16 {
                    Name .= Chr(Random(33, 91))
                }
            }
        }
        return this.Options.Name := Name
    }
    /**
     * @description - Sets or disables an `OnExit` callback to safely close any opened objects when
     * the script exits.
     *
     * @param {Integer} AddRemove - A value to pass to the `AddRemove` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/OnExit.htm `OnExit`}.
     */
    SetOnExitCallback(AddRemove) {
        if AddRemove = this.__OnExitActive {
            return
        }
        if AddRemove && !this.OnExit {
            this.OnExit := FileMapping_CloseOnExit(this.idFileMapping)
        }
        this.__OnExitActive := AddRemove
        OnExit(this.OnExit, AddRemove)
    }
    /**
     * @description - Writes a null terminator at the current position. This does not advance the
     * file pointer. If the current position is at the end of the current view, a new view is opened
     * to accommodate the write operation. The new view will begin at the same page as the current view
     * and will include one additional page, or will stop at the end of the file mapping object,
     * whichever is lesser.
     *
     * If performing the write operation would extend beyond the end of the file mapping object,
     * the function fails and returns 0.
     *
     * @returns {Integer} - If successful, the return value from `NumPut`, which is the address of
     * the next byte after the value that was just written. If unsuccessful, 0.
     *
     * @throws {Error} - "The operation requires an active view.".
     */
    Terminate() {
        if !this.Size {
            throw Error('The operation requires an active view.', , A_ThisFunc)
        }
        offset := this.__Pos
        if offset + this.BytesPerChar > this.Size {
            if offset + this.ViewStart + this.BytesPerChar > this.MaxSize {
                return 0
            }
            this.ExtendView(this.BytesPerChar)
        }
        if this.BytesPerChar = 1 {
            return NumPut('uchar', 0, this.Ptr + offset)
        } else {
            return NumPut('ushort', 0, this.Ptr + offset)
        }
    }
    /**
     * @description - Writes a null terminator at the indicated position.
     *
     * @param {Integer} Offset - The byte offset from the start of the file mapping object at which
     * to write the null terminator. `Offset` must be less than {@link FileMapping.Prototype.MaxSize}.
     * If `Offset` is greater than the end of the current view, {@link FileMapping.Prototype.TerminateEx}
     * caches the current view's page and size, opens a larger view, writes the null terminator,
     * closes the view and reopens a view to the original page and size.
     *
     * @returns {Integer} - If successful, the return value from `NumPut`, which is the address of
     * the next byte after the value that was just written. If unsuccessful, 0.
     *
     * @throws {Error} - "The operation requires an active view.".
     * @throws {Error} - "`Offset` must be less than the file mapping object`s maximum size."
     */
    TerminateEx(Offset) {
        if !this.Size {
            throw Error('The operation requires an active view.', , A_ThisFunc)
        }
        if Offset > this.ViewEnd {
            if Offset >= this.MaxSize {
                throw Error('``Offset`` must be less than the file mapping object`'s maximum size.', , Offset)
            }
            sz := this.Size
            page := this.Page
            this.ExtendView(Offset - this.__Pos - this.ViewStart + this.BytesPerChar)
            if this.BytesPerChar = 1 {
                ptr := NumPut('uchar', 0, this.Ptr + Offset)
            } else {
                ptr := NumPut('ushort', 0, this.Ptr + Offset)
            }
            if IsSet(sz) {
                this.CloseView()
                this.OpenView(page * FileMapping_VirtualMemoryGranularity, sz)
            }
            return ptr
        } else if this.BytesPerChar = 1 {
            return NumPut('uchar', 0, this.Ptr + Offset)
        } else {
            return NumPut('ushort', 0, this.Ptr + Offset)
        }
    }
    /**
     * @description - Writes content to file. {@link FileMapping.Prototype.ToFile} opens a file
     * object using AHK's native {@link https://www.autohotkey.com/docs/v2/lib/FileOpen.htm `FileOpen`},
     * and calls the method `File.RawWrite`. Does not advance the file pointer.
     *
     * @param {String} Path - The file path to write to.
     * @param {String} [Flags = "a"] - The value to pass to the `Flags` parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/FileOpen.htm `FileOpen`}.
     * @param {Integer} [Offset := 0] - The content that is written to file begins at this byte
     * offset from the start of the view.
     * @param {Integer} [Bytes] - If set, the number of bytes to write to the file. If unset, the
     * entire view after `Offset` is written to file.
     * @param {String} [Encoding] - If set, the encoding to use when opening the file. If unset,
     * the file is opened using the same encoding as this file mapping object.
     * @returns {File} - The native AHK `File` object that was created. The file object is already
     * closed, but can be re-opened using the `File.Open` method. Remember that if you set `Flags`
     * with a value that does not support reading, calling `File.Read` returns an empty string; your
     * code would need to create a new `File` object to read the content, or use `FileRead`, or
     * create a {@link FileMapping} object setting `Options.Path`.
     */
    ToFile(Path, Flags := 'a', Offset := 0, Bytes?, Encoding?) {
        f := FileOpen(Path, Flags, Encoding ?? this.Encoding)
        f.RawWrite(this.Ptr + Offset, Bytes ?? this.Size - Offset)
        f.Close()
        return f
    }
    /**
     * @description - Sets the file's last access time and last write time to the current time.
     *
     * See {@link https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-setfiletime}.
     *
     * @example
     * fm := FileMapping({ Path: "C:\users\shared\MyFile.docx" })
     * fm.Open()
     * fm.UpdateFileTime() ; Sets the last access time and last write time to the current time.
     * fm.Close()
     * @
     *
     * @returns {FileMapping_FileTime} - The object used to update the file's time.
     *
     * @throws {Error} - "The `FileMapping` object is not associated with a file."
     * @throws {OSError} - If `SetFileTime` results in an error, `OSError()` is called.
     */
    UpdateFileTime() {
        if this.hFile <= 0 {
            throw Error('The ``FileMapping`` object is not associated with a file.')
        }
        ft := FileMapping_SystemTime().ToFileTime()
        if DllCall(
            g_kernel32_SetFileTime
          , 'ptr', this.hFile
          , 'ptr', 0
          , 'ptr', ft
          , 'ptr', ft
          , 'int'
        ) {
            return ft
        } else {
            throw OSError()
        }
    }
    /**
     * @description - Writes a string to the current position of the file mapping object, and advances
     * the file pointer.
     *
     * If the current view is insufficient to receive the entire string, and if the size of the file
     * mapping object is sufficient to receive the entire string, {@link FileMapping.Prototype.Write}
     * closes the current view and opens a view large enough to receive the string, rounded up to the
     * next page or to the end of the file mapping object, whichever is lesser.
     *
     * If the size of the file mapping object is insufficient to receive the entire string, the behavior
     * of {@link FileMapping.Prototype.Write} is determined by parameter `AdjustMaxSize`.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * @param {String} String - The string to write.
     *
     * @param {Boolean} [AdjustMaxSize = false] - Understand that if the file mapping object is opened
     * in more than one process, you must not set `AdjustMaxSize` to true unless all other processes
     * call `CloseHandle` to close their handle.
     *
     * If true, and if performing the write operation would exceed the file mapping object's maximum
     * size, the file mapping object is closed and re-opened with a new maximum size to accommodate
     * the data (the original maximum size is doubled until a sufficient size is reached). A view is
     * then opened that is sufficient to receive the entire data, rounded up to the next page or to
     * the end of the file mapping object, whichever is lesser.
     *
     * If false, and if performing the write operation would exceed the file mapping object's maximum
     * size, the data is not copied and the function returns 0.
     *
     * @param {Boolean} [Terminate = false] - If true, {@link FileMapping.Prototype.Write} inserts
     * a null terminator at the end of the written string. The file pointer will be positioned just
     * before the null terminator, so the next write operation overwrites the null terminator.
     *
     * @returns {Integer} - The number of bytes copied.
     */
    Write(Str, AdjustMaxSize := false, Terminate := false) {
        offset := this.__Pos
        bytes := StrLen(Str) * this.BytesPerChar
        if bytes + offset > this.Size {
            if this.ViewStart + offset + bytes > this.MaxSize {
                if AdjustMaxSize {
                    this.AdjustMaxSize(bytes)
                } else {
                    return 0
                }
            } else {
                this.ExtendView(bytes)
            }
        }
        this.__Pos += bytes
        if Terminate {
            return StrPut(Str, this.Ptr + offset, this.Encoding)
        } else {
            return StrPut(Str, this.Ptr + offset, StrLen(Str), this.Encoding)
        }
	}
    /**
     * @description - Writes a string to the current position of the file mapping object, and advances
     * the file pointer.
     *
     * This method is the same as {@link FileMapping.Prototype.Write} except parameter `Str` is a
     * `VarRef`.
     *
     * This never writes a null terminator. Call {@link FileMapping.Prototype.Terminate} to add a
     * null terminator.
     *
     * If the current view is insufficient to receive the entire string, and if the size of the file
     * mapping object is sufficient to receive the entire string, {@link FileMapping.Prototype.Write}
     * closes the current view and opens a view large enough to receive the string, rounded up to the
     * next page or to the end of the file mapping object, whichever is lesser.
     *
     * If the size of the file mapping object is insufficient to receive the entire string, the behavior
     * of {@link FileMapping.Prototype.Write} is determined by parameter `AdjustMaxSize`.
     *
     * Remember that, if the file mapping object is backed by a file, you must call
     * {@link FileMapping.Prototype.Flush} to write the changes to the file on disk.
     *
     * @param {VarRef} Str - A variable containing the string to write.
     *
     * @param {Boolean} [AdjustMaxSize = false] - Understand that if the file mapping object is opened
     * in more than one process, you must not set `AdjustMaxSize` to true unless all other processes
     * call `CloseHandle` to close their handle.
     *
     * If true, and if performing the write operation would exceed the file mapping object's maximum
     * size, the file mapping object is closed and re-opened with a new maximum size to accommodate
     * the data (the original maximum size is doubled until a sufficient size is reached). A view is
     * then opened that is sufficient to receive the entire data, rounded up to the next page or to
     * the end of the file mapping object, whichever is lesser.
     *
     * If false, and if performing the write operation would exceed the file mapping object's maximum
     * size, the data is not copied and the function returns 0.
     *
     * @param {Boolean} [Terminate = false] - If true, {@link FileMapping.Prototype.Write} inserts
     * a null terminator at the end of the written string. The file pointer will be positioned just
     * before the null terminator, so the next write operation overwrites the null terminator.
     *
     * @returns {Integer} - The number of bytes copied.
     */
    Write2(&Str, AdjustMaxSize := false, Terminate := false) {
        offset := this.__Pos
        bytes := StrLen(Str) * this.BytesPerChar
        if bytes + offset > this.Size {
            if this.ViewStart + offset + bytes > this.MaxSize {
                if AdjustMaxSize {
                    this.AdjustMaxSize(bytes)
                } else {
                    return 0
                }
            } else {
                this.ExtendView(bytes)
            }
        }
        this.__Pos += bytes
        if Terminate {
            return StrPut(Str, this.Ptr + offset, this.Encoding)
        } else {
            return StrPut(Str, this.Ptr + offset, StrLen(Str), this.Encoding)
        }
	}
    __Delete() {
        this.Close()
        ObjPtrAddRef(this)
        if FileMapping.Collection.Has(this.idFileMapping) {
            FileMapping.Collection.Delete(this.idFileMapping)
        } else {
            OutputDebug('The ``FileMapping`` object has already been deleted from the collection.'
            ' This will cause a memory leak. Do not manually call ``FileMapping.Collection.Delete()``.`n')
        }
    }
    /**
     * Returns an enumerator. When calling the {@link FileMapping} object in a `for` loop, your code
     * can include up to four parameters in the loop. The variables receive the following values,
     * in this order:
     * 1. The view's starting page number.
     * 2. The byte offset from the beginning of the file mapping object to the start of the active view.
     * 3. The size of the active view. This will be the same value for all iteration except
     *    possibly the last.
     * 4. If the view is opened to the last page, 1. Else, 0.
     *
     * Whenever {@link FileMapping.Prototype.__Enum} is called, it always closes the active view
     * (if a view is active) and starts the enumeration at the beginning of the file mapping object.
     * If your code has called {@link FileMapping.Prototype.SetEnumPageCount} or has set property
     * {@link FileMapping#EnumPageCount}, that number of pages will be included in the view for
     * each iteration. If your code has not set {@link FileMapping#EnumPageCount}, then the size
     * of the current view (rounded up to the next page if necessary) is used as the page count. If
     * there is not an active view, then the page count used is 1.
     *
     * The enumerator does not return the {@link FileMapping} object to its original state (i.e.
     * when the enumerator completes, the active view is the same as the view during the last iteration
     * of the enumerator).
     */
    __Enum(*) {
        return FileMapping.Enumerator(this)
    }

    /**
     * Returns 1 if the file pointer is at the end of the view.
     * @instance
     * @member {FileMapping}
     * @type {Boolean}
     */
    AtEoV => this.__Pos == this.Size
    /**
     * Returns 1 if the file pointer is at the end of the file mapping object.
     * @instance
     * @member {FileMapping}
     * @type {Boolean}
     */
    AtEoF => this.__Pos + this.ViewStart = this.MaxSize
    /**
     * Gets or sets the `dwCreationDisposition` value passed to `CreateFileW` when
     * {@link FileMapping.Prototype.OpenFile} is called. If your code sets the value, and if a file
     * mapping object has already been created, your code will need to close the current file mapping
     * object and close the opened file, then re-open the file and file mapping object.
     *
     * See the description of `Options.dwCreationDisposition` in the parameter hint above
     * {@link FileMapping.Prototype.__New} for more information.
     *
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    dwCreationDisposition {
        Get => this.Options.dwCreationDisposition
        Set => this.Options.dwCreationDisposition := Value
    }
    /**
     * Gets or sets the `dwDesiredAccess` value passed to `CreateFileW` when
     * {@link FileMapping.Prototype.OpenFile} is called. If your code sets the value, and if a file
     * mapping object has already been created, your code will need to close the current file mapping
     * object and close the opened file, then re-open the file and file mapping object.
     *
     * See the description of `Options.dwDesiredAccess_file` in the parameter hint above
     * {@link FileMapping.Prototype.__New} for more information.
     *
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    dwDesiredAccess_file {
        Get => this.Options.dwDesiredAccess_file
        Set => this.Options.dwDesiredAccess_file := Value
    }
    /**
     * Gets or sets the `dwDesiredAccess` value passed to `CreateFileMappingW` when
     * {@link FileMapping.Prototype.OpenMapping} is called. If your code sets the value, and if a file
     * mapping object has already been created, your code will need to close the current file mapping
     * object then re-open a file mapping object for it to reflect the new value.
     *
     * See the description of `Options.dwDesiredAccess_view` in the parameter hint above
     * {@link FileMapping.Prototype.__New} for more information.
     *
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    dwDesiredAccess_view {
        Get => this.Options.dwDesiredAccess_view
        Set => this.Options.dwDesiredAccess_view := Value
    }
    /**
     * Gets or sets the `dwFlagsAndAttributes` value passed to `CreateFileW` when
     * {@link FileMapping.Prototype.OpenFile} is called. If your code sets the value, and if a file
     * mapping object has already been created, your code will need to close the current file mapping
     * object and close the opened file, then re-open the file and file mapping object.
     *
     * See the description of `Options.dwFlagsAndAttributes` in the parameter hint above
     * {@link FileMapping.Prototype.__New} for more information.
     *
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    dwFlagsAndAttributes {
        Get => this.Options.dwFlagsAndAttributes
        Set => this.Options.dwFlagsAndAttributes := Value
    }
    /**
     * Returns the high word of `Options.MaxSize`.
     * @member {FileMapping}
     * @instance
     * @type {Integer}
     */
    dwMaximumSizeHigh => Integer(this.Options.MaxSize) >> 32
    /**
     * Returns the low word of `Options.MaxSize`.
     * @member {FileMapping}
     * @instance
     * @type {Integer}
     */
    dwMaximumSizeLow => Integer(this.Options.MaxSize) & 0xFFFFFFFF
    /**
     * Gets or sets the `dwShareMode` value passed to `CreateFileW` when
     * {@link FileMapping.Prototype.OpenFile} is called. If your code sets the value, and if a file
     * mapping object has already been created, your code will need to close the current file mapping
     * object and close the opened file, then re-open the file and file mapping object.
     *
     * See the description of `Options.dwShareMode` in the parameter hint above
     * {@link FileMapping.Prototype.__New} for more information.
     *
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    dwShareMode {
        Get => this.Options.dwShareMode
        Set => this.Options.dwShareMode := Value
    }
    /**
     * Gets or sets the file encoding used when reading from and writing to a view. When your code
     * sets this property, the setter calls {@link FileMapping.Prototype.SetEncoding} which change
     * the value of property {@link FileMapping#BytesPerChar} if necessary.
     *
     * @instance
     * @member {FileMapping}
     * @type {String}
     */
    Encoding {
        Get => this.Options.Encoding
        Set => this.SetEncoding(Value)
    }
    /**
     * Gets or sets the `flProtect` value passed to `CreateFileMappingW` when
     * {@link FileMapping.Prototype.OpenMapping} is called. If your code sets the value, and if a file
     * mapping object has already been created, your code will need to close the current file mapping
     * object then re-open a file mapping object for it to reflect the new value.
     *
     * See the description of `Options.flProtect` in the parameter hint above
     * {@link FileMapping.Prototype.__New} for more information.
     *
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    flProtect {
        Get => this.Options.flProtect
        Set => this.Options.flProtect := Value
    }
    /**
     * Gets or sets the `hTemplateFile` value passed to `CreateFileW` when
     * {@link FileMapping.Prototype.OpenFile} is called. If your code sets the value, and if a file
     * mapping object has already been created, your code will need to close the current file mapping
     * object and close the opened file, then re-open the file and file mapping object.
     *
     * See the description of `Options.hTemplateFile` in the parameter hint above
     * {@link FileMapping.Prototype.__New} for more information.
     *
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    hTemplateFile {
        Get => this.Options.hTemplateFile
        Set => this.Options.hTemplateFile := Value
    }
    /**
     * Returns the number of bytes of the last page in the file mapping object.
     * @member {FileMapping}
     * @instance
     * @type {Integer}
     */
    LastPageSize => Mod(this.MaxSize, FileMapping_VirtualMemoryGranularity)
    /**
     * Gets or sets the `lpFileMappingAttributes` value passed to `CreateFileMappingW` when
     * {@link FileMapping.Prototype.OpenMapping} is called. If your code sets the value, and if a file
     * mapping object has already been created, your code will need to close the current file mapping
     * object then re-open a file mapping object for it to reflect the new value.
     *
     * See the description of `Options.lpFileMappingAttributes` in the parameter hint above
     * {@link FileMapping.Prototype.__New} for more information.
     *
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    lpFileMappingAttributes {
        Get => this.Options.lpFileMappingAttributes
        Set => this.Options.lpFileMappingAttributes := Value
    }
    /**
     * Gets or sets the `lpSecurityAttributes` value passed to `CreateFileW` when
     * {@link FileMapping.Prototype.OpenFile} is called. If your code sets the value, and if a file
     * mapping object has already been created, your code will need to close the current file mapping
     * object and close the opened file, then re-open the file and file mapping object.
     *
     * See the description of `Options.lpSecurityAttributes` in the parameter hint above
     * {@link FileMapping.Prototype.__New} for more information.
     *
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    lpSecurityAttributes {
        Get => this.Options.lpSecurityAttributes
        Set => this.Options.lpSecurityAttributes := Value
    }
    /**
     * Gets or sets the maximum size used when creating a file mapping object.
     *
     * Changing the value of {@link FileMapping.Prototype.MaxSize} while a file mapping object is
     * currently active will not change the maximum size recognized by the system for the file mapping
     * object, but it will likely influence the behavior of any methods that use the property value
     * in its calculations, of which there are many. This can result in unexpected behavior or critical
     * errors. It is best not to set the property when a file mapping object is currently active.
     * Call {@link FileMapping.Prototype.Reload} to seamlessly close an object and reopen one with
     * a new maximum size.
     *
     * See the description of `Options.MaxSize` in the parameter hint above {@link FileMapping.Prototype.__New}
     * for more information.
     *
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    MaxSize {
        Get => this.Options.MaxSize
        Set => this.Options.MaxSize := Value
    }
    /**
     * Gets or sets the name used when creating a file mapping object. If your code sets the name,
     * and if a file mapping object has already been created, your code will need to close the
     * current file mapping object and re-open a new one to obtain a file mapping object with the
     * name.
     *
     * See the description of `Options.Name` in the parameter hint above {@link FileMapping.Prototype.__New}
     * for more information.
     *
     * @instance
     * @member {FileMapping}
     * @type {String}
     */
    Name {
        Get => this.Options.Name
        Set => this.SetName(Value)
    }
    /**
     * Returns 1 if {@link FileMapping.Prototype.SetOnExitCallback} has been called to set the `OnExit` callback.
     * Returns 0 otherwise. Set the property with an integer to call {@link FileMapping.Prototype.SetOnExitCallback},
     * passing the value to the `AddRemove` parameter of `OnExit`.
     * @member {FileMapping}
     * @instance
     * @type {Integer}
     */
    OnExitActive {
        Get => this.__OnExitActive
        Set => this.SetOnExitCallback(Value)
    }
    /**
     * Returns 1 if the view is currently opened to the last page.
     * @instance
     * @member {FileMapping}
     * @type {Boolean}
     */
    OnLastPage => this.ViewEnd = this.MaxSize
    /**
     * Returns {@link FileMapping#Size} / {@link FileMapping_VirtualMemoryGranularity},
     * which represents the size of the current view in pages.
     * @instance
     * @member {FileMapping}
     * @type {Float}
     */
    Pages => this.Size / FileMapping_VirtualMemoryGranularity
    /**
     * Gets or sets the path to a file to associate with the file mapping object. If your code
     * sets the path, and if a file mapping object has already been created, your code will need
     * to close the current file mapping object and re-open a new one to obtain a file mapping
     * object backed by the file.
     * @instance
     * @member {FileMapping}
     * @type {String}
     */
    Path {
        Get => this.Options.Path
        Set => this.Options.Path := Value
    }
    /**
     * Gets or set the file pointer position. This is used and adjusted by the following methods:
     * - {@link FileMapping.ReadPos}
     * - {@link FileMapping.ReadPos2}
     * - {@link FileMapping.WritePos}
     * - {@link FileMapping.WritePos2}
     * - {@link FileMapping.TerminatePos}
     *
     * This is adjusted by the following methods:
     * - {@link FileMapping.Prototype.Close}
     * - {@link FileMapping.Prototype.CloseView}
     * - {@link FileMapping.Prototype.OpenView}
     * - {@link FileMapping.Prototype.OpenViewP}
     * - {@link FileMapping.Prototype.Reload}
     *
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    Pos {
        Get => Integer(this.__Pos)
        Set {
            if Value < 0 {
                if this.Size + Value < 0 {
                    _Throw()
                }
                this.__Pos := Integer(this.Size + Value)
            } else {
                if Value > this.Size {
                    _Throw()
                }
                this.__Pos := Integer(Value)
            }
            _Throw() {
                throw ValueError('The requested position is out of range.', , Value)
            }
        }
    }
    /**
     * Gets or sets the the option `Options.SetOnExit`. Setting this option to a nonzero value does
     * not automatically call {@link FileMapping.Prototype.SetOnExitCallback}; this option determines
     * whether or not the built-in `OnExit` callback is toggled whenever a file / file mapping object
     * is created or closed.
     *
     * See the description of `Options.SetOnExit` in the parameter hint above
     * {@link FileMapping.Prototype.__New} for more information.
     *
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    SetOnExit {
        Get => this.Options.SetOnExit
        Set => this.Options.SetOnExit := Value
    }
    /**
     * Returns {@link FileMapping.Prototype.MaxSize} / {@link FileMapping_VirtualMemoryGranularity},
     * which represents the maximum size of the file mapping object in pages.
     * @instance
     * @member {FileMapping}
     * @type {Float}
     */
    TotalPages => this.MaxSize / FileMapping_VirtualMemoryGranularity
    /**
     * Gets or set the file pointer position.
     * @instance
     * @member {FileMapping}
     * @type {Integer}
     */
    TotalPos => this.ViewStart + this.__Pos
    /**
     * Returns the byte offset from the beginning of the file mapping object to the end of the active view.
     * @member {FileMapping}
     * @instance
     * @type {Integer}
     */
    ViewEnd => this.ViewStart + this.Size
    /**
     * Returns the byte offset from the beginning of the file mapping object to the start of the active view.
     * @member {FileMapping}
     * @instance
     * @type {Integer}
     */
    ViewStart => this.Page * FileMapping_VirtualMemoryGranularity

    class Options {
        static __New() {
            this.DeleteProp('__New')
            FileMapping_SetConstants()
            proto := this.Prototype

            proto.Path :=
            proto.Name :=
            ''

            proto.dwShareMode := FILE_SHARE_WRITE | FILE_SHARE_READ
            proto.dwCreationDisposition := OPEN_EXISTING
            proto.dwFlagsAndAttributes := FILE_ATTRIBUTE_NORMAL
            proto.dwDesiredAccess_file := GENERIC_READWRITE
            proto.hTemplateFile := 0
            proto.lpSecurityAttributes := 0

            proto.flProtect := PAGE_READWRITE
            proto.lpFileMappingAttributes := 0
            proto.dwDesiredAccess_view := FILE_MAP_ALL_ACCESS

            proto.Encoding := 'utf-16'
            proto.SetOnExit := true
            proto.MaxSize := 0
        }
        __New(Options?) {
            if IsSet(Options) {
                for prop in FileMapping.Options.Prototype.OwnProps() {
                    if HasProp(Options, prop) {
                        this.%prop% := Options.%prop%
                    }
                }
                if this.HasOwnProp('__Class') {
                    this.DeleteProp('__Class')
                }
            }
        }
    }

    class Enumerator {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.Page :=
            proto.Flag_Complete :=
            0
        }
        __New(fileMappingObj) {
            this.idFileMapping := fileMappingObj.idFileMapping
            if fileMappingObj.EnumPageCount {
                this.EnumPageCount := fileMappingObj.EnumPageCount
            } else if fileMappingObj.Size {
                this.EnumPageCount := Ceil(fileMappingObj.Size / FileMapping_VirtualMemoryGranularity)
            } else {
                this.EnumPageCount := 1
            }
            this.Page := -this.EnumPageCount
            this.OriginalPage := fileMappingObj.Page
            this.OriginalSize := fileMappingObj.Size
            this.OriginalPos := fileMappingObj.__Pos
            fileMappingObj.CloseView()
        }
        Call(&Page?, &ByteOffset?, &ByteLength?, &IsLastIteration?) {
            if this.Flag_Complete {
                fm := this.FileMapping
                fm.CloseView()
                fm.OpenView(this.OriginalPage * FileMapping_VirtualMemoryGranularity, this.OriginalSize)
                fm.Pos := this.OriginalPos
                return 0
            }
            this.Page += this.EnumPageCount
            Page := this.Page
            ByteOffset := Page * FileMapping_VirtualMemoryGranularity
            ByteLength := this.FileMapping.OpenViewP(this.Page, this.EnumPageCount)
            if IsLastIteration := this.FileMapping.OnLastPage {
                this.Flag_Complete := 1
            }
            return 1
        }
        FileMapping => FileMapping._Get(this.idFileMapping)
    }
}

class FileMapping_SystemTime {
    static __New() {
        this.DeleteProp('__New')
        FileMapping_SystemTime_SetConstants()
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; SizeType      Symbol           OffsetPadding
        2 +   ; WORD    wYear            0
        2 +   ; WORD    wMonth           2
        2 +   ; WORD    wDayOfWeek       4
        2 +   ; WORD    wDay             6
        2 +   ; WORD    wHour            8
        2 +   ; WORD    wMinute          10
        2 +   ; WORD    wSecond          12
        2     ; WORD    wMilliseconds    14
        proto.offset_wYear          := 0
        proto.offset_wMonth         := 2
        proto.offset_wDayOfWeek     := 4
        proto.offset_wDay           := 6
        proto.offset_wHour          := 8
        proto.offset_wMinute        := 10
        proto.offset_wSecond        := 12
        proto.offset_wMilliseconds  := 14
    }
    /**
     * @classdesc - An AHK wrapper around the SYSTEMTIME structure.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-systemtime}
     *
     * @param {Boolean} [GetSystemTime = true] - If true, calls `GetSystemTime` to fill the structure.
     */
    __New(GetSystemTime := true) {
        this.Buffer := Buffer(this.cbSizeInstance)
        if GetSystemTime {
            this()
        }
    }
    /**
     * @description - Calls `GetSystemTime`.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-getsystemtime}
     */
    Call() {
        DllCall(g_kernel32_GetSystemTime, 'ptr', this)
    }
    /**
     * @description - Converts the SYSTEMTIME structure to a FILETIME structure.
     *
     * @param {Buffer|FileTime} [target] - If set, the `Buffer` or {@link FileMapping_FileTime} object to receive
     * the FILETIME structure. If unset, a {@link FileMapping_FileTime} object is created.
     *
     * @returns {FileTime}
     */
    ToFileTime(target?) {
        if !IsSet(target) {
            target := FileMapping_FileTime()
        }
        if !DllCall(
            g_kernel32_SystemTimeToFileTime
          , 'ptr', this
          , 'ptr', target
          , 'int'
        ) {
            throw OSError()
        }
        return target
    }
    wYear {
        Get => NumGet(this.Buffer, this.offset_wYear, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wYear)
        }
    }
    wMonth {
        Get => NumGet(this.Buffer, this.offset_wMonth, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wMonth)
        }
    }
    wDayOfWeek {
        Get => NumGet(this.Buffer, this.offset_wDayOfWeek, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wDayOfWeek)
        }
    }
    wDay {
        Get => NumGet(this.Buffer, this.offset_wDay, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wDay)
        }
    }
    wHour {
        Get => NumGet(this.Buffer, this.offset_wHour, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wHour)
        }
    }
    wMinute {
        Get => NumGet(this.Buffer, this.offset_wMinute, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wMinute)
        }
    }
    wSecond {
        Get => NumGet(this.Buffer, this.offset_wSecond, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wSecond)
        }
    }
    wMilliseconds {
        Get => NumGet(this.Buffer, this.offset_wMilliseconds, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wMilliseconds)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
    Timestamp => Format('{}{:02}{:02}{:02}{:02}{:02}', this.wYear, this.wMonth, this.wDay, this.wHour, this.wMinute, this.wSecond)
}

class FileMapping_FileTime {
    static __New() {
        this.DeleteProp('__New')
        FileMapping_SystemTime_SetConstants()
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; SizeType       Symbol            OffsetPadding
        4 +   ; DWORD    dwLowDateTime     0
        4     ; DWORD    dwHighDateTime    4
        proto.offset_dwLowDateTime   := 0
        proto.offset_dwHighDateTime  := 4
    }
    /**
     * @classdesc - An AHK wrapper around the FILETIME structure.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-filetime}
     */
    __New() {
        this.Buffer := Buffer(this.cbSizeInstance)
    }
    /**
     * @description - Converts the FILETIME value to a string representation of the uint64, which
     * is a 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 (UTC).
     */
    Call() {
        buf := Buffer(40, 0)
        DllCall(
            g_msvcrt__ui64tow
          , 'uint64', (this.dwHighDateTime << 32) | this.dwLowDateTime
          , 'ptr', buf
          , 'uint', 10
          , 'cdecl'
        )
        return StrGet(buf)
    }
    /**
     * @description - Converts the FILETIME structure to a SYSTEMTIME structure.
     * @param {Buffer|FileMapping_SystemTime} [target] - Either a `Buffer` or {@link FileMapping_SystemTime}
     * object to receive the SYSTEMTIME structure. If unset, a {@link FileMapping_SystemTime} object
     * is created.
     * @returns {FileMapping_SystemTime}
     */
    ToSystemTime(target?) {
        if !IsSet(target) {
            target := FileMapping_SystemTime()
        }
        if !DllCall(
            g_kernel32_FileTimeToSystemTime
          , 'ptr', this
          , 'ptr', target
          , 'int'
        ) {
            throw OSError()
        }
        return target
    }
    dwLowDateTime {
        Get => NumGet(this.Buffer, this.offset_dwLowDateTime, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwLowDateTime)
        }
    }
    dwHighDateTime {
        Get => NumGet(this.Buffer, this.offset_dwHighDateTime, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwHighDateTime)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}

FileMapping_SystemTime_SetConstants(force := false) {
    global
    if IsSet(FileMapping_SystemTime_constants_set) && !force {
        return
    }

    local hMod := DllCall('GetModuleHandleW', 'wstr', 'kernel32', 'ptr')
    g_kernel32_FileTimeToSystemTime := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'FileTimeToSystemTime', 'ptr')
    g_kernel32_GetSystemTime := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetSystemTime', 'ptr')
    g_kernel32_SetFileTime := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'SetFileTime', 'ptr')
    g_kernel32_SystemTimeToFileTime := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'SystemTimeToFileTime', 'ptr')
    g_msvcrt__ui64tow := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandleW', 'wstr', 'msvcrt', 'ptr'), 'astr', '_ui64tow', 'ptr')

    FileMapping_SystemTime_constants_set := true
}

FileMapping_SetConstants(force := false) {
    global
    if IsSet(FileMapping_constants_set) && !force {
        return
    }

    local hMod := DllCall('GetModuleHandleW', 'wstr', 'msvcrt', 'ptr')
    g_msvcrt_memmove := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'memmove', 'ptr')
    g_msvcrt_wmemchr := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'wmemchr', 'ptr')
    local hMod := DllCall('GetModuleHandleW', 'wstr', 'kernel32', 'ptr')
    g_kernel32_CloseHandle := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'CloseHandle', 'ptr')
    g_kernel32_CreateFileMappingW := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'CreateFileMappingW', 'ptr')
    g_kernel32_CreateFileW := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'CreateFileW', 'ptr')
    g_kernel32_FlushFileBuffers := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'FlushFileBuffers', 'ptr')
    g_kernel32_FlushViewOfFile := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'FlushViewOfFile', 'ptr')
    g_kernel32_GetFileSize := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetFileSize', 'ptr')
    g_kernel32_MapViewOfFile := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'MapViewOfFile', 'ptr')
    g_kernel32_UnmapViewOfFile := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'UnmapViewOfFile', 'ptr')

    local sysInfo := Buffer(36 + A_ptrSize * 2)
    DllCall('GetSystemInfo', 'ptr', sysInfo)
    FileMapping_VirtualMemoryGranularity := NumGet(sysInfo, 24 + A_ptrSize * 2, 'uint')
    FileMapping_LargePageMinimum := DllCall('GetLargePageMinimum')

    FILEMAPPING_UTF8_BOM := [ 0xEF, 0xBB, 0xBF ]
    FILEMAPPING_UTF16LE_BOM := [ 0xFF, 0xFE ]
    ; AHK doesn't seem to allow cp1201 encoding
    ; FILEMAPPING_UTF16BE_BOM := [ 0xFE, 0xFF ]

    INVALID_HANDLE_VALUE := -1

    ; https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-samr/262970b7-cd4a-41f4-8c4d-5a27f0092aaa

    GENERIC_ALL := 0x10000000
    GENERIC_EXECUTE := 0x20000000
    GENERIC_WRITE := 0x40000000
    GENERIC_READ := 0x80000000
    GENERIC_READWRITE := 0x80000000 | 0x40000000

    ; https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-mapviewoffile

    FILE_MAP_ALL_ACCESS := 0xF001F
    FILE_MAP_READ := 0x0004
    FILE_MAP_WRITE := 0x0002
    FILE_MAP_COPY := 0x1
    FILE_MAP_EXECUTE := 0x0008
    FILE_MAP_LARGE_PAGES := 0x20000000
    FILE_MAP_TARGETS_INVALID := 0x40000000

    ; https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilew

    ; Enables subsequent open operations on a file or device to request delete access.
    ; Otherwise, no process can open the file or device if it requests delete access.
    ; If this flag is not specified, but the file or device has been opened for delete access, the function fails.
    ; Note Delete access allows both delete and rename operations.
    FILE_SHARE_DELETE := 0x00000004

    ; Enables subsequent open operations on a file or device to request read access.
    ; Otherwise, no process can open the file or device if it requests read access.
    ; If this flag is not specified, but the file or device has been opened for read access, the function fails.
    FILE_SHARE_READ := 0x00000001

    ; Enables subsequent open operations on a file or device to request write access.
    ; Otherwise, no process can open the file or device if it requests write access.
    ; If this flag is not specified, but the file or device has been opened for write access or has a file mapping with write access, the function fails.
    FILE_SHARE_WRITE := 0x00000002

    ; Creates a new file, always.
    ; If the specified file exists and is writable, the function truncates the file, the function succeeds, and last-error code is set to ERROR_ALREADY_EXISTS (183).
    ; If the specified file does not exist and is a valid path, a new file is created, the function succeeds, and the last-error code is set to zero.
    ; For more information, see the Remarks section of this topic.
    CREATE_ALWAYS := 2

    ; Creates a new file, only if it does not already exist.
    ; If the specified file exists, the function fails and the last-error code is set to ERROR_FILE_EXISTS (80).
    ; If the specified file does not exist and is a valid path to a writable location, a new file is created.
    CREATE_NEW := 1

    ; Opens a file, always.
    ; If the specified file exists, the function succeeds and the last-error code is set to ERROR_ALREADY_EXISTS (183).
    ; If the specified file does not exist and is a valid path to a writable location, the function creates a file and the last-error code is set to zero.
    OPEN_ALWAYS := 4

    ; Opens a file or device, only if it exists.
    ; If the specified file or device does not exist, the function fails and the last-error code is set to ERROR_FILE_NOT_FOUND (2).
    ; For more information about devices, see the Remarks section.
    OPEN_EXISTING := 3

    ; Opens a file and truncates it so that its size is zero bytes, only if it exists.
    ; If the specified file does not exist, the function fails and the last-error code is set to ERROR_FILE_NOT_FOUND (2).
    ; The calling process must open the file with the GENERIC_WRITE bit set as part of the dwDesiredAccess parameter.
    TRUNCATE_EXISTING := 5

    ; The file should be archived. Applications use this attribute to mark files for backup or removal.
    FILE_ATTRIBUTE_ARCHIVE := 0x20

    ; The file or directory is encrypted. For a file, this means that all data in the file is
    ; encrypted. For a directory, this means that encryption is the default for newly created files
    ; and subdirectories. For more information, see File Encryption.
    ; This flag has no effect if FILE_ATTRIBUTE_SYSTEM is also specified.
    ; This flag is not supported on Home, Home Premium, Starter, or ARM editions of Windows.
    FILE_ATTRIBUTE_ENCRYPTED := 0x4000

    ; The file is hidden. Do not include it in an ordinary directory listing.
    FILE_ATTRIBUTE_HIDDEN := 0x2

    ; The file does not have other attributes set. This attribute is valid only if used alone.
    FILE_ATTRIBUTE_NORMAL := 0x80

    ; The data of a file is not immediately available. This attribute indicates that file data is
    ; physically moved to offline storage. This attribute is used by Remote Storage, the hierarchical
    ; storage management software. Applications should not arbitrarily change this attribute.
    FILE_ATTRIBUTE_OFFLINE := 0x1000

    ; The file is read only. Applications can read the file, but cannot write to or delete it.
    FILE_ATTRIBUTE_READONLY := 0x1

    ; The file is part of or used exclusively by an operating system.
    FILE_ATTRIBUTE_SYSTEM := 0x4

    ; The file is being used for temporary storage.
    ; For more information, see the Caching Behavior section of this topic.
    FILE_ATTRIBUTE_TEMPORARY := 0x100

    ; The file is being opened or created for a backup or restore operation. The system ensures that
    ; the calling process overrides file security checks when the process has SE_BACKUP_NAME and
    ; SE_RESTORE_NAME privileges. For more information, see Changing Privileges in a Token.
    ; You must set this flag to obtain a handle to a directory. A directory handle can be passed to
    ; some functions instead of a file handle. For more information, see the Remarks section.
    FILE_FLAG_BACKUP_SEMANTICS := 0x02000000

    ; The file is to be deleted immediately after all of its handles are closed, which includes the
    ; specified handle and any other open or duplicated handles.
    ; If there are existing open handles to a file, the call fails unless they were all opened with
    ; the FILE_SHARE_DELETE share mode.
    ; Subsequent open requests for the file fail, unless the FILE_SHARE_DELETE share mode is specified.
    FILE_FLAG_DELETE_ON_CLOSE := 0x04000000

    ; The file or device is being opened with no system caching for data reads and writes. This flag
    ; does not affect hard disk caching or memory mapped files.
    ; There are strict requirements for successfully working with files opened with CreateFile using
    ; the FILE_FLAG_NO_BUFFERING flag, for details see File Buffering.
    FILE_FLAG_NO_BUFFERING := 0x20000000

    ; The file data is requested, but it should continue to be located in remote storage. It should
    ; not be transported back to local storage. This flag is for use by remote storage systems.
    FILE_FLAG_OPEN_NO_RECALL := 0x00100000

    ; Normal reparse point processing will not occur; CreateFile will attempt to open the reparse
    ; point. When a file is opened, a file handle is returned, whether or not the filter that controls
    ; the reparse point is operational.
    ; This flag cannot be used with the CREATE_ALWAYS flag.
    ; If the file is not a reparse point, then this flag is ignored.
    ; For more information, see the Remarks section.
    FILE_FLAG_OPEN_REPARSE_POINT := 0x00200000

    ; The file or device is being opened or created for asynchronous I/O.
    ; When subsequent I/O operations are completed on this handle, the event specified in the
    ; OVERLAPPED structure will be set to the signaled state.
    ; If this flag is specified, the file can be used for simultaneous read and write operations.
    ; If this flag is not specified, then I/O operations are serialized, even if the calls to the
    ; read and write functions specify an OVERLAPPED structure.
    ; For information about considerations when using a file handle created with this flag, see the
    ; Synchronous and Asynchronous I/O Handles section of this topic.
    FILE_FLAG_OVERLAPPED := 0x40000000

    ; Access will occur according to POSIX rules. This includes allowing multiple files with names,
    ; differing only in case, for file systems that support that naming. Use care when using this
    ; option, because files created with this flag may not be accessible by applications that are
    ; written for MS-DOS or 16-bit Windows.
    FILE_FLAG_POSIX_SEMANTICS := 0x01000000

    ; Access is intended to be random. The system can use this as a hint to optimize file caching.
    ; This flag has no effect if the file system does not support cached I/O and FILE_FLAG_NO_BUFFERING.
    ; For more information, see the Caching Behavior section of this topic.
    FILE_FLAG_RANDOM_ACCESS := 0x10000000

    ; The file or device is being opened with session awareness. If this flag is not specified,
    ; then per-session devices (such as a device using RemoteFX USB Redirection) cannot be opened
    ; by processes running in session 0. This flag has no effect for callers not in session 0. This
    ; flag is supported only on server editions of Windows.
    ; Windows Server 2008 R2 and Windows Server 2008: This flag is not supported before Windows Server 2012.
    FILE_FLAG_SESSION_AWARE := 0x00800000

    ; Access is intended to be sequential from beginning to end. The system can use this as a hint
    ; to optimize file caching.
    ; This flag should not be used if read-behind (that is, reverse scans) will be used.
    ; This flag has no effect if the file system does not support cached I/O and FILE_FLAG_NO_BUFFERING.
    ; For more information, see the Caching Behavior section of this topic.
    FILE_FLAG_SEQUENTIAL_SCAN := 0x08000000

    ; Write operations will not go through any intermediate cache, they will go directly to disk.
    ; For additional information, see the Caching Behavior section of this topic.
    FILE_FLAG_WRITE_THROUGH := 0x80000000


    ; https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-createfilemappingw

    ; Allows views to be mapped for read-only, copy-on-write, or execute access.
    ; The file handle specified by the hFile parameter must be created with the GENERIC_READ and GENERIC_EXECUTE access rights.
    ; Windows Server 2003 and Windows XP:  This value is not available until Windows XP with SP2 and Windows Server 2003 with SP1.
    PAGE_EXECUTE_READ := 0x20

    ; Allows views to be mapped for read-only, copy-on-write, read/write, or execute access.
    ; The file handle that the hFile parameter specifies must be created with the GENERIC_READ, GENERIC_WRITE, and GENERIC_EXECUTE access rights.
    ; Windows Server 2003 and Windows XP:  This value is not available until Windows XP with SP2 and Windows Server 2003 with SP1.
    PAGE_EXECUTE_READWRITE := 0x40

    ; Allows views to be mapped for read-only, copy-on-write, or execute access. This value is equivalent to PAGE_EXECUTE_READ.
    ; The file handle that the hFile parameter specifies must be created with the GENERIC_READ and GENERIC_EXECUTE access rights.
    ; Windows Vista:  This value is not available until Windows Vista with SP1.
    ; Windows Server 2003 and Windows XP:  This value is not supported.
    PAGE_EXECUTE_WRITECOPY := 0x80

    ; Allows views to be mapped for read-only or copy-on-write access. An attempt to write to a specific region results in an access violation.
    ; The file handle that the hFile parameter specifies must be created with the GENERIC_READ access right.
    PAGE_READONLY := 0x02

    ; Allows views to be mapped for read-only, copy-on-write, or read/write access.
    ; The file handle that the hFile parameter specifies must be created with the GENERIC_READ and GENERIC_WRITE access rights.
    PAGE_READWRITE := 0x04

    ; Allows views to be mapped for read-only or copy-on-write access. This value is equivalent to PAGE_READONLY.
    ; The file handle that the hFile parameter specifies must be created with the GENERIC_READ access right.
    PAGE_WRITECOPY := 0x08

    ; If the file mapping object is backed by the operating system paging file (the
    ; hfile parameter is INVALID_HANDLE_VALUE), specifies that
    ; when  a view of the file is mapped into a process address space, the entire range of pages is
	; committed  rather than reserved. The system must have enough committable pages to hold the entire
	; mapping. Otherwise,  CreateFileMapping fails.
    ; This attribute has no effect for file mapping objects that are backed by executable image files
	; or data files (the hfile parameter is a handle to a file).
    ; SEC_COMMIT cannot be combined with SEC_RESERVE.
    ; If no attribute is specified, SEC_COMMIT is assumed. However, SEC_COMMIT must be explicitly
	; specified when combining it with another SEC_ attribute that requires it.
    SEC_COMMIT := 0x8000000

    ; Specifies that the file that the  hFile parameter specifies is an executable  image file.
    ; The SEC_IMAGE attribute must be combined with a page protection value such as
    ; PAGE_READONLY. However, this page protection value has no effect on views of the
    ; executable image file. Page protection for views of an executable image file is determined by
	; the executable file itself.
    ; No other attributes are valid with SEC_IMAGE.
    SEC_IMAGE := 0x1000000

    ; Specifies that the file that the  hFile parameter specifies is an executable
    ; image file that will not be executed and the loaded image file will have no forced integrity checks run.
    ; Additionally, mapping a view of a file mapping object created with the
    ; SEC_IMAGE_NO_EXECUTE attribute will not invoke driver callbacks registered using
    ; the PsSetLoadImageNotifyRoutine
    ; kernel API.
    ; The SEC_IMAGE_NO_EXECUTE attribute must be combined with the
    ; PAGE_READONLY page protection value. No other attributes are valid with
    ; SEC_IMAGE_NO_EXECUTE.
    ; Windows Server2008R2, Windows7, Windows Server2008, WindowsVista, Windows Server2003 and WindowsXP:
	; This value is not supported before Windows Server2012 and Windows8.
    SEC_IMAGE_NO_EXECUTE := 0x11000000

    ; Enables large pages to be used for file mapping objects that are backed by the operating system
	; paging file (the hfile parameter is INVALID_HANDLE_VALUE). This attribute is not supported for
	; file mapping objects that are backed by executable image files or data files
    ; (the hFile parameter is a handle to an executable image or data file).
    ; The maximum size of the file mapping object must be a multiple of the minimum size of a large
	; page returned by the GetLargePageMinimum function. If it is not, CreateFileMapping fails. When
	; mapping a view of a file mapping object created with SEC_LARGE_PAGES, the base address and
    ; view size must also be multiples of the minimum large page size.
    ; SEC_LARGE_PAGES requires the SeLockMemoryPrivilege privilege to be enabled in the caller's token.
    ; If SEC_LARGE_PAGES is specified, SEC_COMMIT must also be specified.
    ; Windows Server2003: This value is not supported until Windows Server2003 with SP1.
    ; WindowsXP: This value is not supported.
    SEC_LARGE_PAGES := 0x80000000

    ; Sets all pages to be non-cacheable.
    ; Applications should not use this attribute except when
    ; explicitly required for a device. Using the interlocked functions with memory that is mapped with
    ; SEC_NOCACHE can result in an EXCEPTION_ILLEGAL_INSTRUCTION exception.
    ; SEC_NOCACHE requires either the SEC_RESERVE or SEC_COMMIT attribute to be set.
    SEC_NOCACHE := 0x10000000

    ; If the file mapping object is backed by the operating system paging file (the hfile parameter
	; is INVALID_HANDLE_VALUE), specifies that when a view of the file is mapped into a process
	; address space, the entire range of pages is reserved for later use by the process rather than
	; committed. Reserved pages can be committed in subsequent calls to the VirtualAlloc function.
	; After the pages are committed, they cannot be freed or decommitted with the VirtualFree function.
    ; This attribute has no effect for file mapping objects that are backed by executable image files or data
    ; files (the hfile parameter is a handle to a file).
	; SEC_RESERVE cannot be combined with SEC_COMMIT.
    SEC_RESERVE := 0x4000000

    ; Sets all pages to be write-combined. Applications should not use this attribute except when
    ; explicitly required for a device. Using the interlocked functions with memory that is mapped with
    ; SEC_WRITECOMBINE can result in an EXCEPTION_ILLEGAL_INSTRUCTION exception.
    ; SEC_WRITECOMBINE requires either the SEC_RESERVE or SEC_COMMIT attribute to be set.
    ; Windows Server 2003 and WindowsXP: This flag is not supported until WindowsVista.
    SEC_WRITECOMBINE := 0x40000000


    FileMapping_constants_set := true
}

/**
 * @description - Returns the result from multiplying the input by the system's virtual memory
 * granularity, which is considered by this library to be one page.
 * @param {Integer} Pages - The number of pages.
 * @returns {Integer} - Pages * FileMapping_VirtualMemoryGranularity
 */
FileMapping_PagesToBytes(Pages) {
    return Pages * FileMapping_VirtualMemoryGranularity
}
/**
 * @description - Returns the input divided by the system's virtual memory
 * allocation granularity, which is considered by this library to be one page.
 * @param {Number} Bytes - The number of bytes.
 * @returns {Number} - `Bytes / FileMapping_VirtualMemoryGranularity`.
 */
FileMapping_BytesToPages(Bytes) {
    return Bytes / FileMapping_VirtualMemoryGranularity
}
/**
 * @param {Number} Bytes - The number of bytes.
 * @returns {Number} - `Ceil(Bytes / FileMapping_VirtualMemoryGranularity) * FileMapping_VirtualMemoryGranularity`.
 */
FileMapping_RoundUpToPage(Bytes) {
    return Ceil(Bytes / FileMapping_VirtualMemoryGranularity)
}
/**
 * @description - Checks for the UTF-16 and UTF-8 BOM.
 * @param {Integer} ptr - The pointer to the data (i.e. the beginning of the file).
 * @param {String} encoding - The file encoding. This function evaluates the following encodings
 * (any other encodings will just cause the function to return 0):
 * - UTF-16
 * - cp1200
 * - 1200
 * - utf-8
 * - cp65001
 * - 65001
 * @returns {Integer} - If the encoding is UTF-16 and there is a BOM, returns 2 (the size of the BOM).
 *
 * If the encoding is UTF-8 and there is a BOM, returns 3 (the size of the BOM).
 *
 * Else, returns 0.
 */
FileMapping_HasBom(ptr, encoding) {
    ; UTF-16
    if RegExMatch(encoding, 'iS)utf-16|(?:cp)?1200$') {
        return NumGet(ptr, 'uchar') = FILEMAPPING_UTF16LE_BOM[1]
        && NumGet(ptr + 1, 'uchar') = FILEMAPPING_UTF16LE_BOM[2] ? 2 : 0
    }
    ; UTF-8
    if RegExMatch(encoding, 'iS)utf-8|(?:cp)?65001$') {
        return NumGet(ptr, 'uchar') = FILEMAPPING_UTF8_BOM[1]
        && NumGet(ptr + 1, 'uchar') = FILEMAPPING_UTF8_BOM[2]
        && NumGet(ptr + 2, 'uchar') = FILEMAPPING_UTF8_BOM[3] ? 3 : 0
    }
}

class FileMapping_CloseOnExit {
    __New(idFileMapping) {
        this.idFileMapping := idFileMapping
    }
    Call(*) {
        if FileMapping.Collection.Has(this.idFileMapping) {
            FileMapping.Collection.Get(this.idFileMapping).Close()
        }
    }
}
