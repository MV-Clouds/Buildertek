public with sharing class InsertFutureEmailTemp {
    @future
    public static void insertTemplate() {
        EmailTemplate e = new EmailTemplate();
        e.Name = 'Test';
        e.DeveloperName = 'TestTemp';
        e.FolderId = [SELECT Id FROM Folder WHERE Name = 'Invoices AP'].Id;
        e.TemplateType = 'Text';
        insert e;
    }
}