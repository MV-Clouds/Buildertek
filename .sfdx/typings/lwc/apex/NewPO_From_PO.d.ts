declare module "@salesforce/apex/NewPO_From_PO.getPOLines" {
  export default function getPOLines(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/NewPO_From_PO.createNewPo" {
  export default function createNewPo(param: {recordId: any, POLineList: any}): Promise<any>;
}
