declare module "@salesforce/apex/POPageController.getMasterBudgets" {
  export default function getMasterBudgets(param: {recId: any, pageNumber: any, pageSize: any, poFilter: any, poLineFilter: any, tradeTypeFilter: any, projectFilter: any, productFilter: any, permitFilter: any}): Promise<any>;
}
declare module "@salesforce/apex/POPageController.findByName" {
  export default function findByName(param: {searchKey: any, recId: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/POPageController.findByName2" {
  export default function findByName2(param: {searchKey: any, searchKey1: any, recId: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/POPageController.getPORecListDetails" {
  export default function getPORecListDetails(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/POPageController.sendMail" {
  export default function sendMail(param: {budgetIds: any, filedata: any}): Promise<any>;
}
declare module "@salesforce/apex/POPageController.getContactName" {
  export default function getContactName(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/POPageController.updatePOLines" {
  export default function updatePOLines(param: {poLineIds: any, unitCostValue: any}): Promise<any>;
}
