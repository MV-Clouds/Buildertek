declare module "@salesforce/apex/EmailSendController.getEmails" {
  export default function getEmails(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/EmailSendController.processEmail" {
  export default function processEmail(param: {email: any, Subject: any, Message: any}): Promise<any>;
}
