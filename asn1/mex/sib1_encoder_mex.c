#include "mex.h" // Заголовочный файл для MEX-функций
#include "SIB1.h"
#include "asn_application.h"
#include "per_encoder.h"
#include "cellinfo_init.h" 

// Функция обратного вызова, которая собирает закодированные данные в mxArray
static int mxarray_collector(const void *buffer, size_t size, void *app_key) { //см.per_support.h (98)
//вызывается в _uper_encode_flush_outp см.per_encoder.c
    mxArray **output_ptr = (mxArray **)app_key;
    mxArray *output_array = *output_ptr;
    size_t existing_size = mxGetNumberOfElements(output_array);//длина выходного массива
    size_t new_size = existing_size + size;//формирование новой длины

    // Выделяем память под новые данные
    mxSetData(output_array, mxRealloc(mxGetData(output_array), new_size * sizeof(uint8_t)));
    //mxGetData возвращает указатель на данные
    //mxRealloc принимает 2 аргумента: первый - указатель на начало существующего блока памяти, размер которого нужно
    //изменить, второй - новый размер блока памяти в байтах. Возвращает указатель на измененный блок памяти.
    //mxSetData записывает в output_array адрес данных блока созданного mxRealloc
        if (mxGetData(output_array) == NULL && new_size > 0) {
        mexPrintf("mxRealloc failure\n");
        return -1;
    }

    // Копируем новые данные в mxArray
    memcpy((uint8_t *)mxGetData(output_array) + existing_size, buffer, size);
    //memcpy(dest, src, n): Это стандартная функция C для копирования n байт из области памяти, на которую указывает src 
    //(source - источник), в область памяти, на которую указывает dest (destination - назначение).
    //(uint8_t *)mxGetData(output_array) - адрес после конца существующих данных. Побайтовое копирование.
    mxSetN(output_array, new_size);//меняем размер массива
    return 0;
}

// Главная функция mexFunction
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
// nlhs - количество выходных аргументов 
// plhs - массив указателей на выходные переменные
// nrhs - количество входных аргументов 
// prhs - массив указателей на входные переменные
    SIB1_t *sib1 = NULL; // SIB1_t - тип определенный в SIB1.h
    asn_enc_rval_t enc_rval; //используется как возвращаемое значение енкодера asn_codecs.h
    mxArray *output_array = NULL; //mxArray - тип данных для массива MATLAB 

    // 1. Выделение памяти под структуру SIB1
    sib1 = calloc(1, sizeof(SIB1_t));
    if (!sib1) {
        mexErrMsgTxt("Memory allocation failed for SIB1_t");
        return;
    }

 // 2. Инициализация структуры SIB1 через отдельную функцию
    CellAccessRelatedInfo_t *cell_info = initialize_cell_access_related_info();
    if (!cell_info) {
        mexErrMsgTxt("Failed to initialize CellAccessRelatedInfo");
        free(sib1);
        return;
    }

    // Копируем инициализированную структуру в SIB1
    memcpy(&sib1->cellAccessRelatedInfo, cell_info, sizeof(CellAccessRelatedInfo_t));
    free(cell_info);  // Освобождаем временную структуру

    // 3. Создание выходного массива mxArray
    output_array = mxCreateNumericMatrix(1, 0, mxUINT8_CLASS, mxREAL); //mxCreateNumericMatrix - 2D числовая матрица
    //1 - число строк
    //0 - число столбцов (пустая матрица)
    //mxUINT8_CLASS - матрица будет хранить беззнаковые 8-битные целые числа
    //mxREAL - матрица будет хранить только вещественные (не комплексные) числа
    if (!output_array) {
        mexErrMsgTxt("mxCreateNumericMatrix failed");
        ASN_STRUCT_FREE(asn_DEF_SIB1, sib1);
        return;
    }
    plhs[0] = output_array; // Назначаем выходной аргумент

    // 4. Кодирование
    enc_rval = uper_encode(&asn_DEF_SIB1, sib1, mxarray_collector, &output_array);//см.per_encoder.h

    if (enc_rval.encoded == -1) { //проверка на кодирование
        char errbuf[256]; //хранение сообщения для ошибки
        snprintf(errbuf, sizeof(errbuf), "Encoding failed at %s",
                 enc_rval.failed_type ? enc_rval.failed_type->name : "unknown"); //constr_TYPE.h
        mexErrMsgTxt(errbuf);

        ASN_STRUCT_FREE(asn_DEF_SIB1, sib1);
        mxDestroyArray(output_array);//освобождение массива
        return;
    }

    mexPrintf("Successfully encoded %zd bits (%zd bytes)\n", enc_rval.encoded, (enc_rval.encoded + 7) / 8);

    // 5. Освобождение памяти (ВАЖНО!)
    ASN_STRUCT_FREE(asn_DEF_SIB1, sib1); //constr_TYPE.h указатель на структуру дескрпиптора + освобождаемаая структура
    return;
}
