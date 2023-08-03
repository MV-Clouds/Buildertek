declare module "@salesforce/apex/ManageSOVCloneController.getProjectName" {
  export default function getProjectName(param: {projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageSOVCloneController.getManageSovName" {
  export default function getManageSovName(param: {sovId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageSOVCloneController.deleteSovlineData" {
  export default function deleteSovlineData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageSOVCloneController.getManageSovsTotal" {
  export default function getManageSovsTotal(param: {sovId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageSOVCloneController.getApprovedSovData" {
  export default function getApprovedSovData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageSOVCloneController.getPendingSovData" {
  export default function getPendingSovData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageSOVCloneController.updateManageSOV" {
  export default function updateManageSOV(param: {Pendingrecord: any, Approvedrecord: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageSOVCloneController.rejectSovlineData" {
  export default function rejectSovlineData(param: {recordId: any, rejectReason: any}): Promise<any>;
}
