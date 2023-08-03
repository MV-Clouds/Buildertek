declare module "@salesforce/apex/ParticipantUpdatesController.getCourseSession" {
  export default function getCourseSession(param: {coursessId: any}): Promise<any>;
}
declare module "@salesforce/apex/ParticipantUpdatesController.getParticipantName" {
  export default function getParticipantName(param: {recdId: any}): Promise<any>;
}
declare module "@salesforce/apex/ParticipantUpdatesController.getCourse" {
  export default function getCourse(param: {coursessId: any}): Promise<any>;
}
declare module "@salesforce/apex/ParticipantUpdatesController.getSkillLevel" {
  export default function getSkillLevel(): Promise<any>;
}
declare module "@salesforce/apex/ParticipantUpdatesController.getParticipants" {
  export default function getParticipants(param: {couserSessionId: any}): Promise<any>;
}
declare module "@salesforce/apex/ParticipantUpdatesController.updateParticipants" {
  export default function updateParticipants(param: {records: any, sendemailrecordIds: any}): Promise<any>;
}
declare module "@salesforce/apex/ParticipantUpdatesController.readFieldSet" {
  export default function readFieldSet(): Promise<any>;
}
declare module "@salesforce/apex/ParticipantUpdatesController.sendEmialToParticipants" {
  export default function sendEmialToParticipants(param: {recordIds: any, EmailTemplate: any}): Promise<any>;
}
declare module "@salesforce/apex/ParticipantUpdatesController.deleteparticipant" {
  export default function deleteparticipant(param: {deleterecordIds: any}): Promise<any>;
}
declare module "@salesforce/apex/ParticipantUpdatesController.resendEmialToParticipants" {
  export default function resendEmialToParticipants(param: {participantrecId: any, EmailTemplate: any}): Promise<any>;
}
