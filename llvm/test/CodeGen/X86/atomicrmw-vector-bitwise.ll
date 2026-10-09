; RUN: llc < %s -mtriple=x86_64 | FileCheck %s

define void @and_v4i8(ptr %addr, <4 x i8> %val) {
; CHECK-LABEL: and_v4i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movd %xmm0, %eax
; CHECK-NEXT:    lock andl %eax, ({{.*}})
; CHECK-NEXT:    retq
  %old = atomicrmw and ptr %addr, <4 x i8> %val monotonic, align 4
  ret void
}

define void @or_v4i8(ptr %addr, <4 x i8> %val) {
; CHECK-LABEL: or_v4i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movd %xmm0, %eax
; CHECK-NEXT:    lock orl %eax, ({{.*}})
; CHECK-NEXT:    retq
  %old = atomicrmw or ptr %addr, <4 x i8> %val monotonic, align 4
  ret void
}

define void @xor_v4i8(ptr %addr, <4 x i8> %val) {
; CHECK-LABEL: xor_v4i8:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movd %xmm0, %eax
; CHECK-NEXT:    lock xorl %eax, ({{.*}})
; CHECK-NEXT:    retq
  %old = atomicrmw xor ptr %addr, <4 x i8> %val monotonic, align 4
  ret void
}
