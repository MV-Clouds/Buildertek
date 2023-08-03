declare module "@salesforce/apex/PurchaseOrderDAO.createPO" {
  export default function createPO(param: {poJson: any, poItemsJson: any, budgetlineid: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.createLinesForExistedPO" {
  export default function createLinesForExistedPO(param: {poRecordID: any, poItemsJson: any, budgetlineid: any, addbudgetlineids: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.createAPFromPO" {
  export default function createAPFromPO(param: {poid: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.getpricebook" {
  export default function getpricebook(param: {BudgetId: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.getpricebooks" {
  export default function getpricebooks(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.testfromLax" {
  export default function testfromLax(param: {productId: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.getProductPrice" {
  export default function getProductPrice(param: {productId: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.getProductfamilyRecords" {
  export default function getProductfamilyRecords(param: {ObjectName: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.getProductPricevalue" {
  export default function getProductPricevalue(param: {productId: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.savePOItem" {
  export default function savePOItem(param: {POLines: any, POId: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.getProduct" {
  export default function getProduct(param: {poItems: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.addProductsToList" {
  export default function addProductsToList(param: {POItems: any, POItem: any, count: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.getselectOptions" {
  export default function getselectOptions(): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderDAO.saveData" {
  export default function saveData(param: {allData: any}): Promise<any>;
}
