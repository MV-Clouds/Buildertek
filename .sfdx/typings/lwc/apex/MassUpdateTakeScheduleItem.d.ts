declare module "@salesforce/apex/MassUpdateTakeScheduleItem.getCount" {
  export default function getCount(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeScheduleItem.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeScheduleItem.getRecords" {
  export default function getRecords(param: {recordId: any, fieldNameJson: any, pageNumber: any, pageSize: any, phase: any, contractor: any, contractorResources: any, TradeType: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeScheduleItem.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeScheduleItem.updateRecords" {
  export default function updateRecords(param: {recordId: any, updatedRecords: any, fieldSetName: any, pageNumber: any, pageSize: any, phase: any, contractor: any, contractorResources: any, TradeType: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeScheduleItem.deleteProject" {
  export default function deleteProject(param: {deleteRecordId: any, recordId: any, fieldSetName: any, pageNumber: any, pageSize: any, phase: any, contractor: any, contractorResources: any, TradeType: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeScheduleItem.massDeleteProjectTask" {
  export default function massDeleteProjectTask(param: {deleteRecordId: any, recordId: any, fieldSetName: any, pageNumber: any, pageSize: any, phase: any, contractor: any, contractorResources: any, TradeType: any}): Promise<any>;
}
