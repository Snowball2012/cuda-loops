#define LOOP_ADI_46_CUDA_KERNEL_REGS 25
#define LOOP_ADI_51_CUDA_KERNEL_REGS 25
#define LOOP_ADI_41_CUDA_KERNEL_REGS 22
#define LOOP_ADI_92_CUDA_KERNEL_REGS 21

#include <dvmhlib2.h>

#ifdef LOOP_ADI_41_CUDA_KERNEL_REGS
    DvmType loop_adi_41_cuda_kernel_regs = LOOP_ADI_41_CUDA_KERNEL_REGS;
#else
    DvmType loop_adi_41_cuda_kernel_regs = 0;
#endif

#ifdef LOOP_ADI_46_CUDA_KERNEL_REGS
    DvmType loop_adi_46_cuda_kernel_regs = LOOP_ADI_46_CUDA_KERNEL_REGS;
#else
    DvmType loop_adi_46_cuda_kernel_regs = 0;
#endif

#ifdef LOOP_ADI_51_CUDA_KERNEL_REGS
    DvmType loop_adi_51_cuda_kernel_regs = LOOP_ADI_51_CUDA_KERNEL_REGS;
#else
    DvmType loop_adi_51_cuda_kernel_regs = 0;
#endif

#ifdef LOOP_ADI_92_CUDA_KERNEL_REGS
    DvmType loop_adi_92_cuda_kernel_regs = LOOP_ADI_92_CUDA_KERNEL_REGS;
#else
    DvmType loop_adi_92_cuda_kernel_regs = 0;
#endif

