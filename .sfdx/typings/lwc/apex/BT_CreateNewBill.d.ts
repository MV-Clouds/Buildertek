declare module "@salesforce/apex/BT_CreateNewBill.createBill" {
  export default function createBill(param: {billJson: any, budgetlienId: any, BilllineitemsJson: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_CreateNewBill.getProduct" {
  export default function getProduct(param: {Billlineitems: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_CreateNewBill.addProductsToList" {
  export default function addProductsToList(param: {Billlineitems: any, billlineItem: any, count: any}): Promise<any>;
}
