declare module "@salesforce/apex/UploadBillHandler.getFiles" {
  export default function getFiles(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadBillHandler.deleteFiles" {
  export default function deleteFiles(param: {sdocumentId: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadBillHandler.getLatestFiles" {
  export default function getLatestFiles(param: {documentIds: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadBillHandler.getImageResponse" {
  export default function getImageResponse(param: {resultId: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadBillHandler.getSobjectFields" {
  export default function getSobjectFields(param: {objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadBillHandler.getFieldMappings" {
  export default function getFieldMappings(): Promise<any>;
}
declare module "@salesforce/apex/UploadBillHandler.createFieldMapping" {
  export default function createFieldMapping(param: {parentFields: any, childFields: any, fieldMappingName: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadBillHandler.getExistingMapping" {
  export default function getExistingMapping(param: {fieldMappigId: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadBillHandler.updateFieldMapping" {
  export default function updateFieldMapping(param: {fieldMappingId: any, fieldMappingName: any, parentFields: any, childFields: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadBillHandler.createRecord" {
  export default function createRecord(param: {tableData: any, fieldsData: any, fieldMappingId: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadBillHandler.createIncoiceLineItems" {
  export default function createIncoiceLineItems(param: {invoiceId: any, invoiceLinesString: any}): Promise<any>;
}
declare module "@salesforce/apex/UploadBillHandler.getAllFieldMappings" {
  export default function getAllFieldMappings(): Promise<any>;
}
