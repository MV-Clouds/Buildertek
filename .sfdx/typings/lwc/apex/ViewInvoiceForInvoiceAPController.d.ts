declare module "@salesforce/apex/ViewInvoiceForInvoiceAPController.getTemplates" {
  export default function getTemplates(): Promise<any>;
}
declare module "@salesforce/apex/ViewInvoiceForInvoiceAPController.getInvoiceLines" {
  export default function getInvoiceLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewInvoiceForInvoiceAPController.getObjectContact" {
  export default function getObjectContact(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ViewInvoiceForInvoiceAPController.sendInvoice" {
  export default function sendInvoice(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any, emailIds: any, memovalue: any}): Promise<any>;
}
