public with sharing class PreQualificationTemplatesController {
    @AuraEnabled
    public static String getSelectedTemplates(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Selected_Templates__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Pre Qualification Configuration'];
        return adminInterfaceNodeConfigurations.buildertek__Selected_Templates__c;
    }
    
    @AuraEnabled
    public static List<ApexPage> getTemplates(){
        List<ApexPage> pagesList = [SELECT Id, Name FROM APexPage ORDER BY Name ASC];
        return pagesList;
    }
    
    @AuraEnabled
    public static void saveNode(String selectedTemplate){
        system.debug('selectedTemplate ------> '+selectedTemplate);
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Selected_Templates__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Pre Qualification Configuration'];  
                                                                                             
        
        List<ApexPage> ListPage = [SELECT Id, Name,NamespacePrefix FROM APexPage where Name =:selectedTemplate limit 1]; 
        if(!ListPage.isEmpty()){
            if(ListPage[0].NamespacePrefix != null && ListPage[0].NamespacePrefix != ''){
            adminInterfaceNodeConfigurations.buildertek__Selected_Templates__c = ListPage[0].NamespacePrefix+'__'+selectedTemplate;
            }else{
                adminInterfaceNodeConfigurations.buildertek__Selected_Templates__c = selectedTemplate;
            }
        }
        else{
            adminInterfaceNodeConfigurations.buildertek__Selected_Templates__c = selectedTemplate;
        }
        update adminInterfaceNodeConfigurations;
    }
    
    
     @AuraEnabled
   public static string getCheckListData(){
       buildertek__Check_List_Settings__c sitesUrl = [SELECT Id, buildertek__Site_URL__c FROM buildertek__Check_List_Settings__c LIMIT 1];
       return sitesUrl.buildertek__Site_URL__c;
   }
    @AuraEnabled
    public static string getAttachmentData(){
        buildertek__Checklist_Objects__c checkobj = [select id,Name from buildertek__Checklist_Objects__c where Name = 'PreQual Logo'];
        Attachment Att = [select id,Name from attachment where parentId =: checkobj.id];
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@'+Att);
        return Att.id;
    }
     @AuraEnabled
   public static string getCheckListfooter(){
       buildertek__Check_List_Settings__c sitesUrls = [SELECT Id,buildertek__Signature__c FROM buildertek__Check_List_Settings__c LIMIT 1];
       return sitesUrls.buildertek__Signature__c;
   }
    
     @AuraEnabled
    public static Id saveChunks(String fileName, String base64Data, String contentType) {
        list<buildertek__Checklist_Objects__c> checkobjlist = [select id,Name from buildertek__Checklist_Objects__c where Name = 'PreQual Logo'];
        string parentId = '';
        string filesId = '';
        if(!checkobjlist.isEmpty()){
            list<attachment> attlist = [select id from attachment where name = 'PreQualLogo'];
            parentId = checkobjlist[0].id;
            if(!attlist.isEmpty()){
                delete attlist;
            }
            saveTheFile(parentId, fileName, base64Data, contentType);
        }
        else{
            buildertek__Checklist_Objects__c Objs = new buildertek__Checklist_Objects__c();
            Objs.Name = 'PreQual Logo';
            Objs.buildertek__Object_Label__c = 'PreQual Logo';
            insert Objs;
            parentId = Objs.id;
        }
        string fileId = '';
        if (checkobjlist.isEmpty()) {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        }
        return Id.valueOf(parentId);
    }
    
    @AuraEnabled
   public static InnerCheck getPreQualSettings(){
       buildertek__Pre_Qual_Settings__c preQualSettings = [SELECT Id,buildertek__Is_Multiple_PreQual__c,buildertek__Enable_Box__c FROM buildertek__Pre_Qual_Settings__c LIMIT 1];
       InnerCheck  inCheck  =  new InnerCheck();
       inCheck.isMultiPreQual = preQualSettings.buildertek__Is_Multiple_PreQual__c;
         inCheck.isEnableBox = preQualSettings.buildertek__Enable_Box__c;
       return inCheck;
   }
    
    @AuraEnabled
   public static void handlePreQualSettings(boolean isMulti){
       List<buildertek__Pre_Qual_Settings__c> preQualSettings = [SELECT Id,buildertek__Is_Multiple_PreQual__c FROM buildertek__Pre_Qual_Settings__c Where name ='PreQualSettings' LIMIT 1];
       if(preQualSettings.size()>0){
          preQualSettings[0].buildertek__Is_Multiple_PreQual__c = isMulti;
          update preQualSettings; 
       }else{
          buildertek__Pre_Qual_Settings__c ps = new buildertek__Pre_Qual_Settings__c();
           ps.name = 'PreQualSettings';
           ps.buildertek__Is_Multiple_PreQual__c = isMulti;
           insert ps;
       }
       
   }
    
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        system.debug(EncodingUtil.base64Decode(base64Data));
        system.debug(base64Data);
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = 'PreQualLogo';
        oAttachment.ContentType = contentType;
        insert oAttachment;
        return oAttachment.Id;

        /*ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.Title = 'Test File'; 
        conVer.PathOnClient = 'Test File';
        conVer.VersionData = EncodingUtil.base64Decode(base64Data);  
        insert conVer;

         ContentVersion cv = [select id,ContentDocumentId from ContentVersion where id =: conVer.id];
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = cv.contentDocumentId;
        cDe.LinkedEntityId = parentId; // you can use objectId,GroupId etc
        cDe.ShareType = 'V'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        //Insert content document link
        insert cDe ;
        return conVer.id;*/
    }
     /* @AuraEnabled
    public static string getAttachmentData(){
        buildertek__Checklist_Objects__c checkobj = [select id,Name from buildertek__Checklist_Objects__c where Name = 'PreQual Logo'];
        Attachment Att = [select id,Name from attachment where parentId =: checkobj.id];
        return Att.id;
    }*/
    
    public class InnerCheck{
         @AuraEnabled public Boolean isMultiPreQual;
        @AuraEnabled public Boolean isEnableBox;
    }
    
     @AuraEnabled
   public static Boolean updateEnableBox(boolean enableBox){
       List<buildertek__Pre_Qual_Settings__c> preQualSettings = [SELECT Id,buildertek__Enable_Box__c FROM buildertek__Pre_Qual_Settings__c Where name ='PreQualSettings' LIMIT 1];
       if(preQualSettings.size()>0){
          preQualSettings[0].buildertek__Enable_Box__c = enableBox;
          update preQualSettings; 
           return preQualSettings[0].buildertek__Enable_Box__c;
       }else{
          buildertek__Pre_Qual_Settings__c ps = new buildertek__Pre_Qual_Settings__c();
           ps.name = 'PreQualSettings';
           ps.buildertek__Enable_Box__c = enableBox;
           insert ps;
           return ps.buildertek__Enable_Box__c;
       }
       
   }
}