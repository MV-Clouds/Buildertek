declare module "@salesforce/apex/BT_Expenses_ComponentController.getProjects" {
  export default function getProjects(): Promise<any>;
}
declare module "@salesforce/apex/BT_Expenses_ComponentController.getExpenses" {
  export default function getExpenses(param: {projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Expenses_ComponentController.getBudgets" {
  export default function getBudgets(param: {projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Expenses_ComponentController.getBudgetLines" {
  export default function getBudgetLines(param: {budgetId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Expenses_ComponentController.saveExp" {
  export default function saveExp(param: {expenses: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Expenses_ComponentController.getTimeCards" {
  export default function getTimeCards(param: {projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Expenses_ComponentController.saveTC" {
  export default function saveTC(param: {TimeCard: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Expenses_ComponentController.getInvoices" {
  export default function getInvoices(param: {projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Expenses_ComponentController.getChangeOrders" {
  export default function getChangeOrders(param: {projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Expenses_ComponentController.saveInv" {
  export default function saveInv(param: {Invoices: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Expenses_ComponentController.saveChangeOrder" {
  export default function saveChangeOrder(param: {changeOrderList: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Expenses_ComponentController.getPurchaseOrders" {
  export default function getPurchaseOrders(param: {projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Expenses_ComponentController.savePO" {
  export default function savePO(param: {PurchaseOrder: any}): Promise<any>;
}
