declare module "@salesforce/apex/ContractDAO.createSubContract" {
  export default function createSubContract(param: {subContractJson: any, subContractItemsJson: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.createSubContractFromBudget" {
  export default function createSubContractFromBudget(param: {contractJson: any, contractItemsJson: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.getContractTemplates" {
  export default function getContractTemplates(): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.GetContractLines" {
  export default function GetContractLines(param: {contractId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.GetGroupedContractLines" {
  export default function GetGroupedContractLines(param: {contractId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.getProductPrice" {
  export default function getProductPrice(param: {productId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.getProductfamilyRecords" {
  export default function getProductfamilyRecords(param: {ObjectName: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.savecontractlineItemrec" {
  export default function savecontractlineItemrec(param: {Colines: any, contractId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.saveContractLineItem" {
  export default function saveContractLineItem(param: {contractRecord: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.deleteContractLineItem" {
  export default function deleteContractLineItem(param: {contractRecord: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.retrieveGroups" {
  export default function retrieveGroups(param: {contractId: any, pageNumber: any, recordToDisply: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.updateLineFromDataTable" {
  export default function updateLineFromDataTable(param: {items: any, groupId: any, contractId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.getFieldSet" {
  export default function getFieldSet(param: {fieldSetName: any, objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.updateGroupsOrder" {
  export default function updateGroupsOrder(param: {groups: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.deleteGroups" {
  export default function deleteGroups(param: {groups: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.deleteItem" {
  export default function deleteItem(param: {Items: any, groupId: any, contractId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.createContractItem" {
  export default function createContractItem(param: {contractItemsJSON: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.getcontractItem" {
  export default function getcontractItem(param: {contractLineRecord: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.updatecontractLineItem" {
  export default function updatecontractLineItem(param: {contractLineRecord: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.deleteQuoteItem" {
  export default function deleteQuoteItem(param: {quoteId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.deleteSelectedItems" {
  export default function deleteSelectedItems(param: {recordIds: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.groupValues" {
  export default function groupValues(param: {recordId: any, currencyFields: any, allFields: any, groupIds: any, recordToDisply: any, offset: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.getQuoteItemData" {
  export default function getQuoteItemData(param: {recordId: any, fieldsList: any, fieldString: any, recordToDisply: any, offset: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.prepareString" {
  export default function prepareString(param: {contractString: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.saveUpdatedValues" {
  export default function saveUpdatedValues(param: {contractItemList: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.getpricebooks" {
  export default function getpricebooks(): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.massUpdateContractLineItem" {
  export default function massUpdateContractLineItem(param: {contractLineRecords: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.duplicateContractLineItem" {
  export default function duplicateContractLineItem(param: {contractLineRecords: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.getpricebook" {
  export default function getpricebook(param: {ContractId: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.getProduct" {
  export default function getProduct(param: {poItems: any}): Promise<any>;
}
declare module "@salesforce/apex/ContractDAO.addProductsToList" {
  export default function addProductsToList(param: {POItems: any, POItem: any, count: any}): Promise<any>;
}
