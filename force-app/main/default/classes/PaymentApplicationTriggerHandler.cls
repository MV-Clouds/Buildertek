public class PaymentApplicationTriggerHandler {
    
    public static Boolean blnSkipPayAppInsertTrigger = false;
    
    public static Boolean blnSkipPayAppForEmail = false;
    
     public static Boolean blnSkipPayAppForupdateOriginal = false;
    
    
    public void beforeInsert(List<buildertek__SOV_Payment_Application__c> NewApp){
        Set<Id> projectId=new Set<Id>();
        Set<Id> PayAppIds = new Set<Id>();
        for(buildertek__SOV_Payment_Application__c pa:NewApp){
            projectId.add(pa.buildertek__Project__c);
            PayAppIds.add(pa.Id);
        }
        
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry1 = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec1 = Database.query(strQry1);
        if(userRec1.size() > 0){
            portalCode = userRec1[0].get('isPortalEnabled').toString();
        }
        
        List<buildertek__SOV_Payment_Application__c> paymentApplication = new  List<buildertek__SOV_Payment_Application__c>();
        
        if(portalCode == 'true'){
            
            paymentApplication = [SELECT Id,
                                  Name, 
                                  CreatedDate, 
                                  buildertek__Application__c,
                                  buildertek__Project__c, 
                                  recordtype.name,
                                  buildertek__Change_Order_Additions__c, 
                                  buildertek__Change_Order_Decuctions__c ,
                                  buildertek__isCommunityUser__c
                                  FROM buildertek__SOV_Payment_Application__c 
                                  where buildertek__Project__c=:projectId and recordtype.name = 'AP' order by CreatedDate desc limit 1];
            
        }else{
            
            paymentApplication = [SELECT Id,
                                  Name, 
                                  CreatedDate, 
                                  buildertek__Application__c,
                                  buildertek__Project__c, 
                                  recordtype.name,
                                  buildertek__Change_Order_Additions__c, 
                                  buildertek__Change_Order_Decuctions__c ,
                                  buildertek__isCommunityUser__c
                                  FROM buildertek__SOV_Payment_Application__c 
                                  where buildertek__Project__c=:projectId and recordtype.name = 'AR' order by CreatedDate desc limit 1];
            
        }
        
        
        System.debug('leatest payment application*****************************'+paymentApplication);
        List<buildertek__SOV_Payment_Application__c> paymentApplicationnew=new List<buildertek__SOV_Payment_Application__c>();
        for(buildertek__SOV_Payment_Application__c payapp:NewApp){
            if(payapp.buildertek__Application__c != null || payapp.buildertek__Application__c != ''){
                
                
            }
            if(paymentApplication.size() >0 ){
                if(paymentApplication[0].buildertek__Change_Order_Additions__c!=0){
                    payapp.buildertek__CO_Additions_Approved_This_Month__c=paymentApplication[0].buildertek__Change_Order_Additions__c;
                    
                }
                if(paymentApplication[0].buildertek__Change_Order_Decuctions__c!=0){
                    payapp.buildertek__CO_Deductions_Approved_in_Previous_Month__c=paymentApplication[0].buildertek__Change_Order_Decuctions__c;
                }
            }
            
            
            
        }
    }
    
    public void OnAfterupdate(List<buildertek__SOV_Payment_Application__c> oldPayment, List<buildertek__SOV_Payment_Application__c> newPayment,Map<Id, buildertek__SOV_Payment_Application__c> oldPaymetnMap, Map<Id, buildertek__SOV_Payment_Application__c> newPaymentMap){
        
        system.debug('calling');
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry1 = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec1 = Database.query(strQry1);
        if(userRec1.size() > 0){
            portalCode = userRec1[0].get('isPortalEnabled').toString();
        }
        system.debug('postal code'+ portalCode);
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> IntparentSOVList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
        
        List<buildertek__SOV_Continuation__c> continuationSheetIds = [select Id, Name, buildertek__SOV_Payment_Application__c,
                                                                      buildertek__SOV_Payment_Application__r.RecordType.Name,buildertek__SOV_Payment_Application__r.buildertek__Status__c,
                                                                      (SELECT Id,
                                                                       buildertek__Vendor_Work_Completed_from_Previous_Appl__c,
                                                                       buildertek__Vendor_Work_Completed_This_Period__c,
                                                                       buildertek__Vendor_Material_Presently_Stored__c,
                                                                       buildertek__Vendor_Total__c,
                                                                       buildertek__Vendor_G_C__c,
                                                                       buildertek__Vendor_Balance_To_Finish__c,
                                                                       buildertek__Vendor_Retainage__c,
                                                                       buildertek__Scheduled_Value__c,
                                                                       buildertek__Work_Completed_from_Previous_Application__c,
                                                                       buildertek__Work_Completed__c,
                                                                       buildertek__Material_Presently_Stored__c
                                                                       FROM SOV_Continuation_Sheet_Lines__r)
                                                                      from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__c IN:newPayment LIMIT 10000];
        
        
        
        List<buildertek__SOV_Payment_Application__c> arPaymentApp = [select Id, Name, buildertek__Total_Completed__c,buildertek__Certified_Date__c,buildertek__Current_Payment_Due__c, buildertek__Amount_Certified__c,buildertek__Status__c, RecordType.Name from buildertek__SOV_Payment_Application__c where Id IN: newPayment  LIMIT 10000];
        
        if(!arPaymentApp.isEmpty()){
            for(buildertek__SOV_Payment_Application__c paymentRec : arPaymentApp){
                
                paymentRec.buildertek__Amount_Certified__c = paymentRec.buildertek__Current_Payment_Due__c;
                
                /* if(paymentRec.buildertek__Status__c == 'Customer Accepted' && paymentRec.RecordType.Name == 'AR'){
paymentRec.buildertek__Amount_Certified__c = paymentRec.buildertek__Current_Payment_Due__c;
paymentRec.buildertek__Certified_Date__c = Date.today();
}else if(paymentRec.buildertek__Status__c == 'Company Accepted' && paymentRec.RecordType.Name == 'AP'){
paymentRec.buildertek__Amount_Certified__c = paymentRec.buildertek__Current_Payment_Due__c;
}*/
            }                    
        }  
        
        PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = true;
        Update arPaymentApp;
        PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = false; 
        
        
        
        
        
        system.debug('continuationSheetIds-------->'+continuationSheetIds);
        
        
        for(buildertek__SOV_Continuation__c sovRec : continuationSheetIds){
            //system.debug(sovRec[0].buildertek__SOV_Payment_Application__r.RecordType.Name);
            
            if(portalCode == 'true'){
                if(sovRec.buildertek__SOV_Payment_Application__r.RecordType.Name == 'AP' && sovRec.buildertek__SOV_Payment_Application__r.buildertek__Status__c == 'Vendor Submitted'){
                    system.debug('AP');
                    for(buildertek__SOV_Continuation_Sheet_Lines__c sovLineRec : sovRec.SOV_Continuation_Sheet_Lines__r){
                        sovLineRec.buildertek__Scheduled_Value__c = sovLineRec.buildertek__Scheduled_Value__c;
                        sovLineRec.buildertek__Work_Completed_from_Previous_Application__c = sovLineRec.buildertek__Vendor_Work_Completed_from_Previous_Appl__c;
                        sovLineRec.buildertek__Work_Completed__c = sovLineRec.buildertek__Vendor_Work_Completed_This_Period__c;
                        sovLineRec.buildertek__Material_Presently_Stored__c = sovLineRec.buildertek__Vendor_Material_Presently_Stored__c;
                        System.debug('sovLineRec ==> '+sovLineRec);
                        IntparentSOVList.add(sovLineRec);
                    }
                }
            }else{
                if(sovRec.buildertek__SOV_Payment_Application__r.RecordType.Name == 'AP'){
                    for(buildertek__SOV_Continuation_Sheet_Lines__c sovLineRec : sovRec.SOV_Continuation_Sheet_Lines__r){
                        
                        if(sovLineRec.buildertek__Scheduled_Value__c != null && sovLineRec.buildertek__Scheduled_Value__c != 0){
                            sovLineRec.buildertek__Vendor_Scheduled_Value__c = sovLineRec.buildertek__Scheduled_Value__c;
                        }
                        
                        if(sovLineRec.buildertek__Work_Completed_from_Previous_Application__c != null && sovLineRec.buildertek__Work_Completed_from_Previous_Application__c != 0){
                            sovLineRec.buildertek__Vendor_Work_Completed_from_Previous_Appl__c = sovLineRec.buildertek__Work_Completed_from_Previous_Application__c;
                            
                        }
                        system.debug('sovLineRec.buildertek__Work_Completed__c->'+sovLineRec.buildertek__Work_Completed__c);
                        if(sovLineRec.buildertek__Work_Completed__c != null && sovLineRec.buildertek__Work_Completed__c != 0.00){
                            sovLineRec.buildertek__Vendor_Work_Completed_This_Period__c = sovLineRec.buildertek__Work_Completed__c;   
                        }
                        if(sovLineRec.buildertek__Material_Presently_Stored__c != null && sovLineRec.buildertek__Material_Presently_Stored__c != 0){
                            sovLineRec.buildertek__Vendor_Material_Presently_Stored__c = sovLineRec.buildertek__Material_Presently_Stored__c;
                        }
                        System.debug('sovLineRec ==> '+sovLineRec);
                        IntparentSOVList.add(sovLineRec);
                    }
                }
                
            }
            
        }
        
        
        system.debug('IntparentSOVList-------->'+IntparentSOVList);
        
        
        if(!IntparentSOVList.isEmpty()){
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = true;
            
            update IntparentSOVList;
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = false;  
        }
        
        system.debug('IntparentSOVList-------->'+IntparentSOVList);
        
        
        
        
        list<string> updateOldIdsList = new List<string>();
        for(buildertek__SOV_Payment_Application__c paymentRec : newPayment){
            if(paymentRec.buildertek__Status__c == 'Customer Accepted' && paymentRec.RecordType.Name == 'PaymentApplication'){
                string oldpaymentids = paymentRec.buildertek__Old_PA_Ids__c;
                if(oldpaymentids != null){
                    List<String> oldIdsList = paymentRec.buildertek__Old_PA_Ids__c.split('_');
                    updateOldIdsList.addAll(oldIdsList ); 
                }
            }                    
        }  
        list<buildertek__SOV_Payment_Application__c> oldpaylist = new list<buildertek__SOV_Payment_Application__c>(); 
        
        
        list<buildertek__SOV_Payment_Application__c> oldpaymentlist = [select id,Name,buildertek__Old_PA_Ids__c,buildertek__Status__c 
                                                                       from buildertek__SOV_Payment_Application__c where Id IN: updateOldIdsList  LIMIT 10000];
        
        for(buildertek__SOV_Payment_Application__c paymentrec : oldpaymentlist){
            paymentrec.buildertek__Status__c = 'Company Accepted';
            oldpaylist.add(paymentrec);
        }
        if(oldpaylist.size() > 0){
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = true;
            update oldpaylist;
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = false;  
        }
        
        
        
        
        // Code to send email notification to vendor when payapp status changes to company Rejected  Start
        
        
        
        List<String> vendorrecordIds = new List<String>();
        Map<String,string> vendorMap = new Map<String,String>();
        for(buildertek__SOV_Payment_Application__c sov:newPayment){
            vendorrecordIds.add(sov.buildertek__Owner_Account__c);
        }
        
        if(PaymentApplicationTriggerHandler.blnSkipPayAppForEmail == false){
            system.debug('send mails---->');
            List<Account> accList = [Select Id,buildertek__Email_Address__c from Account Where Id IN:vendorrecordIds];
            for(Account ac:accList){
                vendorMap.put(ac.Id,ac.buildertek__Email_Address__c);
            }
            
            
            
            EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE name ='Payment App Reject Notification' limit 1];
            List<contact> conlist = [select id,name, Email from contact where Email != null limit 1];
            for(buildertek__SOV_Payment_Application__c sov:newPayment){
                
                system.debug('oldmapvalue------->'+oldPaymetnMap.get(sov.Id).buildertek__Status__c);
                if(oldPaymetnMap.get(sov.Id).buildertek__Status__c != 'Company Rejected'){
                    if(sov.buildertek__Status__c == 'Company Rejected'){
                        string EmaiValue = vendorMap.get(sov.buildertek__Owner_Account__c);
                        
                        if(EmaiValue != null && EmaiValue != ''){
                            system.debug('@@@@@@@@@@'+EmaiValue);
                            string htmlbody = '';
                            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
                            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                            msg.setTemplateId(et.Id);
                            msg.setWhatId(sov.Id);
                            msg.setTargetObjectId(conlist[0].Id);
                            msg.toAddresses = new String[] { EmaiValue };
                                //msg.setToAddresses(new list<string>{EmaiValue});
                                lstMsgs.add(msg);
                            //Messaging.sendEmail(lstMsgs);
                            Savepoint sp = Database.setSavepoint();
                            Messaging.sendEmail(lstMsgs);
                            Database.rollback(sp);
                            
                            
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            email.setToAddresses(new list<string>{EmaiValue});
                            email.setSubject(lstMsgs[0].Subject);
                            //email.setPlainTextBody(emailBody);
                            email.setHtmlBody(lstMsgs[0].getHTMLBody());
                            
                            if(PaymentApplicationTriggerHandler.blnSkipPayAppForEmail == false){
                                system.debug('send mails---->');
                                if(email != null){
                                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                                }
                                
                                PaymentApplicationTriggerHandler.blnSkipPayAppForEmail = true;
                            }
                            
                            
                            
                            
                            
                        }else{
                            //sov.addError('Vendor Email Should not be null');
                        }
                    }
                    
                    // Code to send email notification to vendor when payapp status changes to company Rejected  END
                    
                }
            }
            PaymentApplicationTriggerHandler.blnSkipPayAppForEmail = true;
        }
        
        
        
        
    }
    
    public void afterInsert(List<buildertek__SOV_Payment_Application__c> NewApp, Map<Id, buildertek__SOV_Payment_Application__c> newAppMap){
        List<buildertek__SOV_Continuation__c> conlst = new List<buildertek__SOV_Continuation__c>();
        system.debug('application'+NewApp);
        system.debug('newAppMap'+newAppMap);
        
        Set<Id> PayAppIds = new Set<Id>();
        for(buildertek__SOV_Payment_Application__c pa:NewApp){
            PayAppIds.add(pa.Id);
        }
        
        
        if(!PayAppIds.isEmpty()){
            List<buildertek__SOV_Payment_Application__c> PaymentApps = [select Id,RecordType.Name,buildertek__PA_Type__c from buildertek__SOV_Payment_Application__c where Id IN:PayAppIds  LIMIT 10000];
            
            
            if(!PaymentApps.isEmpty()){
                for(buildertek__SOV_Payment_Application__c paymentRec : PaymentApps){
                    if(paymentRec.RecordType.Name == 'AR'){
                        paymentRec.buildertek__PA_Type__c = 'AR';
                    }else if(paymentRec.RecordType.Name == 'AP'){
                        paymentRec.buildertek__PA_Type__c = 'AP';
                    }
                }                    
                
            }
            
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = true;
            update PaymentApps;
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = false; 
            
            
        }
        
        
        
        
        
        string portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Name, isPortalEnabled From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        } 
        
        User userAccount = [select Id, buildertek__Account_Id__c from User where Id =:userName ];
        
        system.debug('userAccount'+userAccount);
        system.debug('userId'+userName);
        system.debug('username'+userRec[0].Name);
        
        
        if(portalCode == 'true'){
            
            //For Community
            SET<Id> ProjectIds = new SET<Id>();
            
            for(buildertek__SOV_Payment_Application__c acc:NewApp){
                system.debug('application Id'+acc.id);
                if(acc.buildertek__Project__c != null){
                    ProjectIds.add(acc.buildertek__Project__c);       
                }
                
                system.debug('ProjectIds'+ProjectIds);
                
                buildertek__SOV_Continuation__c con = New buildertek__SOV_Continuation__c();
                con.Name = 'Continuation Sheet - 1';
                con.buildertek__SOV_Payment_Application__c=acc.id;
                conlst.add(con);
                
            }
            
            
            
            //If project with use PA type SOVs
            SET<Id> SovProjectIDS = new SET<Id>();
            /*list<buildertek__Project__c> projWithSovType = [select Id, Name, buildertek__Use_PA_Type__c from buildertek__Project__c where buildertek__Use_PA_Type__c  = 'SOVs' AND Id IN:ProjectIds ] ;
if(projWithSovType.size() >0){
for(buildertek__Project__c proj :projWithSovType){
SovProjectIDS.add(proj.Id);
}
}*/
            system.debug('SovProjectIDS'+SovProjectIDS); 
            
            //If Project With Use OA Type Budget Lines
            SET<Id> BudgetProjectIDS = new SET<Id>();
            list<buildertek__Project__c> projWithBudgetType = [select Id, Name, buildertek__Use_PA_Type__c from buildertek__Project__c where buildertek__Use_PA_Type__c  = 'Budget Lines' AND Id IN:ProjectIds  LIMIT 10000] ;
            if(projWithBudgetType.size() >0){
                for(buildertek__Project__c proj :projWithBudgetType){
                    BudgetProjectIDS.add(proj.Id);
                }
            }
            system.debug('BudgetProjectIDS'+BudgetProjectIDS);
            
            
            if(SovProjectIDS.size()>0 ){
                
                
                
                system.debug('conlst'+conlst);
                
                
                SET<Id> scheduleIds = new SET<Id>();
                
                list<buildertek__Schedule_of_Values__c> scheduleValues = [select Id , buildertek__Project__c from buildertek__Schedule_of_Values__c where buildertek__Project__c IN: SovProjectIDS  LIMIT 10000];
                
                system.debug('scheduleIds'+scheduleValues);
                for(buildertek__Schedule_of_Values__c sov :scheduleValues){
                    if(sov.buildertek__Project__c != null){
                        scheduleIds.add(sov.Id);       
                    }
                }
                
                system.debug('schduleIds'+scheduleIds);
                String uName =userRec[0].Name;
                
                system.debug('Conlist'+conlst); 
                blnSkipPayAppInsertTrigger = true;
                
                if(conlst.size() > 0){
                    insert conlst;
                    system.debug('SovProjectIDS -------> '+SovProjectIDS);
                    if(SovProjectIDS.size() > 0){
                        Map<String, String> projectSheetMap = new Map<String, String>();
                        List<buildertek__SOV_Continuation__c> continuationSheets = [SELECT Id, 
                                                                                    Name, 
                                                                                    buildertek__SOV_Payment_Application__c,
                                                                                    buildertek__SOV_Payment_Application__r.buildertek__Project__c
                                                                                    FROM buildertek__SOV_Continuation__c
                                                                                    WHERE Id IN: conlst  LIMIT 10000]; 
                        system.debug('continuationSheets size ------> '+continuationSheets.size());
                        system.debug('continuationSheets ------> '+continuationSheets);
                        if(continuationSheets.size() > 0){
                            for(buildertek__SOV_Continuation__c contSheet : continuationSheets){
                                system.debug('Project Id ------> '+contSheet.buildertek__SOV_Payment_Application__r.buildertek__Project__c);
                                projectSheetMap.put(contSheet.buildertek__SOV_Payment_Application__r.buildertek__Project__c, contSheet.Id);       
                            }    
                        }
                        
                        system.debug('projectSheetMap'+projectSheetMap);
                        
                        List<buildertek__Schedule_of_Value_Lines__c> SOVItems = [SELECT Id,
                                                                                 Name,
                                                                                 buildertek__Description_of_Work__c,
                                                                                 buildertek__Item__c,
                                                                                 buildertek__Scheduled_Value__c,
                                                                                 buildertek__Schedule_of_Values__c,
                                                                                 buildertek__Schedule_of_Values__r.buildertek__Project__c,
                                                                                 buildertek__Vendor__c
                                                                                 FROM buildertek__Schedule_of_Value_Lines__c
                                                                                 WHERE buildertek__Schedule_of_Values__c IN: scheduleIds AND buildertek__Vendor__c =: userAccount.buildertek__Account_Id__c  LIMIT 10000];
                        system.debug('SOVItems -------> '+SOVItems);
                        if(SOVItems.size() > 0){
                            List<buildertek__SOV_Continuation_Sheet_Lines__c> continuationSheetLines = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                            
                            for(buildertek__Schedule_of_Value_Lines__c SOVLines : SOVItems){
                                buildertek__SOV_Continuation_Sheet_Lines__c continuationSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c(); 
                                continuationSheetLine.Name = SOVLines.Name;
                                continuationSheetLine.buildertek__Description_of_Work__c = SOVLines.buildertek__Description_of_Work__c;
                                continuationSheetLine.buildertek__Scheduled_Value__c = SOVLines.buildertek__Scheduled_Value__c;
                                continuationSheetLine.buildertek__Sheet_Item_No__c = SOVLines.buildertek__Item__c;
                                
                                
                                system.debug('continuation sheet Id ------> '+projectSheetMap.get(SOVLines.buildertek__Schedule_of_Values__r.buildertek__Project__c));
                                continuationSheetLine.buildertek__SOV_Continuation_Sheet__c = projectSheetMap.get(SOVLines.buildertek__Schedule_of_Values__r.buildertek__Project__c);
                                continuationSheetLines.add(continuationSheetLine);
                            } 
                            system.debug('continuationSheetLines -------> '+continuationSheetLines);
                            if(continuationSheetLines.size() > 0){
                                insert continuationSheetLines;   
                            }
                        } 
                    }
                }
            }else if(BudgetProjectIDS.size()>0){
                
                
                
                
                SET<Id> budgetIds = new SET<Id>();
                
                list<buildertek__Budget__c> budgetValues = [select Id , buildertek__Project__c from buildertek__Budget__c where buildertek__Project__c IN: BudgetProjectIDS  LIMIT 10000];
                
                system.debug('buildertek__Budget__c'+budgetValues);
                for(buildertek__Budget__c sov :budgetValues){
                    if(sov.buildertek__Project__c != null){
                        budgetIds.add(sov.Id);       
                    }
                }
                
                system.debug('budgetIds'+budgetIds);
                
                
                system.debug('Conlist'+conlst); 
                blnSkipPayAppInsertTrigger = true;
                if(conlst.size() > 0){
                    
                    insert conlst;
                    
                    if(budgetIds.size() > 0){
                        Map<String, String> budgetSheetMap = new Map<String, String>();
                        List<buildertek__SOV_Continuation__c> continuationSheets = [SELECT Id, 
                                                                                    Name, 
                                                                                    buildertek__SOV_Payment_Application__c,
                                                                                    buildertek__SOV_Payment_Application__r.buildertek__Budget__c,
                                                                                    buildertek__SOV_Payment_Application__r.buildertek__Project__c
                                                                                    FROM buildertek__SOV_Continuation__c
                                                                                    WHERE Id IN: conlst  LIMIT 10000]; 
                        system.debug('continuationSheets size ------> '+continuationSheets.size());
                        system.debug('continuationSheets ------> '+continuationSheets);
                        
                        
                        if(continuationSheets.size() > 0){
                            
                            
                            for(buildertek__SOV_Continuation__c contSheet : continuationSheets){
                                system.debug('Budget Id ------> '+contSheet.buildertek__SOV_Payment_Application__r.buildertek__Project__c);
                                budgetSheetMap.put(contSheet.buildertek__SOV_Payment_Application__r.buildertek__Project__c, contSheet.Id);       
                            }    
                        }
                        
                        system.debug('budgetSheetMap'+budgetSheetMap);
                        
                        String uName =userRec[0].Name;
                        List<buildertek__Budget_Item__c> budgetItems = [SELECT Id,
                                                                        Name,
                                                                        buildertek__Cost_Code__c,
                                                                        buildertek__Cost_Code__r.Name,
                                                                        buildertek__Original_Budget__c,
                                                                        buildertek__Budget__r.Name,
                                                                        buildertek__Group__c,
                                                                        buildertek__Group__r.Name,
                                                                        buildertek__Contractor__r.Name,
                                                                        buildertek__Budget__r.buildertek__Project__c
                                                                        
                                                                        FROM buildertek__Budget_Item__c
                                                                        WHERE buildertek__Contractor__c =:userAccount.buildertek__Account_Id__c AND  buildertek__Budget__c IN: budgetIds  LIMIT 10000];
                        system.debug('budgetItems -------> '+budgetItems);
                        if(budgetItems.size() > 0){
                            List<buildertek__SOV_Continuation_Sheet_Lines__c> continuationSheetLines = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                            
                            for(buildertek__Budget_Item__c budgetItem : budgetItems){
                                buildertek__SOV_Continuation_Sheet_Lines__c continuationSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c(); 
                                continuationSheetLine.Name = budgetItem.Name;
                                continuationSheetLine.buildertek__Description_of_Work__c = budgetItem.Name;
                                continuationSheetLine.buildertek__Scheduled_Value__c = budgetItem.buildertek__Original_Budget__c;
                                continuationSheetLine.buildertek__Work_Completed_from_Previous_Application__c = 0;
                                continuationSheetLine.buildertek__Work_Completed__c = 0;
                                continuationSheetLine.buildertek__Material_Presently_Stored__c = 0;
                                continuationSheetLine.buildertek__Budget_Grouping__c = budgetItem.buildertek__Group__r.Name;
                                system.debug('continuation sheet Id ------> '+budgetSheetMap.get(budgetItem.buildertek__Budget__r.buildertek__Project__c));
                                continuationSheetLine.buildertek__SOV_Continuation_Sheet__c = budgetSheetMap.get(budgetItem.buildertek__Budget__r.buildertek__Project__c);
                                continuationSheetLines.add(continuationSheetLine);
                            } 
                            system.debug('continuationSheetLines -------> '+continuationSheetLines);
                            if(continuationSheetLines.size() > 0){
                                insert continuationSheetLines;   
                            }
                        }
                        
                        
                    }
                }
                
                blnSkipPayAppInsertTrigger = false;
                
            } else{
                SET<Id> budgetIds = new SET<Id>();
                for(buildertek__SOV_Payment_Application__c acc:NewApp){
                    system.debug('application Id'+acc.id);
                    if(acc.buildertek__Budget__c != null){
                        budgetIds.add(acc.buildertek__Budget__c);       
                    }
                    /*buildertek__SOV_Continuation__c con = New buildertek__SOV_Continuation__c();
con.Name = 'Continuation Sheet - 1';
con.buildertek__SOV_Payment_Application__c=acc.id;
conlst.add(con);*/
                    
                }
                system.debug('Conlist'+conlst); 
                blnSkipPayAppInsertTrigger = true;
                if(conlst.size() > 0){
                    insert conlst;
                    system.debug('budgetIds -------> '+budgetIds);
                    if(budgetIds.size() > 0){
                        Map<String, String> budgetSheetMap = new Map<String, String>();
                        List<buildertek__SOV_Continuation__c> continuationSheets = [SELECT Id, 
                                                                                    Name, 
                                                                                    buildertek__SOV_Payment_Application__c,
                                                                                    buildertek__SOV_Payment_Application__r.buildertek__Budget__c
                                                                                    FROM buildertek__SOV_Continuation__c
                                                                                    WHERE Id IN: conlst  LIMIT 10000]; 
                        system.debug('continuationSheets size ------> '+continuationSheets.size());
                        system.debug('continuationSheets ------> '+continuationSheets);
                        if(continuationSheets.size() > 0){
                            for(buildertek__SOV_Continuation__c contSheet : continuationSheets){
                                system.debug('Project----> '+contSheet.buildertek__SOV_Payment_Application__r.buildertek__Budget__c);
                                budgetSheetMap.put(contSheet.buildertek__SOV_Payment_Application__r.buildertek__Budget__c, contSheet.Id);       
                            }    
                        }
                        
                        List<buildertek__Budget_Item__c> budgetItems = [SELECT Id,
                                                                        Name,
                                                                        buildertek__Cost_Code__c,
                                                                        buildertek__Cost_Code__r.Name,
                                                                        buildertek__Original_Budget__c,
                                                                        buildertek__Budget__r.Name,
                                                                        buildertek__Group__c,
                                                                        buildertek__Group__r.Name,
                                                                        buildertek__Contractor__r.Name
                                                                        
                                                                        FROM buildertek__Budget_Item__c
                                                                        WHERE buildertek__Budget__c IN: budgetIds  LIMIT 10000];
                        system.debug('budgetItems -------> '+budgetItems);
                        if(budgetItems.size() > 0){
                            List<buildertek__SOV_Continuation_Sheet_Lines__c> continuationSheetLines = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                            
                            for(buildertek__Budget_Item__c budgetItem : budgetItems){
                                buildertek__SOV_Continuation_Sheet_Lines__c continuationSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c(); 
                                continuationSheetLine.Name = budgetItem.Name;
                                continuationSheetLine.buildertek__Description_of_Work__c = budgetItem.Name;
                                continuationSheetLine.buildertek__Scheduled_Value__c = budgetItem.buildertek__Original_Budget__c;
                                continuationSheetLine.buildertek__Work_Completed_from_Previous_Application__c = 0;
                                continuationSheetLine.buildertek__Work_Completed__c = 0;
                                continuationSheetLine.buildertek__Material_Presently_Stored__c = 0;
                                continuationSheetLine.buildertek__Budget_Grouping__c = budgetItem.buildertek__Group__r.Name;
                                system.debug('continuation sheet Id ------> '+budgetSheetMap.get(budgetItem.buildertek__Budget__c));
                                continuationSheetLine.buildertek__SOV_Continuation_Sheet__c = budgetSheetMap.get(budgetItem.buildertek__Budget__c);
                                continuationSheetLines.add(continuationSheetLine);
                            } 
                            system.debug('continuationSheetLines -------> '+continuationSheetLines);
                            if(continuationSheetLines.size() > 0){
                                insert continuationSheetLines;   
                            }
                        } 
                        
                    }
                    blnSkipPayAppInsertTrigger = false;
                }
                
            }
            
        }else{
            SET<Id> budgetIds = new SET<Id>();
            for(buildertek__SOV_Payment_Application__c acc:NewApp){
                system.debug('application Id'+acc.id);
                if(acc.buildertek__Budget__c != null){
                    budgetIds.add(acc.buildertek__Budget__c);       
                }
                buildertek__SOV_Continuation__c con = New buildertek__SOV_Continuation__c();
                con.Name = 'Continuation Sheet - 1';
                con.buildertek__SOV_Payment_Application__c=acc.id;
                conlst.add(con);
                
            }
            system.debug('Conlist'+conlst); 
            blnSkipPayAppInsertTrigger = true;
            if(conlst.size() > 0){
                insert conlst;
                system.debug('budgetIds -------> '+budgetIds);
                if(budgetIds.size() > 0){
                    Map<String, String> budgetSheetMap = new Map<String, String>();
                    List<buildertek__SOV_Continuation__c> continuationSheets = [SELECT Id, 
                                                                                Name, 
                                                                                buildertek__SOV_Payment_Application__c,
                                                                                buildertek__SOV_Payment_Application__r.buildertek__Budget__c
                                                                                FROM buildertek__SOV_Continuation__c
                                                                                WHERE Id IN: conlst  LIMIT 10000]; 
                    system.debug('continuationSheets size ------> '+continuationSheets.size());
                    system.debug('continuationSheets ------> '+continuationSheets);
                    if(continuationSheets.size() > 0){
                        for(buildertek__SOV_Continuation__c contSheet : continuationSheets){
                            system.debug('Project----> '+contSheet.buildertek__SOV_Payment_Application__r.buildertek__Budget__c);
                            budgetSheetMap.put(contSheet.buildertek__SOV_Payment_Application__r.buildertek__Budget__c, contSheet.Id);       
                        }    
                    }
                    
                    List<buildertek__Budget_Item__c> budgetItems = [SELECT Id,
                                                                    Name,
                                                                    buildertek__Cost_Code__c,
                                                                    buildertek__Cost_Code__r.Name,
                                                                    buildertek__Original_Budget__c,
                                                                    buildertek__Budget__r.Name,
                                                                    buildertek__Group__c,
                                                                    buildertek__Group__r.Name,
                                                                    buildertek__Contractor__r.Name
                                                                    
                                                                    FROM buildertek__Budget_Item__c
                                                                    WHERE buildertek__Budget__c IN: budgetIds  LIMIT 10000];
                    system.debug('budgetItems -------> '+budgetItems);
                    if(budgetItems.size() > 0){
                        List<buildertek__SOV_Continuation_Sheet_Lines__c> continuationSheetLines = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                        
                        for(buildertek__Budget_Item__c budgetItem : budgetItems){
                            buildertek__SOV_Continuation_Sheet_Lines__c continuationSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c(); 
                            continuationSheetLine.Name = budgetItem.Name;
                            continuationSheetLine.buildertek__Description_of_Work__c = budgetItem.Name;
                            continuationSheetLine.buildertek__Scheduled_Value__c = budgetItem.buildertek__Original_Budget__c;
                            continuationSheetLine.buildertek__Work_Completed_from_Previous_Application__c = 0;
                            continuationSheetLine.buildertek__Work_Completed__c = 0;
                            continuationSheetLine.buildertek__Material_Presently_Stored__c = 0;
                            continuationSheetLine.buildertek__Budget_Grouping__c = budgetItem.buildertek__Group__r.Name;
                            system.debug('continuation sheet Id ------> '+budgetSheetMap.get(budgetItem.buildertek__Budget__c));
                            continuationSheetLine.buildertek__SOV_Continuation_Sheet__c = budgetSheetMap.get(budgetItem.buildertek__Budget__c);
                            continuationSheetLines.add(continuationSheetLine);
                        } 
                        system.debug('continuationSheetLines -------> '+continuationSheetLines);
                        if(continuationSheetLines.size() > 0){
                            insert continuationSheetLines;   
                        }
                    } 
                    
                }
                blnSkipPayAppInsertTrigger = false;
            }
        }
    }
    
    public void OnBeforeDelete(List<buildertek__SOV_Payment_Application__c> PaymentToDelete, Map<Id, buildertek__SOV_Payment_Application__c> oldPaymetnMap){
        
        system.debug(' oldPaymetnMap.keySet(----->'+ oldPaymetnMap.keySet());
        
        
        List<buildertek__Change_Order__c> colistNew = [select Id,Name,buildertek__Old_Payment_Application_Id__c,buildertek__Payment_Application_G702__c from buildertek__Change_Order__c where buildertek__Payment_Application_G702__c IN:oldPaymetnMap.keySet() ];
        system.debug('colistNew---->'+colistNew);
        list<String> idsWithdata = new List<String>();
        
        for(buildertek__Change_Order__c co : colistNew){
            idsWithdata.add(co.buildertek__Old_Payment_Application_Id__c);
        }
        
        Map<String,String> CoPayMap = new Map<String,String>();
        
        List<buildertek__SOV_Payment_Application__c> PayApps = new List<buildertek__SOV_Payment_Application__c>();
        if(!idsWithdata.isEmpty()){
            PayApps = [select id, name from buildertek__SOV_Payment_Application__c where Id IN:idsWithdata];
            for(buildertek__SOV_Payment_Application__c payApprec :PayApps){
                CoPayMap.put(payApprec.Id,payApprec.Id);
            }
            
            
        }
        
        List<buildertek__Change_Order__c> ColietToUpdate = new List<buildertek__Change_Order__c>();
        if(!colistNew.isEmpty()){
            for(buildertek__Change_Order__c NCO : colistNew){
                buildertek__Change_Order__c co1 = new buildertek__Change_Order__c();
                co1.Id = NCO.id;
                
                if(NCO.buildertek__Old_Payment_Application_Id__c != null && NCO.buildertek__Old_Payment_Application_Id__c != ''){
                    if(CoPayMap.get(NCO.buildertek__Old_Payment_Application_Id__c) != null){
                        co1.buildertek__Payment_Application_G702__c = NCO.buildertek__Old_Payment_Application_Id__c;
                        ColietToUpdate.add(co1);
                    }
                    
                }
                
            }
        }
        
        if(!ColietToUpdate.isEmpty()){
            update ColietToUpdate;
        }
        
        
        List<buildertek__SOV_Continuation_Sheet_Lines__c> updateCORecsList = [select Id,Name,buildertek__Change_Order__c,
                                                                              buildertek__Change_Order__r.buildertek__Old_Payment_Application_Id__c,
                                                                              buildertek__SOV_Continuation_Sheet__c,
                                                                              buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c,
                                                                              buildertek__Vendor_Sheet_line_Id__c
                                                                              from buildertek__SOV_Continuation_Sheet_Lines__c
                                                                              where buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c IN: oldPaymetnMap.keySet()  AND (buildertek__Vendor_Sheet_line_Id__c = null OR buildertek__Vendor_Sheet_line_Id__c = '')
                                                                              LIMIT 10000  ];
        
        
        List<buildertek__Change_Order__c> changeOrderIds = new List<buildertek__Change_Order__c>();
        Set<String> coidSet = new Set<String>();
        system.debug('updateCORecsList---->'+updateCORecsList);
        if(!updateCORecsList.isEmpty()){
            
            for(buildertek__SOV_Continuation_Sheet_Lines__c csLine :updateCORecsList){
                
                buildertek__Change_Order__c newCO = new buildertek__Change_Order__c();
                newCO.buildertek__Is_CO_Imported__c = false;
                system.debug('testydqdw----->'+csLine.buildertek__Change_Order__r.buildertek__Old_Payment_Application_Id__c);
                system.debug('test changeorder----->'+csLine.buildertek__Change_Order__c);
                /* if(csLine.buildertek__Change_Order__r.buildertek__Old_Payment_Application_Id__c != null || csLine.buildertek__Change_Order__r.buildertek__Old_Payment_Application_Id__c != ''){
newCO.buildertek__Payment_Application_G702__c =  csLine.buildertek__Change_Order__r.buildertek__Old_Payment_Application_Id__c;
}*/
                if(csLine.buildertek__Change_Order__c != null){
                    
                    if(!coidSet.contains(csLine.buildertek__Change_Order__c)){
                        coidSet.add(csLine.buildertek__Change_Order__c);
                        newCO.Id = csLine.buildertek__Change_Order__c;
                        changeOrderIds.add(newCO); 
                    }
                    
                }
                
            }
            
        }
        
        
        system.debug('updateCORecsList--------->'+updateCORecsList);
        
        if(!updateCORecsList.isEmpty()){
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = true;
            update changeOrderIds;
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = true;
        }
        
        
        
        list<buildertek__BT_Change_Order_Payment_Tracking__c> COrecList = [select Id, Name, buildertek__Payment_Application_G702__c from buildertek__BT_Change_Order_Payment_Tracking__c where buildertek__Payment_Application_G702__c IN:oldPaymetnMap.keySet()];
        
        
        if(!COrecList.isEmpty()){
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = true;
            delete COrecList;
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = true;
        }
        
        
        
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        system.debug(userRec[0]);
        // if(userRec[0].IsPortalEnabled == true){
        if(boolean.valueof(portalCode) == true){
            system.debug('PaymentToDelete'+PaymentToDelete);
            for (buildertek__SOV_Payment_Application__c payment : PaymentToDelete){
                system.debug('hai');
                if (payment.buildertek__Status__c != 'Pending' ){
                    system.debug('helo');
                    payment.adderror('You cannot Delete this Payment Application because the Status has been set to '+payment.buildertek__Status__c+'. You will need to contact your Administrator to have the Status updated before you can Delete this record. ' );
                    
                }
            }
            
        }else{
            system.debug('PaymentToDelete'+PaymentToDelete);
            for (buildertek__SOV_Payment_Application__c payment : PaymentToDelete){
                system.debug('hai');
                if (payment.buildertek__Status__c == 'Company Paid' || payment.buildertek__Status__c == 'Customer Accepted' || payment.buildertek__Status__c == 'Company Accepted' || payment.buildertek__Status__c == 'Customer Paid' || payment.buildertek__Status__c == 'Company Submitted' ){
                    system.debug('helo');
                    payment.adderror('You cannot Delete this Payment Application because the Status has been set to '+payment.buildertek__Status__c+'. You will need to contact your Administrator to have the Status updated before you can Delete this record. ' );
                    
                }
            }
        }
        
        List<String> ImportedpaymentIds = new List<String>();
        for(buildertek__SOV_Payment_Application__c payment:PaymentToDelete) {
            system.debug('****'+payment.buildertek__Imported_Payment_IDs__c);
            if(payment.buildertek__Imported_Payment_IDs__c != null){
                ImportedpaymentIds = payment.buildertek__Imported_Payment_IDs__c.split(',');
            }
        }
        List<buildertek__SOV_Payment_Application__c> payList = [SELECT Id,
                                                                Name,
                                                                buildertek__Is_Imported__c
                                                                FROM buildertek__SOV_Payment_Application__c
                                                                Where Id IN:ImportedpaymentIds  LIMIT 10000];
        for(buildertek__SOV_Payment_Application__c pay :payList){
            pay.buildertek__Is_Imported__c = false;
        }
        
        if(payList.size() > 0){
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = true;
            update payList;
            PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = false;  
        }
        
    }
    
    public void updateSheetLinesStatusWhenPaymentAppStatusChanges(List<buildertek__SOV_Payment_Application__c> oldPayment, List<buildertek__SOV_Payment_Application__c> newPayment,Map<Id, buildertek__SOV_Payment_Application__c> oldPaymetnMap, Map<Id, buildertek__SOV_Payment_Application__c> newPaymentMap){
        
        /*    List<buildertek__SOV_Continuation__c> ConsheetList = new List<buildertek__SOV_Continuation__c>();
List<buildertek__SOV_Continuation_Sheet_Lines__c> ConSheetLineList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
List<String> ConSheetIds = new List<String>();

ConsheetList = [select Id, Name, buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__c IN:newPayment];

if(ConsheetList.size() > 0){
for(buildertek__SOV_Continuation__c cons: ConsheetList){
ConSheetIds.add(cons.Id);
}
ConSheetLineList = [select Id, Name, buildertek__SOV_Continuation_Sheet__c, buildertek__Status__c from buildertek__SOV_Continuation_Sheet_Lines__c where buildertek__SOV_Continuation_Sheet__c IN:ConSheetIds];
}

List<buildertek__SOV_Continuation_Sheet_Lines__c> ConSheetLineListTOUpdate = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
if(ConSheetLineList.size() > 0){
for(buildertek__SOV_Payment_Application__c PA : newPayment){
if(PA.buildertek__Status__c == 'Company Accepted'){
for(buildertek__SOV_Continuation_Sheet_Lines__c col : ConSheetLineList){
buildertek__SOV_Continuation_Sheet_Lines__c coline = new buildertek__SOV_Continuation_Sheet_Lines__c();
coline.Id = col.Id;
coline.buildertek__Status__c = 'Accepted';
ConSheetLineListTOUpdate.add(coline);
}
}else if(PA.buildertek__Status__c == 'Customer Accepted'){
for(buildertek__SOV_Continuation_Sheet_Lines__c col : ConSheetLineList){
buildertek__SOV_Continuation_Sheet_Lines__c coline = new buildertek__SOV_Continuation_Sheet_Lines__c();
coline.Id = col.Id;
coline.buildertek__Status__c = 'Accepted';
ConSheetLineListTOUpdate.add(coline);
}
}
}
}

if(ConSheetLineListTOUpdate.size() > 0){
PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = true;
update ConSheetLineListTOUpdate;
PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = false;  
}
*/
        
    }
    

    
}