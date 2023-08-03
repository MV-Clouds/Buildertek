declare module "@salesforce/apex/MassUpdatePurchaseOrderLineItem.getCount" {
  export default function getCount(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdatePurchaseOrderLineItem.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/MassUpdatePurchaseOrderLineItem.getRecords" {
  export default function getRecords(param: {recordId: any, fieldNameJson: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdatePurchaseOrderLineItem.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdatePurchaseOrderLineItem.updateRecords" {
  export default function updateRecords(param: {recordId: any, updatedRecords: any, fieldSetName: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdatePurchaseOrderLineItem.deleteProject" {
  export default function deleteProject(param: {deleteRecordId: any, recordId: any, fieldSetName: any, pageNumber: any, pageSize: any}): Promise<any>;
}
