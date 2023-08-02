public class TrainingSettingsController {
    @AuraEnabled
    public static buildertek__Training_Settings__c getTSettings(){
        buildertek__Training_Settings__c bTSettings = new buildertek__Training_Settings__c();
        list<buildertek__Training_Settings__c> settingslist = new list<buildertek__Training_Settings__c>();
        settingslist = [Select Id,Name, 
                                                                 buildertek__Contact_Info__c,
                                                                 buildertek__Course_Completed_Email_Template__c,
                                                                 buildertek__Registration_Completed_Email_Template__c,
                                                                 buildertek__Registration_Email_Template__c,
                                         						 buildertek__Site_URL__c 
                                                                 from buildertek__Training_Settings__c
                                                                 WHERE Name = 'Training Settings'];
        system.debug('bTSettingsList-------'+settingslist );
        if(settingslist.size() > 0){
            bTSettings = settingslist[0];   
        }else{
            
        }                                                
        return bTSettings;
    }
    
    @AuraEnabled
    public static void saveSettings(buildertek__Training_Settings__c bTSettings){
        system.debug('bTSettings------'+bTSettings);
        bTSettings.Name = 'Training Settings';
        upsert bTSettings;
    }
    
    @AuraEnabled
    public static Id saveChunk(String fileName, String base64Data, String contentType) {
        
        list<buildertek__Admin_Interface_Node_Configuration__c> nodelist = [select id, Name from buildertek__Admin_Interface_Node_Configuration__c where Name='Training Settings'];
        //list<buildertek__Checklist_Objects__c> checkobjlist = [select id,Name from buildertek__Checklist_Objects__c where Name = 'Checklist Logo'];
        string parentId = '';
        string filesId = '';
        if(!nodelist.isEmpty()){
            list<attachment> attlist = [select id from attachment where name = 'TrainingLogo'];
            parentId = nodelist[0].id;
            if(!attlist.isEmpty()){
                delete attlist;
            }
            saveTheFile(parentId, fileName, base64Data, contentType);
        }
        else{
            buildertek__Admin_Interface_Node_Configuration__c Objs = new buildertek__Admin_Interface_Node_Configuration__c();
            Objs.Name = 'Training Settings';            
            insert Objs;
            parentId = Objs.id;
        }
        string fileId = '';
        if (nodelist.isEmpty()) {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        }
        return Id.valueOf(parentId);
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        system.debug('parentId--->'+parentId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = 'TrainingLogo';  //ChecklistLogo';
        oAttachment.ContentType = contentType;
        insert oAttachment;
        return oAttachment.Id;
    }
    
    
    @auraEnabled
    public static string getAttachmentData(){
        buildertek__Admin_Interface_Node_Configuration__c checkobj = [select id,Name from buildertek__Admin_Interface_Node_Configuration__c where Name = 'Training Settings' limit 1];
        Attachment Att = [select id,Name from attachment where parentId =: checkobj.id];
        return Att.id;
    }
}