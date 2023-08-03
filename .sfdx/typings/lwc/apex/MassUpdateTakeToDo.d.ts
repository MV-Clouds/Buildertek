declare module "@salesforce/apex/MassUpdateTakeToDo.getName" {
  export default function getName(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeToDo.getRecords" {
  export default function getRecords(param: {parentRecordId: any, fieldNameJson: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeToDo.getFieldSet" {
  export default function getFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeToDo.getDropDown" {
  export default function getDropDown(param: {objName: any, fieldName: any}): Promise<any>;
}
declare module "@salesforce/apex/MassUpdateTakeToDo.updateToDoItems" {
  export default function updateToDoItems(param: {recordId: any, updatedToDoItems: any, fieldSetName: any}): Promise<any>;
}
