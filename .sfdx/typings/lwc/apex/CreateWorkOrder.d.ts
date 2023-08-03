declare module "@salesforce/apex/CreateWorkOrder.getWarrantyLines" {
  export default function getWarrantyLines(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateWorkOrder.createWorkOrder" {
  export default function createWorkOrder(param: {warrantyRecId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateWorkOrder.CreateWorkOrderLines" {
  export default function CreateWorkOrderLines(param: {budgetIds: any, recordId: any}): Promise<any>;
}
