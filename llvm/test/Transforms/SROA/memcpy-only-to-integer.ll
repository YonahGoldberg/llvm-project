; RUN: opt -passes=sroa -S < %s | FileCheck %s

target datalayout = "e-p:64:64-pe4:64:64-n8:16:32:64"

declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg)
declare void @llvm.memmove.p0.p0.i64(ptr writeonly captures(none), ptr readonly captures(none), i64, i1 immarg)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none))
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none))

define void @integer_array(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @integer_array(
; CHECK-NEXT:    [[V:%.*]] = load i64, ptr [[SRC:%.*]], align 4
; CHECK-NEXT:    store i64 [[V]], ptr [[DST:%.*]], align 4
; CHECK-NEXT:    ret void
  %a = alloca [2 x i32], align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %a, ptr align 4 %src, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %dst, ptr align 4 %a, i64 8, i1 false)
  ret void
}

define void @float_array(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @float_array(
; CHECK-NEXT:    [[V:%.*]] = load i64, ptr [[SRC:%.*]], align 4
; CHECK-NEXT:    store i64 [[V]], ptr [[DST:%.*]], align 4
; CHECK-NEXT:    ret void
  %a = alloca [2 x float], align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %a, ptr align 4 %src, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %dst, ptr align 4 %a, i64 8, i1 false)
  ret void
}

define void @scalar_float(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @scalar_float(
; CHECK-NEXT:    [[V:%.*]] = load i64, ptr [[SRC:%.*]], align 8
; CHECK-NEXT:    store i64 [[V]], ptr [[DST:%.*]], align 8
; CHECK-NEXT:    ret void
  %a = alloca double, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %a, ptr align 8 %src, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %dst, ptr align 8 %a, i64 8, i1 false)
  ret void
}

define void @mixed_struct(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @mixed_struct(
; CHECK-NEXT:    [[V:%.*]] = load i64, ptr [[SRC:%.*]], align 4
; CHECK-NEXT:    store i64 [[V]], ptr [[DST:%.*]], align 4
; CHECK-NEXT:    ret void
  %a = alloca { i32, float }, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %a, ptr align 4 %src, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %dst, ptr align 4 %a, i64 8, i1 false)
  ret void
}

define void @vector(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @vector(
; CHECK-NEXT:    [[V:%.*]] = load i64, ptr [[SRC:%.*]], align 8
; CHECK-NEXT:    store i64 [[V]], ptr [[DST:%.*]], align 8
; CHECK-NEXT:    ret void
  %a = alloca <2 x float>, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %a, ptr align 8 %src, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %dst, ptr align 8 %a, i64 8, i1 false)
  ret void
}

define void @pointer(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @pointer(
; CHECK-NEXT:    [[V:%.*]] = load i64, ptr [[SRC:%.*]], align 8
; CHECK-NEXT:    store i64 [[V]], ptr [[DST:%.*]], align 8
; CHECK-NEXT:    ret void
  %a = alloca ptr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %a, ptr align 8 %src, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %dst, ptr align 8 %a, i64 8, i1 false)
  ret void
}

define void @illegal_integer_width(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @illegal_integer_width(
; CHECK-NEXT:    [[A:%.*]] = alloca [3 x i8], align 1
; CHECK-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr align 1 [[A]], ptr align 1 [[SRC:%.*]], i64 3, i1 false)
; CHECK-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr align 1 [[DST:%.*]], ptr align 1 [[A]], i64 3, i1 false)
; CHECK-NEXT:    ret void
  %a = alloca [3 x i8], align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %a, ptr align 1 %src, i64 3, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %dst, ptr align 1 %a, i64 3, i1 false)
  ret void
}

define void @lifetime_is_ignored(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @lifetime_is_ignored(
; CHECK-NEXT:    [[V:%.*]] = load i64, ptr [[SRC:%.*]], align 4
; CHECK-NEXT:    store i64 [[V]], ptr [[DST:%.*]], align 4
; CHECK-NEXT:    ret void
  %a = alloca [2 x float], align 4
  call void @llvm.lifetime.start.p0(i64 8, ptr %a)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %a, ptr align 4 %src, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %dst, ptr align 4 %a, i64 8, i1 false)
  call void @llvm.lifetime.end.p0(i64 8, ptr %a)
  ret void
}

define void @non_integral_pointer(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @non_integral_pointer(
; CHECK-NEXT:    [[V:%.*]] = load ptr addrspace(4), ptr [[SRC:%.*]], align 8
; CHECK-NEXT:    store ptr addrspace(4) [[V]], ptr [[DST:%.*]], align 8
; CHECK-NEXT:    ret void
  %a = alloca ptr addrspace(4), align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %a, ptr align 8 %src, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %dst, ptr align 8 %a, i64 8, i1 false)
  ret void
}

define float @has_non_memcpy_user(ptr %src) {
; CHECK-LABEL: define float @has_non_memcpy_user(
; CHECK-NOT: load i64
; CHECK: load float, ptr
; CHECK: ret float
  %a = alloca [2 x float], align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %a, ptr align 4 %src, i64 8, i1 false)
  %v = load float, ptr %a, align 4
  ret float %v
}

