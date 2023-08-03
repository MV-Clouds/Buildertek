declare module "@salesforce/apex/sendMeetingController.getHTML" {
  export default function getHTML(param: {EmaiValue: any, ccValue: any, SubjectValue: any, recId: any}): Promise<any>;
}
declare module "@salesforce/apex/sendMeetingController.sendMail" {
  export default function sendMail(param: {atendeeList: any, ccContactList: any, EmaiValue: any, ccValue: any, SubjectValue: any, bodyvalue: any}): Promise<any>;
}
