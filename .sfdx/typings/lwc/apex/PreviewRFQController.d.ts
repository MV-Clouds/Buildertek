declare module "@salesforce/apex/PreviewRFQController.getTemplates" {
  export default function getTemplates(): Promise<any>;
}
declare module "@salesforce/apex/PreviewRFQController.getPurchaseOrderLines" {
  export default function getPurchaseOrderLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewRFQController.sendProposal" {
  export default function sendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any, fileid: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewRFQController.acceptandsendProposal" {
  export default function acceptandsendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any, Emailsubject: any, fileid: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewRFQController.saveSign" {
  export default function saveSign(param: {recId: any, base64Data: any, contentType: any, signName: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewRFQController.rejectSign" {
  export default function rejectSign(param: {recId: any, base64Data: any, contentType: any, signName: any, rejectionReason: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewRFQController.rejectionWithReason" {
  export default function rejectionWithReason(param: {recId: any, base64Data: any, contentType: any, signName: any, rejectionReason: any}): Promise<any>;
}