define void @small_partitions_of_large_alloca(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @small_partitions_of_large_alloca(
; CHECK-NEXT:    [[SRC_TAIL:%.*]] = getelementptr inbounds i8, ptr [[SRC:%.*]], i64 8
; CHECK-NEXT:    [[DST_TAIL:%.*]] = getelementptr inbounds i8, ptr [[DST:%.*]], i64 8
; CHECK-NEXT:    [[LO:%.*]] = load i64, ptr [[SRC]], align 4
; CHECK-NEXT:    [[HI:%.*]] = load i64, ptr [[SRC_TAIL]], align 4
; CHECK-NEXT:    store i64 [[LO]], ptr [[DST]], align 4
; CHECK-NEXT:    store i64 [[HI]], ptr [[DST_TAIL]], align 4
; CHECK-NEXT:    ret void
  %a = alloca [4 x float], align 4
  %a.tail = getelementptr inbounds i8, ptr %a, i64 8
  %src.tail = getelementptr inbounds i8, ptr %src, i64 8
  %dst.tail = getelementptr inbounds i8, ptr %dst, i64 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %a, ptr align 4 %src, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %a.tail, ptr align 4 %src.tail, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %dst, ptr align 4 %a, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %dst.tail, ptr align 4 %a.tail, i64 8, i1 false)
  ret void
}

define void @too_large(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @too_large(
; CHECK:         [[A:%.*]] = alloca [3 x float], align 4
; CHECK:         call void @llvm.memcpy.p0.p0.i64(ptr align 4 [[A]], ptr align 4 [[SRC:%.*]], i64 12, i1 false)
; CHECK:         call void @llvm.memcpy.p0.p0.i64(ptr align 4 [[DST:%.*]], ptr align 4 [[A]], i64 12, i1 false)
  %a = alloca [3 x float], align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %a, ptr align 4 %src, i64 12, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %dst, ptr align 4 %a, i64 12, i1 false)
  ret void
}

define void @has_memmove_user(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @has_memmove_user(
; CHECK:         [[A:%.*]] = alloca [2 x float], align 4
; CHECK:         call void @llvm.memmove.p0.p0.i64(ptr align 4 [[A]], ptr align 4 [[SRC:%.*]], i64 8, i1 false)
; CHECK:         call void @llvm.memcpy.p0.p0.i64(ptr align 4 [[DST:%.*]], ptr align 4 [[A]], i64 8, i1 false)
  %a = alloca [2 x float], align 4
  call void @llvm.memmove.p0.p0.i64(ptr align 4 %a, ptr align 4 %src, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %dst, ptr align 4 %a, i64 8, i1 false)
  ret void
}

define void @has_memset_user(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @has_memset_user(
; CHECK:         [[A:%.*]] = alloca [2 x float], align 4
; CHECK:         call void @llvm.memcpy.p0.p0.i64(ptr align 4 [[A]], ptr align 4 [[SRC:%.*]], i64 8, i1 false)
; CHECK:         call void @llvm.memset.p0.i64(ptr align 4 [[A]], i8 0, i64 8, i1 false)
; CHECK:         call void @llvm.memcpy.p0.p0.i64(ptr align 4 [[DST:%.*]], ptr align 4 [[A]], i64 8, i1 false)
  %a = alloca [2 x float], align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %a, ptr align 4 %src, i64 8, i1 false)
  call void @llvm.memset.p0.i64(ptr align 4 %a, i8 0, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %dst, ptr align 4 %a, i64 8, i1 false)
  ret void
}

define void @has_volatile_memcpy(ptr %dst, ptr %src) {
; CHECK-LABEL: define void @has_volatile_memcpy(
; CHECK:         [[A:%.*]] = alloca [2 x float], align 4
; CHECK:         call void @llvm.memcpy.p0.p0.i64(ptr align 4 [[A]], ptr align 4 [[SRC:%.*]], i64 8, i1 true)
; CHECK:         call void @llvm.memcpy.p0.p0.i64(ptr align 4 [[DST:%.*]], ptr align 4 [[A]], i64 8, i1 false)
  %a = alloca [2 x float], align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %a, ptr align 4 %src, i64 8, i1 true)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %dst, ptr align 4 %a, i64 8, i1 false)
  ret void
}

define void @has_variable_memcpy(ptr %dst, ptr %src, i64 %size) {
; CHECK-LABEL: define void @has_variable_memcpy(
; CHECK:         [[A:%.*]] = alloca [2 x float], align 4
; CHECK:         call void @llvm.memcpy.p0.p0.i64(ptr align 4 [[A]], ptr align 4 [[SRC:%.*]], i64 [[SIZE:%.*]], i1 false)
; CHECK:         call void @llvm.memcpy.p0.p0.i64(ptr align 4 [[DST:%.*]], ptr align 4 [[A]], i64 8, i1 false)
  %a = alloca [2 x float], align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %a, ptr align 4 %src, i64 %size, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %dst, ptr align 4 %a, i64 8, i1 false)
  ret void
}
