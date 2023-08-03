declare module "@salesforce/apex/newOptionClass.createoption" {
  export default function createoption(param: {option: any, salesPrice: any, BudgetId: any, budgetLineId: any}): Promise<any>;
}
declare module "@salesforce/apex/newOptionClass.getProduct" {
  export default function getProduct(param: {productId: any}): Promise<any>;
}
declare module "@salesforce/apex/newOptionClass.getBudget" {
  export default function getBudget(param: {seleTypeId: any}): Promise<any>;
}
declare module "@salesforce/apex/newOptionClass.getBudgetLine" {
  export default function getBudgetLine(param: {BudgetId: any}): Promise<any>;
}
declare module "@salesforce/apex/newOptionClass.getBudgetLineUnitSalesPrice" {
  export default function getBudgetLineUnitSalesPrice(param: {budgetLineId: any}): Promise<any>;
}
declare module "@salesforce/apex/newOptionClass.getfield" {
  export default function getfield(param: {objectName: any, fieldSetName: any}): Promise<any>;
}
declare module "@salesforce/apex/newOptionClass.getFieldSet" {
  export default function getFieldSet(param: {objectName: any, fieldSetName: any}): Promise<any>;
}
declare module "@salesforce/apex/newOptionClass.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/newOptionClass.saveData" {
  export default function saveData(param: {allData: any}): Promise<any>;
}
declare module "@salesforce/apex/newOptionClass.searchRecords" {
  export default function searchRecords(param: {searchKey: any, projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/newOptionClass.searchBudgetLineRecords" {
  export default function searchBudgetLineRecords(param: {searchKey: any, budgetId: any}): Promise<any>;
}
declare module "@salesforce/apex/newOptionClass.getAllBudget1" {
  export default function getAllBudget1(): Promise<any>;
}
