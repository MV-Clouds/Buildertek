declare module "@salesforce/apex/RFQLinesDAO.saveRFQItem" {
  export default function saveRFQItem(param: {rfqLines: any, costCode: any, rfqId: any, quantity: any, tradetype: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQLinesDAO.getProductfamilyRecords" {
  export default function getProductfamilyRecords(param: {ObjectName: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQLinesDAO.getpricebook" {
  export default function getpricebook(param: {BudgetId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQLinesDAO.getpricebooks" {
  export default function getpricebooks(): Promise<any>;
}
declare module "@salesforce/apex/RFQLinesDAO.getTradeTypes" {
  export default function getTradeTypes(): Promise<any>;
}
declare module "@salesforce/apex/RFQLinesDAO.RFQITEM" {
  export default function RFQITEM(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQLinesDAO.getRFQ" {
  export default function getRFQ(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQLinesDAO.getRFQLinesUsingProduct" {
  export default function getRFQLinesUsingProduct(): Promise<any>;
}
