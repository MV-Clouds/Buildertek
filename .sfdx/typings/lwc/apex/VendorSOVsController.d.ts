declare module "@salesforce/apex/VendorSOVsController.getcurrency" {
  export default function getcurrency(): Promise<any>;
}
declare module "@salesforce/apex/VendorSOVsController.getSovType" {
  export default function getSovType(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSOVsController.getSOVs" {
  export default function getSOVs(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSOVsController.getSOVLines" {
  export default function getSOVLines(param: {sovids: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSOVsController.ApproveSOV" {
  export default function ApproveSOV(param: {recId: any, sovIds: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSOVsController.rejectSOVs" {
  export default function rejectSOVs(param: {recId: any, sovIds: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSOVsController.createMasterSOV1" {
  export default function createMasterSOV1(param: {recId: any, sovlineids: any, sovIds: any}): Promise<any>;
}
declare module "@salesforce/apex/VendorSOVsController.createSOVLines" {
  export default function createSOVLines(param: {selectedSOV: any, newSOV: any}): Promise<any>;
}
