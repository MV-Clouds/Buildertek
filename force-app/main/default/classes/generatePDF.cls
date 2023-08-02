public with sharing class generatePDF {
     public id id                                       {get;set;}
     public String qtid                                       {get;set;}
     public list<user> QTlist              {get;set;}
     public list<contact> contactlist              {get;set;}
     public string inputtext                            {get;set;}
     public string contactinputtext                            {get;set;}
     public string selectedid                           {get;set;}
     public Quote_Template__c QuoteInfoList             {get;set;}
     public list<Quote_Item__c> quoteLineItemList       {get;set;}
     public list<Quote_Item__c> quoteLineItemNoneProdList  {get;set;}
     public list<Email_Line_Item_Column__c> emailLineItemList  {get;set;}
     public map<string,string> mapLineItemFields{get;set;}
     public list<string> LineItemAPIFields{get;set;}
     public list<string> LineItemLabelFields{get;set;}
     
     public Quote__c quoteInfo{get;set;}
     public string  sendCC{get;set;}
     public string  userCC{get;set;}
     public string  userMails{get;set;}
     public Quote__c myCustomObject;
     public Email_Template__c EmailTemplateInfo{get;set;}
     public string SiteName{get;set;}
     public string SiteUrl{get;set;}
      
     public Task Taskhistory {get;set;}
     private ApexPages.StandardController stdController;
     public String redirectUrl {public get; private set;}
     public Boolean shouldRedirect {public get; private set;}
     public Organization org1;
 

     public list<DocTemplate_Page__c> QuotePageList   {get;set;}
     
     
     public generatePDF(ApexPages.StandardController stdController) {
        this.stdController = stdController;
         System.debug('Generate PDF');
        //sObject sobj = Schema.getGlobalDescribe().get('Quote__c').newSObject();
        myCustomObject = (Quote__c) stdController.getRecord();
        id = myCustomObject.id;
         list<Quote__c> quoteList;
        if(Schema.sObjectType.Quote__c.fields.Id.isAccessible()&&
            Schema.sObjectType.Quote__c.fields.Doc_Template__c.isAccessible()){ 
           quoteList = [Select id,Doc_Template__c From Quote__c Where id=:id];
         }
         if(quoteList.size() > 0){
         selectedid = quoteList[0].Doc_Template__c;
         }
          if (Schema.sObjectType.user.fields.name.isAccessible()
                && Schema.sObjectType.user.fields.email.isAccessible()) {
                QTlist = [select id, name,email from user limit 1000];
          }
           if (Schema.sObjectType.contact.fields.name.isAccessible()
                && Schema.sObjectType.contact.fields.Id.isAccessible()
                && Schema.sObjectType.contact.fields.FirstName.isAccessible()
                && Schema.sObjectType.contact.fields.LastName.isAccessible()) {
                contactlist = [select id, name,FirstName,LastName from contact limit 100];
           }
      
         QuoteInfoList = new Quote_Template__c();
         QuotePageList = new list<DocTemplate_Page__c>();
         quoteLineItemList = new list<Quote_Item__c>();
         quoteLineItemNoneProdList = new list<Quote_Item__c>();
         emailLineItemList = new list<Email_Line_Item_Column__c>();
         LineItemAPIFields = new list<string>();
         LineItemLabelFields = new list<string>();
         mapLineItemFields = new map<string,string>();

         quoteInfo = new Quote__c();
         shouldRedirect = false;
         preview();
         /*Get SiteName*/
        /*JunoOrders_Site_Name__c SettingslistCheck = JunoOrders_Site_Name__c.getInstance('JunoOrdersSiteName');
         List<JunoOrders_Site_Name__c> SiteValues = JunoOrders_Site_Name__c.getall().values();*/
         
         /*JunoOrders_Site_Name__c  SettingslistCheck =  JunoOrders_Site_Name__c.getInstance('DefaultSettings');    
         list<JunoOrders_Site_Name__c>  SiteValues = JunoOrders_Site_Name__c.getall().values(); 
           
         SiteName = SiteValues[0].Site_Name__c; 
         if(SiteName != null && SiteName != ''){
             list<Site> site = [SELECT GuestUserId, Name, Subdomain, UrlPathPrefix FROM Site WHERE Name=:SiteName];
             if(site.size() > 0){
                 Organization org = [SELECT InstanceName, IsSandbox, OrganizationType FROM Organization limit 40000];
                 SiteUrl = 'https://' + site[0].Subdomain + '.';
                 SiteUrl += (org.IsSandbox || org.OrganizationType == 'Developer Edition' ? (org.InstanceName.toLowerCase() + '.') : '') + 'force.com';
                 SiteUrl += '/' + site[0].UrlPathPrefix;
                 System.debug('222222222:'+SiteName);   
                 
                 
            }
                        
         }*/
         
        //   JunoOrders_Site_Name__c  SettingslistCheck =  JunoOrders_Site_Name__c.getInstance('JunoOrdersSiteName');      
        //   list<JunoOrders_Site_Name__c>  SiteValues = JunoOrders_Site_Name__c.getall().values(); 
          
           
//           List<String> a=new List<String>();
//           a.add('site');
//           Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
//           Map<String , Map<String,Schema.SObjectField>> mapObj_FielMap = new Map<String , Map<String,Schema.SObjectField>>();
//           Schema.SObjectType sobjType;
//           sobjType = gd.get(a[0]);
          if(Schema.sObjectType.Organization.fields.Id.isAccessible() &&
                Schema.sObjectType.Organization.fields.OrganizationType.isAccessible()){
		        org1 = [SELECT OrganizationType FROM Organization LIMIT 1];
            }
// 			if(org1.OrganizationType != 'Professional Edition'){
				// if(SiteValues.size()>0) 
				// SiteName = SiteValues[0].Site_Name__c; 
				// 	if(SiteName != null && SiteName != ''){
				//         list<Sobject> site;
				// 		String Query = 'SELECT GuestUserId, Name, Subdomain, UrlPathPrefix FROM Site WHERE Name=:SiteName';
				// 			site = database.query(Query);
			       
				// 		     if(site.size() > 0){
				// 		         Organization org;
				// 		         org = [SELECT InstanceName,IsSandbox,OrganizationType FROM Organization limit 40000];
				// 		         SiteUrl = 'https://' + site[0].get('Subdomain') + '.';
				// 		         SiteUrl += (org.IsSandbox || org.OrganizationType == 'Developer Edition' ? (org.InstanceName.toLowerCase() + '.') : '') + 'force.com';
				// 		         SiteUrl += '/' + site[0].get('UrlPathPrefix');
				// 		         System.debug('UpdateUrl:'+SiteUrl);                 
				// 		 	}
				// 	} 
				// }
			} 


     public void userValue(){
        
        for(user q:QTList){
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
        

   /*  if(selectedid != null && id != null){
         pagereference p = new pagereference('/apex/QuoteTemplate_PDF_VF?qid='+id+'&qtid='+selectedid);
         return p;
     } 
     
         pagereference p = new pagereference('/'+id);
         return p;*/
         return null;
     }
     
     public void CreatePDF(){

     if(selectedid != null && id != null){
         Quote__c quoteInfo;
         Quote_Template__c templateInfo;
             if (Schema.sObjectType.Quote__c.fields.Name.isAccessible() && 
                Schema.sObjectType.Quote__c.fields.ownerId.isAccessible() && 
                Schema.sObjectType.Quote__c.fields.buildertek__Primary_Contact__c.isAccessible() && 
                Schema.sObjectType.Contact.fields.Email.isAccessible()){
                quoteInfo = [Select id,
                                    Name, 
                                    buildertek__Primary_Contact__c,
                                    buildertek__Primary_Contact__r.Email 
                                    From Quote__c Where id=:id];
            }
           
          
           if (Schema.sObjectType.Quote_Template__c.fields.Id.isAccessible() && 
                Schema.sObjectType.Quote_Template__c.fields.Description__c.isAccessible() ){
                    templateInfo = [Select id,Description__c From Quote_Template__c Where id=:selectedid];
           } 
        PageReference pagePdf = new PageReference('/apex/QuoteTemplate_PDF_VF'); 
        pagePdf.getParameters().put('qid', id); 
        pagePdf.getParameters().put('qtid', selectedid); 
        Blob pdfPageBlob; 
        if (Test.IsRunningTest()){
             pdfPageBlob = Blob.valueOf('UNIT.TEST');
        }
        else{
             pdfPageBlob = pagePdf.getContentAsPDF(); 
         }
        
        //if(quoteInfo.buildertek__Primary_Contact__r.Email != null){
     
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
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PDF Attachment created to this Quote.'));
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
          Quote__c quoteInfo;
         /*  if (Schema.sObjectType.Quote__c.fields.Name.isAccessible() && Schema.sObjectType.Quote__c.fields.Company__c.isAccessible()
         &&Schema.sObjectType.Quote__c.fields.Contact__c.isAccessible()   &&Schema.sObjectType.Quote__c.fields.ownerId.isAccessible()
                    &&Schema.sObjectType.Quote__c.fields.Shipping_Company__c.isAccessible() && Schema.sObjectType.Quote__c.fields.Shipping_Street__c.isAccessible()
                       &&Schema.sObjectType.Quote__c.fields.Shipping_State__c.isAccessible() && Schema.sObjectType.Quote__c.fields.Shipping_Country__c.isAccessible()
                        &&Schema.sObjectType.Quote__c.fields.Shipping_Zip_Postal_Code__c.isAccessible() && Schema.sObjectType.Quote__c.fields.Email_Template__c.isAccessible()
                         &&Schema.sObjectType.Quote__c.fields.Shipping_Contact_First_Name__c.isAccessible()&&Schema.sObjectType.Quote__c.fields.Shipping_Contact_Last_Name__c.isAccessible()
                         &&Schema.sObjectType.Quote__c.fields.Shipping_Phone__c.isAccessible() && Schema.sObjectType.Quote__c.fields.ShippingCity__c.isAccessible()){*/
         if(Schema.sObjectType.Quote__c.fields.Id.isAccessible()&&
            Schema.sObjectType.Quote__c.fields.Name.isAccessible()&&
            Schema.sObjectType.Quote__c.fields.Doc_Template__c.isAccessible()&&
            Schema.sObjectType.Quote__c.fields.Email_Template__c.isAccessible()&& 
            Schema.sObjectType.Contact.fields.Email.isAccessible() &&
            Schema.sObjectType.Contact.fields.Name.isAccessible() &&
            Schema.sObjectType.User.fields.Name.isAccessible() &&
            Schema.sObjectType.User.fields.Email.isAccessible()){
            quoteInfo = [Select id,
                                Name,
                                Doc_Template__c,
                                Email_Template__c,
                                buildertek__Primary_Contact__r.Email,
                                buildertek__Primary_Contact__r.Name,
                                owner.Name,
                                owner.Email 
                                From Quote__c Where id=:id];
          }              //  }
           Quote_Template__c templateInfo;              
            if (Schema.sObjectType.Quote_Template__c.fields.Id.isAccessible() && 
                Schema.sObjectType.Quote_Template__c.fields.Description__c.isAccessible()){
                templateInfo = [Select id,Description__c From Quote_Template__c Where id=:selectedid];
            }

           if(Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible()&&
              Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
              Schema.sObjectType.buildertek__Quote__c.fields.Id.isAccessible()){                   
              quoteLineItemNoneProdList = [Select id,buildertek__Quantity__c From buildertek__Quote_Item__c Where buildertek__Quote__r.id=:id];
           }
           
            if(quoteInfo.Email_Template__c != null){
                if (Schema.sObjectType.Email_Template__c.fields.Id.isAccessible()
                    && Schema.sObjectType.Email_Template__c.fields.Allow_LineItems__c.isAccessible()
                    && Schema.sObjectType.Email_Template__c.fields.Body__c.isAccessible()
		            && Schema.sObjectType.Email_Template__c.fields.Template_Format__c.isAccessible() 
		            && Schema.sObjectType.Email_Template__c.fields.Subject__c.isAccessible()
		            && Schema.sObjectType.Email_Template__c.fields.Address_Label__c.isAccessible()){
		    	    
		    	    EmailTemplateInfo = [Select id,
		    	                                Allow_LineItems__c,
		    	                                Body__c,
		    	                                Template_Format__c,
		    	                                Subject__c,
		    	                                Address_Label__c 
		    	                                From Email_Template__c 
		    	                                Where id=:quoteInfo.Email_Template__c];
		        }
   
            if(Schema.sObjectType.Email_Line_Item_Column__c.fields.Id.isAccessible()&&
                Schema.sObjectType.Email_Line_Item_Column__c.fields.Name.isAccessible()&&
                Schema.sObjectType.Email_Line_Item_Column__c.fields.Column_Width__c.isAccessible() &&
    			Schema.sObjectType.Email_Line_Item_Column__c.fields.Email_Template__c.isAccessible() &&
    			Schema.sObjectType.Email_Line_Item_Column__c.fields.Field_Name__c.isAccessible() &&
    			Schema.sObjectType.Email_Line_Item_Column__c.fields.Sort_Order__c.isAccessible() &&
    			Schema.sObjectType.Email_Line_Item_Column__c.fields.Field_API_Name__c.isAccessible()){
			    
                emailLineItemList = [Select id,
                                            Name,
                                            Column_Width__c,
                                            Email_Template__c,
                                            Field_API_Name__c,
                                            Field_Name__c,
                                            Sort_Order__c 
                                            From Email_Line_Item_Column__c 
                                            Where Email_Template__c=:quoteInfo.Email_Template__c];
			}
            for(Email_Line_Item_Column__c rec:emailLineItemList){
                mapLineItemFields.put(rec.Field_Name__c,rec.Field_API_Name__c);
                LineItemAPIFields.add(rec.Field_API_Name__c);
                LineItemLabelFields.add(rec.Field_Name__c);
            }
        }
        
      /*if (Schema.sObjectType.Quote_Item__c.fields.Product__c.isAccessible() && Schema.sObjectType.Quote_Item__c.fields.Description_Notes__c.isAccessible()
      &&Schema.sObjectType.Quote_Item__c.fields.Quantity__c.isAccessible() && Schema.sObjectType.Quote_Item__c.fields.Quote_Price__c.isAccessible()
      &&Schema.sObjectType.Quote_Item__c.fields.Extended_Total__c.isAccessible() && Schema.sObjectType.Quote_Item__c.fields.Unit_Cost__c.isAccessible()){*/
          
        String SobjectApiName = 'buildertek__Quote_Item__c';
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
 		string query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName+'  where buildertek__Quote__c =:id';
 		system.debug('query---->'+query);

     /* quoteLineItemList = [Select id,Product__c,Description_Notes__c,
                                Product__r.Name,Quantity__c,
                                Quote_Price__c,Extended_Total__c,
                                Unit_Cost__c From Quote_Item__c
                                Where Quote__c=:id
                                And Product__r.Product_Type__c !='Tax' And Product__r.Product_Type__c !='Shipping' And Product__r.Product_Type__c !='Discount'];*/
        
   /*if(Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible()&&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
             Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isAccessible() ){*/
          quoteLineItemList = Database.query(String.escapeSingleQuotes(query));
            /* }*/
    //   }
      
      
        system.debug('----quoteLineItemList-------'+quoteLineItemList);
        
        PageReference pagePdf = new PageReference('/apex/QuoteTemplate_PDF_VF'); 
        pagePdf.getParameters().put('qid', id); 
        pagePdf.getParameters().put('qtid', selectedid); 
        Blob pdfPageBlob; 
        if (Test.IsRunningTest()){
             pdfPageBlob = Blob.valueOf('UNIT.TEST');
        }
        else{
             pdfPageBlob = pagePdf.getContentAsPDF(); 
         }
        //pdfPageBlob = pagePdf.getContentAsPDF(); 
        //String[] ccadd = sendCC.split(',');
        //if(quoteInfo.buildertek__Primary_Contact__r.Email != null && quoteInfo.buildertek__Primary_Contact__r.Email!=''){
        // && !quoteInfo.Contact__r.Email.contains('@marketplace.amazon.com')){
        try{
            
            MergeData_CTR md = new MergeData_CTR();
        //md.QuoteTemplateId = QuoteInfoList.Id;
        md.SObjectName = 'buildertek__Quote__c';
        md.QuoteID = id;
     
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
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setReplyTo(quoteInfo.owner.Email);
        mail.setSenderDisplayName(quoteInfo.owner.Name);
        String companyName = '';
        String subject = '';
        
        if(quoteInfo.Email_Template__c != null && EmailTemplateInfo.Subject__c != null){
            
        subject = md.m_MergeData(EmailTemplateInfo.Subject__c);
        system.debug('@@@@@@@@@@@@@'+EmailTemplateInfo.Subject__c);
        } 
        else{
        subject = companyName + 'Proposal Number ' + quoteInfo.Name;    
        }
        mail.setSubject(subject);
        Datetime myDatetime = Datetime.now();
        String quoteTime = myDatetime.format('MMM d,  yyyy');
        String body = '';
        
        /*********** Static Body***********/
        if(quoteInfo.Email_Template__c != null && EmailTemplateInfo.Body__c != null && EmailTemplateInfo.Body__c != '' ){
            body = md.m_MergeData(EmailTemplateInfo.Body__c);   
        }
        else{
            if(quoteInfo.buildertek__Primary_Contact__c == null){
                body = '<div style="padding:10px;"><font>Hello,</font><br /><br />';    
            }else{
                 body = '<div style="padding:10px;"><font>Hello ' + quoteInfo.buildertek__Primary_Contact__r.Name + ',</font><br /><br />';     
            }
        
        
        body += 'Thank you again for your request for Quote.<br /><br />';
        body += 'You will find our proposal in the attached PDF.<br />';
        body += '<font>Your Quote Request '+ quoteInfo.Name + ' ( placed on ' + quoteTime + ' )</font><br />';
        }
        if(org1.OrganizationType != 'Professional Edition'){
        if(SiteUrl != null && SiteUrl != ''){
        body += 'Please click the below Quote number for approve the Quote.<br />';
        body += '<a href="'+SiteUrl+'/?id='+quoteInfo.Id+'">'+quoteInfo.Name+'</a><br /><br />';
        } 
        }
        /*********** Static Body End***********/
        
        
        /*********** LineItems***********/    
        if(quoteInfo.Email_Template__c != null && EmailTemplateInfo.Allow_LineItems__c == true && emailLineItemList.size()>0){
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
             
            for(Quote_Item__c ql:quoteLineItemNoneProdList){
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
        if(quoteInfo.buildertek__Primary_Contact__r.Email != null && quoteInfo.buildertek__Primary_Contact__r.Email != ''){
            mail.setToAddresses(new String[] { quoteInfo.buildertek__Primary_Contact__r.Email }); 
            if(sendCC != ''){
                mail.setCCAddresses(ccadd );
            }
        }else{
            if(sendCC != ''){
                mail.setToAddresses(ccadd );
            }    
        }
        
        
        
        
       
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
          if (Schema.sObjectType.Attachment.fields.Name.isAccessible() && Schema.sObjectType.Attachment.fields.Body.isAccessible()
          && Schema.sObjectType.Attachment.fields.BodyLength.isAccessible()){
        for (Attachment at : [select Name,Body,BodyLength from Attachment where id= :a.id]) 
        
        {   
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();  
            efa.setFileName(at.Name); 
            efa.setBody(at.body); 
            fileAttachments.add(efa);
        }
          }
        mail.setFileAttachments(fileAttachments);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        Taskhistory = new Task();
        //  if(Schema.sObjectType.Task.fields.whatId.isCreateable() && Schema.sObjectType.Task.fields.Status.isCreateable()
        //     && Schema.sObjectType.Task.fields.Subject.isCreateable() && Schema.sObjectType.Task.fields.To_Email__c.isCreateable()
        //     && Schema.sObjectType.Task.fields.ActivityDate.isCreateable() && Schema.sObjectType.Task.fields.Description.isCreateable()){
                
         Taskhistory.whatId = id;
         //Taskhistory.Name = templateInfo.Description__c + '.pdf'; 
         Taskhistory.Status='Completed';
         Taskhistory.Subject = Subject;
        //  Taskhistory.To_Email__c = quoteInfo.Contact.Email;
         Taskhistory.ActivityDate = System.Today();
         Taskhistory.Description =body; 
         if(Schema.sObjectType.Task.fields.whatId.isCreateable() && Schema.sObjectType.Task.fields.Status.isCreateable()
            && Schema.sObjectType.Task.fields.Subject.isCreateable() && Schema.sObjectType.Task.fields.ActivityDate.isCreateable()
            && Schema.sObjectType.Task.fields.Description.isCreateable()){
            insert Taskhistory;
            }
        // }
         
          Attachment att = new Attachment();
          if(Schema.sObjectType.Attachment.fields.ContentType.isCreateable() && Schema.sObjectType.Attachment.fields.Description.isCreateable()
            && Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.Attachment.fields.ParentID.isCreateable()
            && Schema.sObjectType.Attachment.fields.Body.isCreateable()){
                
            att.Body = pdfPageBlob; 
            att.ParentID = Taskhistory.Id; 
            att.Name = templateInfo.Description__c + '.pdf';
            att.Description = templateInfo.Description__c; 
            att.ContentType = 'application/pdf';
            insert att;
          }
          
       
         
        //if(quoteInfo.buildertek__Primary_Contact__r.Email != null){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with Attachment sent to '+quoteInfo.buildertek__Primary_Contact__r.Email));    
        //}else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with Attachment sent successfully'));
        //}
         
        if(Attachment.sObjectType.getDescribe().isDeletable()){
            delete[Select id From Attachment Where id=:a.id];
        }
        doStuffAndRedirect();        
        }catch(Exception exp){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, exp.getMessage()));        
        }    
        
       //}
     }
     else{
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please search the correct value.'));
         
     }
    //  } catch (Exception  e) {
    //     if(e.getMessage().contains('SINGLE_EMAIL_LIMIT_EXCEEDED')){
    //          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Email limit exceeded .Please Try Later.'));
    //     }
    //  }
     
     //return null;
     }
     
     public PageReference doStuffAndRedirect() {
        shouldRedirect = true;
        redirectUrl = stdController.view().getUrl();
        system.debug('redirectUrl ---------> '+redirectUrl);
        return null;
    }
   
    
}