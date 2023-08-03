declare module "@salesforce/apex/QuickbooksConfigController.getQBConfigs" {
  export default function getQBConfigs(): Promise<any>;
}
declare module "@salesforce/apex/QuickbooksConfigController.authorizeQuickBook" {
  export default function authorizeQuickBook(param: {client_id: any, client_secret: any, scope: any}): Promise<any>;
}
declare module "@salesforce/apex/QuickbooksConfigController.getPages" {
  export default function getPages(): Promise<any>;
}
declare module "@salesforce/apex/QuickbooksConfigController.saveSettings" {
  export default function saveSettings(param: {qbConfigs: any}): Promise<any>;
}
