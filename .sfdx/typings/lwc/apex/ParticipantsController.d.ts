declare module "@salesforce/apex/ParticipantsController.getParticipantAccount" {
  export default function getParticipantAccount(param: {participantId: any}): Promise<any>;
}
declare module "@salesforce/apex/ParticipantsController.checkDuplicateSessions" {
  export default function checkDuplicateSessions(param: {participantEmail: any, CourseSessionRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ParticipantsController.checkMassDuplicateParticipants" {
  export default function checkMassDuplicateParticipants(param: {participantEmails: any, CourseSessionRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ParticipantsController.getParticipants" {
  export default function getParticipants(param: {couserSessionId: any}): Promise<any>;
}
declare module "@salesforce/apex/ParticipantsController.saveParticipants" {
  export default function saveParticipants(param: {records: any, CourseSessionRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/ParticipantsController.getContacts" {
  export default function getContacts(param: {accId: any, couserSessionId: any}): Promise<any>;
}
