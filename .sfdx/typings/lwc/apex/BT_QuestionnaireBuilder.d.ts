declare module "@salesforce/apex/BT_QuestionnaireBuilder.getSelection" {
  export default function getSelection(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getImageVisibility" {
  export default function getImageVisibility(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.retriveContentVersionId" {
  export default function retriveContentVersionId(param: {documentId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.checkIfCustomerCommunity" {
  export default function checkIfCustomerCommunity(): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.retrieveCitations" {
  export default function retrieveCitations(param: {adId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.deleteImage" {
  export default function deleteImage(param: {questionId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.updateQuestion" {
  export default function updateQuestion(param: {documentId: any, questionId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.saveQuestion" {
  export default function saveQuestion(param: {questions: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.saveAttributeTypeValue" {
  export default function saveAttributeTypeValue(param: {questions: any, choices: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.addNewAnswerChoices" {
  export default function addNewAnswerChoices(param: {choices: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.saveAttribute" {
  export default function saveAttribute(param: {questions: any, choices: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.retrieveControls" {
  export default function retrieveControls(param: {citationId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getQuestionInfo" {
  export default function getQuestionInfo(param: {priceBookId: any, productId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getpricebooks" {
  export default function getpricebooks(): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getselectOptionsforproductfamily" {
  export default function getselectOptionsforproductfamily(): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.retriveChangeNodeConfig" {
  export default function retriveChangeNodeConfig(): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.retriveAllowanceOverage" {
  export default function retriveAllowanceOverage(): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.retrieveQuestions" {
  export default function retrieveQuestions(param: {controlId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.updateQuestionGroup" {
  export default function updateQuestionGroup(param: {questions: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getAllProductAttributes" {
  export default function getAllProductAttributes(): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getProductColor" {
  export default function getProductColor(): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getProductFinish" {
  export default function getProductFinish(): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getProductOptionNumber" {
  export default function getProductOptionNumber(): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getProductCategory" {
  export default function getProductCategory(): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.addNewQuestion" {
  export default function addNewQuestion(param: {questionRecord: any, choices: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.addQuestion1" {
  export default function addQuestion1(param: {questionRecord: any, choices: any, childChoicesLevelOne: any, childChoicesLevelTwo: any, childChoicesLevelThree: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.createChoices" {
  export default function createChoices(param: {choices: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.updateCitationOrder" {
  export default function updateCitationOrder(param: {citations: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.updateControlOrder" {
  export default function updateControlOrder(param: {controls: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.deleteRecord" {
  export default function deleteRecord(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.deleteControlRecord" {
  export default function deleteControlRecord(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.deleteCheckRecord" {
  export default function deleteCheckRecord(param: {checkId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getObjectFieldSet" {
  export default function getObjectFieldSet(param: {fieldSetName: any, objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getSectionFields" {
  export default function getSectionFields(param: {adId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getControlDetails" {
  export default function getControlDetails(param: {fieldSetName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getQuestionFieldSet" {
  export default function getQuestionFieldSet(param: {fieldSetName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getFiles" {
  export default function getFiles(param: {fileIds: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.retrieveAllQuestionResults" {
  export default function retrieveAllQuestionResults(param: {selectionSheetid: any, sectionId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getTreeQueryParamters" {
  export default function getTreeQueryParamters(param: {selectionSheetId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getProjectName" {
  export default function getProjectName(param: {selectionSheetId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.submitSelectionType" {
  export default function submitSelectionType(param: {selectionType: any, checkresult: any, answerChoices: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.getChangeOrderIdExist" {
  export default function getChangeOrderIdExist(param: {projectId: any, optionName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_QuestionnaireBuilder.createChangeOrder" {
  export default function createChangeOrder(param: {optionName: any, projectName: any, optionOverage: any}): Promise<any>;
}
