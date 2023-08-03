declare module "@salesforce/apex/CreateNewPO.getobjectName" {
  export default function getobjectName(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateNewPO.getPOAddress" {
  export default function getPOAddress(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateNewPO.contractdetails" {
  export default function contractdetails(param: {venderId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateNewPO.saveNewPO" {
  export default function saveNewPO(param: {recordId: any, vender: any, billToAddress: any, description: any, POtype: any, requiredDeliverydate: any, shiptoAddress: any, shiptoCity: any, shiptoState: any, shiptoCountry: any, shiptoZip: any, contractlinelist: any, objName: any}): Promise<any>;
}
