declare module "@salesforce/apex/PreviewQuoteController.getTemplates" {
  export default function getTemplates(): Promise<any>;
}
declare module "@salesforce/apex/PreviewQuoteController.getObjectContact" {
  export default function getObjectContact(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewQuoteController.getQuoteLines" {
  export default function getQuoteLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewQuoteController.getProposalImages" {
  export default function getProposalImages(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewQuoteController.sendProposal" {
  export default function sendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any, emailIds: any, memovalue: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewQuoteController.acceptandsendProposal" {
  export default function acceptandsendProposal(param: {signName: any, htmlBody: any, recordId: any, templateId: any, to: any, cc: any, fileid: any, emailIds: any, memovalue: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewQuoteController.getBlobBody" {
  export default function getBlobBody(param: {recordId: any, templateId: any, fileid: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewQuoteController.createTask" {
  export default function createTask(param: {whatId: any, emailSubject: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewQuoteController.saveSign" {
  export default function saveSign(param: {recId: any, base64Data: any, contentType: any, signName: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewQuoteController.getmemoval" {
  export default function getmemoval(param: {recordId: any}): Promise<any>;
}
