declare module "@salesforce/apex/ImportQuotes.getMasterQuotes" {
  export default function getMasterQuotes(): Promise<any>;
}
declare module "@salesforce/apex/ImportQuotes.importMasterQuoteLines" {
  export default function importMasterQuoteLines(param: {quoteIds: any, recordId: any}): Promise<any>;
}
