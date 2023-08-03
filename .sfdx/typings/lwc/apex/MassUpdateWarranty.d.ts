declare module "@salesforce/apex/MassUpdateWarranty.getWarrantyItems" {
  export default function getWarrantyItems(param: {recordId: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateWarranty.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateWarranty.updateRecords" {
  export default function updateRecords(param: {recordId: any, updatedRecords: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateWarranty.deleteWarrantyRecord" {
  export default function deleteWarrantyRecord(param: {deleteRecordId: any, recordId: any, pageNumber: any, pageSize: any}): Promise<any>;
}
