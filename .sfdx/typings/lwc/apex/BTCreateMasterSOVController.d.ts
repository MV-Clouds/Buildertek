declare module "@salesforce/apex/BTCreateMasterSOVController.getSOVs" {
  export default function getSOVs(): Promise<any>;
}
declare module "@salesforce/apex/BTCreateMasterSOVController.getSOVLines" {
  export default function getSOVLines(param: {sovids: any}): Promise<any>;
}
declare module "@salesforce/apex/BTCreateMasterSOVController.createMasterSOV" {
  export default function createMasterSOV(param: {recId: any, sovlineids: any, sovIds: any}): Promise<any>;
}
declare module "@salesforce/apex/BTCreateMasterSOVController.rejectSelectedSOVs" {
  export default function rejectSelectedSOVs(param: {sovIds: any}): Promise<any>;
}
