declare module "@salesforce/apex/PreQualObject_MSAFormController.getMSASettings" {
  export default function getMSASettings(param: {RecordId: any, iscontractor: any}): Promise<any>;
}
declare module "@salesforce/apex/PreQualObject_MSAFormController.UpdateAccount" {
  export default function UpdateAccount(param: {recId: any, Name: any, Phone: any, Fax: any, City: any, State: any, Zip: any, Federal: any, Contractor: any, Address: any, subContractorBy: any, subContractorprintedName: any, subContractorVendorName: any, day: any, month: any, isContractor: any, year: any}): Promise<any>;
}
declare module "@salesforce/apex/PreQualObject_MSAFormController.saveSign" {
  export default function saveSign(param: {recId: any, base64Data: any, contentType: any, signName: any, contractorSignbase64Data: any, iscontractor: any}): Promise<any>;
}
declare module "@salesforce/apex/PreQualObject_MSAFormController.getJSonString" {
  export default function getJSonString(param: {jsonData: any, AccountId: any, FileId: any, isContractor: any, isresendMSA: any}): Promise<any>;
}
declare module "@salesforce/apex/PreQualObject_MSAFormController.getErrorMsg" {
  export default function getErrorMsg(): Promise<any>;
}
