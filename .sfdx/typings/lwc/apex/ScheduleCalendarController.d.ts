declare module "@salesforce/apex/ScheduleCalendarController.getProjects" {
  export default function getProjects(param: {projectIdList: any, tradeTypeId: any, vendorId: any}): Promise<any>;
}
declare module "@salesforce/apex/ScheduleCalendarController.getAllProjects" {
  export default function getAllProjects(): Promise<any>;
}
declare module "@salesforce/apex/ScheduleCalendarController.getVendors" {
  export default function getVendors(): Promise<any>;
}
declare module "@salesforce/apex/ScheduleCalendarController.getTradeTypes" {
  export default function getTradeTypes(): Promise<any>;
}
declare module "@salesforce/apex/ScheduleCalendarController.updateDate" {
  export default function updateDate(param: {recordId: any, endDate: any}): Promise<any>;
}
declare module "@salesforce/apex/ScheduleCalendarController.updateEndDate" {
  export default function updateEndDate(param: {recordId: any, endDate: any}): Promise<any>;
}
