declare module "@salesforce/apex/InvoiceAR.getItem" {
  export default function getItem(param: {coItems: any}): Promise<any>;
}
declare module "@salesforce/apex/InvoiceAR.addProductsToList" {
  export default function addProductsToList(param: {COItems: any, COItem: any, count: any}): Promise<any>;
}
declare module "@salesforce/apex/InvoiceAR.createInvoiceAR" {
  export default function createInvoiceAR(param: {coJson: any, coItemsJson: any, budgetlineid: any, descri: any}): Promise<any>;
}
declare module "@salesforce/apex/InvoiceAR.getProductPricevalues" {
  export default function getProductPricevalues(param: {productId: any}): Promise<any>;
}
