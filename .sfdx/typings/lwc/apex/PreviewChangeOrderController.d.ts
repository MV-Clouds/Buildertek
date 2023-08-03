declare module "@salesforce/apex/PreviewChangeOrderController.getTemplates" {
  export default function getTemplates(): Promise<any>;
}
declare module "@salesforce/apex/PreviewChangeOrderController.getObjectContact" {
  export default function getObjectContact(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewChangeOrderController.getChangeOrderLines" {
  export default function getChangeOrderLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewChangeOrderController.sendProposal" {
  export default function sendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any, Emailsubject: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewChangeOrderController.acceptandsendProposal" {
  export default function acceptandsendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any, Emailsubject: any, fileid: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewChangeOrderController.saveSign" {
  export default function saveSign(param: {recId: any, base64Data: any, contentType: any, signName: any}): Promise<any>;
}
