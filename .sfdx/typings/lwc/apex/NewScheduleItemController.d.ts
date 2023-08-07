declare module "@salesforce/apex/NewScheduleItemController.getPurchaseOrderData" {
  export default function getPurchaseOrderData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/NewScheduleItemController.getSchedulelist" {
  export default function getSchedulelist(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/NewScheduleItemController.insertScheduleTask" {
  export default function insertScheduleTask(param: {task: any, scheduleId: any, dependency: any, startdate: any, project: any, contactorResource: any}): Promise<any>;
}
declare module "@salesforce/apex/NewScheduleItemController.getPredecessorList" {
  export default function getPredecessorList(param: {scheduleId: any}): Promise<any>;
}
