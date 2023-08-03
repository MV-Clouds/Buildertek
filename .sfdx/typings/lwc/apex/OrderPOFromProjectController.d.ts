declare module "@salesforce/apex/OrderPOFromProjectController.getMasterBudgets" {
  export default function getMasterBudgets(param: {recId: any, pageNumber: any, pageSize: any, poFilter: any, poLineFilter: any, tradeTypeFilter: any, projectFilter: any, productFilter: any, permitFilter: any}): Promise<any>;
}
declare module "@salesforce/apex/OrderPOFromProjectController.getPORecListDetails" {
  export default function getPORecListDetails(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/OrderPOFromProjectController.sendMail" {
  export default function sendMail(param: {budgetIds: any, filedata: any}): Promise<any>;
}
declare module "@salesforce/apex/OrderPOFromProjectController.updatePOLines" {
  export default function updatePOLines(param: {poLineIds: any, unitCostValue: any}): Promise<any>;
}
