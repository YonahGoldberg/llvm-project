; RUN: llc < %s -start-after=atomic-expand -mtriple=mips64-mti-linux-gnu | FileCheck %s --check-prefix=BE
; RUN: llc < %s -start-after=atomic-expand -mtriple=mips64el-mti-linux-gnu | FileCheck %s --check-prefix=LE

; Check that reconstructing a split vector from the scalar atomic result
; respects the target's endianness.

define i32 @and_v2i32_extract0(ptr %addr, <2 x i32> %val) {
; BE-LABEL: and_v2i32_extract0:
; BE:         lld $1, 0($4)
; BE:         dsrl $1, $1, 32
; BE:         jr $ra
; BE-NEXT:    sll $2, $1, 0
;
; LE-LABEL: and_v2i32_extract0:
; LE:         lld $1, 0($4)
; LE-NOT:     dsrl
; LE:         jr $ra
; LE-NEXT:    sll $2, $1, 0
entry:
  %old = atomicrmw and ptr %addr, <2 x i32> %val monotonic, align 8
  %elt = extractelement <2 x i32> %old, i32 0
  ret i32 %elt
}

define i32 @xchg_v2i32_extract0(ptr %addr, <2 x i32> %val) {
; BE-LABEL: xchg_v2i32_extract0:
; BE:         lld $1, 0($4)
; BE:         dsrl $1, $1, 32
; BE:         jr $ra
; BE-NEXT:    sll $2, $1, 0
;
; LE-LABEL: xchg_v2i32_extract0:
; LE:         lld $1, 0($4)
; LE-NOT:     dsrl
; LE:         jr $ra
; LE-NEXT:    sll $2, $1, 0
entry:
  %old = atomicrmw xchg ptr %addr, <2 x i32> %val monotonic, align 8
  %elt = extractelement <2 x i32> %old, i32 0
  ret i32 %elt
}
