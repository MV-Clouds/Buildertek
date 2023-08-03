declare module "@salesforce/apex/ManageVendorSOVController.getcurrency" {
  export default function getcurrency(): Promise<any>;
}
declare module "@salesforce/apex/ManageVendorSOVController.getSOVdata" {
  export default function getSOVdata(param: {SOVId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageVendorSOVController.getUser" {
  export default function getUser(): Promise<any>;
}
declare module "@salesforce/apex/ManageVendorSOVController.getVendorSOVLines" {
  export default function getVendorSOVLines(param: {SOVId: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageVendorSOVController.getSOVlineslistbyType" {
  export default function getSOVlineslistbyType(param: {SOVId: any, filter: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageVendorSOVController.ApproveSovLines" {
  export default function ApproveSovLines(param: {sovLineIds: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageVendorSOVController.getAllApproved" {
  export default function getAllApproved(param: {sovLineIds: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageVendorSOVController.rejectSovLines" {
  export default function rejectSovLines(param: {sovLineIds: any, rejectReason: any}): Promise<any>;
}
declare module "@salesforce/apex/ManageVendorSOVController.getAllApprovedexceptReject" {
  export default function getAllApprovedexceptReject(param: {sovLineIds: any}): Promise<any>;
}
