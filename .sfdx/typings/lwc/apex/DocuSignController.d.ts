declare module "@salesforce/apex/DocuSignController.sendDocEnv" {
  export default function sendDocEnv(param: {recordId: any, SelectedDoc: any}): Promise<any>;
}
declare module "@salesforce/apex/DocuSignController.getDocuments" {
  export default function getDocuments(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/DocuSignController.GetDocusignTemplates" {
  export default function GetDocusignTemplates(param: {recordId: any}): Promise<any>;
}
