declare module "@salesforce/apex/MassUpdatePackageLien.getRecords" {
  export default function getRecords(param: {recordId: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdatePackageLien.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdatePackageLien.updateRecords" {
  export default function updateRecords(param: {recordId: any, updatedRecords: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdatePackageLien.deleteRecords" {
  export default function deleteRecords(param: {deleteRecordId: any, recordId: any, pageNumber: any, pageSize: any}): Promise<any>;
}
