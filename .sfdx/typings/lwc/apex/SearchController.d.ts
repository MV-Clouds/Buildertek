declare module "@salesforce/apex/SearchController.search" {
  export default function search(param: {objectName: any, fields: any, searchTerm: any}): Promise<any>;
}
declare module "@salesforce/apex/SearchController.searchContact" {
  export default function searchContact(param: {searchTerm: any}): Promise<any>;
}
