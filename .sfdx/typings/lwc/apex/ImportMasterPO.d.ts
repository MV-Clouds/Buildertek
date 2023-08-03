declare module "@salesforce/apex/ImportMasterPO.getProjectPlan" {
  export default function getProjectPlan(): Promise<any>;
}
declare module "@salesforce/apex/ImportMasterPO.getMasterPO" {
  export default function getMasterPO(param: {planType: any, currentProjectId: any, vendorName: any}): Promise<any>;
}
declare module "@salesforce/apex/ImportMasterPO.getAllMasterPO" {
  export default function getAllMasterPO(param: {currentProjectId: any, vendorName: any}): Promise<any>;
}
declare module "@salesforce/apex/ImportMasterPO.importPurchaseOrder" {
  export default function importPurchaseOrder(param: {currentProjectId: any, selectedPOId: any}): Promise<any>;
}
