declare module "@salesforce/apex/ChooseBTChecklist.getchecklistObjects" {
  export default function getchecklistObjects(): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.getAllGroup" {
  export default function getAllGroup(): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.getQuestions" {
  export default function getQuestions(): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.getQuestion" {
  export default function getQuestion(param: {QuestionIds: any}): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.createQuestions" {
  export default function createQuestions(param: {type: any, QuestionName: any, Options: any}): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.getPickValues" {
  export default function getPickValues(param: {objectName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.saveQuestion" {
  export default function saveQuestion(param: {QuestionType: any, QuestionText: any, Options: any, groupname: any, selectedgroup: any, recordid: any}): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.savingQuestion" {
  export default function savingQuestion(param: {QuestionType: any, QuestionText: any, Options: any, groupname: any, selectedgroup: any, recordid: any}): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.saveQuestions" {
  export default function saveQuestions(param: {QuestionType: any, QuestionText: any, Options: any, groupname: any, selectedgroup: any, recordid: any}): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.ChecklistConfiguration" {
  export default function ChecklistConfiguration(param: {QuestionIds: any, Name: any, SelectedObject: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.getCheckListCofigRecords" {
  export default function getCheckListCofigRecords(): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.geteditRecord" {
  export default function geteditRecord(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.editRecord" {
  export default function editRecord(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.getDeleteRecord" {
  export default function getDeleteRecord(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/ChooseBTChecklist.getDeleteQuestion" {
  export default function getDeleteQuestion(param: {recId: any}): Promise<any>;
}
