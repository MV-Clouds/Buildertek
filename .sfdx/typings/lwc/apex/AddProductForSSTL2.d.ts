declare module "@salesforce/apex/AddProductForSSTL2.getpricebook" {
  export default function getpricebook(param: {BudgetId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getpricebooks" {
  export default function getpricebooks(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getBOMRec" {
  export default function getBOMRec(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getProjectSelectionSheetTakeOffRec" {
  export default function getProjectSelectionSheetTakeOffRec(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getAllProductsAndTakeOffLines" {
  export default function getAllProductsAndTakeOffLines(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getAllProductsAndSelectedTakeOffLines" {
  export default function getAllProductsAndSelectedTakeOffLines(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filteredTakeOffLines: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.assignProductToSSTLRecord1" {
  export default function assignProductToSSTLRecord1(param: {productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filteredTakeOffLines: any, productId: any, selectedSSTL: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.createTakeOffLinesRecords" {
  export default function createTakeOffLinesRecords(param: {productIds: any, recordId: any, productPageNumber: any, productPageSize: any, pageSize: any, pageNumber: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, productIdList: any, takeOffLineList: any, projectId: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.searchQueryResult2" {
  export default function searchQueryResult2(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, packageLinesSearchTradeType: any, packageLinesSearchCategory: any, packageLinesSearchProductType: any, collection: any, buildPhase: any, tradeType: any, category: any, productType: any, locationSearch: any, tradeTypeSSTL: any, categorySSTL: any, productTypeSSTL: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.retrieveProductRecords" {
  export default function retrieveProductRecords(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, filteredTakeOffLines: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.deleteSelectedSSTLRecord" {
  export default function deleteSelectedSSTLRecord(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, deleteSSTLIds: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getImages" {
  export default function getImages(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.searchQueryResult3" {
  export default function searchQueryResult3(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getFiledNameAndApi" {
  export default function getFiledNameAndApi(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getProductFiledNameAndApi" {
  export default function getProductFiledNameAndApi(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getBOMLineFiledNameAndApi" {
  export default function getBOMLineFiledNameAndApi(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.fetchObjectRecords" {
  export default function fetchObjectRecords(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getTakeOffLinesData" {
  export default function getTakeOffLinesData(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getProductPrice" {
  export default function getProductPrice(param: {productId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getProductfamilyRecords" {
  export default function getProductfamilyRecords(param: {ObjectName: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.savePToffline" {
  export default function savePToffline(param: {takeoffLines: any, PtoffId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getTakeoffId" {
  export default function getTakeoffId(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.getPackageTakeoff" {
  export default function getPackageTakeoff(): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.importPackageLinesRecords" {
  export default function importPackageLinesRecords(param: {takeOffLinesIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductForSSTL2.deleteSelectedProducts" {
  export default function deleteSelectedProducts(param: {prodIds: any}): Promise<any>;
}
