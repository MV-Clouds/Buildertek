declare module "@salesforce/apex/SubmittalDAO.getobjectName" {
  export default function getobjectName(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/SubmittalDAO.getCurrentLoggedInUser" {
  export default function getCurrentLoggedInUser(): Promise<any>;
}
declare module "@salesforce/apex/SubmittalDAO.createNewSubmittal" {
  export default function createNewSubmittal(param: {submittalRecord: any, userId: any, projectId: any}): Promise<any>;
}
declare module "@salesforce/apex/SubmittalDAO.saveTheChunkFile" {
  export default function saveTheChunkFile(param: {parentId: any, fileName: any, base64Data: any, contentType: any, fileId: any}): Promise<any>;
}
declare module "@salesforce/apex/SubmittalDAO.saveFiles" {
  export default function saveFiles(param: {recordId: any, fileName: any, base64Data: any}): Promise<any>;
}
declare module "@salesforce/apex/SubmittalDAO.appendToFile" {
  export default function appendToFile(param: {contentDocumentId: any, base64Data: any}): Promise<any>;
}
