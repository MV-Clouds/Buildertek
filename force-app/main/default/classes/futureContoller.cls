public class futureContoller {
    @future
    public static void createContractsFromQuote(List<Id> listQuoteIds){
        BudgetContractCreateHelper.createContractsFromQuote(listQuoteIds);     
    }
    
    @future
    public static void createBudgetFromQuote(List<Id> QuoteId){
        BudgetContractCreateHelper.createBudgetFromQuote(QuoteId);     
    }
    @future
    public static void updatetimecardlist(Map<Id,decimal> timecardmap){
       list<buildertek__Time_Cards__c> timelist = new list<buildertek__Time_Cards__c>();
       for(Id key: timecardmap.keySet()){
          buildertek__Time_Cards__c timerec = new buildertek__Time_Cards__c();
           timerec.id =key;
           timerec.buildertek__Weekly_OT__c =timecardmap.get(key);
           timelist.add(timerec);
       }
       update timelist;
        /* buildertek__Time_Cards__c  resloglist = [select id,
                                                             Name,buildertek__Complete__c,buildertek__Budget_Line__c,buildertek__Resource__c,buildertek__Resource__r.Name,
                                                             buildertek__Daily_Expense__c,buildertek__Description__c,buildertek__Details__c,buildertek__End_Distance__c,
                                                             buildertek__End_Location__c,buildertek__End_Time2__c,buildertek__End_Time__c,buildertek__Entry_Date__c,
                                                             buildertek__Lunch_In__c,buildertek__Lunch_Out__c,buildertek__Schedule_Item__c,buildertek__Start_Time__c,
                                                             buildertek__Total_Break_Time__c,buildertek__Weekly_OT__c 
                                                             from buildertek__Time_Cards__c
                                                             where Id =:recordId];  
        resloglist.Id = recordId;
        resloglist.buildertek__Weekly_OT__c = weeklyot;
        Update resloglist;*/
    }
   public static void updateScheduleRec(String recId){
   System.debug('recId-----------'+recId);
       list<buildertek__Schedule__c> scheduleList =[SELECT Id, 
                                                    buildertek__Start_Date__c,
                                                    buildertek__End_Date__c, 
                                                    buildertek__Original_Start_Date__c, 
                                                    buildertek__Original_End_Date__c FROM buildertek__Schedule__c where id=:recId];
       System.debug('scheduleList-----------'+scheduleList[0].buildertek__Start_Date__c);
       System.debug('scheduleList-----------'+scheduleList[0].buildertek__End_Date__c);
       List<buildertek__Schedule__c> scheduleListNew=new List<buildertek__Schedule__c>();
       for(buildertek__Schedule__c scheduleRec:scheduleList){
           if(scheduleRec.buildertek__Start_Date__c!=null && scheduleRec.buildertek__End_Date__c!=null){
           if(scheduleRec.buildertek__Original_Start_Date__c==null && scheduleRec.buildertek__Original_End_Date__c==null){
               scheduleRec.buildertek__Original_Start_Date__c=scheduleRec.buildertek__Start_Date__c;
                scheduleRec.buildertek__Original_End_Date__c=scheduleRec.buildertek__End_Date__c;
                }
           }
           scheduleListNew.add(scheduleRec);
          
       }
       update scheduleListNew;
       }
    @future
    public static void futuremethod(Boolean rfqstatus, string rfqToVendorId){
    system.debug('YYYY');
    buildertek__RFQ_Template_Settings__c rfqTemplateSettings;
     rfqTemplateSettings = buildertek__RFQ_Template_Settings__c.getOrgDefaults();
        List<buildertek__RFQ_To_Vendor__c> rfqToVendorListDup = [Select Id, Name, buildertek__RFQ__c,buildertek__RFQ__r.buildertek__Status__c,
            buildertek__Status__c ,buildertek__Contact__c
                               FROM buildertek__RFQ_To_Vendor__c
                               WHERE Id = :rfqToVendorId
                               Limit 1];
        buildertek__RFQ__c rfqrec = [select id,Name,buildertek__Project__c,buildertek__Project__r.Name,
                buildertek__Project__r.OwnerId,buildertek__Project__r.Owner.Email
                from buildertek__RFQ__c where Id =: rfqToVendorListDup[0].buildertek__RFQ__c ];
    
                string toemailadd='';
                if(rfqrec.buildertek__Project__c!=null){
                  toemailadd = rfqrec.buildertek__Project__r.Owner.Email;
                    System.debug('toemailadd--->'+toemailadd);
                }
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[]{rfqTemplateSettings.buildertek__Inbound_Email_Address__c};
        message.optOutPolicy = 'FILTER';
        if (rfqStatus == true){
            message.subject = 'Accept [ref:' + rfqToVendorId + ']';
            message.plainTextBody = 'Accepted';
            buildertek__rfq_to_vendor__c rfqToVendor;
                            rfqToVendor = [select Id, name, buildertek__status__c, buildertek__RFQ__c,buildertek__Accepted_Date__c
                                           from buildertek__rfq_to_vendor__c
                                           where id = :rfqToVendorId];

                            if (rfqToVendor.Id != null){
                                rfqToVendor.buildertek__status__c = 'Accepted';
                                rfqToVendor.buildertek__Accepted_Date__c = system.now();
                                update rfqToVendor;

                                if (rfqToVendor.buildertek__RFQ__c != null){
                                    buildertek__RFQ__c rfqRec1 = [SELECT Id, Name, buildertek__Accepted_Date__c, buildertek__Awarded_Date__c, buildertek__RFQ_s_Replied_To__c
                                                                 FROM buildertek__RFQ__c
                                                                 WHERE Id = :rfqToVendor.buildertek__RFQ__c];

                                    rfqRec1.buildertek__Accepted_Date__c = System.today(); // here we update the accepted date when the status is accepted
                                    rfqRec1.buildertek__status__c = 'Accepted';
                                   // rfqRec.buildertek__RFQ_s_Replied_To__c += 1; // here we get the count of replied email messages
                                    update rfqRec1;
                                }
                            }
            
        } else{
            message.subject = 'Decline [ref:' + rfqToVendorId + ']';
            message.plainTextBody = 'Rejected';
        }
        system.debug('---->'+message);
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        System.debug('results------>'+results);
        if (rfqStatus == true && (rfqrec.buildertek__Project__c!=null)){   
                       string theTemplate;
                        theTemplate = [SELECT Id
                        FROM EmailTemplate
                        WHERE Name  = 'Award Accept Manager Email'].Id;        
                        system.debug('theTemplate>'+theTemplate);
               //   toemailadd = 'harika.chunduri@diligentforcelabs.com';
                        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();    
                        Messaging.SingleEmailMessage message1= new        Messaging.SingleEmailMessage();
            
                        message1.toAddresses = new String[] { toemailadd};
                        message1.setTemplateID(theTemplate);     
                       // message1.setSaveAsActivity(false);
                        //message1.setHTMLBody('HIIIIIIIIIIIIII');
                        message1.setWhatId(rfqToVendorId);
                        //message1.setSubject('New RFI Notification - [ref:'+newrfi.Id+']');
                        message1.setTargetObjectId(rfqToVendorListDup[0].buildertek__Contact__c);
                        messageList.add(message1);
                        Savepoint sp = Database.setSavepoint();
                        Messaging.sendEmail(messageList);
                        Database.rollback(sp);
                     //try{ 
            
                            //List<string> CCAdresses = new List<string>();                    
                            //CCAdresses.add('sowndarya.nittala@diligentforcelabs.com'); 
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
                             system.debug('actualMessageList---->'+actualMessageList);
                            Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);           
                            System.debug('The email was sent successfully.');
                     // }catch(Exception e){
                       //    System.debug('The email failed to send: ');             
                       // }                
                    }

    }

    
}