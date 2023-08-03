declare module "@salesforce/apex/PreviewSalesOrderController.getTemplates" {
  export default function getTemplates(): Promise<any>;
}
declare module "@salesforce/apex/PreviewSalesOrderController.getSalesOrderLines" {
  export default function getSalesOrderLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewSalesOrderController.sendProposal" {
  export default function sendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any, Emailsubject: any}): Promise<any>;
}
