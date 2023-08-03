declare module "@salesforce/apex/PricingRequestLinesController.getcurrency" {
  export default function getcurrency(): Promise<any>;
}
declare module "@salesforce/apex/PricingRequestLinesController.getSOVName" {
  export default function getSOVName(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingRequestLinesController.getSovLines" {
  export default function getSovLines(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingRequestLinesController.createSheetLines" {
  export default function createSheetLines(param: {SovLineValues: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PricingRequestLinesController.deletesheetline" {
  export default function deletesheetline(param: {sheetlineIds: any, recordId: any}): Promise<any>;
}
