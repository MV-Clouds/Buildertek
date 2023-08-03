declare module "@salesforce/apex/QuoteDAO.getRfqTo" {
  export default function getRfqTo(): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getmulticurrency" {
  export default function getmulticurrency(): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getpricebook" {
  export default function getpricebook(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getpricebooks" {
  export default function getpricebooks(): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getProductfamilyRecords" {
  export default function getProductfamilyRecords(param: {ObjectName: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getQuoteGrouping" {
  export default function getQuoteGrouping(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getQuoteTemplates" {
  export default function getQuoteTemplates(): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.sendQuote" {
  export default function sendQuote(param: {recordId: any, targetRecipientId: any, templateId: any, signatureBase64: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.createQuoteItem" {
  export default function createQuoteItem(param: {quoteItemsJSON: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.saveQuoteLineItemsValues" {
  export default function saveQuoteLineItemsValues(param: {quoteRec: any, markupvalue: any, marginvalue: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.insertQuoteLines" {
  export default function insertQuoteLines(param: {quoteLines: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getLookupData" {
  export default function getLookupData(param: {strObject: any, strSearch: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getBaseData" {
  export default function getBaseData(): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.insertQuoteLineItem" {
  export default function insertQuoteLineItem(param: {quoteItem: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getTasksInSchedule" {
  export default function getTasksInSchedule(param: {searchKeyWord: any, ObjectName: any, filter: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getTaskName" {
  export default function getTaskName(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getContractResource" {
  export default function getContractResource(param: {searchKeyWord: any, ObjectName: any, filter: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getContactName" {
  export default function getContactName(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getProductPrice" {
  export default function getProductPrice(param: {productId: any, pricebookId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getProductUOM" {
  export default function getProductUOM(param: {productId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.saveQuoteLineItem" {
  export default function saveQuoteLineItem(param: {quoteLineRecord: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.updateDescription" {
  export default function updateDescription(param: {groupId: any, groupDescription: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.updateGroupName" {
  export default function updateGroupName(param: {groupId: any, groupName: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.retrieveGroups" {
  export default function retrieveGroups(param: {quoteId: any, pageNumber: any, recordToDisply: any, status: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getFieldSet" {
  export default function getFieldSet(param: {fieldSetName: any, objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.insertQuoteLineGroup" {
  export default function insertQuoteLineGroup(param: {groupName: any, groupDescription: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getQuoteItem" {
  export default function getQuoteItem(param: {QuoteLineRecord: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getselectOptions" {
  export default function getselectOptions(param: {QuoteObject: any, QuoteField: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getQuoteRecord" {
  export default function getQuoteRecord(param: {quoteRecId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.saveQuoteSingleRec" {
  export default function saveQuoteSingleRec(param: {quoteRec: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.massDuplicateQuoteLineItem" {
  export default function massDuplicateQuoteLineItem(param: {quoteLineRecords: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.massUpdateQuoteLineItem" {
  export default function massUpdateQuoteLineItem(param: {quoteLineRecords: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.updateQuoteLineItem" {
  export default function updateQuoteLineItem(param: {QuoteLineRecord: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.cloneQuote" {
  export default function cloneQuote(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.updateGroupsOrder" {
  export default function updateGroupsOrder(param: {groups: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.deleteGroups" {
  export default function deleteGroups(param: {groups: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.deleteItem" {
  export default function deleteItem(param: {Items: any, groupId: any, quoteId: any, status: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.deleteLineItems" {
  export default function deleteLineItems(param: {quoteItemIds: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.deleteQuoteItem" {
  export default function deleteQuoteItem(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.deleteSelectedItems" {
  export default function deleteSelectedItems(param: {recordIds: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.prepareString" {
  export default function prepareString(param: {quoteString: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.saveUpdatedValues" {
  export default function saveUpdatedValues(param: {quoteItemList: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getquote" {
  export default function getquote(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.updatequote" {
  export default function updatequote(param: {recordId: any, markup: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getProject" {
  export default function getProject(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getProducts" {
  export default function getProducts(): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getProductRecordsByIds" {
  export default function getProductRecordsByIds(param: {Ids: any, PricebookId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.createQuoteLineGroup" {
  export default function createQuoteLineGroup(param: {productFamilyName: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getQuoteLineGroup" {
  export default function getQuoteLineGroup(param: {productList: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.QuoteLinesInsert" {
  export default function QuoteLinesInsert(param: {Quotelines: any, QuoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getQuoteGrouping2" {
  export default function getQuoteGrouping2(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getProducts2" {
  export default function getProducts2(): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getProductsthroughPriceBook" {
  export default function getProductsthroughPriceBook(param: {pbookId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getProductRecordsByIds1" {
  export default function getProductRecordsByIds1(param: {Ids: any, pBookId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.priceBookInProject" {
  export default function priceBookInProject(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.searchProdcutFamily" {
  export default function searchProdcutFamily(param: {searchedWord: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getQuoteLines" {
  export default function getQuoteLines(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getadminvalues" {
  export default function getadminvalues(): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getQuoteData" {
  export default function getQuoteData(param: {quoteId: any, pageNumber: any, recordToDisply: any, groupingList: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getPricebookList" {
  export default function getPricebookList(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getProductsthroughPriceBook2" {
  export default function getProductsthroughPriceBook2(param: {pbookId: any}): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getQuoteLineGroups" {
  export default function getQuoteLineGroups(): Promise<any>;
}
declare module "@salesforce/apex/QuoteDAO.getProductRecords" {
  export default function getProductRecords(param: {searchKeyWord: any, ObjectName: any, filter: any, parentId: any, prodctfamly: any}): Promise<any>;
}
