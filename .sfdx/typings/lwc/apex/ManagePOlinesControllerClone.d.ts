declare module "@salesforce/apex/ManagePOlinesControllerClone.getProject" {
  export default function getProject(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesControllerClone.getProductOptionLines" {
  export default function getProductOptionLines(param: {pageNumber: any, pageSize: any, recordId: any, vendorName: any, category: any, tradeType: any, purchaseOrder: any, productType: any, buildPhase: any, toggleValue: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesControllerClone.createPO" {
  export default function createPO(param: {selectedIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesControllerClone.getVendors" {
  export default function getVendors(param: {optionLineID: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesControllerClone.getprovendors" {
  export default function getprovendors(param: {optionLineID: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesControllerClone.createNewOptionLine" {
  export default function createNewOptionLine(param: {productId: any, projectId: any, optionLineId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManagePOlinesControllerClone.deleteOptionLine" {
  export default function deleteOptionLine(param: {productId: any, projectId: any, optionLineId: any}): Promise<any>;
}
