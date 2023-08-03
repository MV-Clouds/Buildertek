declare module "@salesforce/apex/SOVSheetController.getUser" {
  export default function getUser(): Promise<any>;
}
declare module "@salesforce/apex/SOVSheetController.getContinuationSheetLines" {
  export default function getContinuationSheetLines(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/SOVSheetController.createSheetLines" {
  export default function createSheetLines(param: {SovLineValues: any, recordId: any}): Promise<any>;
}
