declare module "@salesforce/apex/ReviewPricingRequestController.getcurrency" {
  export default function getcurrency(): Promise<any>;
}
declare module "@salesforce/apex/ReviewPricingRequestController.getSOVName" {
  export default function getSOVName(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ReviewPricingRequestController.getVendorSOVLines" {
  export default function getVendorSOVLines(param: {SOVId: any}): Promise<any>;
}
declare module "@salesforce/apex/ReviewPricingRequestController.ApproveSovLines" {
  export default function ApproveSovLines(param: {sovLineIds: any}): Promise<any>;
}
declare module "@salesforce/apex/ReviewPricingRequestController.rejectSovLines" {
  export default function rejectSovLines(param: {sovLineIds: any, rejectReason: any}): Promise<any>;
}
declare module "@salesforce/apex/ReviewPricingRequestController.createSheetLines" {
  export default function createSheetLines(param: {SovLineValues: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ReviewPricingRequestController.getAllApproved" {
  export default function getAllApproved(param: {sovLineIds: any}): Promise<any>;
}
declare module "@salesforce/apex/ReviewPricingRequestController.getAllRejected" {
  export default function getAllRejected(param: {sovLineIds: any, rejectReason: any}): Promise<any>;
}
declare module "@salesforce/apex/ReviewPricingRequestController.clearAllLines" {
  export default function clearAllLines(param: {sovLineIds: any}): Promise<any>;
}
