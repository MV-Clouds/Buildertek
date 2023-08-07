declare module "@salesforce/apex/BT_NewGanttChartCls.getProject" {
  export default function getProject(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.chekIsOldGantt" {
  export default function chekIsOldGantt(): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getObjectTypeName" {
  export default function getObjectTypeName(param: {recorId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getholidays" {
  export default function getholidays(): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getPhaseDates" {
  export default function getPhaseDates(param: {scheduleId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getScheduleItemRecords" {
  export default function getScheduleItemRecords(param: {objApi: any, scheduleid: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getattachmentLength" {
  export default function getattachmentLength(param: {objApi: any, scheduleid: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.insertUpdateTask" {
  export default function insertUpdateTask(param: {taskFields: any, isUpdate: any, scheduleId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getAllContacts" {
  export default function getAllContacts(): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.deleteTasks" {
  export default function deleteTasks(param: {taskId: any, type: any, ScheduleId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getTask" {
  export default function getTask(param: {taskId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.updateHideGanttOnSch" {
  export default function updateHideGanttOnSch(param: {hideGantt: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.insertUpdateTaskList" {
  export default function insertUpdateTaskList(param: {taskJSON: any, isUpdate: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getEndDate" {
  export default function getEndDate(param: {sDate: any, eDate: any, duration: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getEndDateBeforeCellEdit" {
  export default function getEndDateBeforeCellEdit(param: {sDate: any, duration: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getDurationAfterCellEdit" {
  export default function getDurationAfterCellEdit(param: {sDate: any, eDate: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.pickListValueDynamically" {
  export default function pickListValueDynamically(param: {customObjInfo: any, selectPicklistApi: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.addCommentToRecord" {
  export default function addCommentToRecord(param: {schItem: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.addNotesCommentToRecord" {
  export default function addNotesCommentToRecord(param: {schItem: any, notes: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getNotesofRecord" {
  export default function getNotesofRecord(param: {schId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getAllNotes" {
  export default function getAllNotes(param: {schId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.saveResourceForRecord" {
  export default function saveResourceForRecord(param: {taskId: any, resourceId: any, resourceApiName: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.changeOriginalDates" {
  export default function changeOriginalDates(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.getRecordType" {
  export default function getRecordType(): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.updateTaskRecord" {
  export default function updateTaskRecord(param: {taskData: any}): Promise<any>;
}
declare module "@salesforce/apex/BT_NewGanttChartCls.setWBSValue" {
  export default function setWBSValue(param: {scheduleItemMap: any}): Promise<any>;
}
