declare module "@salesforce/apex/PreviewPurchaseOrderController.getTemplates" {
  export default function getTemplates(): Promise<any>;
}
declare module "@salesforce/apex/PreviewPurchaseOrderController.getPurchaseOrderLines" {
  export default function getPurchaseOrderLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewPurchaseOrderController.sendProposal" {
  export default function sendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any, fileid: any, attacheDocs: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewPurchaseOrderController.acceptandsendProposal" {
  export default function acceptandsendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any, Emailsubject: any, fileid: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewPurchaseOrderController.saveSign" {
  export default function saveSign(param: {recId: any, base64Data: any, contentType: any, signName: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewPurchaseOrderController.rejectSign" {
  export default function rejectSign(param: {recId: any, base64Data: any, contentType: any, signName: any, rejectionReason: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewPurchaseOrderController.rejectionWithReason" {
  export default function rejectionWithReason(param: {recId: any, base64Data: any, contentType: any, signName: any, rejectionReason: any}): Promise<any>;
}
