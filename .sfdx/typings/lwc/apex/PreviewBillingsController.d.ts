declare module "@salesforce/apex/PreviewBillingsController.getTemplates" {
  export default function getTemplates(): Promise<any>;
}
declare module "@salesforce/apex/PreviewBillingsController.getInvoiceLines" {
  export default function getInvoiceLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewBillingsController.updateMemo" {
  export default function updateMemo(param: {recordId: any, memoValue: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewBillingsController.sendProposal" {
  export default function sendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any}): Promise<any>;
}
