declare module "@salesforce/apex/ImportMasterSchedules.getMasterSchedule" {
  export default function getMasterSchedule(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ImportMasterSchedules.importMasterScheduleLines" {
  export default function importMasterScheduleLines(param: {scheduleRecIds: any, recordId: any, initialDate: any, projectManagerId: any}): Promise<any>;
}
