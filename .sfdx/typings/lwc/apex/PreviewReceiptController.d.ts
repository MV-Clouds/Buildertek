declare module "@salesforce/apex/PreviewReceiptController.getTemplates" {
  export default function getTemplates(): Promise<any>;
}
declare module "@salesforce/apex/PreviewReceiptController.getReceiptLines" {
  export default function getReceiptLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewReceiptController.sendProposal" {
  export default function sendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any}): Promise<any>;
}
