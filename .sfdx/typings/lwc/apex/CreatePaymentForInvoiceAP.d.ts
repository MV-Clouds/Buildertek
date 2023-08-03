declare module "@salesforce/apex/CreatePaymentForInvoiceAP.getPaymentLines" {
  export default function getPaymentLines(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentForInvoiceAP.createSovLines" {
  export default function createSovLines(param: {recordId: any, invoiceLineList: any, lineIds: any, invoiceId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentForInvoiceAP.getFieldSet" {
  export default function getFieldSet(param: {objectName: any, fieldSetName: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentForInvoiceAP.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
