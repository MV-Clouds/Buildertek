declare module "@salesforce/apex/CloneAddProductForSSTL.getpricebook" {
  export default function getpricebook(param: {BudgetId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getpricebooks" {
  export default function getpricebooks(): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getBOMRec" {
  export default function getBOMRec(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getProjectSelectionSheetTakeOffRec" {
  export default function getProjectSelectionSheetTakeOffRec(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getAllProductsAndTakeOffLines" {
  export default function getAllProductsAndTakeOffLines(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getAllProductsAndSelectedTakeOffLines" {
  export default function getAllProductsAndSelectedTakeOffLines(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filteredTakeOffLines: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.assignProductToSSTLRecord1" {
  export default function assignProductToSSTLRecord1(param: {productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filteredTakeOffLines: any, productId: any, selectedSSTL: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.createTakeOffLinesRecords" {
  export default function createTakeOffLinesRecords(param: {productIds: any, recordId: any, productPageNumber: any, productPageSize: any, pageSize: any, pageNumber: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, productIdList: any, takeOffLineList: any, projectId: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.searchQueryResult2" {
  export default function searchQueryResult2(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, packageLinesSearchTradeType: any, packageLinesSearchCategory: any, packageLinesSearchProductType: any, collection: any, buildPhase: any, tradeType: any, category: any, productType: any, locationSearch: any, tradeTypeSSTL: any, categorySSTL: any, productTypeSSTL: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.retrieveProductRecords" {
  export default function retrieveProductRecords(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, filteredTakeOffLines: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.deleteSelectedSSTLRecord" {
  export default function deleteSelectedSSTLRecord(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, deleteSSTLIds: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getImages" {
  export default function getImages(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.searchQueryResult3" {
  export default function searchQueryResult3(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filter1: any, filter2: any, filter3: any, selectPriceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getFiledNameAndApi" {
  export default function getFiledNameAndApi(): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getProductFiledNameAndApi" {
  export default function getProductFiledNameAndApi(): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getBOMLineFiledNameAndApi" {
  export default function getBOMLineFiledNameAndApi(): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.fetchObjectRecords" {
  export default function fetchObjectRecords(): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getTakeOffLinesData" {
  export default function getTakeOffLinesData(): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getProductPrice" {
  export default function getProductPrice(param: {productId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getProductfamilyRecords" {
  export default function getProductfamilyRecords(param: {ObjectName: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.savePToffline" {
  export default function savePToffline(param: {takeoffLines: any, PtoffId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getTakeoffId" {
  export default function getTakeoffId(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.getPackageTakeoff" {
  export default function getPackageTakeoff(): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.importPackageLinesRecords" {
  export default function importPackageLinesRecords(param: {takeOffLinesIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneAddProductForSSTL.deleteSelectedProducts" {
  export default function deleteSelectedProducts(param: {prodIds: any}): Promise<any>;
}
