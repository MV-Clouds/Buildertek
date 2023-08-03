declare module "@salesforce/apex/ViewVendorPaymentApplicationController.getcurrency" {
  export default function getcurrency(): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.getCommUser" {
  export default function getCommUser(): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.getUser" {
  export default function getUser(): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.createSheetLines" {
  export default function createSheetLines(param: {SovLineValues: any, recordId: any, vendorId: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.getListViews" {
  export default function getListViews(): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.getSovLines" {
  export default function getSovLines(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.deletesheetline" {
  export default function deletesheetline(param: {sheetlineIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.submitSOVForView" {
  export default function submitSOVForView(param: {recordId: any, todayDate: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.isSovSubmitted" {
  export default function isSovSubmitted(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.getSOVName" {
  export default function getSOVName(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.getSovforCurrency" {
  export default function getSovforCurrency(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.getSOVlineslistbyType" {
  export default function getSOVlineslistbyType(param: {SOVId: any, filter: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.delSlctRec" {
  export default function delSlctRec(param: {slctRec: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.getSovType" {
  export default function getSovType(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.getSOVs" {
  export default function getSOVs(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewVendorPaymentApplicationController.createSOVLines" {
  export default function createSOVLines(param: {selectedSOV: any, newSOV: any}): Promise<any>;
}
