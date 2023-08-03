declare module "@salesforce/apex/editResourcesController.getAccounts" {
  export default function getAccounts(param: {pageNumber: any, pageSize: any, selected: any, searchaccount: any}): Promise<any>;
}
declare module "@salesforce/apex/editResourcesController.getContacts" {
  export default function getContacts(param: {selected: any, searchname: any, searchaccount: any}): Promise<any>;
}
declare module "@salesforce/apex/editResourcesController.getContactsDup" {
  export default function getContactsDup(param: {taskid: any, pageNumber: any, pageSize: any, selected: any, searchname: any, searchaccount: any}): Promise<any>;
}
