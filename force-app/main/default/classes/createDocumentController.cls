public class createDocumentController {
    public buildertek__MSA_Settings__c msaSettings {get;set;}
    public string FileId{get;set;}
    public string contractorFileId{get;set;}
    public string iscontractor{get;set;}
    public innerclass inn {get;set;}    
    public class innerclass {
        public string jname {get;set;} 
        public string jaddress {get;set;}
        public string jcitystate {get;set;}
        public string jstate {get;set;}
        public string jzip {get;set;}
        public string jphone {get;set;}
        public string jfax {get;set;}
        public string jcontractorlicence {get;set;}
        public string jfederaltaxId {get;set;}
        public string jsubBy {get;set;}
        public string jsubprintedName {get;set;}
        public string jsubVendorName {get;set;}
        public string jsubDate {get;set;}
        public string jcontractorby {get;set;}
        public string jprintedName {get;set;} 
        public string jcontractorDate {get;set;}
        public string jday {get;set;}
        public string jmonth {get;set;}
        public string jyear {get;set;}
        
    }
    

    public createDocumentController(){
        String content = String.valueof(ApexPages.currentPage().getParameters().get('contentdata'));
        FileId = String.valueof(ApexPages.currentPage().getParameters().get('contractorFileId'));
        contractorFileId = String.valueof(ApexPages.currentPage().getParameters().get('FileId'));
         iscontractor = String.valueof(ApexPages.currentPage().getParameters().get('iscontractor'));
        system.debug('@@@iscontractor'+iscontractor);
        system.debug('@@@FileId'+FileId);
        system.debug('@@@contractorFileId'+contractorFileId);
        if(content != null){
            inn = (innerclass)System.JSON.deserialize(content, innerclass.class);
        }
        msaSettings = new buildertek__MSA_Settings__c();
        msaSettings = [Select Id, 
                                buildertek__City__c,
                                buildertek__Company_Full_Name__c,
                                buildertek__Company_Name__c,
                                buildertek__Fax__c,
                                buildertek__MSA_Template__c,
                                buildertek__Phone__c,
                                buildertek__State__c,
                                buildertek__Street__c,
                                buildertek__Website__c,
                                buildertek__Zipcode__c,
                                buildertek__MSA_PDF_Template__c
                                from buildertek__MSA_Settings__c
                                WHERE Name = :'MSA Settings'];
    }
 }