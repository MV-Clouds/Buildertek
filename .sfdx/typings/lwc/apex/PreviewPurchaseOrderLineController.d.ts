declare module "@salesforce/apex/PreviewPurchaseOrderLineController.getTemplates" {
  export default function getTemplates(): Promise<any>;
}
declare module "@salesforce/apex/PreviewPurchaseOrderLineController.getvendorcon" {
  export default function getvendorcon(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewPurchaseOrderLineController.getPurchaseOrderLines" {
  export default function getPurchaseOrderLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewPurchaseOrderLineController.sendPurchaseOrderLineRelease" {
  export default function sendPurchaseOrderLineRelease(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any, Emailsubject: any, fileid: any}): Promise<any>;
}
