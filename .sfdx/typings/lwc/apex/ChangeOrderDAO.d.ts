declare module "@salesforce/apex/ChangeOrderDAO.getUser" {
  export default function getUser(): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.createCO" {
  export default function createCO(param: {coJson: any, coItemsJson: any, budgetlineid: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.getProductPricevalue" {
  export default function getProductPricevalue(param: {productId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.createARFromCO" {
  export default function createARFromCO(param: {coId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.getProduct" {
  export default function getProduct(param: {coItems: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.addProductsToList" {
  export default function addProductsToList(param: {COItems: any, COItem: any, count: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.getpricebook" {
  export default function getpricebook(param: {BudgetId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.saveCOItem" {
  export default function saveCOItem(param: {COLines: any, COId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.getpricebooks" {
  export default function getpricebooks(): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.getProductPrice" {
  export default function getProductPrice(param: {productId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.getProductfamilyRecords" {
  export default function getProductfamilyRecords(param: {ObjectName: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.getselectOptions" {
  export default function getselectOptions(): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.getCORecordTypes" {
  export default function getCORecordTypes(): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderDAO.checkCustomSettings" {
  export default function checkCustomSettings(): Promise<any>;
}
