#include "cellinfo_init.h"
#include "SIB1.h"
#include "asn_application.h"
#include <stdlib.h>
#include <string.h>
#include "PLMN-IdentityInfo.h"

CellAccessRelatedInfo_t* initialize_cell_access_related_info(void) {
    CellAccessRelatedInfo_t* cell_info = calloc(1, sizeof(CellAccessRelatedInfo_t));
    if (!cell_info) {
        return NULL;
    }

    // Инициализация списка PLMN Identity Info
    asn_set_empty(&cell_info->plmn_IdentityInfoList.list);

    //====================== ПЕРВЫЙ PLMN_IdentityInfo ========================
    PLMN_IdentityInfo_t *plmn_info = calloc(1, sizeof(PLMN_IdentityInfo_t));
    if (!plmn_info) {
        free(cell_info);
        return NULL;
    }

    if (ASN_SET_ADD(&cell_info->plmn_IdentityInfoList.list, plmn_info) != 0) {
        free(plmn_info);
        free(cell_info);
        return NULL;
    }

    asn_set_empty(&plmn_info->plmn_IdentityList.list);

    //====================== ПЕРВЫЙ PLMN_Identity ========================
    PLMN_Identity_t *plmn = calloc(1, sizeof(PLMN_Identity_t));
    if (!plmn) {
        free(plmn_info);
        free(cell_info);
        return NULL;
    }

    if (ASN_SET_ADD(&plmn_info->plmn_IdentityList.list, plmn) != 0) {
        free(plmn);
        free(plmn_info);
        free(cell_info);
        return NULL;
    }
    
    // Инициализация MNC
    asn_set_empty(&plmn->mnc.list);
    for (int i = 0; i < 2; i++) {
      MCC_MNC_Digit_t *digit = calloc(1, sizeof(MCC_MNC_Digit_t));
        if (!digit) {
            ASN_STRUCT_FREE(asn_DEF_SIB1, cell_info);
            return NULL;
        }
        *digit = (i == 0 ? 0 : 1); // MNC = 01

        if (ASN_SET_ADD(&plmn->mnc.list, digit) != 0) {
            free(digit);
            ASN_STRUCT_FREE(asn_DEF_SIB1, cell_info);
            return NULL;
        }
    }
    
 // Инициализация MCC
    plmn->mcc = calloc(1, sizeof(MCC_t));
    if (!plmn->mcc) {
        free(plmn);
        free(plmn_info);
        free(cell_info);
        return NULL;
    }
    asn_set_empty(&plmn->mcc->list);

    for (int i = 0; i < 3; i++) {
        MCC_MNC_Digit_t *digit = calloc(1, sizeof(MCC_MNC_Digit_t));
        if (!digit) {
            ASN_STRUCT_FREE(asn_DEF_SIB1, cell_info);
            return NULL;
        }
        *digit = (i == 0 ? 3 : (i == 1 ? 5 : 0)); // MCC = 250

        if (ASN_SET_ADD(&plmn->mcc->list, digit) != 0) {
            free(digit);
            ASN_STRUCT_FREE(asn_DEF_SIB1, cell_info);
            return NULL;
        }
    }

    // Инициализация Cell Identity
    uint8_t *cell_id_buf = calloc(5, sizeof(uint8_t));
    if (!cell_id_buf) {
        ASN_STRUCT_FREE(asn_DEF_SIB1, cell_info);
        return NULL;
    }
    cell_id_buf[0] = 0xAA;
    cell_id_buf[1] = 0xBB;
    cell_id_buf[2] = 0xCC;
    cell_id_buf[3] = 0xDD;
    cell_id_buf[4] = 0xEE;
    plmn_info->cellIdentity.buf = cell_id_buf;
    plmn_info->cellIdentity.size = 5;
    plmn_info->cellIdentity.bits_unused = 4;

// Инициализация cellReservedForOperatorUse
  plmn_info->cellReservedForOperatorUse = 0; 

    return cell_info;
    
}
