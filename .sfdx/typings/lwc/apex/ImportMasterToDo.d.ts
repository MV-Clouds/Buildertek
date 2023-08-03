declare module "@salesforce/apex/ImportMasterToDo.getAllMaseterRecords" {
  export default function getAllMaseterRecords(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ImportMasterToDo.importToDoRecords" {
  export default function importToDoRecords(param: {recordId: any, selectedRecordId: any}): Promise<any>;
}
