declare module "@salesforce/apex/PreQualObjectQualificationController.getPreQualStage" {
  export default function getPreQualStage(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreQualObjectQualificationController.ChangeAccountStatus" {
  export default function ChangeAccountStatus(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreQualObjectQualificationController.ChangeAccountStatustoOld" {
  export default function ChangeAccountStatustoOld(param: {recordId: any, oldstatus: any}): Promise<any>;
}
declare module "@salesforce/apex/PreQualObjectQualificationController.saveFile" {
  export default function saveFile(param: {parentId: any, fileName: any, base64Data: any, contentType: any, fileId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreQualObjectQualificationController.sendEmail" {
  export default function sendEmail(param: {recordId: any, filedata: any}): Promise<any>;
}
