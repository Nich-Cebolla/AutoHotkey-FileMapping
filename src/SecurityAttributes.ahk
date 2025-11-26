
class SecurityAttributes {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; Size      Type        Symbol                  Offset               Padding
        A_PtrSize + ; DWORD     nLength                 0                    +4 on x64 only
        A_PtrSize + ; LPVOID    lpSecurityDescriptor    0 + A_PtrSize * 1
        A_PtrSize   ; BOOL      bInheritHandle          0 + A_PtrSize * 2    +4 on x64 only
        proto.offset_nLength               := 0
        proto.offset_lpSecurityDescriptor  := 0 + A_PtrSize * 1
        proto.offset_bInheritHandle        := 0 + A_PtrSize * 2
    }
    __New(nLength?, lpSecurityDescriptor?, bInheritHandle?) {
        this.Buffer := Buffer(this.cbSizeInstance)
        if IsSet(nLength) {
            this.nLength := nLength
        }
        if IsSet(lpSecurityDescriptor) {
            this.lpSecurityDescriptor := lpSecurityDescriptor
        }
        if IsSet(bInheritHandle) {
            this.bInheritHandle := bInheritHandle
        }
    }
    nLength {
        Get => NumGet(this.Buffer, this.offset_nLength, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_nLength)
        }
    }
    lpSecurityDescriptor {
        Get => NumGet(this.Buffer, this.offset_lpSecurityDescriptor, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_lpSecurityDescriptor)
        }
    }
    bInheritHandle {
        Get => NumGet(this.Buffer, this.offset_bInheritHandle, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_bInheritHandle)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}
