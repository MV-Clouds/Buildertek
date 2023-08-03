declare module "@salesforce/apex/TrainingSettingsController.getTSettings" {
  export default function getTSettings(): Promise<any>;
}
declare module "@salesforce/apex/TrainingSettingsController.saveSettings" {
  export default function saveSettings(param: {bTSettings: any}): Promise<any>;
}
declare module "@salesforce/apex/TrainingSettingsController.saveChunk" {
  export default function saveChunk(param: {fileName: any, base64Data: any, contentType: any}): Promise<any>;
}
declare module "@salesforce/apex/TrainingSettingsController.getAttachmentData" {
  export default function getAttachmentData(): Promise<any>;
}
