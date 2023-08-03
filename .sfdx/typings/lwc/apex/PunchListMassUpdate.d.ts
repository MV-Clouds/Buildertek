declare module "@salesforce/apex/PunchListMassUpdate.getCount" {
  export default function getCount(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PunchListMassUpdate.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/PunchListMassUpdate.getRecords" {
  export default function getRecords(param: {recordId: any, fieldNameJson: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/PunchListMassUpdate.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/PunchListMassUpdate.updateRecords" {
  export default function updateRecords(param: {recordId: any, updatedRecords: any, fieldSetName: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/PunchListMassUpdate.deleteProject" {
  export default function deleteProject(param: {deleteRecordId: any, recordId: any, fieldSetName: any, pageNumber: any, pageSize: any}): Promise<any>;
}
