public class PreQualProcessController {
    public String isPreview{get; set;}
    public String recordId{get; set;}
    public String documentURL{get; set;}
  //  public Boolean isSuccess{get; set;}
    public PreQualProcessController(){
        isPreview = ApexPages.currentPage().getParameters().get('preview');
        recordId = ApexPages.currentPage().getParameters().get('id');
      /*  if(ApexPages.currentPage().getParameters().get('isSuccess') != null){
        isSuccess = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isSuccess'));
        }
        else{
        isSuccess = false;
        } */

        system.debug('isPreview ------> '+isPreview);
        List<Document> docList = [SELECT Id, Name FROM Document WHERE Name =: 'Company Logo' LIMIT 1];
        system.debug('@@docList'+docList);
        //buildertek__Check_List_Settings__c sitesUrl = [SELECT Id, buildertek__Site_URL__c FROM buildertek__Check_List_Settings__c LIMIT 1];
       buildertek__MSA_Settings__c sitesUrl = [SELECT Id, buildertek__Site_URL__c FROM buildertek__MSA_Settings__c LIMIT 1];
         system.debug('@@@sitesUrl'+sitesUrl);
        //List<buildertek__Checklist_Objects__c> checkobj = [select id,Name from buildertek__Checklist_Objects__c where Name = 'Checklist Logo'];
        List<buildertek__Checklist_Objects__c> checkobj = [select id,Name from buildertek__Checklist_Objects__c where Name = 'PreQual Logo'];
        if(checkobj.size()>0){
        system.debug('@@@');
       Attachment Att = [select id,Name from attachment where parentId =: checkobj[0].id];
       
        documentURL = sitesUrl.buildertek__Site_URL__c+'/servlet/servlet.FileDownload?file='+att.id;
        system.debug('documentURL ------> '+documentURL);
        }
    }
}