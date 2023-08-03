declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getRfqTo" {
  export default function getRfqTo(): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getChangeOrderBtValue" {
  export default function getChangeOrderBtValue(): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getPaymentApplications" {
  export default function getPaymentApplications(param: {budgetId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.InsertApplication" {
  export default function InsertApplication(param: {paymentApplicationsRecord: any, applicationName: any, periodDate: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.insertContinuationSheet" {
  export default function insertContinuationSheet(param: {continuationSheet: any, paymentApplicationId: any, applicationNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.createSheetLines" {
  export default function createSheetLines(param: {sheetLines: any, continuationId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getContinuationSheetLines" {
  export default function getContinuationSheetLines(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.updateSheetLines" {
  export default function updateSheetLines(param: {sheetLines: any, sheetId: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.updateFormula" {
  export default function updateFormula(param: {sheetItemId: any, sheetId: any, fieldName: any, fieldValue: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.deletesheetline" {
  export default function deletesheetline(param: {sheetlineIds: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.acceptsheetline" {
  export default function acceptsheetline(param: {sheetlineIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.rejectsheetline" {
  export default function rejectsheetline(param: {sheetlineIds: any, rejectreason: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.insertSheetLine" {
  export default function insertSheetLine(param: {sheetLineToInsert: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getApprovedCOs" {
  export default function getApprovedCOs(param: {projectId: any, commRecId: any, sfRecId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getVendorSubmittedPaymentApps" {
  export default function getVendorSubmittedPaymentApps(param: {projectId: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.importContinuationLines" {
  export default function importContinuationLines(param: {PAIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.createSheetLinesNew" {
  export default function createSheetLinesNew(param: {coIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getCommUser" {
  export default function getCommUser(): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.submitPAForView" {
  export default function submitPAForView(param: {recordId: any, todayDate: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getreason" {
  export default function getreason(param: {recordid: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getstatus" {
  export default function getstatus(param: {recordid: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.isSovSubmitted" {
  export default function isSovSubmitted(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getPaymentAppStatus" {
  export default function getPaymentAppStatus(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getadminvalues" {
  export default function getadminvalues(): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.saveSign" {
  export default function saveSign(param: {recId: any, base64Data: any, contentType: any, signName: any, LienTest: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getLienRelease" {
  export default function getLienRelease(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.AceptConnLines" {
  export default function AceptConnLines(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.getPaymentRecord" {
  export default function getPaymentRecord(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreatePaymentApplicationForBudget.checkPeriodTo" {
  export default function checkPeriodTo(param: {recordId: any}): Promise<any>;
}
