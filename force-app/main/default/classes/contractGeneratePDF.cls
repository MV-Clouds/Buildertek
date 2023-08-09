public with sharing class contractGeneratePDF {
     public id id { get; set; }
     public String contId { get; set; }
     public list<user> userList { get; set; }
     public list<contact> contactlist { get; set; }
     public string inputtext { get; set; }
     public string contactinputtext { get; set; }
     public string selectedid { get; set; }
     public Quote_Template__c ContractInfoList { get; set; }
     public list<buildertek__Contract_Item__c> contractLineItemList { get; set; }
     public list<buildertek__Contract_Item__c> contractLineItemNoneProdList  {get;set;}
     public list<Email_Line_Item_Column__c> emailLineItemList  {get;set;}
     public map<string,string> mapLineItemFields{get;set;}
     public list<string> LineItemAPIFields{get;set;}
     public list<string> LineItemLabelFields{get;set;}
     
     public buildertek__Contract__c contractInfo{get;set;}
     public string  sendCC{get;set;}
     public string  userCC{get;set;}
     public string  userMails{get;set;}
     public buildertek__Contract__c myCustomObject;
     public Email_Template__c EmailTemplateInfo{get;set;}
     public string SiteName{get;set;}
     public string SiteUrl{get;set;}
      
     public Task Taskhistory {get;set;}
     private ApexPages.StandardController stdController;
     public String redirectUrl {public get; private set;}
     public Boolean shouldRedirect {public get; private set;}
     public Organization org1;
 

     public list<DocTemplate_Page__c> contractPageList {get;set;}
     
     
     public contractGeneratePDF(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        //sObject sobj = Schema.getGlobalDescribe().get('buildertek__Contract__c').newSObject();
        myCustomObject = (buildertek__Contract__c) stdController.getRecord();
        id = myCustomObject.id;
         list<buildertek__Contract__c> contractList;
         if (Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Doc_Template__c.isAccessible() &&
             Schema.sObjectType.buildertek__Contract__c.fields.id.isAccessible()) {
         contractList = [Select id,Doc_Template__c From buildertek__Contract__c Where id=:id];
         }
         if(contractList.size() > 0){
         selectedid = contractList[0].Doc_Template__c;
         }
          if (Schema.sObjectType.user.fields.id.isAccessible()&&Schema.sObjectType.user.fields.name.isAccessible()&&Schema.sObjectType.user.fields.email.isAccessible()) {
         userList = [select id, name,email from user limit 1000];
          }
           if (Schema.sObjectType.contact.fields.name.isAccessible()
                &&Schema.sObjectType.contact.fields.id.isAccessible()
            &&Schema.sObjectType.contact.fields.FirstName.isAccessible()
           &&Schema.sObjectType.contact.fields.LastName.isAccessible()) {
         contactlist = [select id, name,FirstName,LastName from contact limit 100];
           }
      
         ContractInfoList = new Quote_Template__c();
         contractPageList = new list<DocTemplate_Page__c>();
         contractLineItemList = new list<buildertek__Contract_Item__c>();
         contractLineItemNoneProdList = new list<buildertek__Contract_Item__c>();
         emailLineItemList = new list<Email_Line_Item_Column__c>();
         LineItemAPIFields = new list<string>();
         LineItemLabelFields = new list<string>();
         mapLineItemFields = new map<string,string>();

         contractInfo = new buildertek__Contract__c();
         shouldRedirect = false;
         preview();
         if(Schema.sObjectType.Organization.fields.OrganizationType.isAccessible()){
		 org1 = [SELECT OrganizationType FROM Organization LIMIT 1];
         }
	} 


     public void userValue(){
        
        for(user q:userList){
            if(inputtext == q.name){
                if(userCC != null){
                userCC = userCC +', '+q.email;
                    if(sendCC != null){
                    sendCC = sendCC +', '+userCC;
                    }
                }
                else{
                userCC = q.email;
                sendCC = sendCC +', '+ userCC;  
                }

            }
        }
     }
     
     public void contactValue(){
        System.debug('contactlist'+contactlist);
        System.debug('contactinputtext'+contactinputtext);
        System.debug('userCC'+userCC);
        System.debug('userCC'+userCC);
        for(contact con:contactlist){
            if(contactinputtext == con.name){
                if(userCC != null){
                userCC = userCC +', '+con.email;
                    if(sendCC != null){
                    sendCC = sendCC +', '+userCC;
                    }
                }
                else{
                userCC = con.email;
                sendCC = sendCC +', '+ userCC;  
                }

            }
        }
        System.debug('sendCC'+sendCC);
     }
         
          
     public pagereference preview(){
         return null;
     }
     
     public void CreatePDF(){

     if(selectedid != null && id != null){
         buildertek__Contract__c contractInfo;
         Quote_Template__c templateInfo;
             if (Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.ownerId.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Primary_Contact__c.isAccessible() &&
                Schema.sObjectType.Contact.fields.Email.isAccessible() ){
               contractInfo =[Select id,Name, buildertek__Primary_Contact__c,buildertek__Primary_Contact__r.Email From buildertek__Contract__c Where id=:id];
              }
           
          
           if (Schema.sObjectType.Quote_Template__c.fields.Description__c.isAccessible() &&
           Schema.sObjectType.Quote_Template__c.fields.id.isAccessible()){
                    templateInfo = [Select id,Description__c From Quote_Template__c Where id=:selectedid];
           } 
        PageReference pagePdf = new PageReference('/apex/Contract_Template_PDF_VF'); 
        pagePdf.getParameters().put('qid', id); 
        pagePdf.getParameters().put('qtid', selectedid); 
        Blob pdfPageBlob; 
        if (Test.IsRunningTest()){
             pdfPageBlob = Blob.valueOf('UNIT.TEST');
        }
        else{
             pdfPageBlob = pagePdf.getContentAsPDF(); 
         }
        
        //if(contractInfo.buildertek__Primary_Contact__r.Email != null){
     
        Attachment a = new Attachment(); 
        if(Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentID.isCreateable()
           && Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.Attachment.fields.Description.isCreateable()
           && Schema.sObjectType.Attachment.fields.ContentType.isCreateable()){
        
            a.Body = pdfPageBlob; 
            a.ParentID = id; 
            a.Name = templateInfo.Description__c + '.pdf';
            a.Description = templateInfo.Description__c; 
            a.ContentType = 'application/pdf';
            insert a; 
         }    
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PDF Attachment created to this Contract.'));
        doStuffAndRedirect();
        
        //}
     }
     else{
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please search the correct value.'));
         
     }                          
        
        //return null;
     }
     
     public void SendPDF(){
    //  try{
     
     if(selectedid != null && id != null){
         buildertek__Contract__c contractInfo;
         if(Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Contract__c.fields.Doc_Template__c.isAccessible() &&
			Schema.sObjectType.buildertek__Contract__c.fields.Email_Template__c.isAccessible() &&
			Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Primary_Contact__c.isAccessible() &&
			Schema.sObjectType.buildertek__Contract__c.fields.ownerId.isAccessible() ){
            contractInfo =[Select id,Name,Doc_Template__c,Email_Template__c,buildertek__Primary_Contact__r.Email,buildertek__Primary_Contact__r.Name,owner.Name,owner.Email From buildertek__Contract__c Where id=:id];
			}
           Quote_Template__c templateInfo;              
     if (Schema.sObjectType.Quote_Template__c.fields.Description__c.isAccessible()){
           templateInfo = [Select id,Description__c From Quote_Template__c Where id=:selectedid];
      }

         if(Schema.sObjectType.buildertek__Contract_Item__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isAccessible()){                     
            contractLineItemNoneProdList = [Select id, buildertek__Quantity__c From buildertek__Contract_Item__c Where buildertek__Contract__c =: id];
            }
        
        if(contractInfo.Email_Template__c != null){
             if (Schema.sObjectType.Email_Template__c.fields.Allow_LineItems__c.isAccessible() &&Schema.sObjectType.Email_Template__c.fields.Body__c.isAccessible()
		        &&Schema.sObjectType.Email_Template__c.fields.Template_Format__c.isAccessible() &&Schema.sObjectType.Email_Template__c.fields.Subject__c.isAccessible()){
		    	EmailTemplateInfo = [Select id,Allow_LineItems__c,Body__c,Template_Format__c,Subject__c,Address_Label__c From Email_Template__c Where id=:contractInfo.Email_Template__c];
		      }
   
            if(Schema.sObjectType.Email_Line_Item_Column__c.fields.Id.isAccessible()&&
            Schema.sObjectType.Email_Line_Item_Column__c.fields.Name.isAccessible()&&
            Schema.sObjectType.Email_Line_Item_Column__c.fields.Column_Width__c.isAccessible() &&
			Schema.sObjectType.Email_Line_Item_Column__c.fields.Email_Template__c.isAccessible() &&
			Schema.sObjectType.Email_Line_Item_Column__c.fields.Field_Name__c.isAccessible() &&
			Schema.sObjectType.Email_Line_Item_Column__c.fields.Sort_Order__c.isAccessible() &&
			Schema.sObjectType.Email_Line_Item_Column__c.fields.Field_API_Name__c.isAccessible()){
            emailLineItemList = [Select id,Name,Column_Width__c,Email_Template__c,Field_API_Name__c,Field_Name__c,Sort_Order__c From Email_Line_Item_Column__c Where Email_Template__c=:contractInfo.Email_Template__c];
			}
            for(Email_Line_Item_Column__c rec:emailLineItemList){
                mapLineItemFields.put(rec.Field_Name__c,rec.Field_API_Name__c);
                LineItemAPIFields.add(rec.Field_API_Name__c);
                LineItemLabelFields.add(rec.Field_Name__c);
            }
        }
        
          
        String SobjectApiName = 'buildertek__Contract_Item__c';
        system.debug('SobjectApiName---->'+ SobjectApiName);
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            system.debug('fieldName---->'+ fieldName);
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        string tax='Tax';
        string shipping='Shipping';
        string discount='Discount';
 		string query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName+'  where buildertek__Contract__c =:id';
 		system.debug('query---->'+query);
       /* if(Schema.sObjectType.buildertek__Contract_Item__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__contract__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Total_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Item_Name__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Description__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Line_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Budget_Item__c.isAccessible() &&
				Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Reason_for_Change__c.isAccessible()){*/
                 contractLineItemList = Database.query(String.escapeSingleQuotes(query));
			/*	}*/
        system.debug('----contractLineItemList-------'+contractLineItemList);
        
        PageReference pagePdf = new PageReference('/apex/Contract_Template_PDF_VF'); 
        pagePdf.getParameters().put('qid', id); 
        pagePdf.getParameters().put('qtid', selectedid); 
        Blob pdfPageBlob; 
        if (Test.IsRunningTest()){
             pdfPageBlob = Blob.valueOf('UNIT.TEST');
        }
        else{
             pdfPageBlob = pagePdf.getContentAsPDF(); 
        }
        try{
            
            MergeData_CTR md = new MergeData_CTR();
        //md.QuoteTemplateId = ContractInfoList.Id;
            md.SObjectName = 'buildertek__Contract__c';
            md.QuoteID = id;
      
            Attachment a = new Attachment();
            a.Body = pdfPageBlob; 
            a.ParentID = id; 
            a.Name = templateInfo.Description__c + '.pdf';
            a.Description = templateInfo.Description__c; 
            a.ContentType = 'application/pdf';
            if(Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentID.isCreateable()
               && Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.Attachment.fields.Description.isCreateable()
               && Schema.sObjectType.Attachment.fields.ContentType.isCreateable()){
                   insert a;
               }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setReplyTo(contractInfo.owner.Email);
            mail.setSenderDisplayName(contractInfo.owner.Name);
            String companyName = '';
            String subject = '';
        
            if(contractInfo.Email_Template__c != null && EmailTemplateInfo.Subject__c != null){
            
                subject = md.m_MergeData(EmailTemplateInfo.Subject__c);
                system.debug('@@@@@@@@@@@@@'+EmailTemplateInfo.Subject__c);
            } 
            else{
                subject = companyName + 'Proposal Number ' + contractInfo.Name;    
            }
            mail.setSubject(subject);
            Datetime myDatetime = Datetime.now();
            String quoteTime = myDatetime.format('MMM d,  yyyy');
            String body = '';
        
            /*********** Static Body***********/
            if(contractInfo.Email_Template__c != null && EmailTemplateInfo.Body__c != null && EmailTemplateInfo.Body__c != '' ){
                body = md.m_MergeData(EmailTemplateInfo.Body__c);   
            }
            if(org1.OrganizationType != 'Professional Edition'){
                if(SiteUrl != null && SiteUrl != ''){
                    body += 'Please click the below Contract number<br />';
                    body += '<a href="'+SiteUrl+'/?id='+contractInfo.Id+'">'+contractInfo.Name+'</a><br /><br />';
                } 
            }
            /*********** Static Body End***********/
        
        
            /*********** LineItems***********/    
            if(contractInfo.Email_Template__c != null && EmailTemplateInfo.Allow_LineItems__c == true && emailLineItemList.size()>0){
                body += '<div><table style="border:1px solid silver;" width="100%" cellpadding="5px" cellspacing="0px"><tr style="background-color:silver">';
                for(string str :LineItemAPIFields){
                    for(Email_Line_Item_Column__c item:emailLineItemList){ 
                        if(str == item.Field_API_Name__c)
                            body+='<th align="left" style="width:{!item.Column_Width__c}%">'+item.Field_Name__c+'</th>';
                         }
                    }
                    body += '</tr>';
        
                    Decimal Subtotal=0.00;
                    Decimal Total=0.00;

                    body += '</table></div><br />';
                    //------------Second  One-------
                    body += '<div style="float:right !important"><table style="border:0.5px solid black" width="250px" cellpadding="5px" cellspacing="0px">';
           
                    if(Subtotal != null){
                        body += '<tr style="border:0.5px solid black;"><td style="border:1px solid black;" width="20%"> Subtotal</td><td width="20%" style="border:0.5px solid black;align:right !important">$'+Subtotal+'</td></tr>';
                        Total +=Subtotal;
                    }
             
                    for(buildertek__Contract_Item__c ql:contractLineItemNoneProdList){
                        body += '<tr style="border:0.5px solid black">';
                        body += '</tr>';
                    }
                    if(Total != null){
                        body += '<tr><td width="20%" style="border:0.5px solid black;"> Total</td><td width="20%" style="border:0.5px solid black;align:right !important">$'+Total+'</td></tr>';
                    }
                    body += '</table></div>';
           //-----------Second One-----------
                }
                body += '</div>';
                /*********** LineItems End***********/   
        
                mail.setHtmlBody(body);
                mail.setUseSignature(false);
                String[] ccadd = sendCC.split(',');
                if(contractInfo.buildertek__Primary_Contact__r.Email != null && contractInfo.buildertek__Primary_Contact__r.Email != ''){
                    mail.setToAddresses(new String[] { contractInfo.buildertek__Primary_Contact__r.Email }); 
                if(sendCC != ''){
                    mail.setCCAddresses(ccadd );
                }
            }else{
                if(sendCC != ''){
                 mail.setToAddresses(ccadd );
            }    
        }
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for (Attachment at : [select Name,Body,BodyLength from Attachment where id= :a.id]) {   
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();  
            efa.setFileName(at.Name); 
            efa.setBody(at.body); 
            fileAttachments.add(efa);
        }
        mail.setFileAttachments(fileAttachments);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        Taskhistory = new Task();
        Taskhistory.whatId = id; 
        Taskhistory.Status='Completed';
        Taskhistory.Subject = Subject;
        Taskhistory.ActivityDate = System.Today();
        Taskhistory.Description =body; 
         if(Schema.sObjectType.Task.fields.whatId.isCreateable() && Schema.sObjectType.Task.fields.Status.isCreateable()
            && Schema.sObjectType.Task.fields.Subject.isCreateable() && Schema.sObjectType.Task.fields.ActivityDate.isCreateable()
            && Schema.sObjectType.Task.fields.Description.isCreateable()){
            insert Taskhistory;
        }
         
        Attachment att = new Attachment();
        att.Body = pdfPageBlob; 
        att.ParentID = Taskhistory.Id; 
        att.Name = templateInfo.Description__c + '.pdf';
        att.Description = templateInfo.Description__c; 
        att.ContentType = 'application/pdf';
         if(Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentID.isCreateable()
            && Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.Attachment.fields.Description.isCreateable()
            && Schema.sObjectType.Attachment.fields.ContentType.isCreateable()){
            insert att;
            }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with Attachment sent successfully'));
        if(Attachment.sObjectType.getDescribe().isDeletable()){
            delete[Select id From Attachment Where id=:a.id];
        }
        doStuffAndRedirect();        
        }catch(Exception exp){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, exp.getMessage()));        
        } 
     }
     else{
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please search the correct value.'));
         
     }
     }
     
     public PageReference doStuffAndRedirect() {
        shouldRedirect = true;
        redirectUrl = stdController.view().getUrl();
        system.debug('redirectUrl ---------> '+redirectUrl);
        return null;
    }
   
    
}