declare module "@salesforce/apex/ScheduleIteminlineEditcontroller.fetchAccts" {
  export default function fetchAccts(): Promise<any>;
}
declare module "@salesforce/apex/ScheduleIteminlineEditcontroller.getFieldSet" {
  export default function getFieldSet(param: {sObjectName: any, fieldSetName: any, parentRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ScheduleIteminlineEditcontroller.getRecords" {
  export default function getRecords(param: {sObjectName: any, parentFieldName: any, parentRecordId: any, fieldNameJson: any}): Promise<any>;
}
declare module "@salesforce/apex/ScheduleIteminlineEditcontroller.fetchprojecttasks" {
  export default function fetchprojecttasks(param: {parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/ScheduleIteminlineEditcontroller.updateprojeccttasks" {
  export default function updateprojeccttasks(param: {updatedprojecttaskList: any}): Promise<any>;
}
declare module "@salesforce/apex/ScheduleIteminlineEditcontroller.updateprojeccttasksDuplicate" {
  export default function updateprojeccttasksDuplicate(param: {updatedprojecttaskListJSON: any, scheduleId: any, currentPage: any}): Promise<any>;
}
declare module "@salesforce/apex/ScheduleIteminlineEditcontroller.deletescheduleitemrec" {
  export default function deletescheduleitemrec(param: {projecttasks: any}): Promise<any>;
}
declare module "@salesforce/apex/ScheduleIteminlineEditcontroller.getDataTableDetails" {
  export default function getDataTableDetails(param: {objApi: any, fieldSetName: any, scheduleid: any}): Promise<any>;
}
declare module "@salesforce/apex/ScheduleIteminlineEditcontroller.updateTaskOrder" {
  export default function updateTaskOrder(param: {scheduleItemListJSON: any, currentPage: any}): Promise<any>;
}
declare module "@salesforce/apex/ScheduleIteminlineEditcontroller.getScheduleRecord" {
  export default function getScheduleRecord(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ScheduleIteminlineEditcontroller.UPandINTaskOrder" {
  export default function UPandINTaskOrder(param: {scheduleItemsListJSON: any, scheduleId: any, currentPage: any}): Promise<any>;
}
