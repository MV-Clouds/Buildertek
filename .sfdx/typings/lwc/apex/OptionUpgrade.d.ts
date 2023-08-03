declare module "@salesforce/apex/OptionUpgrade.getProductDetails" {
  export default function getProductDetails(param: {recordId: any, searchNameValue: any, searchTypeValue: any, searchManufacturerValue: any, searchFamilyValue: any, searchCategoryValue: any, selectedPriceBook: any, priceBookFilter: any}): Promise<any>;
}
declare module "@salesforce/apex/OptionUpgrade.upgradeOption" {
  export default function upgradeOption(param: {optionValue: any, productValue: any}): Promise<any>;
}
declare module "@salesforce/apex/OptionUpgrade.getProductFamily" {
  export default function getProductFamily(param: {searchFamilyValue: any}): Promise<any>;
}
declare module "@salesforce/apex/OptionUpgrade.getProductCategory" {
  export default function getProductCategory(param: {searchCategoryValue: any}): Promise<any>;
}
declare module "@salesforce/apex/OptionUpgrade.getProductType" {
  export default function getProductType(param: {searchTypeValue: any}): Promise<any>;
}
declare module "@salesforce/apex/OptionUpgrade.getProductName" {
  export default function getProductName(param: {searchNameValue: any}): Promise<any>;
}
declare module "@salesforce/apex/OptionUpgrade.getManufacturer" {
  export default function getManufacturer(param: {searchManufacturerValue: any}): Promise<any>;
}
declare module "@salesforce/apex/OptionUpgrade.getOptionRecord" {
  export default function getOptionRecord(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/OptionUpgrade.cloneOptionRecord" {
  export default function cloneOptionRecord(param: {optionRec: any, recordId: any}): Promise<any>;
}
