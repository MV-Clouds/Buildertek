declare module "@salesforce/apex/ProjectMassUpdate.getCount" {
  export default function getCount(): Promise<any>;
}
declare module "@salesforce/apex/ProjectMassUpdate.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/ProjectMassUpdate.getRecords" {
  export default function getRecords(param: {fieldNameJson: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/ProjectMassUpdate.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/ProjectMassUpdate.updateRecords" {
  export default function updateRecords(param: {updatedRecords: any, fieldSetName: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/ProjectMassUpdate.deleteProject" {
  export default function deleteProject(param: {recordId: any, fieldSetName: any, pageNumber: any, pageSize: any}): Promise<any>;
}
