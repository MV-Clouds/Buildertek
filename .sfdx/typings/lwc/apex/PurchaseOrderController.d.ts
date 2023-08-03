declare module "@salesforce/apex/PurchaseOrderController.getProject" {
  export default function getProject(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderController.getMasterRFQs" {
  export default function getMasterRFQs(param: {recordId: any, vendorName: any, status: any, description: any}): Promise<any>;
}
declare module "@salesforce/apex/PurchaseOrderController.sendMailToContact" {
  export default function sendMailToContact(param: {PoIds: any}): Promise<any>;
}
