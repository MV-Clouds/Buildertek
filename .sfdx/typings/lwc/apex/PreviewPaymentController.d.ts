declare module "@salesforce/apex/PreviewPaymentController.getTemplates" {
  export default function getTemplates(): Promise<any>;
}
declare module "@salesforce/apex/PreviewPaymentController.getPaymentLines" {
  export default function getPaymentLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewPaymentController.sendProposal" {
  export default function sendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any}): Promise<any>;
}
