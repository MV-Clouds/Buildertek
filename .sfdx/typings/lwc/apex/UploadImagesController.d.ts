declare module "@salesforce/apex/UploadImagesController.getFiles" {
  export default function getFiles(param: {recordIds: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadImagesController.deleteFiles" {
  export default function deleteFiles(param: {filesList: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadImagesController.insertProposalImages" {
  export default function insertProposalImages(param: {parentId: any, description: any, filesList: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadImagesController.getUploadedFiles" {
  export default function getUploadedFiles(param: {productId: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadImagesController.deleteProductFile" {
  export default function deleteProductFile(param: {contentDocumentId: any, productId: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadImagesController.updateQuestions" {
  export default function updateQuestions(param: {documentId: any, productId: any}): Promise<any>;
}
