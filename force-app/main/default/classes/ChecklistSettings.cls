public class ChecklistSettings {
   
    @AuraEnabled
    public static Id saveChunk(String fileName, String base64Data, String contentType) {
        list<buildertek__Checklist_Objects__c> checkobjlist = [select id,Name from buildertek__Checklist_Objects__c where Name = 'Checklist Logo'];
        string parentId = '';
        string filesId = '';
        if(!checkobjlist.isEmpty()){
            list<attachment> attlist = [select id from attachment where name = 'ChecklistLogo'];
             parentId = checkobjlist[0].id;
            if(!attlist.isEmpty()){
              delete attlist;
            }
                saveTheFile(parentId, fileName, base64Data, contentType);
        }
        else{
            buildertek__Checklist_Objects__c Objs = new buildertek__Checklist_Objects__c();
            Objs.Name = 'Checklist Logo';
            Objs.buildertek__Object_Label__c = 'Checklist Logo';
            insert Objs;
            parentId = Objs.id;
        }
        string fileId = '';
        if (checkobjlist.isEmpty()) {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        }
        return Id.valueOf(parentId);
    }
 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = 'ChecklistLogo';
        oAttachment.ContentType = contentType;
        insert oAttachment;
        return oAttachment.Id;
    }
 
   
      @auraEnabled
   public static string getAttachmentData(){
       buildertek__Checklist_Objects__c checkobj = [select id,Name from buildertek__Checklist_Objects__c where Name = 'Checklist Logo'];
       Attachment Att = [select id,Name from attachment where parentId =: checkobj.id];
       return Att.id;
   }
   @AuraEnabled
   public static string getCheckListfooter(){
       buildertek__Check_List_Settings__c sitesUrls = [SELECT Id,buildertek__Signature__c FROM buildertek__Check_List_Settings__c LIMIT 1];
       return sitesUrls.buildertek__Signature__c;
   }
     @AuraEnabled
   public static string getCheckListData(){
       buildertek__Check_List_Settings__c sitesUrl = [SELECT Id, buildertek__Site_URL__c FROM buildertek__Check_List_Settings__c LIMIT 1];
       return sitesUrl.buildertek__Site_URL__c;
   }
    @AuraEnabled
     public static void updateCheckListData(string siteURL ,string Text){
       List<buildertek__Check_List_Settings__c> sitesUrl = [SELECT Id, buildertek__Site_URL__c,buildertek__Signature__c FROM buildertek__Check_List_Settings__c LIMIT 1];
         if(sitesUrl.size()>0 ){
             sitesUrl[0].buildertek__Site_URL__c = siteURL;
             sitesUrl[0].buildertek__Signature__c = Text;
             update sitesUrl[0];
         }else{
            buildertek__Check_List_Settings__c site = new buildertek__Check_List_Settings__c(); 
             site.Name= 'Check List Settings';
             site.buildertek__Site_URL__c = siteURL;
             site.buildertek__Signature__c = Text;
             insert site;
         }
        
     }
   /* @AuraEnabled
    public static void updateCheckListDataText( string Text){
        List<buildertek__Check_List_Settings__c> Texts = [SELECT Id,buildertek__Signature__c FROM buildertek__Check_List_Settings__c ];
        if(Texts.size()>0 ){
            Texts[0].buildertek__Site_URL__c = Text;
            update Texts[0];
        }else{
            buildertek__Check_List_Settings__c textdata = new buildertek__Check_List_Settings__c(); 
            textdata.Name= 'Check List Setting';
            textdata.buildertek__Signature__c = Text;
            insert textdata;
        }
        
    }*/
}