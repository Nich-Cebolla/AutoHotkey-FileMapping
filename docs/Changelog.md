2025-05-21
- I corrected an error in my documentation regarding opening a file mapping for IPC. I previously wrote that one should name the file mapping object with the "Global" prefix, but "Local" requires lower access.
- I corrected an error that caused opening the file mapping object to fail when using the `Name` parameter instead of the `Path` parameter.
- I added basic writing support with the `FileMapping.Prototype.Write` method.
- Verified the class can be used for inter-process communication.
- Wrote "test-ipc.ahk".
