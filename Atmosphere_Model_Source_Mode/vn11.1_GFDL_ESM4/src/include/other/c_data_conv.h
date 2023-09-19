/**********************************COPYRIGHT***********************************/
/*            (C) Crown copyright Met Office. All rights reserved.            */
/*         For further details please refer to the file COPYRIGHT.txt         */
/*        which you should have received as part of this distribution.        */
/**********************************COPYRIGHT***********************************/

/* Code Owner: Please refer to the UM file CodeOwners.txt                     */
/* This file belongs in section: C Code                                       */

/* Start C_DATA_CONV                                                */
/*                                                                  */
/* Description:                                                     */
/*                                                                  */
/* Global constants for Data Conversion routines                    */
/*                                                                  */
/* Information:                                                     */
/*                                                                  */
/* Header file providing global constants required by the portable  */
/* data conversion routines.  These constants provide masks for     */
/* for selectively extracting the sign, exponent and mantissa       */
/* parts from IEEE and IBM 32 and 64 bit reals and integers.        */
/* The constants are expressed here in hex format.  The             */
/* corresponding binary representations are given by the usual      */
/* relationships:                                                   */
/*    0=0000, 1=0001, 2=0010,....., 9=1001, A=1010,....F=1111       */
/*                                                                  */
/*                                                                  */
/*                                                                  */

#if !defined(C_DATA_CONV_H)
#define C_DATA_CONV_H

#include <stdint.h>

#define FULLMASK64 UINT64_C(0xFFFFFFFFFFFFFFFF)
#define ONE64      UINT64_C(0x0000000000000001)

/* Format 1: IBM 32 bit floating point numbers                      */
#define ibm_sign_32   UINT32_C(0x80000000)
#define ibm_expo_32   UINT32_C(0x7F000000)
#define ibm_mant_32   UINT32_C(0x00FFFFFF)
#define ibm_mant_bits_32 24
#define ibm_expo_bits_32 7
#define ibm_expo_bias_32 64

/* Format 2: IBM 64 bit floating point numbers                      */
#define ibm_sign_64   UINT64_C(0x8000000000000000)
#define ibm_expo_64   UINT64_C(0x7F00000000000000)
#define ibm_mant_64   UINT64_C(0x00FFFFFFFFFFFFFF)
#define ibm_mant_bits_64 56
#define ibm_expo_bits_64 7
#define ibm_expo_bias_64 64

/* Format 3: IEEE 32 bit floating point numbers                     */
#define ieee_sign_32  UINT32_C(0x80000000)
#define ieee_expo_32  UINT32_C(0x7F800000)
#define ieee_mant_32  UINT32_C(0x007FFFFF)
#define ieee_mant_bits_32 23
#define ieee_expo_bits_32 8
#define ieee_expo_bias_32 127

/* Format 4: IEEE 64 bit floating point numbers                     */
#define ieee_sign_64  UINT64_C(0x8000000000000000)
#define ieee_expo_64  UINT64_C(0x7FF0000000000000)
#define ieee_mant_64  UINT64_C(0x000FFFFFFFFFFFFF)
#define ieee_mant_bits_64 52
#define ieee_expo_bits_64 11
#define ieee_expo_bias_64 1023

/* Format 6: IEEE 16 bit integers (two's complement)                */
#define ieee_int_sign_16  UINT16_C(0x8000)
#define ieee_int_mant_16  UINT16_C(0x7FFF)
#define ieee_int_mant_bits_16 15

/* Format 7: IEEE 32 bit integers (two's complement)                */
#define ieee_int_sign_32  UINT32_C(0x80000000)
#define ieee_int_mant_32  UINT64_C(0x7FFFFFFF)
#define ieee_int_mant_bits_32 31

/* Format 8: IEEE 64 bit integers (two's complement)                */
#define ieee_int_sign_64  UINT64_C(0x8000000000000000)
#define ieee_int_mant_64  UINT64_C(0x7FFFFFFFFFFFFFFF)
#define ieee_int_mant_bits_64 63

typedef enum DATAFORMATS {

       // Floating Point Types
       FLT_TYPES,
       IBM32FLT_FORMAT, IBM64FLT_FORMAT, IEEE32FLT_FORMAT, IEEE64FLT_FORMAT,

       // Integer Types
       INT_TYPES,
       IEEE16INT_FORMAT, IEEE32INT_FORMAT, IEEE64INT_FORMAT

       } dataformat;

typedef enum DATATYPES {

       TYPENULL,
       TYPELESS,
       INTEGER,
       REAL,
       COMPLEX,
       LOGICAL,
       CHARACTER

       } datatypes;

extern int64_t ibm2ieee(datatypes *data_type,
                        int64_t   *num,
                        void      *ibm_num_in,
                        int64_t   *offset_in,
                        void      *cri_num_out,
                        int64_t   *stride,
                        int64_t   *size_num_out,
                        int64_t   *size_num_in);

extern int64_t ieee2ibm(datatypes *data_type,
                        int64_t *num,
                        void *ibm_num_out,
                        int64_t *offset_out,
                        void *cri_num_in,
                        int64_t *stride,
                        int64_t *size_num_in,
                        int64_t *size_num_out);

extern int64_t ieee2ieg (datatypes *data_type,
                         int64_t *num,
                         void *ieg_num_out,
                         int64_t *offset_out,
                         void *cri_num_in,
                         int64_t *stride,
                         int64_t *size_num_in,
                         int64_t *size_num_out);

extern int64_t ieg2ieee (datatypes *data_type,
                         int64_t *num,
                         void *ieg_num_in,
                         int64_t *offset_in,
                         void *cri_num_out,
                         int64_t *stride,
                         int64_t *size_num_out,
                         int64_t *size_num_in);

#endif

/* End C_DATA_CONV                                                  */