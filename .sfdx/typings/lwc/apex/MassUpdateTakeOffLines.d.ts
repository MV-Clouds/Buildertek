declare module "@salesforce/apex/MassUpdateTakeOffLines.getName" {
  export default function getName(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeOffLines.getParentId" {
  export default function getParentId(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeOffLines.getCount" {
  export default function getCount(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeOffLines.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeOffLines.getRecords" {
  export default function getRecords(param: {recordId: any, fieldNameJson: any, pageNumber: any, pageSize: any, productType: any, searchLocation: any, searchCategory: any, searchTradeType: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeOffLines.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeOffLines.updateRecords" {
  export default function updateRecords(param: {recordId: any, updatedRecords: any, fieldSetName: any, pageNumber: any, pageSize: any, searchName: any, searchPlan: any, searchCategory: any, searchTradeType: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeOffLines.deleteProject" {
  export default function deleteProject(param: {deleteRecordId: any, recordId: any, fieldSetName: any, pageNumber: any, pageSize: any, searchName: any, searchPlan: any, searchCategory: any, searchTradeType: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeOffLines.DeleteMassTakeOffLines" {
  export default function DeleteMassTakeOffLines(param: {sovLineIds: any}): Promise<any>;
}
