declare module "@salesforce/apex/CreateMasterSOVForProjectController2.getcurrency" {
  export default function getcurrency(): Promise<any>;
}
declare module "@salesforce/apex/CreateMasterSOVForProjectController2.getProjectName" {
  export default function getProjectName(param: {projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateMasterSOVForProjectController2.deleteSovLines" {
  export default function deleteSovLines(param: {recIds: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateMasterSOVForProjectController2.getItemNumber" {
  export default function getItemNumber(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateMasterSOVForProjectController2.getManageSovName" {
  export default function getManageSovName(param: {sovId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateMasterSOVForProjectController2.deleteSovlineData" {
  export default function deleteSovlineData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateMasterSOVForProjectController2.getManageSovsTotal" {
  export default function getManageSovsTotal(param: {sovId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateMasterSOVForProjectController2.getApprovedSovData" {
  export default function getApprovedSovData(param: {recordId: any, pageNumber: any, pageSize: any, vendorName: any, itemNo: any, description: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateMasterSOVForProjectController2.getPendingSovData" {
  export default function getPendingSovData(param: {recordId: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateMasterSOVForProjectController2.updateManageSOV" {
  export default function updateManageSOV(param: {Pendingrecord: any, Approvedrecord: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateMasterSOVForProjectController2.rejectSovlineData" {
  export default function rejectSovlineData(param: {recordId: any, rejectReason: any}): Promise<any>;
}
