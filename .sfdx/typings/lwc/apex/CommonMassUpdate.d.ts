declare module "@salesforce/apex/CommonMassUpdate.getCount" {
  export default function getCount(param: {objName: any, parentField: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CommonMassUpdate.getFieldSet" {
  export default function getFieldSet(param: {objName: any, fieldSetName: any}): Promise<any>;
}
declare module "@salesforce/apex/CommonMassUpdate.getRecords" {
  export default function getRecords(param: {objName: any, parentField: any, recordId: any, fieldNameJson: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/CommonMassUpdate.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/CommonMassUpdate.updateRecords" {
  export default function updateRecords(param: {objName: any, parentField: any, recordId: any, updatedRecords: any, fieldSetName: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/CommonMassUpdate.deleteProject" {
  export default function deleteProject(param: {objName: any, parentField: any, parentRecordId: any, recordId: any, fieldSetName: any, pageNumber: any, pageSize: any}): Promise<any>;
}
