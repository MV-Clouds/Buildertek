declare module "@salesforce/apex/CreateTakeOffPackage.getPackageTakeoff" {
  export default function getPackageTakeoff(): Promise<any>;
}
declare module "@salesforce/apex/CreateTakeOffPackage.getPackageTakeoffRecords" {
  export default function getPackageTakeoffRecords(param: {takeOffLinesIds: any, recordId: any, pageNumber: any, pageSize: any, packageLinesSearchTradeType: any, packageLinesSearchCategory: any, packageLinesSearchProductType: any, searchTradeType: any, searchCategory: any, searchProductType: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateTakeOffPackage.getFilteredTakeoffRecords" {
  export default function getFilteredTakeoffRecords(param: {takeOffLinesIds: any, recordId: any, pageNumber: any, pageSize: any, packageLinesSearchTradeType: any, packageLinesSearchCategory: any, packageLinesSearchProductType: any, searchTradeType: any, searchCategory: any, searchProductType: any, filteredTakeOffLines: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateTakeOffPackage.addGroupedLinesRecords" {
  export default function addGroupedLinesRecords(param: {takeOffLinesIds: any, recordId: any, pageNumber: any, pageSize: any, packageLinesSearchTradeType: any, packageLinesSearchCategory: any, packageLinesSearchProductType: any, searchTradeType: any, searchCategory: any, searchProductType: any, listOfIdsToInsert: any, groupName: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateTakeOffPackage.addIndividualTakeOffLinesRecords" {
  export default function addIndividualTakeOffLinesRecords(param: {takeOffLinesIds: any, recordId: any, pageNumber: any, pageSize: any, packageLinesSearchTradeType: any, packageLinesSearchCategory: any, packageLinesSearchProductType: any, searchTradeType: any, searchCategory: any, searchProductType: any, packageLineId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateTakeOffPackage.deleteTakeOffLinesRecords" {
  export default function deleteTakeOffLinesRecords(param: {takeOffLinesIds: any, recordId: any, pageNumber: any, pageSize: any, packageLinesSearchTradeType: any, packageLinesSearchCategory: any, packageLinesSearchProductType: any, searchTradeType: any, searchCategory: any, searchProductType: any, takeOffLinesToDeleteList: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateTakeOffPackage.getProjectTakeOffRec" {
  export default function getProjectTakeOffRec(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateTakeOffPackage.replaceTakeOffLinesRecords" {
  export default function replaceTakeOffLinesRecords(param: {takeOffLinesIdsToDelete: any, takeOffLinesIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateTakeOffPackage.replaceTakeOffLinesRecords2" {
  export default function replaceTakeOffLinesRecords2(param: {takeOffLinesIdsToDelete: any, takeOffLinesIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateTakeOffPackage.importPackageLinesRecords" {
  export default function importPackageLinesRecords(param: {takeOffLinesIds: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/CreateTakeOffPackage.importPackageLines" {
  export default function importPackageLines(param: {takeOffLinesIds: any, recordId: any}): Promise<any>;
}
