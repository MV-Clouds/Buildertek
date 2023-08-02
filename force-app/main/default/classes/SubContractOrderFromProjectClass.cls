public class SubContractOrderFromProjectClass {
      @AuraEnabled
    public static object getMasterBudgets(String recId){
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        List<buildertek__Budget_Item__c> rfqList;
          If(Schema.sObjectType.buildertek__Budget_Item__c.fields.Name.isAccessible() &&
           Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Sub_Contract__c.isAccessible() &&
           Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Contractor__c.isAccessible() &&
           Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Description__c.isAccessible() &&
           Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
           Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget__c.isAccessible()){
               rfqList = [SELECT Id,
                          Name, 
                          buildertek__Contractor__r.Name,
                          buildertek__Budget__c,
                          buildertek__Budget__r.buildertek__Project__c,
                          buildertek__Contractor__r.buildertek__Email_Address__c,
                          buildertek__Sub_Contract__r.buildertek__Contract_Amount__c,
                          buildertek__Group__r.Name,
                          buildertek__Description__c,
                          buildertek__Cost_Code__r.Name,
                          buildertek__Sub_Contract__r.Name,
                          buildertek__Sub_Contract__r.buildertek__Purchase_Order__c,
                          buildertek__Purchase_Order__c,
                          buildertek__Purchase_Order__r.Name,(select id,buildertek__Budget_Line2__c from Purchase_Orders1__r)
                                FROM buildertek__Budget_Item__c Where buildertek__Budget__r.buildertek__Project__c =: recId AND buildertek__Sub_Contract__c != ''  ORDER BY Name ASC  ];    
               
           }
        for(buildertek__Budget_Item__c bud : rfqList){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
             MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassList;   
    }
    
    
     
 
public class MessageClass{
    @AuraEnabled
    public String Status {get;set;}
     @AuraEnabled
    public string Message {get;set;}
    
} 
    @AuraEnabled
    public static object findByName(String searchKey , string recId) {
        List<MasterBudgetsClass> MasterBudgetsClassLists = new List<MasterBudgetsClass>();
        List<buildertek__Budget_Item__c> rfqLists;
        String  name =  + searchKey + '%'; 
        rfqLists = [SELECT Id,
                    Name, 
                    buildertek__Contractor__r.Name,
                    buildertek__Budget__c,
                    buildertek__Budget__r.buildertek__Project__c,
                    buildertek__Contractor__r.buildertek__Email_Address__c,
                    buildertek__Description__c,
                    buildertek__Sub_Contract__r.buildertek__Contract_Amount__c,
                    buildertek__Group__r.Name,
                    buildertek__Cost_Code__r.Name,
                    buildertek__Sub_Contract__r.Name,
                    buildertek__Purchase_Order__c,
                    buildertek__Purchase_Order__r.Name
                    FROM buildertek__Budget_Item__c
                    Where buildertek__Budget__r.buildertek__Project__c =: recId AND buildertek__Sub_Contract__c != '' 
                    and buildertek__Group__r.Name LIKE :name ];
        
        for(buildertek__Budget_Item__c bud : rfqLists){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassLists.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassLists;  
    }
    
     @AuraEnabled
    public static object findByName1(String searchKey , string recId) {
        List<MasterBudgetsClass> MasterBudgetsClassLists1 = new List<MasterBudgetsClass>();
        List<buildertek__Budget_Item__c> rfqLists;
        String  name =  + searchKey + '%'; 
        rfqLists = [SELECT Id,
                    Name, 
                    buildertek__Contractor__r.Name,
                    buildertek__Budget__c,
                    buildertek__Budget__r.buildertek__Project__c,
                    buildertek__Contractor__r.buildertek__Email_Address__c,
                    buildertek__Description__c,
                    buildertek__Sub_Contract__r.buildertek__Contract_Amount__c,
                    buildertek__Group__r.Name,
                    buildertek__Cost_Code__r.Name,
                    buildertek__Sub_Contract__r.Name,
                    buildertek__Purchase_Order__c,
                    buildertek__Purchase_Order__r.Name
                    FROM buildertek__Budget_Item__c
                    Where buildertek__Budget__r.buildertek__Project__c =: recId AND buildertek__Sub_Contract__c != '' 
                    and buildertek__Contractor__r.Name LIKE :name ];
        
        for(buildertek__Budget_Item__c bud : rfqLists){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassLists1.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassLists1;  
    }
    
     @AuraEnabled
    public static object findByName2(String searchKey , string recId) {
        List<MasterBudgetsClass> MasterBudgetsClassLists2 = new List<MasterBudgetsClass>();
        List<buildertek__Budget_Item__c> rfqLists;
        String  name =  + searchKey + '%'; 
        rfqLists = [SELECT Id,
                    Name, 
                    buildertek__Contractor__r.Name,
                    buildertek__Budget__c,
                    buildertek__Budget__r.buildertek__Project__c,
                    buildertek__Contractor__r.buildertek__Email_Address__c,
                    buildertek__Description__c,
                    buildertek__Sub_Contract__r.buildertek__Contract_Amount__c,
                    buildertek__Group__r.Name,
                    buildertek__Cost_Code__r.Name,
                    buildertek__Sub_Contract__r.Name,
                    buildertek__Purchase_Order__c,
                    buildertek__Purchase_Order__r.Name
                    FROM buildertek__Budget_Item__c
                    Where buildertek__Budget__r.buildertek__Project__c =: recId AND buildertek__Sub_Contract__c != '' 
                    and buildertek__Cost_Code__r.Name LIKE :name ];
        
        for(buildertek__Budget_Item__c bud : rfqLists){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassLists2.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassLists2;  
    }
    
     public class MasterBudgetsClass{
         @AuraEnabled
         public buildertek__Budget_Item__c budgetRecord {get;set;}
        
         @AuraEnabled
         public boolean budgetCheck {get;set;}
    }
    
    
     @AuraEnabled
    public static List<buildertek__Purchase_Order__c> createPO(List<String> budgetIds, String recordId, String fileData){
        system.debug('budgetIds--------->'+budgetIds);
      //  system.debug('fileData--------->'+fileData);
        
           List<Innerclass> inn = new  List<Innerclass>();
        if(filedata != null && filedata != '' && filedata != '[]'){
            system.debug('filedata'+filedata);
            inn = (List<Innerclass>)JSON.deserialize((filedata),List<Innerclass>.Class);
            system.debug(inn);
            system.debug(inn[0].fileName);
            system.debug(inn[0].fileContent);
            system.debug('kdhiic------>'+inn[0].POId);
        }

        buildertek__Project__c pro = [select id,buildertek__Customer__c from buildertek__Project__c where id =: recordId];
       List<buildertek__Budget_Item__c> BudgetLineList;
        BudgetLineList = [SELECT Id,
                       Name, 
                       buildertek__Contractor__r.Name,
                       buildertek__Budget__c,
                       buildertek__Budget__r.buildertek__Project__c,
                       buildertek__Contractor__r.buildertek__Email_Address__c,
                       buildertek__Description__c,
                       buildertek__Sub_Contract__r.buildertek__Contract_Amount__c,
                       buildertek__Group__r.Name,
                       buildertek__Cost_Code__r.Name,
                       buildertek__Sub_Contract__r.Name,
                       buildertek__Purchase_Order__c,
                       buildertek__Purchase_Order__r.Name
                       FROM buildertek__Budget_Item__c Where Id IN:budgetIds];
        
      
      
        List<String> ConIds = new List<String> ();
        
        for(buildertek__Budget_Item__c bi : BudgetLineList){
            ConIds.add(bi.buildertek__Sub_Contract__c);
        }
       
        List<buildertek__Contract__c> subcontractList;
        subcontractList = [SELECT Id,
                           Name, 
                           buildertek__Budget__c,
                           buildertek__Type__c,
                           buildertek__Project__c,
                           buildertek__Vendor__c    
                           FROM buildertek__Contract__c Where ID IN:ConIds];
        
       system.debug('subcontractList...'+subcontractList);        
        List<String> SubConIds = new List<String> ();
        
        
     /*   List<buildertek__Purchase_Order__c> purchaseorder  = new List<buildertek__Purchase_Order__c>();
        if(!subcontractList.isEmpty()){
            for(buildertek__Contract__c contract : subcontractList){
                buildertek__Purchase_Order__c purchase  = new buildertek__Purchase_Order__c();
              
                SubConIds.add(contract.Id);
                purchase.buildertek__Budget__c = contract.buildertek__Budget__c;
                purchase.buildertek__Sub_Contract__c = contract.Id;
                 system.debug(purchase.buildertek__Sub_Contract__c = contract.Id);
                system.debug(contract.Id);
                purchase.buildertek__Project__c = recordId;
                system.debug(contract.buildertek__Vendor__c );
               //
                    System.debug('one');
                 purchase.buildertek__Vendor__c = contract.buildertek__Vendor__c;
                  if(contract.buildertek__Vendor__c == null ){
                   purchase.buildertek__Vendor__c = '0011K00002T3H6nQAF';
                  system.debug('hai');
                  }
               // }
               // else{
                // purchase.buildertek__Vendor__c = COItem.buildertek__Vendor__c;
                  //  purchase.buildertek__Vendor__c = '0011K00002T3H6nQAF';
               // }
                purchaseorder.add(purchase);
            }
        } */
        
        //--------------------------------------------------------
        
        Map<String,buildertek__Contract__c> mapList = new Map<String,buildertek__Contract__c>();
        
        for(buildertek__Budget_Item__c bI : BudgetLineList){
        
           mapList.put(bI.Id, [SELECT Id,
                           Name, 
                           buildertek__Budget__c,
                           buildertek__Type__c,
                           buildertek__Project__c,
                           buildertek__Vendor__c    
                           FROM buildertek__Contract__c Where ID =: bI.buildertek__Sub_Contract__c]);
        
        }
          List<buildertek__Purchase_Order__c> purchaseorder  = new List<buildertek__Purchase_Order__c>();
        Set<String> budgetIds2 = mapList.keySet();
        if(budgetIds2.size() > 0){
        for(String a : budgetIds){
           
           buildertek__Purchase_Order__c purchase  = new buildertek__Purchase_Order__c();
          purchase.buildertek__Budget__c = mapList.get(a).buildertek__Budget__c;
           purchase.buildertek__Sub_Contract__c = mapList.get(a).Id;
            purchase.buildertek__Project__c = recordId;
             purchase.buildertek__Vendor__c = mapList.get(a).buildertek__Vendor__c;
             purchase.buildertek__Budget_Line2__c = a;
               if(mapList.get(a).buildertek__Vendor__c == null ){
                   purchase.buildertek__Vendor__c = '0011K00002T3H6nQAF';
                  system.debug('hai');
                  }
             purchaseorder.add(purchase);
        
        }
        }
        
        //----------------------------------------------------------
        if(purchaseorder.size() > 0){
               System.debug('ok1');
            insert purchaseorder;
               System.debug('ok2');
        }    
        for(buildertek__Purchase_Order__c purcha :purchaseorder ){
            SubConIds.add(purcha.buildertek__Sub_Contract__c);
        }
        
       List<Attachment> attachList = new  List<Attachment>();
         System.debug('two');
        for(buildertek__Purchase_Order__c po : purchaseorder){
               System.debug('three');
            if(inn.size() > 0){
            for(Innerclass a : inn){
                if(po.buildertek__Sub_Contract__c == a.POId){
                  /*  System.debug('Attached in the record');
                    String base64Data = EncodingUtil.urlDecode(a.fileContent, 'UTF-8');
                    Attachment attach = new Attachment();
                    attach.parentId = po.Id;
                    attach.Body = EncodingUtil.base64Decode(base64Data);
                    attach.Name = a.fileName;
                  //  attach.ContentType = contentType;
                   attachList.add(attach); */
                    ContentVersion cv = createContentVersion(a.fileContent, a.filename);
                    ContentDocumentLink cdl = createContentLink(cv.Id, po.Id);
                }
                else{
                    System.debug('Not attached');
                }
            }
        }
        }
        
     //   insert attachList;
      //  System.debug('Attachement id ==== : '+attachList[0].Id);
        
        
     /*   ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = Blob.valueOf('string');
            ContVerFile.Title = 'title'; 
            ContVerFile.ContentLocation= 's';
            ContVerFile.PathOnClient='title.csv';
      insert ContVerFile; */
        
        
        
        
       List<buildertek__Contract_Item__c> subcontractitemList;
        subcontractitemList = [SELECT Id,
                               Name, 
                               buildertek__Budget_Item__c,
                               buildertek__Contract__c,
                               buildertek__Quantity__c,
                               buildertek__Unit_Price__c
                               FROM buildertek__Contract_Item__c Where buildertek__Contract__c IN:SubConIds];
        system.debug('subcontractitemList...'+subcontractitemList);
        
        List<buildertek__Purchase_Order_Item__c> purchaseItemist =  new List<buildertek__Purchase_Order_Item__c>();
        
        integer poinc = 0;
        
        // if(!subcontractitemList.isEmpty()){
              for(buildertek__Purchase_Order__c polineslist : purchaseorder){
             for(buildertek__Contract_Item__c contractline : subcontractitemList){
                 if(polineslist.buildertek__Sub_Contract__c == contractline.buildertek__Contract__c ){
               buildertek__Purchase_Order_Item__c purchaseitem  = new buildertek__Purchase_Order_Item__c();
                 // buildertek__Contract_Item__c COntract = new buildertek__Contract_Item__c();
                // purchaseitem.buildertek__Item_Name__c = contractline.buildertek__Item_Name__c;
               purchaseitem.buildertek__Purchase_Order__c = polineslist.id;
                 purchaseitem.Name = contractline.Name;
                   // purchaseitem.buildertek__Total_Price__c =  contractline.buildertek__Total_Price__c;
                     purchaseitem.buildertek__Unit_Price__c = contractline.buildertek__Unit_Price__c;
                //purchaseitem.buildertek__Purchase_Order__r.buildertek__Sub_Contract__c = polineslist.id;
                 purchaseItemist.add(purchaseitem);
             }
              }
           //  }
        }
           if(purchaseItemist.size() > 0){
            insert purchaseItemist;
               system.debug('purchaseItemist.....'+purchaseItemist);
        }  
        
                          

        
         List<buildertek__PO_Item_To_Budget_Item_Link__c> junction;
        junction = [SELECT Id,
                    Name,
                    buildertek__Budget_Item__c,
                    buildertek__PO_Item__c
                    FROM buildertek__PO_Item_To_Budget_Item_Link__c
                   ];
                   
                   
                List<String> poIds = new List<String> ();
        
        for(buildertek__Purchase_Order_Item__c poite : purchaseItemist){
            poIds.add(poite.id);
        }
        system.debug(poIds);
        
        List<buildertek__Purchase_Order_Item__c>newpolist ;
        newpolist = [SELECT Id,
                    Name,
                    buildertek__Purchase_Order__r.buildertek__Sub_Contract__c
                    from buildertek__Purchase_Order_Item__c  Where ID IN:poIds ];
        
        system.debug(newpolist);
        
        
        List<buildertek__PO_Item_To_Budget_Item_Link__c> junctionItemist =  new List<buildertek__PO_Item_To_Budget_Item_Link__c>();
                       for(buildertek__Budget_Item__c budgetlist : BudgetLineList){
                       system.debug('helo');
             for(buildertek__Purchase_Order_Item__c poitemline : newpolist){
             system.debug(budgetlist.buildertek__Sub_Contract__c);
             system.debug(poitemline.buildertek__Purchase_Order__r.buildertek__Sub_Contract__c);
                 if(budgetlist.buildertek__Sub_Contract__c == poitemline.buildertek__Purchase_Order__r.buildertek__Sub_Contract__c ){
                 system.debug('hai');
                      buildertek__PO_Item_To_Budget_Item_Link__c junitem  = new buildertek__PO_Item_To_Budget_Item_Link__c(); 
                     junitem.buildertek__Budget_Item__c = budgetlist.id;
                     junitem.buildertek__PO_Item__c = poitemline.id;
                 
                     system.debug(poitemline.id);
                     junctionItemist.add(junitem);
                      system.debug('junctionItemist.....'+junctionItemist);
                 }
             }
                       }
         if(junctionItemist.size() > 0){
            insert junctionItemist;
               system.debug('junctionItemist.....'+junctionItemist);
        }  
        
        
        
        
        
        return purchaseorder;
    }
    
        
        
    
    
     @AuraEnabled
    public static MessageClass sendMail(List<String> budgetId,string filedata){
        
        system.debug('filedata------->'+filedata);
        System.debug('Budget ids : '+budgetId);
 
        List<Innerclass> inn;
        if(filedata != null && filedata != '' && filedata != '[]'){
            system.debug('filedata'+filedata);
            inn = (List<Innerclass>)JSON.deserialize((filedata),List<Innerclass>.Class);
            system.debug(inn);
            system.debug(inn[0].fileName);
            system.debug(inn[0].fileContent);
            system.debug('kdhiic------>'+inn[0].POId);
        }

        EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE name ='Purchase Order Template' limit 1];
        system.debug(et);
        
        
        MessageClass msgCls = new MessageClass();
        
        List<String> VendorEmails = new List<String>();
        
        List<buildertek__Purchase_Order__c> poList = [Select Id, Name, buildertek__Vendor__c, buildertek__Vendor__r.buildertek__Email_Address__c, buildertek__Vendor__r.Name, buildertek__Status__c,buildertek__Sub_Contract__c,buildertek__Sub_Contract__r.Name,buildertek__Date_Ordered__c,buildertek__PO_Total__c from buildertek__Purchase_Order__c Where Id IN: budgetId];
        
        system.debug('poList--------->'+poList);
        
        List<buildertek__Purchase_Order__c> OrderedPOList =  new List<buildertek__Purchase_Order__c>();
        
        
        List<contact> conlist = [select id,name from contact limit 1];
        
        List<buildertek__ConfirmationPageSiteURL__c> confirmationurl = buildertek__ConfirmationPageSiteURL__c.getall().values();
        string SiteUrl;
        if(confirmationurl.size() > 0){
            SiteUrl = confirmationurl[0].buildertek__SiteURL__c ;
        }
        
        if(!poList.isEmpty()){
          system.debug('hai');
            // Step 0: Create a master list to hold the emails we'll send
            List<Messaging.SingleEmailMessage> mails = 
                new List<Messaging.SingleEmailMessage>();
            
            for (buildertek__Purchase_Order__c myContact : poList) {
                if (myContact.buildertek__Vendor__c != null && myContact.buildertek__Vendor__r.buildertek__Email_Address__c != null) {
                    
                    // Update Puechase Order Status To Ordered
                    buildertek__Purchase_Order__c poRec = new buildertek__Purchase_Order__c();
                  //  poRec.buildertek__Status__c = 'Ordered';
                   // poRec.buildertek__Date_Ordered__c = System.today();
                    poRec.Id = myContact.Id;
                    OrderedPOList.add(poRec);
                    //
                    
                    String body = '';
                    List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    msg.setTemplateId(et.Id);
                    msg.setWhatId(myContact.Id);
                    msg.setTargetObjectId(conlist[0].Id);
                    system.debug('testtttttttttttttt------------>'+myContact.buildertek__Vendor__r.buildertek__Email_Address__c);
                    msg.toAddresses = new String[] { myContact.buildertek__Vendor__r.buildertek__Email_Address__c };
                        //msg.setToAddresses(new list<string>{EmaiValue});
                        lstMsgs.add(msg);
                    //Messaging.sendEmail(lstMsgs);
                    Savepoint sp = Database.setSavepoint();
                    Messaging.sendEmail(lstMsgs);
                    Database.rollback(sp);
                    
                    system.debug('after savepoint------->');
                    
                    // List<Messaging.Emailfileattachment> signeefileAttachments = new List<Messaging.Emailfileattachment>();
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new list<string>{myContact.buildertek__Vendor__r.buildertek__Email_Address__c});
                    email.setSubject(lstMsgs[0].Subject);
                    
                    body += 'Hi, <br/><br/> ';
                    body += '</br> Please &nbsp;'; 
                    body += '<a href='+ SiteUrl +'buildertek__ConfirmationPage?Id='+myContact.Id+'&templateId='+et.Id+'>Click here</a>';
                    body += '&nbsp;to confirm your Purchase Order details.' ;
                    
                    //email.setPlainTextBody(emailBody);
                    email.setHtmlBody(body);
                    
                    PageReference pagePdf = new PageReference('/apex/PurchaseOrderAttachment'); 
                    pagePdf.getParameters().put('budgetId', myContact.Id);
                    System.debug('okkkkkkkkkkkkkkkkkkkkkkkkkk');
                    blob pdfPageBlob = pagePdf.getContentAsPDF();
                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                    if(filedata != null && filedata != '' && filedata != '[]'){
                        if(inn.size() > 0){
                        for(Innerclass i:inn){
                            system.debug('myContact.id------->'+myContact.id);
                            system.debug('i.POId--------->'+i.POId);
                            if(myContact.buildertek__Sub_Contract__c == i.POId){
                            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();  
                            efa.setFileName(i.fileName); 
                            system.debug('wiuhwih------->'+EncodingUtil.base64Decode(i.fileContent));
                            efa.setBody(EncodingUtil.base64Decode(i.fileContent)); 
                            //efa.setContentType('application/pdf');
                            fileAttachments.add(efa);
                            }
                        }
                        }
                    }
                    if(fileAttachments.size()>0){
                        email.setFileAttachments(fileAttachments);
                    }
                    mails.add(email);
                }
            }
            // Step 6: Send all emails in the master list
            Messaging.sendEmail(mails);
            
            
            msgCls.Status = 'Success';
            msgCls.Message = 'Email sent to selected Vendors successfully';
            
        }else{
            msgCls.Status = 'Failed';
            msgCls.Message = 'Please select atleast one Purchase Order'; 
        }
        
        system.debug('OrderedPOList----->'+OrderedPOList);
        
        if(!OrderedPOList.isEmpty()){
            update OrderedPOList;
        }
        
        return msgCls ;
    }
    
      public class Innerclass{
        @AuraEnabled public string fileName;
        @AuraEnabled public string fileContent;
        @AuraEnabled public string POId;
    }
    
    private static ContentVersion createContentVersion(String base64, String filename) {
    ContentVersion cv = new ContentVersion();
    cv.VersionData = EncodingUtil.base64Decode(base64);
    cv.Title = filename;
    cv.PathOnClient = filename;
    try {
      insert cv;
      return cv;
    } catch(DMLException e) {
      System.debug(e);
      return null;
    }
  }
    
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
              if (contentVersionId == null || recordId == null) { return null; }
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = [
      SELECT ContentDocumentId 
      FROM ContentVersion 
      WHERE Id =: contentVersionId
    ].ContentDocumentId;
    cdl.LinkedEntityId = recordId;
    // ShareType is either 'V', 'C', or 'I'
    // V = Viewer, C = Collaborator, I = Inferred
    cdl.ShareType = 'V';
    try {
      insert cdl;
      return cdl;
    } catch(DMLException e) {
      System.debug(e);
      return null;
    }
  }
    

    

}