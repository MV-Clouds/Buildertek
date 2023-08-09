public with sharing class NewPricingRequestController{
    @AuraEnabled
    public static String approvepricingRequest(Id recordId){
        buildertek__Pricing_Request__c pricingRec=  [SELECT Id, Name, buildertek__Status__c, buildertek__Information__c, buildertek__Quoted_By__c,buildertek__Quoted_By__r.Email, buildertek__Selections_Manager__c, buildertek__Customer__c, buildertek__Price__c, buildertek__Project__c,
                                                     buildertek__Date_Pricing_Submitted__c, buildertek__Date_Pricing_Returned__c, buildertek__Date_Pricing_Completed__c,
                                                     buildertek__Change_Order__c FROM buildertek__Pricing_Request__c where Id =: recordId];
        pricingRec.buildertek__Status__c = 'Customer Approved';
        pricingRec.buildertek__Date_Pricing_Completed__c = system.today();
        Update pricingRec;

        list<buildertek__Pricing_Request_Line__c> prlineRecs=[Select id , Name , buildertek__Description__c , buildertek__Status__c , buildertek__Pricing_Request__c  FROM buildertek__Pricing_Request_Line__c WHERE buildertek__Pricing_Request__c =: pricingRec.Id and buildertek__Status__c !='Rejected'];
        for(buildertek__Pricing_Request_Line__c prline : prlineRecs){
            prline.buildertek__Status__c='Pricing Complete';

        }
        update prlineRecs;
        return 'success';
    }
    @AuraEnabled
    public static string getprrec(Id recordId){
        buildertek__Pricing_Request__c pricingRec=  [SELECT Id, Name, buildertek__Status__c, buildertek__Information__c, buildertek__Quoted_By__c,buildertek__Quoted_By__r.Email, buildertek__Selections_Manager__c, buildertek__Customer__c, buildertek__Price__c, buildertek__Project__c,
                                                     buildertek__Date_Pricing_Submitted__c, buildertek__Date_Pricing_Returned__c, buildertek__Date_Pricing_Completed__c,
                                                     buildertek__Change_Order__c FROM buildertek__Pricing_Request__c where Id =: recordId];
        list<buildertek__Pricing_Request_Line__c> prlineRecs=  [SELECT Id,Name, buildertek__Description__c, buildertek__Status__c, buildertek__Vendor__c, buildertek__Pricing_Request__c, buildertek__Notes__c, buildertek__Reject_Reason__c, buildertek__Type__c,
                                                                buildertek__Pricing_Request__r.Name,buildertek__Pricing_Request__r.buildertek__Project__c,buildertek__Change_Order__c,
                                                                buildertek__RFQ__c, buildertek__Cost__c, buildertek__Markup__c, buildertek__Price__c FROM buildertek__Pricing_Request_Line__c where buildertek__Pricing_Request__c =: pricingRec.Id and 
                                                               buildertek__Status__c = 'Accepted'];
        System.debug('Size of PR Lines : '+prlineRecs.size());
        if(prlineRecs.size()>0){
        list<Id> prlds = new list<Id>();
        list<buildertek__Pricing_Request_Line__c> prlinelist = new list<buildertek__Pricing_Request_Line__c>();
        list<buildertek__Change_Order__c> COList= new list<buildertek__Change_Order__c>();
        for(buildertek__Pricing_Request_Line__c prline : prlineRecs){
            if(prline.buildertek__Status__c == 'Accepted'){
                prlds.add(prline.id);
                buildertek__Change_Order__c changeorderRec = new buildertek__Change_Order__c();
                changeorderRec.Name = prline.buildertek__Description__c;
                changeorderRec.buildertek__Project__c = prline.buildertek__Pricing_Request__r.buildertek__Project__c;
                changeorderRec.buildertek__Date_Created__c = System.today();
                changeorderRec.buildertek__Vendor__c = prline.buildertek__Vendor__c;
                //changeorderRec.buildertek__Markup__c = prline.buildertek__Markup__c;
                changeorderRec.buildertek__Pricing_Request_Line__c = prline.id;
                changeorderRec.buildertek__Pricing_Request__c = prline.buildertek__Pricing_Request__c;
                COList.add(changeorderRec);
            }
        }
        insert COList;
        list<buildertek__Pricing_Request_Line_Details__c> linedetaillist = [SELECT Id, Name, buildertek__Description__c, buildertek__Cost__c, buildertek__Pricing_Request_Line__c, 
                                                                      buildertek__Vendor__c, buildertek__Markup__c,buildertek__Price__c, buildertek__Product__c,buildertek__Pricing_Request_Line__r.buildertek__Change_Order__c
                                                                      FROM buildertek__Pricing_Request_Line_Details__c where buildertek__Pricing_Request_Line__c IN: prlds];
        list<buildertek__Change_Order_Item__c> chageordelist= new list<buildertek__Change_Order_Item__c>();
        if(linedetaillist.size()>0){
            for(buildertek__Change_Order__c prline : COList){
                for(buildertek__Pricing_Request_Line_Details__c prdetailline : linedetaillist){
                    if(prline.buildertek__Pricing_Request_Line__c == prdetailline.buildertek__Pricing_Request_Line__c){
                        buildertek__Change_Order_Item__c changeorderRec = new buildertek__Change_Order_Item__c();
                        changeorderRec.Name = prdetailline.buildertek__Description__c;
                        changeorderRec.buildertek__Change_Order__c = prline.id;
                        changeorderRec.buildertek__Description__c = prdetailline.buildertek__Description__c;
                        changeorderRec.buildertek__Item_Name__c = prdetailline.buildertek__Description__c;
                        //changeorderRec.buildertek__Markup__c = prdetailline.buildertek__Markup__c;
                        changeorderRec.buildertek__Product__c = prdetailline.buildertek__Product__c;
                        changeorderRec.buildertek__Quantity__c = 1;
                        changeorderRec.buildertek__Unit_Price__c = prdetailline.buildertek__Price__c;
                        changeorderRec.buildertek__Vendor__c =prdetailline.buildertek__Vendor__c;
                        chageordelist.add(changeorderRec);
                    }
                } 
            }
            if(chageordelist.size() > 0){
                insert chageordelist;
            }
        }
        return 'success';
        }else{
          return 'error';   
        }
    }
  
    
    @AuraEnabled
    public static String getpricingRequest(Id recordId){
     buildertek__Pricing_Request__c pricingRec=  [SELECT Id, Name, buildertek__Status__c, buildertek__Information__c, buildertek__Quoted_By__c,buildertek__Quoted_By__r.Email, buildertek__Selections_Manager__c, buildertek__Customer__c, buildertek__Price__c, buildertek__Project__c,
          buildertek__Date_Pricing_Submitted__c, buildertek__Date_Pricing_Returned__c, buildertek__Date_Pricing_Completed__c,
          buildertek__Change_Order__c FROM buildertek__Pricing_Request__c where Id =: recordId];
            pricingRec.buildertek__Status__c = 'Submitted';
            pricingRec.buildertek__Date_Pricing_Submitted__c = system.today();
            Update pricingRec;
             string toemailadd='';
        if(pricingRec.buildertek__Quoted_By__r.Email !=null){
            toemailadd = pricingRec.buildertek__Quoted_By__r.Email;
            System.debug('toemailadd--->'+toemailadd);
            string theTemplate;
            theTemplate = [SELECT Id,Name
            FROM EmailTemplate
            WHERE Name  = 'Pricing Request Submitted Notification'].Id;        
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();    
            Messaging.SingleEmailMessage message1= new        Messaging.SingleEmailMessage();
            message1.toAddresses = new String[] { toemailadd};
            message1.setTemplateID(theTemplate);     
            message1.setSaveAsActivity(false);
            message1.setWhatId(pricingRec.Id);
            //message1.setSubject('New RFI Notification - [ref:'+newrfi.Id+']');
            message1.setTargetObjectId(pricingRec.buildertek__Quoted_By__c);
            messageList.add(message1);
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(messageList);
            Database.rollback(sp);
            try{ 
            List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
            // loop through the previous message list and set the email fields
            for (Messaging.SingleEmailMessage email : messageList) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSaveAsActivity(false);
            emailToSend.setSubject(email.getSubject());
            //emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
            emailToSend.setFileAttachments(email.getFileAttachments());
            //emailToSend.setCcAddresses(CCAdresses);
            actualMessageList.add(emailToSend);
            system.debug('emailToSend--->'+emailToSend);
            }
            Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);           
            }catch(Exception e){
                System.debug('The email failed to send: ');             
            }    

        }
        return 'success';
    }
     @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }
     @AuraEnabled
     public static String getRecordField(Id recordId) {
         buildertek__Project__c admin = [select id,buildertek__Customer__c from buildertek__Project__c where id =:recordId];
         /*if(admin.buildertek__Administrator__c != null){
             return admin.buildertek__Administrator__c;
         }
         else{*/
             return admin.buildertek__Customer__c;
        // }
     }
    @AuraEnabled
     public static String getFieldSet(String objectName, String fieldSetName){
         String result = '';
         List<String> pickListValuesList = new List<String>();
         try{
             SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
             Schema.DescribeSObjectResult d = objToken.getDescribe();
             Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
             if (FsMap.containsKey(fieldSetName)){
                 for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
                     if (result != ''){
                         result += ',';
                     }
                     String jsonPart = '{';
                     jsonPart += '"label":"' + f.getLabel()+'",';
                     jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                     jsonPart += '"type":"' + (f.getType())+'",';
                     jsonPart += '"name":"' + f.getFieldPath()+'"';
                     if (String.valueOf(f.getType()) == 'PICKLIST'){
                         pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
                         jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                     }
                     jsonPart += '}';
                     result += jsonPart;
                 }
             }
             
         } catch (Exception e){
             result += e.getLineNumber()+' : ' + e.getMessage();
             System.debug('Error::' + e.getMessage());
             System.debug('Error At Line::' + e.getLineNumber());
         }
         return '[' + result + ']';
     }
     
     @AuraEnabled
     public static List<String> getDropDown(String objName, String fieldName){
         List<String> pickListValuesList = new List<String>();
         try{
             Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
             Schema.DescribeSObjectResult r = s.getDescribe();
             Map<String, Schema.SObjectField> fields = r.fields.getMap();
             Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
             List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
             for (Schema.PicklistEntry pickListVal : ple){
                 pickListValuesList.add(pickListVal.getLabel());
             }
         } catch (Exception e){
             throw new AuraHandledException(e.getMessage());
         }
         return pickListValuesList;
     }
     @AuraEnabled
    public static buildertek__Pricing_Request__c getSOVName(string recordId){
        buildertek__Pricing_Request__c consSovLines = [select Id, Name, buildertek__Project__c, buildertek__Project__r.Name from buildertek__Pricing_Request__c WHERE Id =:recordId ORDER by Name ASC  ];
         return consSovLines;
    }
     @AuraEnabled
    public static object getPRs(){
        List<MasterquoteClass> MasterquoteClassList = new List<MasterquoteClass>();
        List<buildertek__Pricing_Request__c> prList;
             prList = [SELECT Id, Name, buildertek__Status__c, buildertek__Information__c, buildertek__Quoted_By__c,buildertek__Quoted_By__r.Email, buildertek__Selections_Manager__c, buildertek__Customer__c, buildertek__Price__c, buildertek__Project__c,
                       buildertek__Date_Pricing_Submitted__c, buildertek__Date_Pricing_Returned__c, buildertek__Date_Pricing_Completed__c,buildertek__Project__r.Name,buildertek__Type__c,
                       buildertek__Change_Order__c FROM buildertek__Pricing_Request__c
                       WHERE buildertek__Type__c = 'Master' ORDER by Name ASC  ];    
        
        for(buildertek__Pricing_Request__c bud : prList){
            MasterquoteClass MasterquotesClassRecord = new MasterquoteClass(); 
            MasterquotesClassRecord.quoteRecord = bud;
            MasterquotesClassRecord.budgetCheck = false;
            MasterquoteClassList.add(MasterquotesClassRecord);
        }
        return  MasterquoteClassList;                                               
    }
    public class MasterquoteClass{
         @AuraEnabled
         public buildertek__Pricing_Request__c quoteRecord {get;set;}
         @AuraEnabled
         public buildertek__Master_Budget__c masterBudgetRecord {get;set;}
         @AuraEnabled
         public boolean budgetCheck {get;set;}
    }
     @AuraEnabled
    public static MessageClass importMasterBudgetLines1(List<String> budgetIds, String recordId){
        MessageClass msg = new MessageClass();
        try{
            List<buildertek__Pricing_Request_Line__c> masterquoteList;
            List<buildertek__Pricing_Request_Line_Details__c> pricingrequestlinedetails;
            
            masterquoteList = [SELECT Id,Name, buildertek__Description__c, buildertek__Status__c, buildertek__Pricing_Request__c, buildertek__Notes__c, buildertek__Type__c,
                              buildertek__Change_Order__c,
                               buildertek__RFQ__c, buildertek__Cost__c, buildertek__Markup__c, buildertek__Price__c
                               FROM buildertek__Pricing_Request_Line__c
                               WHERE buildertek__Pricing_Request__c IN: budgetIds]; 
            List<buildertek__Pricing_Request_Line__c> prlineslist =  new List<buildertek__Pricing_Request_Line__c>();
            list<Id> pricingrequestids= new list<Id>();
            if(!masterquoteList.isEmpty()){
                for(buildertek__Pricing_Request_Line__c masterquote : masterquoteList){
                    pricingrequestids.add(masterquote.id);
                    buildertek__Pricing_Request_Line__c prline = new buildertek__Pricing_Request_Line__c();
                    prline.buildertek__Description__c = masterquote.buildertek__Description__c;
                    prline.buildertek__Markup__c = masterquote.buildertek__Markup__c;
                    prline.buildertek__Notes__c = masterquote.buildertek__Notes__c;
                    prline.buildertek__Pricing_Request__c = recordId;
                    prline.buildertek__Type__c = masterquote.buildertek__Type__c;
                    prline.buildertek__Status__c = masterquote.buildertek__Status__c;
                    prline.buildertek__Old_Pricing_Reuest_Id__c = masterquote.id;
                    prlineslist.add(prline);
               }   
            }
            if(prlineslist.size() > 0){
               insert prlineslist;
                list<buildertek__Pricing_Request_Line_Details__c> pricingdetailList = new list<buildertek__Pricing_Request_Line_Details__c>();
                pricingrequestlinedetails = [SELECT Id, Name, buildertek__Pricing_Request_Line__c, buildertek__Cost__c, buildertek__Vendor__c, buildertek__Markup__c, buildertek__Price__c, 
                                             buildertek__Product__c, buildertek__Description__c, buildertek__Quantity__c FROM buildertek__Pricing_Request_Line_Details__c
                                             Where buildertek__Pricing_Request_Line__c IN: pricingrequestids];
                for(buildertek__Pricing_Request_Line__c prlineRec : prlineslist){
                    for(buildertek__Pricing_Request_Line_Details__c oldpredetaillineRec : pricingrequestlinedetails){
                        if(prlineRec.buildertek__Old_Pricing_Reuest_Id__c == oldpredetaillineRec .buildertek__Pricing_Request_Line__c){
                            buildertek__Pricing_Request_Line_Details__c newpricingdetalRec = new buildertek__Pricing_Request_Line_Details__c();
                            newpricingdetalRec.buildertek__Pricing_Request_Line__c = prlineRec.Id;
                            newpricingdetalRec.buildertek__Cost__c = oldpredetaillineRec.buildertek__Cost__c;
                            newpricingdetalRec.buildertek__Vendor__c = oldpredetaillineRec.buildertek__Vendor__c;
                            newpricingdetalRec.buildertek__Markup__c = oldpredetaillineRec.buildertek__Markup__c;
                            newpricingdetalRec.buildertek__Product__c = oldpredetaillineRec.buildertek__Product__c;
                            newpricingdetalRec.buildertek__Description__c = oldpredetaillineRec.buildertek__Description__c;
                            if(oldpredetaillineRec.buildertek__Quantity__c != null){
                                newpricingdetalRec.buildertek__Quantity__c = oldpredetaillineRec.buildertek__Quantity__c;
                            }else{
                               newpricingdetalRec.buildertek__Quantity__c = 1; 
                            }
                            pricingdetailList.add(newpricingdetalRec);
                         }
                    }
                }
                if(pricingdetailList.size() > 0){
                 insert pricingdetailList;   
                }
                msg.Status = 'Success';
                msg.Message = 'Pricing Reqest Lines Imported Successfully';
            }else{
                msg.Status = 'Failed';
                msg.Message = 'There were no Pricing Reqest Lines for the selected Pricing Request';    
            }
            return msg;
        }catch(Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();  
            return msg;
        }                                           
    }
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
         @AuraEnabled
        public string Message {get;set;}
        
    } 
     
 }