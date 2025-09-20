#include "mex.h"
#include "SIB1.h"
#include "per_decoder.h"
#include <stdio.h>

// Функция для печати PLMN информации (в MATLAB console)
void print_plmn_info(const PLMN_IdentityInfo_t *plmn_info) { //принимает указатель на структуру
    if (!plmn_info) return;

    mexPrintf("  PLMN Identity Info:\n");

    // PLMN Identity List
    for (size_t i = 0; i < plmn_info->plmn_IdentityList.list.count; i++) {
        const PLMN_Identity_t *plmn = plmn_info->plmn_IdentityList.list.array[i]; //см. A_SET_OF.h

        // MCC
        if (plmn->mcc) {
            mexPrintf("   MCC: ");
            for (size_t j = 0; j < plmn->mcc->list.count; j++) {
                long *digit = (long *)plmn->mcc->list.array[j];
                if (digit) {
                    mexPrintf("%ld", *digit);
                } else {
                    mexPrintf("?");
                }
            }
            mexPrintf("\n");
        }

        // MNC
        mexPrintf("   MNC: ");
        for (size_t j = 0; j < plmn->mnc.list.count; j++) {
            long *digit = (long *)plmn->mnc.list.array[j];
             if (digit) {
                mexPrintf("%ld", *digit);
            } else {
                mexPrintf("?");
            }
        }
        mexPrintf("\n");
    }

    // Cell Identity
    mexPrintf("   Cell Identity (hex): ");
    for (size_t i = 0; i < plmn_info->cellIdentity.size; i++) {//см.BIT_STRING.h
        mexPrintf("%02X", plmn_info->cellIdentity.buf[i]);
    }
    mexPrintf("\n");


 // cellReservedForOperatorUse
    mexPrintf("   Cell Reserved For Operator Use: ");
    switch (plmn_info->cellReservedForOperatorUse) {
        case 0: // Или константа, соответствующая reserved
            mexPrintf("Reserved\n");
            break;
        case 1: // Или константа, соответствующая notReserved
            mexPrintf("Not Reserved\n");
            break;
        default:
            mexPrintf("Unknown (%ld)\n", plmn_info->cellReservedForOperatorUse);
            break;
    }
}

// Главная функция mexFunction
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
// nlhs - количество выходных аргументов 
// plhs - массив указателей на выходные переменные
// nrhs - количество входных аргументов 
// prhs - массив указателей на входные переменные
    uint8_t *data = NULL; //указатель на массив байтов
    size_t data_len = 0;
    SIB1_t *sib1 = NULL;
    asn_dec_rval_t rval;

    // 1. Проверка входных аргументов
    if (nrhs != 1) {
        mexErrMsgTxt("One input argument required (encoded data).");
        return;
    }

    // 2. Получение указателя на данные и их длины из входного mxArray
    if (!mxIsUint8(prhs[0])) { //определение представляет ли mxArray данные как 8-битные целые числа без знака
        mexErrMsgTxt("Input data must be a uint8 array.");
        return;
    }

    data = (uint8_t *)mxGetData(prhs[0]); //mxGetData возвращает (void*)
    data_len = mxGetNumberOfElements(prhs[0]);

    // 3. Декодирование
    rval = uper_decode_complete(NULL, &asn_DEF_SIB1, (void**)&sib1, data, data_len);//см. per_decoder.h 

    // 4. Обработка результатов декодирования
    if (rval.code == RC_OK && sib1) { //декодирование успешно и sib1 не NULL
        mexPrintf("=== Decoding successful ===\n");

        // Вывод информации о cellAccessRelatedInfo
        if (sib1->cellAccessRelatedInfo.plmn_IdentityInfoList.list.count > 0) {
            mexPrintf("\nPLMN Identity Info List:\n");
            for (size_t i = 0; i < sib1->cellAccessRelatedInfo.plmn_IdentityInfoList.list.count; i++) {
                print_plmn_info(sib1->cellAccessRelatedInfo.plmn_IdentityInfoList.list.array[i]);//вызов
            }
        } else {
            mexPrintf("No PLMN Identity Info found.\n");
        }
    } else {
        mexPrintf("Decoding failed\n");
    }

    // 5. Освобождение памяти
    ASN_STRUCT_FREE(asn_DEF_SIB1, sib1);
}
