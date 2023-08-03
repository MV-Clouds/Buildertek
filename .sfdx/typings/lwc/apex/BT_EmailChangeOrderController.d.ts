declare module "@salesforce/apex/BT_EmailChangeOrderController.getTemplates" {
  export default function getTemplates(param: {folderName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_EmailChangeOrderController.getbodyTemplates" {
  export default function getbodyTemplates(param: {folderName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_EmailChangeOrderController.gettemplatebodyContent" {
  export default function gettemplatebodyContent(param: {recordId: any, templateId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_EmailChangeOrderController.getFileAttachments" {
  export default function getFileAttachments(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_EmailChangeOrderController.getObjectContact" {
  export default function getObjectContact(param: {recordId: any, objectAPIName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_EmailChangeOrderController.getdetails" {
  export default function getdetails(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_EmailChangeOrderController.getsubject" {
  export default function getsubject(param: {recordId: any, objectAPIName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_EmailChangeOrderController.SendEmail" {
  export default function SendEmail(param: {to: any, cc: any, files: any, subject: any, body: any, recordId: any, templateId: any, pdfFileName: any, emailIds: any, Ids: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_EmailChangeOrderController.uploadFile" {
  export default function uploadFile(param: {parentId: any, fileName: any, base64Data: any, contentType: any, fileId: any}): Promise<any>;
}
