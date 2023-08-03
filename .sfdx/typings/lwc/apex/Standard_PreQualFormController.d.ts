declare module "@salesforce/apex/Standard_PreQualFormController.getMetaData" {
  export default function getMetaData(): Promise<any>;
}
declare module "@salesforce/apex/Standard_PreQualFormController.getIsMultiPreQual" {
  export default function getIsMultiPreQual(): Promise<any>;
}
declare module "@salesforce/apex/Standard_PreQualFormController.getAccountRecord" {
  export default function getAccountRecord(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/Standard_PreQualFormController.createPreQual" {
  export default function createPreQual(param: {boxData: any, recId: any, accountRecord: any, ref1: any, ref2: any, ref3: any, projectlist1: any, projectlist2: any, projectlist3: any}): Promise<any>;
}
declare module "@salesforce/apex/Standard_PreQualFormController.createMultiPreQual" {
  export default function createMultiPreQual(param: {boxData: any, recId: any, preQualRecord: any, ref1: any, ref2: any, ref3: any, projectlist1: any, projectlist2: any, projectlist3: any}): Promise<any>;
}
declare module "@salesforce/apex/Standard_PreQualFormController.getparameters" {
  export default function getparameters(): Promise<any>;
}
declare module "@salesforce/apex/Standard_PreQualFormController.uploadFilesInSalesforce" {
  export default function uploadFilesInSalesforce(param: {fileData: any}): Promise<any>;
}
declare module "@salesforce/apex/Standard_PreQualFormController.checkEnableBox" {
  export default function checkEnableBox(): Promise<any>;
}
declare module "@salesforce/apex/Standard_PreQualFormController.saveFile" {
  export default function saveFile(param: {parentId: any, fileName: any, base64Data: any, contentType: any, fileId: any}): Promise<any>;
}
