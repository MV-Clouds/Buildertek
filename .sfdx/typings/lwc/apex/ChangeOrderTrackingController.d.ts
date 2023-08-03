declare module "@salesforce/apex/ChangeOrderTrackingController.getcurrency" {
  export default function getcurrency(): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderTrackingController.getVendorSOVLines" {
  export default function getVendorSOVLines(param: {SOVId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderTrackingController.updateLines" {
  export default function updateLines(param: {recordId: any, LinesList: any}): Promise<any>;
}
declare module "@salesforce/apex/ChangeOrderTrackingController.getPaymentAppDetails" {
  export default function getPaymentAppDetails(param: {recordId: any}): Promise<any>;
}
