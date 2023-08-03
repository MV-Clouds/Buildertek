declare module "@salesforce/apex/RFQDAO.awardVendor" {
  export default function awardVendor(param: {vendorId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getRfqTo" {
  export default function getRfqTo(): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getmulticurrency" {
  export default function getmulticurrency(): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getRfqConfig" {
  export default function getRfqConfig(param: {rfqId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getRfqToVendors" {
  export default function getRfqToVendors(param: {rfqId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getSelectedVendorData" {
  export default function getSelectedVendorData(param: {vendorId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getSelectedVendorsData" {
  export default function getSelectedVendorsData(param: {vendorId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.linkVendors" {
  export default function linkVendors(param: {rfqId: any, vendorIds: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.selectedVendors" {
  export default function selectedVendors(param: {rfqId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.deleteVendorLinks" {
  export default function deleteVendorLinks(param: {vendorIds: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.deleteVendor" {
  export default function deleteVendor(param: {vendorIds: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.sendRFQEmailToVendor" {
  export default function sendRFQEmailToVendor(param: {rfqToVendorLinkIds: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getBudgetData" {
  export default function getBudgetData(param: {pageNumber: any, pageSize: any, RFQRecId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.addAcceptedRFQToBudget" {
  export default function addAcceptedRFQToBudget(param: {recordId: any, budgetIds: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.updateRFQToVendorStatus" {
  export default function updateRFQToVendorStatus(param: {rfqToVendorLinkIds: any, Status: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.cancelRFQOnly" {
  export default function cancelRFQOnly(param: {recordId: any, reason: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getrfqstatus" {
  export default function getrfqstatus(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.cancelRFQvendor" {
  export default function cancelRFQvendor(param: {rfqToVendorLinkIds: any, recordId: any, reason: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.voidRFQvendor" {
  export default function voidRFQvendor(param: {rfqToVendorLinkIds: any, recordId: any, reason: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.sendRFQCancelEmailToVendor" {
  export default function sendRFQCancelEmailToVendor(param: {rfqToVendorLinkIds: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.linkRFQDocuments" {
  export default function linkRFQDocuments(param: {files: any, RFQid: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.linkRFQDocumentToVendor" {
  export default function linkRFQDocumentToVendor(param: {fileId: any, vendorId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.createRFQ" {
  export default function createRFQ(param: {rfqJson: any, rfqItemsJson: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getAllApprovedRFQ" {
  export default function getAllApprovedRFQ(param: {quotId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getRFQSearch" {
  export default function getRFQSearch(param: {quotId: any, searchKeyword: any, searchProject: any, searchVendor: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.createCOFromRFQ" {
  export default function createCOFromRFQ(param: {rfqId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.emailPreview" {
  export default function emailPreview(param: {rfqId: any, vendorId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.sendEmail" {
  export default function sendEmail(param: {parentRecordID: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getProduct" {
  export default function getProduct(param: {rfqItems: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.addProductsToList" {
  export default function addProductsToList(param: {rfqItemsList: any, rfqItem: any, count: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.createTask" {
  export default function createTask(param: {whoId: any, whatId: any, emailSubject: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.createMultipleTasks" {
  export default function createMultipleTasks(param: {contactIds: any, whatId: any, emailSubject: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getmasterRFQItems" {
  export default function getmasterRFQItems(): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.importRFQItems" {
  export default function importRFQItems(param: {Id: any, RFQId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.createRFQFromQuote" {
  export default function createRFQFromQuote(param: {QuoteId: any, selectQuoteItemId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getContentDocs1" {
  export default function getContentDocs1(param: {arecordId: any, rfqID: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getContentDocs" {
  export default function getContentDocs(param: {arecordId: any, rfqID: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.checkClosedRFIs" {
  export default function checkClosedRFIs(param: {rfqtovendorids: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.uploadFile" {
  export default function uploadFile(param: {parentId: any, fileName: any, base64Data: any, contentType: any, fileId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.saveTheChunk" {
  export default function saveTheChunk(param: {parentId: any, fileName: any, base64Data: any, contentType: any, fileId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.checkStatus" {
  export default function checkStatus(param: {rfqtovendorids: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getContactData" {
  export default function getContactData(param: {pageNumber: any, pageSize: any, recordId: any, vendorRFQId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.saverfqvendorcontacts" {
  export default function saverfqvendorcontacts(param: {recordid: any, accrecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.savecontacts" {
  export default function savecontacts(param: {contractId: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.getadminvalues" {
  export default function getadminvalues(): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.checkProtalUsers" {
  export default function checkProtalUsers(param: {recordId: any, selectedVendors: any}): Promise<any>;
}
declare module "@salesforce/apex/RFQDAO.saveRFQs" {
  export default function saveRFQs(param: {selectedRFQS: any, quoteId: any}): Promise<any>;
}
