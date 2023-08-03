declare module "@salesforce/apex/NewResourceScheduleDashnoardCls.getProjectId" {
  export default function getProjectId(param: {scheduleId: any}): Promise<any>;
}
declare module "@salesforce/apex/NewResourceScheduleDashnoardCls.getScheduleItemsByProject" {
  export default function getScheduleItemsByProject(param: {fromDate: any, toDate: any, slectedTradetypeId: any, slectedprojectId: any, slectedcontactId: any, projectSearch: any, resourceSearch: any, alltypeSearch: any}): Promise<any>;
}
declare module "@salesforce/apex/NewResourceScheduleDashnoardCls.getResourcesByProject" {
  export default function getResourcesByProject(param: {projId: any, contractResourceId: any, fromDate: any, toDate: any}): Promise<any>;
}
