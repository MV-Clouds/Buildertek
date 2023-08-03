declare module "@salesforce/apex/ImportMasterQuotes.getMasterQuotes" {
  export default function getMasterQuotes(param: {searchKeyword: any}): Promise<any>;
}
declare module "@salesforce/apex/ImportMasterQuotes.getQuoteSearch" {
  export default function getQuoteSearch(param: {searchKeyword: any}): Promise<any>;
}
declare module "@salesforce/apex/ImportMasterQuotes.importMasterQuoteLines" {
  export default function importMasterQuoteLines(param: {quoteIds: any, recordId: any}): Promise<any>;
}
