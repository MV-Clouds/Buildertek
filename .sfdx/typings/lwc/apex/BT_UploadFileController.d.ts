declare module "@salesforce/apex/BT_UploadFileController.insertFiles" {
  export default function insertFiles(param: {fileObj: any, mainObjectFieldAPI: any, mainObjectId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_UploadFileController.insertFile" {
  export default function insertFile(param: {fileObjJSON: any, mainObjectFieldAPI: any, mainObjectId: any, selectedFiles: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_UploadFileController.InsertAttachment" {
  export default function InsertAttachment(param: {IdsList: any, mainObjectFieldAPI: any, mainObjectId: any, selectedFiles: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_UploadFileController.AddFileAttachments" {
  export default function AddFileAttachments(param: {IdsList: any, mainObjectFieldAPI: any, mainObjectId: any, selectedFiles: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_UploadFileController.getConfig" {
  export default function getConfig(param: {mofa: any, moi: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_UploadFileController.getFiles" {
  export default function getFiles(param: {recordId: any, objectAPI: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_UploadFileController.getRecentFiles" {
  export default function getRecentFiles(param: {recordId: any, objectAPI: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_UploadFileController.getRelatedFiles" {
  export default function getRelatedFiles(param: {recordId: any, objectAPI: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_UploadFileController.getFilesUploaded" {
  export default function getFilesUploaded(param: {recordIds: any, mainObjectId: any, mainObjectFieldAPI: any, selectedFiles: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_UploadFileController.gets3Key" {
  export default function gets3Key(): Promise<any>;
}
