declare module "@salesforce/apex/PreviewContractController.getTemplates" {
  export default function getTemplates(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewContractController.getContractLines" {
  export default function getContractLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewContractController.getProposalImages" {
  export default function getProposalImages(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewContractController.sendProposal" {
  export default function sendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewContractController.saveSign" {
  export default function saveSign(param: {recId: any, base64Data: any, contentType: any, signName: any}): Promise<any>;
}
declare module "@salesforce/apex/PreviewContractController.acceptandsendProposal" {
  export default function acceptandsendProposal(param: {htmlBody: any, recordId: any, templateId: any, to: any, cc: any, Emailsubject: any, fileid: any}): Promise<any>;
}
