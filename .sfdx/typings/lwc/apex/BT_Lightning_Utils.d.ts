declare module "@salesforce/apex/BT_Lightning_Utils.sessionId" {
  export default function sessionId(): Promise<any>;
}
declare module "@salesforce/apex/BT_Lightning_Utils.columnsHeader" {
  export default function columnsHeader(param: {objectName: any, fieldSetAPI: any, groupingFields: any, rowActions: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Lightning_Utils.columnsModels" {
  export default function columnsModels(param: {objectName: any, fieldSetAPI: any, groupingFields: any, editableColumnList: any, rowActions: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Lightning_Utils.recordData" {
  export default function recordData(param: {objectName: any, filterConditions: any, fieldSetAPI: any, parentId: any, gridType: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Lightning_Utils.deleteRecords" {
  export default function deleteRecords(param: {objectName: any, selectedRecords: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Lightning_Utils.addRecordToRHS" {
  export default function addRecordToRHS(param: {ids: any, GridType: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Lightning_Utils.deleteRecordRHS" {
  export default function deleteRecordRHS(param: {ids: any, GridType: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Lightning_Utils.getFieldSet" {
  export default function getFieldSet(param: {objectName: any, FieldSetName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Lightning_Utils.getFieldSetForDataTable" {
  export default function getFieldSetForDataTable(param: {objectName: any, FieldSetName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Lightning_Utils.getListViews" {
  export default function getListViews(param: {SobjectType: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Lightning_Utils.getAllVendors" {
  export default function getAllVendors(param: {vendorName: any, ratingValue: any, tradeType: any, rfqId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_Lightning_Utils.getSelectedVendor" {
  export default function getSelectedVendor(param: {selectedvendorId: any}): Promise<any>;
}
