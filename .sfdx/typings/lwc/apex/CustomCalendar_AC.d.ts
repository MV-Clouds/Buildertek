declare module "@salesforce/apex/CustomCalendar_AC.getAllResourcess" {
  export default function getAllResourcess(param: {selected: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.getAllProjectTasks" {
  export default function getAllProjectTasks(param: {selected: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.getAllProjects" {
  export default function getAllProjects(param: {selected: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.getWeekRecords" {
  export default function getWeekRecords(param: {fromDate: any, toDate: any, selected: any, ChildSelected: any, ContChildSelected: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.getSelectedWeekRecords" {
  export default function getSelectedWeekRecords(param: {fromDate: any, toDate: any, selected: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.getSchedulers" {
  export default function getSchedulers(param: {ProjectID: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.updateDates" {
  export default function updateDates(param: {ResourceId: any, DataType: any, ResourceSetDate: any, ProjectId: any, ScheduleId: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.getprojectJunction" {
  export default function getprojectJunction(): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.DeleteProject" {
  export default function DeleteProject(param: {junctionId: any, ResourceSetDate: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.updateProject" {
  export default function updateProject(param: {junctionId: any, ResourceSetDate: any, projectJunctionId: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.updateResource" {
  export default function updateResource(param: {junctionId: any, ResourceSetDate: any, ProjectId: any, ResourceId: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.DeleteResource" {
  export default function DeleteResource(param: {junctionId: any, ResourceSetDate: any, ProjectId: any, ResourceId: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.setResourceText" {
  export default function setResourceText(param: {rid: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.getContacts" {
  export default function getContacts(param: {contactName: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.getAllJunctionprojects" {
  export default function getAllJunctionprojects(param: {fromDate: any, toDate: any, recordId: any, projecttaskrec: any, Resourcerecs: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.getAllJunctionResources" {
  export default function getAllJunctionResources(param: {fromDate: any, toDate: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.CreateServiceRequest" {
  export default function CreateServiceRequest(param: {Datevalue: any, ProjectId: any, ContactId: any, Description: any, PrimaryAssign: any, Subject: any, Timevalue: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomCalendar_AC.getServiceRequest" {
  export default function getServiceRequest(param: {Datevalue: any, ProjectId: any}): Promise<any>;
}
