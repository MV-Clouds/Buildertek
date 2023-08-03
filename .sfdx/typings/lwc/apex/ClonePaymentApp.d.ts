declare module "@salesforce/apex/ClonePaymentApp.getUser" {
  export default function getUser(): Promise<any>;
}
declare module "@salesforce/apex/ClonePaymentApp.getIsNextPAyment" {
  export default function getIsNextPAyment(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ClonePaymentApp.cloneAnySobjet" {
  export default function cloneAnySobjet(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ClonePaymentApp.updateClonedRecord" {
  export default function updateClonedRecord(param: {recordId: any, newRecId: any}): Promise<any>;
}
