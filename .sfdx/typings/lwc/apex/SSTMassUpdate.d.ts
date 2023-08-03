declare module "@salesforce/apex/SSTMassUpdate.getName" {
  export default function getName(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/SSTMassUpdate.getRecords" {
  export default function getRecords(param: {parentRecordId: any, fieldNameJson: any}): Promise<any>;
}
declare module "@salesforce/apex/SSTMassUpdate.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/SSTMassUpdate.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/SSTMassUpdate.updateRecords" {
  export default function updateRecords(param: {recordId: any, updatedRecords: any, fieldSetName: any}): Promise<any>;
}
declare module "@salesforce/apex/SSTMassUpdate.deleteQuoteItem" {
  export default function deleteQuoteItem(param: {quoteId: any, recordId: any, fieldSetName: any}): Promise<any>;
}
