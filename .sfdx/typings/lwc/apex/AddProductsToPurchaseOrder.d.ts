declare module "@salesforce/apex/AddProductsToPurchaseOrder.getProducts" {
  export default function getProducts(param: {pageNumber: any, pageSize: any, RFQRecId: any, productFamily: any, tradeType: any, productType: any, Product: any, category: any, priceBook: any}): Promise<any>;
}
declare module "@salesforce/apex/AddProductsToPurchaseOrder.addProductToPO" {
  export default function addProductToPO(param: {productIds: any, RfqId: any}): Promise<any>;
}
