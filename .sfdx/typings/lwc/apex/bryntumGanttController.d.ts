declare module "@salesforce/apex/bryntumGanttController.getScheduleWrapperAtLoading" {
  export default function getScheduleWrapperAtLoading(param: {scheduleid: any}): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.getAccounts" {
  export default function getAccounts(param: {pageNumber: any, pageSize: any, selected: any, searchaccount: any}): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.getContacts" {
  export default function getContacts(param: {selected: any, searchname: any, searchaccount: any}): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.searchProject" {
  export default function searchProject(param: {searchProjectName: any}): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.searchUsers" {
  export default function searchUsers(param: {searchProjectManagerName: any}): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.getDropDown" {
  export default function getDropDown(param: {fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.fetchScheduleList" {
  export default function fetchScheduleList(): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.getScheduleItemList" {
  export default function getScheduleItemList(param: {masterId: any}): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.saveResourceForRecord" {
  export default function saveResourceForRecord(param: {taskId: any, resourceId: any, resourceApiName: any}): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.getPickListValuesIntoList" {
  export default function getPickListValuesIntoList(): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.upsertDataOnSaveChanges" {
  export default function upsertDataOnSaveChanges(param: {scheduleRecordStr: any, taskRecordsStr: any, listOfRecordsToDelete: any}): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.createNewSchedule" {
  export default function createNewSchedule(param: {description: any, project: any, initialStartDate: any, type: any, user: any, masterId: any}): Promise<any>;
}
declare module "@salesforce/apex/bryntumGanttController.createScheduleLineFromMasterSchedule" {
  export default function createScheduleLineFromMasterSchedule(param: {recordId: any, masterId: any, initialStartDate: any}): Promise<any>;
}
