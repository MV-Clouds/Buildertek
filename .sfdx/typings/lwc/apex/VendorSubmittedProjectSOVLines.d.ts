declare module "@salesforce/apex/VendorSubmittedProjectSOVLines.getProjectDetails" {
  export default function getProjectDetails(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSubmittedProjectSOVLines.getAllProductsAndTakeOffLines" {
  export default function getAllProductsAndTakeOffLines(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSubmittedProjectSOVLines.getAllProductsAndSelectedTakeOffLines" {
  export default function getAllProductsAndSelectedTakeOffLines(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filteredTakeOffLines: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSubmittedProjectSOVLines.assignProductToSSTLRecord1" {
  export default function assignProductToSSTLRecord1(param: {productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, filteredTakeOffLines: any, productId: any, selectedSSTL: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSubmittedProjectSOVLines.createTakeOffLinesRecords" {
  export default function createTakeOffLinesRecords(param: {productIds: any, recordId: any, productPageNumber: any, productPageSize: any, pageSize: any, pageNumber: any, SSTLPageNumber: any, SSTLPageSize: any, packageLinesSearchTradeType: any, packageLinesSearchCategory: any, packageLinesSearchProductType: any, collection: any, buildPhase: any, tradeType: any, category: any, productType: any, locationSearch: any, tradeTypeSSTL: any, categorySSTL: any, productTypeSSTL: any, productIdList: any, takeOffLineList: any, projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSubmittedProjectSOVLines.searchQueryResult2" {
  export default function searchQueryResult2(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, packageLinesSearchTradeType: any, packageLinesSearchCategory: any, packageLinesSearchProductType: any, collection: any, buildPhase: any, tradeType: any, category: any, productType: any, locationSearch: any, tradeTypeSSTL: any, categorySSTL: any, productTypeSSTL: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSubmittedProjectSOVLines.retrieveProductRecords" {
  export default function retrieveProductRecords(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, packageLinesSearchTradeType: any, packageLinesSearchCategory: any, packageLinesSearchProductType: any, collection: any, buildPhase: any, tradeType: any, category: any, productType: any, locationSearch: any, tradeTypeSSTL: any, categorySSTL: any, productTypeSSTL: any, filteredTakeOffLines: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSubmittedProjectSOVLines.deleteSelectedSSTLRecord" {
  export default function deleteSelectedSSTLRecord(param: {recordId: any, productPageNumber: any, productPageSize: any, pageNumber: any, pageSize: any, SSTLPageNumber: any, SSTLPageSize: any, packageLinesSearchTradeType: any, packageLinesSearchCategory: any, packageLinesSearchProductType: any, collection: any, buildPhase: any, tradeType: any, category: any, productType: any, locationSearch: any, tradeTypeSSTL: any, categorySSTL: any, productTypeSSTL: any, deleteSSTLIds: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSubmittedProjectSOVLines.getImages" {
  export default function getImages(param: {recordId: any}): Promise<any>;
}
