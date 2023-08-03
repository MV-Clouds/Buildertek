declare module "@salesforce/apex/massUpdateSovController.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/massUpdateSovController.getRecords" {
  export default function getRecords(param: {recordId: any, fieldNameJson: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/massUpdateSovController.getCount" {
  export default function getCount(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/massUpdateSovController.updateRecords" {
  export default function updateRecords(param: {recordId: any, updatedRecords: any, fieldSetName: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/massUpdateSovController.massDeleteProjectTask" {
  export default function massDeleteProjectTask(param: {deleteRecordId: any, recordId: any, fieldSetName: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/massUpdateSovController.getSOVName" {
  export default function getSOVName(param: {deleteRecordId: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/massUpdateSovController.getUser" {
  export default function getUser(): Promise<any>;
}
declare module "@salesforce/apex/massUpdateSovController.isSovSubmitted" {
  export default function isSovSubmitted(param: {recordId: any}): Promise<any>;
}
