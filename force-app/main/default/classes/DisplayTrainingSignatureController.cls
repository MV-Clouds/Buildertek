public class DisplayTrainingSignatureController {

    @auraEnabled
    public static string getAttachmentData(){
        buildertek__Admin_Interface_Node_Configuration__c checkobj = [select id,Name from buildertek__Admin_Interface_Node_Configuration__c where Name = 'BT Training'];
        Attachment Att = [select id,Name from attachment where parentId =: checkobj.id];
        return Att.id;
    }
}