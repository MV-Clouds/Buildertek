declare module "@salesforce/apex/SchedulePOController.getPurchaseOrderData" {
  export default function getPurchaseOrderData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/SchedulePOController.getSchedulelist" {
  export default function getSchedulelist(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/SchedulePOController.getProjectSchedules" {
  export default function getProjectSchedules(param: {projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/SchedulePOController.getselectOptions" {
  export default function getselectOptions(param: {objectName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/SchedulePOController.insertScheduleTask" {
  export default function insertScheduleTask(param: {task: any, poId: any, scheduleId: any, dependency: any, contactorResource: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/SchedulePOController.getPredecessorList" {
  export default function getPredecessorList(param: {scheduleId: any}): Promise<any>;
}
