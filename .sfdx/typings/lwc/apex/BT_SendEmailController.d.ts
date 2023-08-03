declare module "@salesforce/apex/BT_SendEmailController.getTemplates" {
  export default function getTemplates(param: {folderName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.getbodyTemplates" {
  export default function getbodyTemplates(param: {folderName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.gettemplatebodyContent" {
  export default function gettemplatebodyContent(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.getFileAttachments" {
  export default function getFileAttachments(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.getObjectContact" {
  export default function getObjectContact(param: {recordId: any, objectAPIName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.getsubject" {
  export default function getsubject(param: {recordId: any, objectAPIName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.SendEmail" {
  export default function SendEmail(param: {to: any, cc: any, files: any, subject: any, body: any, recordId: any, templateId: any, pdfFileName: any, emailIds: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.uploadFile" {
  export default function uploadFile(param: {parentId: any, fileName: any, base64Data: any, contentType: any, fileId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.getTemplatesBody" {
  export default function getTemplatesBody(): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.getTemplatesForSignedChange" {
  export default function getTemplatesForSignedChange(): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.getChangeOrderLines" {
  export default function getChangeOrderLines(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.saveSign" {
  export default function saveSign(param: {recId: any, base64Data: any, contentType: any, signName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.sendEmailApex1" {
  export default function sendEmailApex1(param: {to: any, cc: any, emailsubject: any, emailBody: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_SendEmailController.getProNameAndAutoNum" {
  export default function getProNameAndAutoNum(param: {recordId: any, objectAPIName: any}): Promise<any>;
}
