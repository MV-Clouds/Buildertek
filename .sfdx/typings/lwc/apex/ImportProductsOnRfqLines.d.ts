declare module "@salesforce/apex/ImportProductsOnRfqLines.getTradeTypes" {
  export default function getTradeTypes(param: {RFQRecId: any}): Promise<any>;
}
declare module "@salesforce/apex/ImportProductsOnRfqLines.getprodlist" {
  export default function getprodlist(): Promise<any>;
}
declare module "@salesforce/apex/ImportProductsOnRfqLines.productfamilyList" {
  export default function productfamilyList(param: {ObjectName: any, parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/ImportProductsOnRfqLines.pricebookList" {
  export default function pricebookList(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ImportProductsOnRfqLines.getProducts" {
  export default function getProducts(param: {RFQRecId: any, productFamily: any, tradeType: any, productType: any, Product: any, category: any, priceBook: any, vendor: any}): Promise<any>;
}
declare module "@salesforce/apex/ImportProductsOnRfqLines.addProductToRfq" {
  export default function addProductToRfq(param: {productIds: any, RfqId: any}): Promise<any>;
}
declare module "@salesforce/apex/ImportProductsOnRfqLines.addProductToPO" {
  export default function addProductToPO(param: {productIds: any, RfqId: any}): Promise<any>;
}
