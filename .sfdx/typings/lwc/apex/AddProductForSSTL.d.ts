declare module "@salesforce/apex/AddProductForSSTL.getadminvalue" {
  export default function getadminvalue(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.productrecords" {
  export default function productrecords(param: {productIds: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.updateBOMquantityvalues" {
  export default function updateBOMquantityvalues(param: {prodIds: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.verifytakeofflines" {
  export default function verifytakeofflines(param: {sheetId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.updatequantityvalues" {
  export default function updatequantityvalues(param: {prodIds: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getpricebook" {
  export default function getpricebook(param: {BudgetId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getpricebooks" {
  export default function getpricebooks(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getBOMRec" {
  export default function getBOMRec(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getProjectSelectionSheetTakeOffRec" {
  export default function getProjectSelectionSheetTakeOffRec(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getAllProductsAndTakeOffLines" {
  export default function getAllProductsAndTakeOffLines(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getAllProductsAndSelectedTakeOffLines" {
  export default function getAllProductsAndSelectedTakeOffLines(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filteredTakeOffLines: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.assignProductToSSTLRecord1" {
  export default function assignProductToSSTLRecord1(param: {productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filteredTakeOffLines: any, productId: any, selectedSSTL: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.validateAndCreateBOMLines" {
  export default function validateAndCreateBOMLines(param: {billOfMaterialId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getPriceBookEntries" {
  export default function getPriceBookEntries(param: {priceBookIds: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.createTakeOffLinesRecords" {
  export default function createTakeOffLinesRecords(param: {productIds: any, recordId: any, productPageNumber: any, productPageSize: any, pageSize: any, pageNumber: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, productIdList: any, takeOffLineList: any, projectId: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.createBOMLinesAuto" {
  export default function createBOMLinesAuto(param: {productIds: any, recordId: any, productPageNumber: any, productPageSize: any, pageSize: any, pageNumber: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, productIdList: any, takeOffLineList: any, projectId: any, selectPriceBook: any, takeOffVsProdCode: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.searchQueryResult2" {
  export default function searchQueryResult2(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, packageLinesSearchTradeType: any, packageLinesSearchCategory: any, packageLinesSearchProductType: any, collection: any, buildPhase: any, tradeType: any, category: any, productType: any, locationSearch: any, tradeTypeSSTL: any, categorySSTL: any, productTypeSSTL: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.retrieveProductRecords" {
  export default function retrieveProductRecords(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, filteredTakeOffLines: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.deleteSelectedSSTLRecord" {
  export default function deleteSelectedSSTLRecord(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, deleteSSTLIds: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getImages" {
  export default function getImages(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.searchQueryResult3" {
  export default function searchQueryResult3(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getFiledNameAndApi" {
  export default function getFiledNameAndApi(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getProductFiledNameAndApi" {
  export default function getProductFiledNameAndApi(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getBOMLineFiledNameAndApi" {
  export default function getBOMLineFiledNameAndApi(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.fetchObjectRecords" {
  export default function fetchObjectRecords(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getTakeOffLinesData" {
  export default function getTakeOffLinesData(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getProductPrice" {
  export default function getProductPrice(param: {productId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getProductfamilyRecords" {
  export default function getProductfamilyRecords(param: {ObjectName: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.savePToffline" {
  export default function savePToffline(param: {takeoffLines: any, PtoffId: any, bomRecordString: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getTakeoffId" {
  export default function getTakeoffId(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.getPackageTakeoff" {
  export default function getPackageTakeoff(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.importPackageLinesRecords" {
  export default function importPackageLinesRecords(param: {takeOffLinesIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.deleteSelectedProducts" {
  export default function deleteSelectedProducts(param: {prodIds: any, sheetId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL.deleteTakeoffLines" {
  export default function deleteTakeoffLines(param: {TakeOffIds: any}): Promise<any>;
}
