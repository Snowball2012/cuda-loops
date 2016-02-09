#define LOOP_ADI_74_CUDA_KERNEL_REGS 21
#define LOOP_ADI_33_CUDA_KERNEL_1_CASE_REGS 19
#define LOOP_ADI_16_CUDA_KERNEL_1_CASE_REGS 16
#define LOOP_ADI_24_CUDA_KERNEL_1_CASE_REGS 16

#include <dvmhlib.h>

      
#ifdef LOOP_ADI_16_1_CASE_REGS
         DvmType loop_adi_16_1_case_regs = LOOP_ADI_16_1_CASE_REGS;
#else
         DvmType loop_adi_16_1_case_regs = 0;
#endif
#ifdef LOOP_ADI_24_1_CASE_REGS
         DvmType loop_adi_24_1_case_regs = LOOP_ADI_24_1_CASE_REGS;
#else
         DvmType loop_adi_24_1_case_regs = 0;
#endif
#ifdef LOOP_ADI_33_1_CASE_REGS
         DvmType loop_adi_33_1_case_regs = LOOP_ADI_33_1_CASE_REGS;
#else
         DvmType loop_adi_33_1_case_regs = 0;
#endif
#ifdef LOOP_ADI_74_CUDA_KERNEL_REGS
         DvmType loop_adi_74_cuda_kernel_regs = LOOP_ADI_74_CUDA_KERNEL_REGS;
#else
         DvmType loop_adi_74_cuda_kernel_regs = 0;
#endif
      
