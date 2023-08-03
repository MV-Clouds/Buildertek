declare module "@salesforce/apex/EmailServiceOutbound.getFileAttachments" {
  export default function getFileAttachments(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/EmailServiceOutbound.sendMailMethod" {
  export default function sendMailMethod(param: {mMail: any, ccEmail: any, mSubject: any, mbody: any, recid: any, msgId: any, files: any}): Promise<any>;
}
