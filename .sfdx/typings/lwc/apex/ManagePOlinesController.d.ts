declare module "@salesforce/apex/ManagePOlinesController.getProject" {
  export default function getProject(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.getProductOptionLines" {
  export default function getProductOptionLines(param: {pageNumber: any, pageSize: any, recordId: any, vendorName: any, category: any, tradeType: any, purchaseOrder: any, productType: any, buildPhase: any, toggleValue: any, filter: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.createPO" {
  export default function createPO(param: {selectedIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.getVendors" {
  export default function getVendors(param: {optionLineID: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.getprovendors" {
  export default function getprovendors(param: {optionLineID: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.createNewOptionLine" {
  export default function createNewOptionLine(param: {productId: any, projectId: any, optionLineId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.deleteOptionLine" {
  export default function deleteOptionLine(param: {productId: any, projectId: any, optionLineId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.getTakeOffLinesData" {
  export default function getTakeOffLinesData(): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.getBOMLineFiledNameAndApi" {
  export default function getBOMLineFiledNameAndApi(): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.updateRecords" {
  export default function updateRecords(param: {recordId: any, updatedRecords: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.deleteBOMLine" {
  export default function deleteBOMLine(param: {deleteRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.checkFabricationTaxes" {
  export default function checkFabricationTaxes(): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.getBTAdminRecorDetails" {
  export default function getBTAdminRecorDetails(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.updateBomRecords" {
  export default function updateBomRecords(param: {updatedBomList: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.getAllCountryList" {
  export default function getAllCountryList(): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.getproductCodes" {
  export default function getproductCodes(param: {bomId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.getExtendedCosts" {
  export default function getExtendedCosts(param: {bomId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.calculateOCIP_CCIP" {
  export default function calculateOCIP_CCIP(param: {JSONData: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.getBomLineDetails" {
  export default function getBomLineDetails(param: {bomId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesController.createQuoteMethod" {
  export default function createQuoteMethod(param: {recordId: any, mapFieldData: any}): Promise<any>;
}
