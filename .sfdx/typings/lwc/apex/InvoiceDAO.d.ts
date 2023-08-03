declare module "@salesforce/apex/InvoiceDAO.getProduct" {
  export default function getProduct(param: {coItems: any}): Promise<any>;
}
declare module "@salesforce/apex/InvoiceDAO.addProductsToList" {
  export default function addProductsToList(param: {COItems: any, COItem: any, count: any}): Promise<any>;
}
declare module "@salesforce/apex/InvoiceDAO.createCO" {
  export default function createCO(param: {coJson: any, coItemsJson: any, budgetlineid: any, descri: any}): Promise<any>;
}
declare module "@salesforce/apex/InvoiceDAO.getProductPricevalues" {
  export default function getProductPricevalues(param: {productId: any}): Promise<any>;
}
