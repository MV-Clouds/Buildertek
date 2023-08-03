declare module "@salesforce/apex/PreviewPayableController.getTemplates" {
  export default function getTemplates(): Promise<any>;
}
declare module "@salesforce/apex/PreviewPayableController.getPayableLines" {
  export default function getPayableLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewPayableController.sendProposal" {
  export default function sendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any, emailIds: any}): Promise<any>;
}
