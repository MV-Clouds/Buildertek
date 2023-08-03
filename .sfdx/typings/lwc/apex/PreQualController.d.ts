declare module "@salesforce/apex/PreQualController.getTemplates" {
  export default function getTemplates(): Promise<any>;
}
declare module "@salesforce/apex/PreQualController.getPrimaryContacts" {
  export default function getPrimaryContacts(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreQualController.getContact" {
  export default function getContact(param: {conId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreQualController.getPreQualStage" {
  export default function getPreQualStage(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PreQualController.sendEmailToVendor" {
  export default function sendEmailToVendor(param: {recordId: any, emailTemplateId: any, to: any, cc: any, emailIds: any, filedata: any}): Promise<any>;
}
