declare module "@salesforce/apex/AccountQualiicationController.getPreQualStage" {
  export default function getPreQualStage(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountQualiicationController.ChangeAccountStatus" {
  export default function ChangeAccountStatus(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountQualiicationController.ChangeAccountStatustoOld" {
  export default function ChangeAccountStatustoOld(param: {recordId: any, oldstatus: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountQualiicationController.saveFile" {
  export default function saveFile(param: {parentId: any, fileName: any, base64Data: any, contentType: any, fileId: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountQualiicationController.sendEmail" {
  export default function sendEmail(param: {recordId: any, filedata: any}): Promise<any>;
}
