declare module "@salesforce/apex/MassUpdateQuote.getName" {
  export default function getName(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateQuote.getCount" {
  export default function getCount(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateQuote.getRecords" {
  export default function getRecords(param: {parentRecordId: any, fieldNameJson: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateQuote.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateQuote.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateQuote.updateRecords" {
  export default function updateRecords(param: {recordId: any, updatedRecords: any, fieldSetName: any, pageNumber: any, pageSize: any, deleteLineitems: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateQuote.deleteQuoteItem" {
  export default function deleteQuoteItem(param: {quoteId: any, recordId: any, fieldSetName: any, pageNumber: any, pageSize: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateQuote.getadminvalues" {
  export default function getadminvalues(): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateQuote.getpricebooks" {
  export default function getpricebooks(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateQuote.ProductsthroughPB" {
  export default function ProductsthroughPB(param: {pbookId: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateQuote.QLGroups" {
  export default function QLGroups(): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateQuote.saveQuoteLine" {
  export default function saveQuoteLine(param: {quotelineList: any}): Promise<any>;
}
