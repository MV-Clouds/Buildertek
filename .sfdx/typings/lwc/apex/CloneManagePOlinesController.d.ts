declare module "@salesforce/apex/CloneManagePOlinesController.getProject" {
  export default function getProject(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneManagePOlinesController.getProductOptionLines" {
  export default function getProductOptionLines(param: {pageNumber: any, pageSize: any, recordId: any, vendorName: any, category: any, tradeType: any, purchaseOrder: any, productType: any, buildPhase: any, toggleValue: any, filter: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneManagePOlinesController.createPO" {
  export default function createPO(param: {selectedIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneManagePOlinesController.getVendors" {
  export default function getVendors(param: {optionLineID: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneManagePOlinesController.getprovendors" {
  export default function getprovendors(param: {optionLineID: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneManagePOlinesController.createNewOptionLine" {
  export default function createNewOptionLine(param: {productId: any, projectId: any, optionLineId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneManagePOlinesController.deleteOptionLine" {
  export default function deleteOptionLine(param: {productId: any, projectId: any, optionLineId: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneManagePOlinesController.getTakeOffLinesData" {
  export default function getTakeOffLinesData(): Promise<any>;
}
declare module "@salesforce/apex/CloneManagePOlinesController.getBOMLineFiledNameAndApi" {
  export default function getBOMLineFiledNameAndApi(): Promise<any>;
}
declare module "@salesforce/apex/CloneManagePOlinesController.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneManagePOlinesController.updateRecords" {
  export default function updateRecords(param: {recordId: any, updatedRecords: any}): Promise<any>;
}
declare module "@salesforce/apex/CloneManagePOlinesController.deleteBOMLine" {
  export default function deleteBOMLine(param: {deleteRecordId: any}): Promise<any>;
}
