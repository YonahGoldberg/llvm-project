; RUN: llc < %s -mtriple=nvptx64-nvidia-cuda -mcpu=sm_70 -mattr=+ptx60 | FileCheck %s

define <1 x i32> @and_v1i32(ptr %addr, <1 x i32> %val) {
; CHECK-LABEL: and_v1i32(
; CHECK-NOT: atom{{.*}}cas
; CHECK: atom.relaxed.sys.and.b32
; CHECK-NOT: atom{{.*}}cas
  %old = atomicrmw and ptr %addr, <1 x i32> %val monotonic, align 4
  ret <1 x i32> %old
}

define <4 x i8> @and_elementwise_v4i8(ptr %addr, <4 x i8> %val) {
; CHECK-LABEL: and_elementwise_v4i8(
; CHECK-NOT: atom{{.*}}cas
; CHECK: atom.relaxed.sys.and.b32
; CHECK-NOT: atom{{.*}}cas
  %old = atomicrmw elementwise and ptr %addr, <4 x i8> %val monotonic, align 4
  ret <4 x i8> %old
}

define <4 x i16> @and_v4i16(ptr %addr, <4 x i16> %val) {
; CHECK-LABEL: and_v4i16(
; CHECK-NOT: atom{{.*}}cas
; CHECK: atom.relaxed.sys.and.b64
; CHECK-NOT: atom{{.*}}cas
  %old = atomicrmw and ptr %addr, <4 x i16> %val monotonic, align 8
  ret <4 x i16> %old
}

define <4 x i8> @or_v4i8(ptr %addr, <4 x i8> %val) {
; CHECK-LABEL: or_v4i8(
; CHECK-NOT: atom{{.*}}cas
; CHECK: atom.relaxed.sys.or.b32
; CHECK-NOT: atom{{.*}}cas
  %old = atomicrmw or ptr %addr, <4 x i8> %val monotonic, align 4
  ret <4 x i8> %old
}

define <4 x i16> @or_elementwise_v4i16(ptr %addr, <4 x i16> %val) {
; CHECK-LABEL: or_elementwise_v4i16(
; CHECK-NOT: atom{{.*}}cas
; CHECK: atom.relaxed.sys.or.b64
; CHECK-NOT: atom{{.*}}cas
  %old = atomicrmw elementwise or ptr %addr, <4 x i16> %val monotonic, align 8
  ret <4 x i16> %old
}

define <4 x i8> @xor_elementwise_v4i8(ptr %addr, <4 x i8> %val) {
; CHECK-LABEL: xor_elementwise_v4i8(
; CHECK-NOT: atom{{.*}}cas
; CHECK: atom.relaxed.sys.xor.b32
; CHECK-NOT: atom{{.*}}cas
  %old = atomicrmw elementwise xor ptr %addr, <4 x i8> %val monotonic, align 4
  ret <4 x i8> %old
}

define <4 x i16> @xor_v4i16(ptr %addr, <4 x i16> %val) {
; CHECK-LABEL: xor_v4i16(
; CHECK-NOT: atom{{.*}}cas
; CHECK: atom.relaxed.sys.xor.b64
; CHECK-NOT: atom{{.*}}cas
  %old = atomicrmw xor ptr %addr, <4 x i16> %val monotonic, align 8
  ret <4 x i16> %old
}
