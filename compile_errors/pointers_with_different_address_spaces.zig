fn entry(a: ?*addrspace(.gs) i32) *i32 {
    return a.?;
}
pub fn main() void {
    _ = &entry;
}

// error
// output_mode=Exe
// backend=stage2,llvm
// target=x86_64-linux,x86_64-macos
//
// :2:13: error: expected type '*i32', found '*addrspace(.gs) i32'
// :2:13: note: address space 'gs' cannot cast into address space 'generic'
// :1:35: note: function return type declared here
