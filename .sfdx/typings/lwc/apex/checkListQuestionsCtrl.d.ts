declare module "@salesforce/apex/checkListQuestionsCtrl.getAttachmentData" {
  export default function getAttachmentData(): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.getProjectName" {
  export default function getProjectName(param: {Ids: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.getAccountName" {
  export default function getAccountName(param: {Ids: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.getsubject" {
  export default function getsubject(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.getCheckListConfigurationData" {
  export default function getCheckListConfigurationData(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.getvalues" {
  export default function getvalues(param: {CheckQuestionIds: any, sub: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.signaturetext" {
  export default function signaturetext(): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.getQuestions" {
  export default function getQuestions(param: {CheckQuestionId: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.createchecklistquestion" {
  export default function createchecklistquestion(param: {QuestionString: any, recordId: any, checkName: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.sendchecklist" {
  export default function sendchecklist(param: {checklistId: any, recordId: any, Email: any, FieldName: any, isparent: any, parentObj: any, recipient: any, text: any, subject: any, contactEmail: any, selectCheckListName: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.getEmailFieldsList" {
  export default function getEmailFieldsList(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.getObjectLabelName" {
  export default function getObjectLabelName(param: {ObjAPIName: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.getinitialObjectFields" {
  export default function getinitialObjectFields(param: {ObjAPIName: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.getAllObjectFields" {
  export default function getAllObjectFields(param: {ObjAPIName: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.GetSecLevelFieldDetailscontroller" {
  export default function GetSecLevelFieldDetailscontroller(param: {ObjectName: any, FirstField: any, SecondField: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.GetFieldDetails" {
  export default function GetFieldDetails(param: {ObjectName: any, FirstField: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.validateEmail" {
  export default function validateEmail(param: {isparent: any, FieldName: any, recordId: any, parentObj: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.getContactEmail" {
  export default function getContactEmail(param: {ContactrecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/checkListQuestionsCtrl.sendEmail" {
  export default function sendEmail(): Promise<any>;
}
