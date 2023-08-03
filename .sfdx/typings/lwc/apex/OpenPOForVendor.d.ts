declare module "@salesforce/apex/OpenPOForVendor.getobjectName" {
  export default function getobjectName(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpenPOForVendor.openPO" {
  export default function openPO(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/OpenPOForVendor.createItem" {
  export default function createItem(param: {recordId: any, purchaseOrderList: any}): Promise<any>;
}
declare module "@salesforce/apex/OpenPOForVendor.createReceiptItem" {
  export default function createReceiptItem(param: {receiptObj: any, POList: any}): Promise<any>;
}
