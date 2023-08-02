public class ClonePaymentApp {
    
    @AuraEnabled 
    public static User getUser(){
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        return  userRec[0] ;
    }
    
    @AuraEnabled
    public static innerclass getIsNextPAyment(String recordId){
        system.debug('recordId------->'+recordId);
        if(recordId != null){
            String portalCode = '';
            string userName = userInfo.getUserId();
            string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
            list<User> userRec = Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
            
            Integer PaymentAppNumber;
            String Projectid;
            
            buildertek__SOV_Payment_Application__c  paymentold;
            
            buildertek__SOV_Payment_Application__c paymentold1 = [select id,buildertek__Project__c, recordtype.name, buildertek__Application__c, buildertek__IsNextPayment__c,buildertek__Status__c from buildertek__SOV_Payment_Application__c where id=:recordId];
            
            
            system.debug('paymentold1------->'+paymentold1);
            
            system.debug('paymentold1.Project------->'+paymentold1.buildertek__Project__c);
            
            if(paymentold1.recordtype.name == 'AP'){
                paymentold = [select id,buildertek__Project__c, buildertek__Application__c,buildertek__Application_Number__c, buildertek__IsNextPayment__c,buildertek__Status__c, recordtype.name from buildertek__SOV_Payment_Application__c where buildertek__Project__c =: paymentold1.buildertek__Project__c AND recordtype.name = 'AP' order by buildertek__Application_Number__c desc limit 1 ];
                
            }else{
                paymentold = [select id,buildertek__Project__c, buildertek__Application__c,buildertek__Application_Number__c, buildertek__IsNextPayment__c,buildertek__Status__c, recordtype.name from buildertek__SOV_Payment_Application__c where buildertek__Project__c =: paymentold1.buildertek__Project__c AND recordtype.name = 'AR' order by buildertek__Application_Number__c desc limit 1 ];
                PaymentAppNumber = Integer.ValueOf(paymentold.buildertek__Application__c);
                Projectid = paymentold.buildertek__Project__c;
                PaymentAppNumber++;
            }
            
            
            system.debug('PaymentAppNumber--------->'+PaymentAppNumber);
            system.debug('Projectid------>'+Projectid);
            system.debug('paymentold------->'+paymentold);
            
            List<buildertek__SOV_Payment_Application__c> VendorPayApps = new List<buildertek__SOV_Payment_Application__c>();
            
            String PayAppNum = String.valueOf(PaymentAppNumber);
            system.debug('portalCode---->'+portalCode);
            if(portalCode == 'false'){
                VendorPayApps = [select id,
                                 name, 
                                 buildertek__Project__c,
                                 buildertek__Application__c,
                                 buildertek__Status__c,
                                 recordtype.name
                                 from buildertek__SOV_Payment_Application__c 
                                 where buildertek__Project__c =: Projectid and buildertek__Application__c =:PayAppNum and recordtype.name = 'AP' 
                                ];
            }
            
            Boolean AllVendorsApproved = true;
            
            if(!VendorPayApps.isEmpty()){
                for(buildertek__SOV_Payment_Application__c PA :VendorPayApps){
                    System.debug('check PA --> '+PA);
                    if(PA.buildertek__Status__c != 'Company Accepted'){
                        AllVendorsApproved = false;
                    }
                }
            }
            
            List<buildertek__SOV_Payment_Application__c> payList = [select Id,buildertek__Old_PaymentApp_Id__c from buildertek__SOV_Payment_Application__c where buildertek__Old_PaymentApp_Id__c =:paymentold.id];
           
            system.debug('payList------>'+payList);
            //  ClonePaymentAppwithoutSharing innerClassHandler = New ClonePaymentAppwithoutSharing();
            buildertek__SOV_Continuation__c conSheet = [select Id, Name, buildertek__IsNextPayment__c,buildertek__SOV_Payment_Application__r.buildertek__Status__c, buildertek__SOV_Payment_Application__r.buildertek__PA_Type__c, buildertek__SOV_Payment_Application__r.RecordTypeId, buildertek__SOV_Payment_Application__r.recordtype.name  from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__c =: paymentold.id];
            
            List<Id> sovConIds = New List<Id>();
            List<buildertek__SOV_Continuation__c> sovConList = [SELECT Id, buildertek__SOV_Payment_Application__c FROM buildertek__SOV_Continuation__c WHERE buildertek__SOV_Payment_Application__c =: paymentold.id];
            
            List<buildertek__SOV_Continuation_Sheet_Lines__c> sovConLinesList = New List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            // Below list adds list of records with sov lines without 100% completed
            List<buildertek__SOV_Continuation_Sheet_Lines__c> sovConLinesGCList = New List<buildertek__SOV_Continuation_Sheet_Lines__c>();
            for(buildertek__SOV_Continuation__c sovConRec : sovConList){
                sovConIds.add(sovConRec.Id);
            }
            
            if(!sovConIds.isEmpty()){
                sovConLinesList = [SELECT Id, Name, buildertek__SOV_Continuation_Sheet__c, buildertek__New_G_C__c FROM buildertek__SOV_Continuation_Sheet_Lines__c WHERE buildertek__SOV_Continuation_Sheet__c IN: sovConIds];
            }
            for(buildertek__SOV_Continuation_Sheet_Lines__c sovConLinesRec : sovConLinesList){
                if(sovConLinesRec.buildertek__New_G_C__c != 100){
                    sovConLinesGCList.add(sovConLinesRec);
                }
            }
            
            innerclass inn = new innerclass(); 
            inn.userrec = userRec[0]; 
            inn.payment = conSheet;
            inn.isAllVendorAppsApproved = AllVendorsApproved;
            if(payList.isEmpty()){
                inn.validIsNext = true;
            }else{
                inn.validIsNext = false;
            }
            if(!sovConLinesGCList.isEmpty()){
                inn.checkGCWithCompletion = false;
            }
            else if(sovConLinesGCList.isEmpty()){ 
                inn.checkGCWithCompletion = true;
            }
            
            if(sovConLinesList.isEmpty()){
                inn.NoSOVLines = true;
            }
            System.debug('inn wrapper --> '+inn);
            return inn;
        }
        return null;
    }
    
    public class innerclass{
        @AuraEnabled
        public User userrec;
        @AuraEnabled
        public buildertek__SOV_Continuation__c  payment;
        @AuraEnabled
        public boolean validIsNext;
        @AuraEnabled
        public boolean checkGCWithCompletion;
        @AuraEnabled
        public boolean NoSOVLines;
        @AuraEnabled
        public boolean isAllVendorAppsApproved;
    }
    
    @AuraEnabled
    public static String cloneAnySobjet(String recordId){
        
        String OldPayAppId ;
        
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Get_Lines_From_CO__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Payment Application Configuration'];
        Boolean isCOEnable = false;
        if(adminInterfaceNodeConfigurations.buildertek__Get_Lines_From_CO__c == true){
            isCOEnable = true;
        }
        
        
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry1 = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec1 = Database.query(strQry1);
        if(userRec1.size() > 0){
            portalCode = userRec1[0].get('isPortalEnabled').toString();
        }
        
        PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger = true;
        if(recordId != null){
            
            buildertek__SOV_Payment_Application__c sovPaymentAppRec;
            
            buildertek__SOV_Payment_Application__c paymentold1 = [SELECT Id,Name,recordtype.name, buildertek__Project__c, buildertek__Status__c, buildertek__Less__c, buildertek__Total_Completed__c, buildertek__Amount_Certified__c FROM buildertek__SOV_Payment_Application__c WHERE Id =: recordId];
            
            
            if(paymentold1.recordtype.name == 'AP'){
                sovPaymentAppRec = [SELECT Id,Name,recordtype.name,buildertek__Application_Number__c, buildertek__Project__c, buildertek__Status__c, buildertek__Less__c, buildertek__Total_Completed__c,buildertek__Total_Earned_Less_Retainage__c, buildertek__Amount_Certified__c from buildertek__SOV_Payment_Application__c where buildertek__Project__c =: paymentold1.buildertek__Project__c AND recordtype.name = 'AP' order by buildertek__Application_Number__c desc limit 1 ];
                
            }else{
                sovPaymentAppRec = [SELECT Id,Name,recordtype.name,buildertek__Application_Number__c, buildertek__Project__c, buildertek__Status__c, buildertek__Less__c, buildertek__Total_Completed__c,buildertek__Total_Earned_Less_Retainage__c, buildertek__Amount_Certified__c from buildertek__SOV_Payment_Application__c where buildertek__Project__c =: paymentold1.buildertek__Project__c AND recordtype.name = 'AR' order by buildertek__Application_Number__c desc limit 1 ];
                
            }
            
            
            OldPayAppId = sovPaymentAppRec.Id;
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            String objectAPIName = 'buildertek__SOV_Payment_Application__c';
            String keyPrefix = (''+sovPaymentAppRec.Id).substring(0,3);
            Set <String> fieldMap = schemaMap.get(objectAPIName).getDescribe().fields.getMap().keySet();
            String soqlQuery = 'Select ' ; 
            for (String s :fieldMap ){
                if(schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap().get(s).getDescribe().isAccessible()){
                    soqlQuery +=  + s+',';
                }
            }
            soqlQuery =  soqlQuery.removeEnd(',');
            soqlQuery += ' FROM ' +objectAPIName +' WHERE ID = \'' + sovPaymentAppRec.Id +'\'' ;
            buildertek__SOV_Payment_Application__c record = Database.query(soqlQuery);
            
            buildertek__SOV_Payment_Application__c clondedParentRecordID= record.clone(false, false, false, false);
            
            if(clondedParentRecordID.buildertek__Application__c == null){
                clondedParentRecordID.buildertek__Application__c = '0';
            }
            clondedParentRecordID.buildertek__Application__c = String.valueof(integer.valueof(clondedParentRecordID.buildertek__Application__c)+1) ;
            clondedParentRecordID.buildertek__Old_PaymentApp_Id__c = sovPaymentAppRec.Id; 
            clondedParentRecordID.buildertek__Old_PA_Ids__c = sovPaymentAppRec.Id;
            clondedParentRecordID.buildertek__Period_To__c = null;
            clondedParentRecordID.buildertek__Status__c  = 'Pending';
            clondedParentRecordID.buildertek__Change_Order_Additions__c  = 0 ;
            clondedParentRecordID.buildertek__Change_Order_Decuctions__c  = 0;
            clondedParentRecordID.buildertek__Less__c  = sovPaymentAppRec.buildertek__Total_Earned_Less_Retainage__c;
            clondedParentRecordID.buildertek__Amount_Certified__c  = sovPaymentAppRec.buildertek__Amount_Certified__c;
            clondedParentRecordID.buildertek__Is_Imported__c  = false;
            clondedParentRecordID.buildertek__Submission_Date__c = null;
            
            insert clondedParentRecordID ;
            record.buildertek__Payment_Application__c = clondedParentRecordID.Id;
            update record;
            
            //    Start Change order bt value enable---------------------------
            
            
            
            Map<String,String> COPAYAPPTracMap = new  Map<String,String>();
            Map<String,String> COandCOLineMap = new  Map<String,String>();  
            
            Map<String,String> COTracCOTracLineMap = new  Map<String,String>();
            
            Map<String,String> ConLineCoTracMap = new  Map<String,String>();
            
            List<string> OldCoIds = new List<string>();
            
            List<String> COPayAppTraKIds = new List<String>();
            
            
            if(isCOEnable == true){
                
                List<buildertek__Change_Order__c> coList1 = [SELECT Id,
                                                             Name,buildertek__Payment_Application_G702__c,buildertek__Old_Payment_Application_Id__c,
                                                             buildertek__isARCO__c,
                                                             buildertek__Payment_Application_G702__r.RecordType.Name
                                                             FROM buildertek__Change_Order__c
                                                             WHERE buildertek__Payment_Application_G702__c =: OldPayAppId];
                
                system.debug('OldPayAppId------>'+OldPayAppId);
                system.debug('coList1---------------->'+coList1);
                
                List<buildertek__Change_Order_Item__c> COLineList = [select Id, Name, buildertek__Total__c, buildertek__Change_Order__c, buildertek__Change_Order__r.buildertek__Payment_Application_G702__c from buildertek__Change_Order_Item__c where buildertek__Change_Order__r.buildertek__Payment_Application_G702__c =:OldPayAppId ];
                
                
                system.debug('COLineList--->'+COLineList);
                
                list<buildertek__SOV_Continuation_Sheet_Lines__c> conShetLineOldList = [select Id, Name, 
                                                                                        buildertek__Change_Order_Payment_Tracking__c,
                                                                                        buildertek__Change_Order__c,
                                                                                        buildertek__Change_Order__r.buildertek__isARCO__c,
                                                                                        buildertek__SOV_Continuation_Sheet__c, 
                                                                                        buildertek__Balance_To_Finish__c,
                                                                                        buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c,
                                                                                        buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.RecordType.Name,
                                                                                        buildertek__Budget_Grouping__c
                                                                                        from buildertek__SOV_Continuation_Sheet_Lines__c 
                                                                                        where buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =: OldPayAppId 
                                                                                        AND buildertek__Budget_Grouping__c = 'Change Orders'
                                                                                        AND buildertek__Balance_To_Finish__c > 0
                                                                                       ];
                
                List<buildertek__Change_Order__c> PaymentAppCOList1 = new List<buildertek__Change_Order__c>();
                
                if(coList1.size() > 0){
                    for(buildertek__Change_Order__c coItem : coList1){
                        buildertek__Change_Order__c PACO = new buildertek__Change_Order__c();
                        PACO.Id = coItem.Id;
                        PACO.buildertek__Payment_Application_G702__c = clondedParentRecordID.Id;
                        PACO.buildertek__Old_Payment_Application_Id__c = OldPayAppId;
                        PaymentAppCOList1.add(PACO);
                        OldCoIds.add(coItem.Id);
                    }
                    
                    if(PaymentAppCOList1.size() > 0){
                        update PaymentAppCOList1;
                    }
                }
                
                
                
                List<buildertek__BT_Change_Order_Payment_Tracking__c> oldTracrecs = [select Id, Name,buildertek__Old_Tracking_Id__c, buildertek__Change_Order__c from buildertek__BT_Change_Order_Payment_Tracking__c where buildertek__Change_Order__c IN:OldCoIds ];
                
                List<buildertek__BT_Change_Order_Payment_Tracking__c> COPayAppTrackRecs = new List<buildertek__BT_Change_Order_Payment_Tracking__c>();
                
                
                if(conShetLineOldList.size() > 0){
                    for(buildertek__SOV_Continuation_Sheet_Lines__c coItem : conShetLineOldList){
                        buildertek__BT_Change_Order_Payment_Tracking__c COPATrac = new buildertek__BT_Change_Order_Payment_Tracking__c();
                        if(coItem.buildertek__Change_Order__c != null){
                            if(coItem.buildertek__Budget_Grouping__c  == 'Change Orders'){
                                if(coItem.buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.RecordType.Name == 'AP'){
                                    COPATrac.Name = clondedParentRecordID.Name +' - '+ clondedParentRecordID.buildertek__Application__c ;
                                    COPATrac.buildertek__Change_Order__c = coItem.buildertek__Change_Order__c;
                                    COPATrac.buildertek__Payment_Application_G702__c = clondedParentRecordID.Id;
                                    COPATrac.buildertek__Old_Tracking_Id__c = coItem.buildertek__Change_Order_Payment_Tracking__c;
                                    COPayAppTrackRecs.add(COPATrac);
                                }else{
                                    if(coItem.buildertek__Change_Order__r.buildertek__isARCO__c == true){
                                        COPATrac.Name = clondedParentRecordID.Name +' - '+ clondedParentRecordID.buildertek__Application__c ;
                                        COPATrac.buildertek__Change_Order__c = coItem.buildertek__Change_Order__c;
                                        COPATrac.buildertek__Payment_Application_G702__c = clondedParentRecordID.Id;
                                        COPATrac.buildertek__Old_Tracking_Id__c = coItem.buildertek__Change_Order_Payment_Tracking__c;
                                        COPayAppTrackRecs.add(COPATrac); 
                                    }
                                }
                            }
                        }
                    }
                }  
                
                System.debug('COPayAppTrackRecs => '+COPayAppTrackRecs);
                if(COPayAppTrackRecs.size() > 0){
                    Insert COPayAppTrackRecs;
                } 
                
                system.debug('COPayAppTrackRecs---->'+COPayAppTrackRecs);
                
                if(COPayAppTrackRecs.size() > 0){
                    for(buildertek__BT_Change_Order_Payment_Tracking__c COPaymentTrackRecs : COPayAppTrackRecs){
                        COPayAppTraKIds.add(COPaymentTrackRecs.Id);
                    }
                }
                
                system.debug('COPayAppTraKIds------->'+COPayAppTraKIds);
                List<buildertek__BT_Change_Order_Payment_Tracking__c> COTracRecs = [select Id, Name,buildertek__Old_Tracking_Id__c, buildertek__Change_Order__c from buildertek__BT_Change_Order_Payment_Tracking__c where Id IN:COPayAppTraKIds ];
                
                system.debug('COTracRecs---------->'+COTracRecs);
                
                if(COTracRecs.size() > 0){
                    for(buildertek__BT_Change_Order_Payment_Tracking__c COPATRec : COTracRecs){
                        COPAYAPPTracMap.put(COPATRec.buildertek__Old_Tracking_Id__c, COPATRec.Id);
                    }
                }     
                
                system.debug('COPAYAPPTracMap0------->'+COPAYAPPTracMap);
                
                List<buildertek__Change_Order_Payment_Tracking_Line__c> COPATrackingLines = [select Id, Name,buildertek__Scheduled_Value__c ,buildertek__Description__c, buildertek__Change_Order_Payment_Tracking__c,buildertek__Change_Order_Payment_Tracking__r.buildertek__Change_Order__c, buildertek__Work_Completed_From_Previous_App__c, buildertek__Work_Completed_This_Period__c from buildertek__Change_Order_Payment_Tracking_Line__c where  buildertek__Change_Order_Payment_Tracking__c IN:COPayAppTraKIds ];
                
                system.debug('COPATrackingLines=======-->'+COPATrackingLines);
                if(COPATrackingLines.size() > 0){
                    for(buildertek__Change_Order_Payment_Tracking_Line__c COPATRec : COPATrackingLines){
                        COTracCOTracLineMap.put(COPATRec.buildertek__Change_Order_Payment_Tracking__c, COPATRec.Id);
                    }
                }    
                system.debug('COTracCOTracLineMap---->'+COTracCOTracLineMap);
                
                system.debug('OldCoIds---->'+OldCoIds);
                
                List<buildertek__Change_Order_Payment_Tracking_Line__c> COPATrackingLines1 = [select Id, Name,buildertek__Scheduled_Value__c ,buildertek__Description__c, buildertek__Change_Order_Payment_Tracking__c,buildertek__Change_Order_Payment_Tracking__r.buildertek__Change_Order__c, buildertek__Work_Completed_From_Previous_App__c, buildertek__Work_Completed_This_Period__c from buildertek__Change_Order_Payment_Tracking_Line__c where buildertek__Change_Order_Payment_Tracking__r.buildertek__Change_Order__c IN:OldCoIds ];
                
                List<buildertek__Change_Order_Payment_Tracking_Line__c> COPayAppTrackLineRecs = new List<buildertek__Change_Order_Payment_Tracking_Line__c>();
                
                system.debug('COPATrackingLines1----->'+COPATrackingLines1);
                
                if(COPATrackingLines1.size() > 0){
                    for(buildertek__Change_Order_Payment_Tracking_Line__c COItem : COPATrackingLines1){
                        buildertek__Change_Order_Payment_Tracking_Line__c COPATracLine = new buildertek__Change_Order_Payment_Tracking_Line__c();
                        if(COPAYAPPTracMap.get(COItem.buildertek__Change_Order_Payment_Tracking__c) != null){
                            COPATracLine.Name = COItem.Name;
                            COPATracLine.buildertek__Scheduled_Value__c  = COItem.buildertek__Scheduled_Value__c;
                            COPATracLine.buildertek__Description__c = COItem.buildertek__Description__c;
                            if(COItem.buildertek__Work_Completed_This_Period__c != null){
                                COPATracLine.buildertek__Work_Completed_From_Previous_App__c = COItem.buildertek__Work_Completed_From_Previous_App__c + COItem.buildertek__Work_Completed_This_Period__c;
                            }else{
                                COPATracLine.buildertek__Work_Completed_From_Previous_App__c = COItem.buildertek__Work_Completed_From_Previous_App__c + 0;
                            }
                            COPATracLine.buildertek__Work_Completed_This_Period__c = 0;
                            COPATracLine.buildertek__Change_Order_Payment_Tracking__c = COPAYAPPTracMap.get(COItem.buildertek__Change_Order_Payment_Tracking__c);
                            COPayAppTrackLineRecs.add(COPATracLine);
                        }
                    }
                }
                
                if(COPayAppTrackLineRecs.size() > 0){
                    Insert COPayAppTrackLineRecs;
                }
                
            }
            
            //   END  Change order bt value  --------------------------------------------
            
            buildertek__SOV_Continuation__c conSheet = [select Id, Name, buildertek__IsNextPayment__c from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__c =: sovPaymentAppRec.Id];
            conSheet.buildertek__IsNextPayment__c = true;
            
            update conSheet;
            
            list<buildertek__SOV_Continuation__c> continutionSheet = new list<buildertek__SOV_Continuation__c>();
            List<buildertek__SOV_Continuation__c> cs = [SELECT Id, buildertek__Application__c, buildertek__Application_Date__c,
                                                        buildertek__Architect_Project_No__c, Name, buildertek__SOV_Payment_Application__c,
                                                        buildertek__Period_To__c 
                                                        FROM buildertek__SOV_Continuation__c WHERE buildertek__SOV_Payment_Application__c = : sovPaymentAppRec.Id ];
            if(cs.size()>0){
                for(Integer i=0; i<cs.Size();i++){
                    buildertek__SOV_Continuation__c csCopy = cs[i].clone(false,true);
                    csCopy.buildertek__SOV_Payment_Application__c = clondedParentRecordID.id;
                    continutionSheet.add(csCopy);
                }
                insert continutionSheet;
                
                list<buildertek__SOV_Continuation_Sheet_Lines__c> lastSOV = [SELECT Id,buildertek__Item_No__c,
                                                                             buildertek__SOV_Continuation_Sheet__c,
                                                                             buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c 
                                                                             from buildertek__SOV_Continuation_Sheet_Lines__c 
                                                                             where buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =: sovPaymentAppRec.Id ORDER BY buildertek__Item_No__c DESC];
                
                integer itemInc = 100;
                
                if(lastSOV.size() > 0){
                    
                    if(lastSOV[0].buildertek__Item_No__c != null){
                        itemInc = Integer.valueOf(lastSOV[0].buildertek__Item_No__c)+1;
                    }
                }
                
                list<buildertek__SOV_Continuation_Sheet_Lines__c> continutionSheetLine = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
                
                if(portalCode == 'true'){
                    
                    List<buildertek__SOV_Continuation_Sheet_Lines__c> csl = [SELECT Id, Name, buildertek__Item_No__c,
                                                                             buildertek__Sheet_Item_No__c,
                                                                             buildertek__Description_of_Work__c,
                                                                             buildertek__Budget_Grouping__c,
                                                                             buildertek__Grouping__c,buildertek__Grouping2__c,
                                                                             buildertek__Scheduled_Value__c, 
                                                                             buildertek__Work_Completed__c,
                                                                             buildertek__Status__c,
                                                                             buildertek__Work_Completed_from_Previous_Application__c,
                                                                             buildertek__Material_Presently_Stored__c,
                                                                             buildertek__Total__c, buildertek__New_G_C__c, 
                                                                             buildertek__Balance_To_Finish__c,
                                                                             buildertek__Vendor_Sheet_line_Id__c,
                                                                             buildertek__SOV_Continuation_Sheet__c,
                                                                             buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.buildertek__Status__c,
                                                                             buildertek__Vendor_Work_Completed_from_Previous_Appl__c,
                                                                             buildertek__Vendor_Work_Completed_This_Period__c,
                                                                             buildertek__Vendor_Material_Presently_Stored__c,
                                                                             buildertek__Vendor_Total__c,
                                                                             buildertek__Vendor_G_C__c,
                                                                             buildertek__Change_Order__c,
                                                                             buildertek__Is_Created_In_This_App__c,
                                                                             buildertek__Vendor_Balance_To_Finish__c,
                                                                             buildertek__Change_Order_Payment_Tracking__c
                                                                             FROM buildertek__SOV_Continuation_Sheet_Lines__c WHERE buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =: sovPaymentAppRec.Id AND (buildertek__Status__c = 'Accepted')];
                    
                    for(Integer i=0; i<csl.Size();i++){
                        buildertek__SOV_Continuation_Sheet_Lines__c cslCopy = csl[i].clone(false,true);
                        cslCopy.buildertek__SOV_Continuation_Sheet__c = continutionSheet[0].Id;
                        cslCopy.buildertek__Vendor_Work_Completed_This_Period__c = 0;
                        cslCopy.buildertek__Work_Completed__c = 0;
                        cslCopy.buildertek__Status__c = 'Pending';
                        cslCopy.buildertek__Budget_Grouping__c =  csl[i].buildertek__Budget_Grouping__c;
                        cslCopy.buildertek__Vendor_Material_Presently_Stored__c =  0;
                        cslCopy.buildertek__Material_Presently_Stored__c =  0;
                         cslCopy.buildertek__Is_Created_In_This_App__c =  false;
                        cslCopy.buildertek__Grouping__c =  csl[i].buildertek__Grouping__c;
                        cslCopy.buildertek__Grouping2__c =  csl[i].buildertek__Grouping2__c;
                        cslCopy.buildertek__Item_No__c = csl[i].buildertek__Item_No__c;
                        if(isCOEnable== true){
                            if(cslCopy.buildertek__Budget_Grouping__c  == 'Change Orders'){
                                cslCopy.buildertek__Change_Order__c =  cslCopy.buildertek__Change_Order__c;
                                cslCopy.buildertek__Old_Tracking_Id__c =  cslCopy.buildertek__Change_Order_Payment_Tracking__c;
                                cslCopy.buildertek__Change_Order_Payment_Tracking__c = COPAYAPPTracMap.get(cslCopy.buildertek__Change_Order_Payment_Tracking__c);
                            }
                        }
                        if(portalCode == 'true'){
                            cslCopy.buildertek__Vendor_Sheet_line_Id__c =  csl[i].Id;  
                        }
                        if(csl[i].buildertek__Vendor_Work_Completed_from_Previous_Appl__c != null && csl[i].buildertek__Vendor_Work_Completed_This_Period__c != null ){
                            cslCopy.buildertek__Vendor_Work_Completed_from_Previous_Appl__c = csl[i].buildertek__Vendor_Work_Completed_from_Previous_Appl__c + csl[i].buildertek__Vendor_Work_Completed_This_Period__c + csl[i].buildertek__Vendor_Material_Presently_Stored__c ;    
                        }
                        
                        if(csl[i].buildertek__Work_Completed_from_Previous_Application__c != null && csl[i].buildertek__Work_Completed__c != null ){
                            cslCopy.buildertek__Work_Completed_from_Previous_Application__c = csl[i].buildertek__Work_Completed_from_Previous_Application__c + csl[i].buildertek__Work_Completed__c + csl[i].buildertek__Vendor_Material_Presently_Stored__c ;    
                        }
                        
                        continutionSheetLine.add(cslCopy);
                        // itemInc++;
                    }
                    
                    if(!continutionSheetLine.isEmpty()){
                        insert continutionSheetLine;
                    }  
                }
                else{
                    system.debug('payappId--<-->'+sovPaymentAppRec.Id);
                    list<buildertek__SOV_Continuation_Sheet_Lines__c> ARcontinutionSheetLine = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
                    List<buildertek__SOV_Continuation_Sheet_Lines__c> csl = [SELECT Id, Name,
                                                                             buildertek__Item_No__c,
                                                                             buildertek__Sheet_Item_No__c,
                                                                             buildertek__Description_of_Work__c,
                                                                             buildertek__Budget_Grouping__c,
                                                                             buildertek__Grouping__c,
                                                                             buildertek__Grouping2__c,
                                                                             buildertek__Scheduled_Value__c,
                                                                             buildertek__Work_Completed__c,
                                                                             buildertek__Status__c,
                                                                             buildertek__Work_Completed_from_Previous_Application__c,
                                                                             buildertek__Material_Presently_Stored__c,
                                                                             buildertek__Vendor_Work_Completed_from_Previous_Appl__c,
                                                                             buildertek__Vendor_Work_Completed_This_Period__c,
                                                                             buildertek__Vendor_Material_Presently_Stored__c,
                                                                             buildertek__Total__c, 
                                                                             buildertek__New_G_C__c, 
                                                                             buildertek__Is_Created_In_This_App__c,
                                                                             buildertek__Balance_To_Finish__c,
                                                                             buildertek__Vendor_Sheet_line_Id__c,
                                                                             buildertek__SOV_Continuation_Sheet__c,
                                                                             buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.buildertek__Status__c,
                                                                             buildertek__Change_Order_Payment_Tracking__c,
                                                                             buildertek__Old_Tracking_Id__c,
                                                                             buildertek__Change_Order__c
                                                                             FROM buildertek__SOV_Continuation_Sheet_Lines__c WHERE buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =: sovPaymentAppRec.Id];
                    
                   
                    
                    Set<String> vendorPayAppIds = new Set<String>();
                    
                    system.debug('csl----------->'+csl);
                    system.debug('sovPaymentAppRec.Id----=-->'+sovPaymentAppRec.Id);
                    List<String> prevVendorSheetLineIds = new List<String>();
                    List<String> vendoraddedLineIds = new List<String>();
                    map<String,string> tracConLineMap = new map<String,string>();
                    for(Integer i=0; i<csl.Size();i++){
                        if(csl[i].buildertek__Vendor_Sheet_line_Id__c != null){
                            system.debug('vendorlineIds---->'+csl[i].buildertek__Vendor_Sheet_line_Id__c);
                            prevVendorSheetLineIds.add(csl[i].buildertek__Vendor_Sheet_line_Id__c);  
                            //  tracConLineMap.put();
                            
                        }else{
                            system.debug('cslIds'+csl[i].Id);
                            vendoraddedLineIds.add(csl[i].Id);
                            ARcontinutionSheetLine.add(csl[i]);  
                        }
                    }
                    
                    system.debug('ARcontinutionSheetLine------------>'+ARcontinutionSheetLine);
                    system.debug('prevVendorSheetLineIds------>'+prevVendorSheetLineIds);
                    
                    
                    List<buildertek__SOV_Continuation_Sheet_Lines__c> VendorPrevConSheetLines = [select Id,
                                                                                                 Name,
                                                                                                 buildertek__Vendor_Sheet_line_Id__c,
                                                                                                 buildertek__SOV_Continuation_Sheet__c,
                                                                                                 buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c
                                                                                                 from buildertek__SOV_Continuation_Sheet_Lines__c
                                                                                                 where Id IN: prevVendorSheetLineIds
                                                                                                ];
                    
                    
                    for(Integer i=0; i<VendorPrevConSheetLines.Size();i++){
                        vendorPayAppIds.add(VendorPrevConSheetLines[i].buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c);
                    }
                    
                     List<buildertek__SOV_Payment_Application__c> CompletedPaymentApp = new  List<buildertek__SOV_Payment_Application__c>();
                    
                    if(vendorPayAppIds.size() > 0){
                        CompletedPaymentApp = [SELECT Id,Name,recordtype.name,buildertek__Application_Number__c, buildertek__Project__c, buildertek__Status__c,buildertek__IsCompleted__c FROM buildertek__SOV_Payment_Application__c WHERE buildertek__Project__c =: paymentold1.buildertek__Project__c AND Id IN: vendorPayAppIds  AND recordtype.name = 'AP' AND buildertek__IsCompleted__c = true order by buildertek__Application_Number__c desc ];
                        
                    }
                    
                     set<String> VendorComplPayAppIds = new set<String>();
                    
                     for(Integer i=0; i<CompletedPaymentApp.Size();i++){
                        VendorComplPayAppIds.add(CompletedPaymentApp[i].Id);
                    }
                    
                    
                    system.debug('VendorComplPayAppIds------->'+VendorComplPayAppIds);
                    
                    List<buildertek__SOV_Continuation_Sheet_Lines__c> completedPayAppCSLinesList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                    
                    if(VendorComplPayAppIds.size() > 0){
                        completedPayAppCSLinesList = [SELECT Id, Name,
                                                      buildertek__Item_No__c,
                                                      buildertek__Sheet_Item_No__c,
                                                      buildertek__Grouping2__c,
                                                      buildertek__Scheduled_Value__c,
                                                      buildertek__Work_Completed__c,
                                                      buildertek__Status__c,
                                                      buildertek__Vendor_Sheet_line_Id__c,
                                                      buildertek__SOV_Continuation_Sheet__c,
                                                      buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.buildertek__Status__c,
                                                      buildertek__Change_Order_Payment_Tracking__c,
                                                      buildertek__Old_Tracking_Id__c,
                                                      buildertek__Change_Order__c
                                                      FROM buildertek__SOV_Continuation_Sheet_Lines__c WHERE buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c In: VendorComplPayAppIds];
                        
                        
                    }
                    
                    
                    List<String> CompletedAPARConSheetLines = new List<String>();
                    
                    for(Integer i=0; i<completedPayAppCSLinesList.Size();i++){
                       // if(completedPayAppCSLinesList[i].buildertek__Vendor_Sheet_line_Id__c != null){
                            system.debug('vendorlineIds---->'+completedPayAppCSLinesList[i].Id);
                            CompletedAPARConSheetLines.add(completedPayAppCSLinesList[i].Id);  
                            
                       // }
                    }
                    
                    List<buildertek__SOV_Continuation_Sheet_Lines__c> completedARtoAPconSLinesList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                    
                    
                    if(CompletedAPARConSheetLines.size() > 0){
                        completedARtoAPconSLinesList = [SELECT Id, Name,
                                                                             buildertek__Item_No__c,
                                                                             buildertek__Sheet_Item_No__c,
                                                                             buildertek__Description_of_Work__c,
                                                                             buildertek__Budget_Grouping__c,
                                                                             buildertek__Grouping__c,
                                                                             buildertek__Grouping2__c,
                                                                             buildertek__Scheduled_Value__c,
                                                                             buildertek__Work_Completed__c,
                                                                             buildertek__Status__c,
                                                                             buildertek__Work_Completed_from_Previous_Application__c,
                                                                             buildertek__Material_Presently_Stored__c,
                                                                             buildertek__Vendor_Work_Completed_from_Previous_Appl__c,
                                                                             buildertek__Vendor_Work_Completed_This_Period__c,
                                                                             buildertek__Vendor_Material_Presently_Stored__c,
                                                                             buildertek__Total__c, 
                                                                             buildertek__New_G_C__c, 
                                                                             buildertek__Balance_To_Finish__c,
                                                                             buildertek__Vendor_Sheet_line_Id__c,
                                                                             buildertek__SOV_Continuation_Sheet__c,
                                                                             buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.buildertek__Status__c,
                                                                             buildertek__Change_Order_Payment_Tracking__c,
                                                                             buildertek__Old_Tracking_Id__c,
                                                        buildertek__Is_Created_In_This_App__c,
                                                                             buildertek__Change_Order__c
                                                                             FROM buildertek__SOV_Continuation_Sheet_Lines__c WHERE buildertek__Vendor_Sheet_line_Id__c IN: CompletedAPARConSheetLines AND buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.recordtype.name = 'AR' AND buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c =: sovPaymentAppRec.Id];
                    
                    }
                    
                    system.debug('completedARtoAPconSLinesList------->'+completedARtoAPconSLinesList);
                    
                    
                    list<buildertek__SOV_Continuation_Sheet_Lines__c> ARCompletedVendorcontinutionSheetLine = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
                    
                    for(Integer i=0; i<completedARtoAPconSLinesList.Size();i++){
                        ARCompletedVendorcontinutionSheetLine.add(completedARtoAPconSLinesList[i]);  
                    }
                    
                    
                   
                    if(!ARCompletedVendorcontinutionSheetLine.isEmpty()){
                        
                           for(Integer i=0; i<ARCompletedVendorcontinutionSheetLine.Size();i++){
                                buildertek__SOV_Continuation_Sheet_Lines__c ARAPCompletedcslCopy = ARCompletedVendorcontinutionSheetLine[i].clone(false,true);
                                ARAPCompletedcslCopy.buildertek__SOV_Continuation_Sheet__c = continutionSheet[0].Id;
                               system.debug('ARAPCompletedcslCopy.buildertek__Work_Completed__c-------->'+ARAPCompletedcslCopy.buildertek__Work_Completed__c);
                                ARAPCompletedcslCopy.buildertek__Work_Completed_from_Previous_Application__c = ARAPCompletedcslCopy.buildertek__Work_Completed_from_Previous_Application__c + ARAPCompletedcslCopy.buildertek__Work_Completed__c + ARAPCompletedcslCopy.buildertek__Material_Presently_Stored__c ;
                                ARAPCompletedcslCopy.buildertek__Vendor_Material_Presently_Stored__c = 0;
                                
                                ARAPCompletedcslCopy.buildertek__Material_Presently_Stored__c = 0;
                               ARAPCompletedcslCopy.buildertek__Is_Created_In_This_App__c = false;
                                
                                ARAPCompletedcslCopy.buildertek__Status__c = 'Pending';
                                ARAPCompletedcslCopy.buildertek__Work_Completed__c = 0 ;
                                if(isCOEnable== true){
                                    system.debug('ARAPCompletedcslCopy.buildertek__Budget_Grouping__c------->'+ARAPCompletedcslCopy.buildertek__Budget_Grouping__c);
                                    if(ARAPCompletedcslCopy.buildertek__Budget_Grouping__c  == 'Change Orders'){
                                        system.debug('ARAPCompletedcslCopy.buildertek__Change_Order__c---->'+ARAPCompletedcslCopy.buildertek__Change_Order__c);
                                        ARAPCompletedcslCopy.buildertek__Change_Order__c =  ARAPCompletedcslCopy.buildertek__Change_Order__c;
                                        ARAPCompletedcslCopy.buildertek__Old_Tracking_Id__c =  ARAPCompletedcslCopy.buildertek__Change_Order_Payment_Tracking__c;
                                        system.debug('ARTracking-->'+ COPAYAPPTracMap.get(ARAPCompletedcslCopy.buildertek__Change_Order_Payment_Tracking__c));
                                        ARAPCompletedcslCopy.buildertek__Change_Order_Payment_Tracking__c = COPAYAPPTracMap.get(ARAPCompletedcslCopy.buildertek__Change_Order_Payment_Tracking__c);
                                    }
                                }
                                ARAPCompletedcslCopy.buildertek__Item_No__c=ARAPCompletedcslCopy.buildertek__Item_No__c;
                                continutionSheetLine.add(ARAPCompletedcslCopy);
                               // itemInc++;
                            }
                     
                        
                        
                    }
                    
          
                    
                    map<String,buildertek__SOV_Continuation_Sheet_Lines__c> NewVendorConnectionMap = new map<String,buildertek__SOV_Continuation_Sheet_Lines__c>();
                    
                    List<buildertek__SOV_Continuation_Sheet_Lines__c> csl1 = [SELECT Id, Name, 
                                                                              buildertek__Item_No__c, 
                                                                              buildertek__Sheet_Item_No__c,
                                                                              buildertek__Description_of_Work__c,
                                                                              buildertek__Budget_Grouping__c,
                                                                              buildertek__Grouping__c,
                                                                              buildertek__Grouping2__c,
                                                                              buildertek__Scheduled_Value__c,
                                                                              buildertek__Work_Completed__c,
                                                                              buildertek__Status__c,
                                                                              buildertek__Vendor_Work_Completed_from_Previous_Appl__c,
                                                                              buildertek__Vendor_Work_Completed_This_Period__c,
                                                                              buildertek__Vendor_Material_Presently_Stored__c,
                                                                              buildertek__Work_Completed_from_Previous_Application__c,
                                                                              buildertek__Material_Presently_Stored__c,
                                                                              buildertek__Total__c,
                                                                              buildertek__New_G_C__c,
                                                                              buildertek__Balance_To_Finish__c,
                                                                              buildertek__Vendor_Sheet_line_Id__c,
                                                                              buildertek__SOV_Continuation_Sheet__c,
                                                                              buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.buildertek__Status__c,
                                                                              buildertek__Change_Order_Payment_Tracking__c,
                                                                              buildertek__Old_Tracking_Id__c,
                                                                              buildertek__Is_Created_In_This_App__c,
                                                                              buildertek__Change_Order__c
                                                                              FROM buildertek__SOV_Continuation_Sheet_Lines__c WHERE  buildertek__Vendor_Sheet_line_Id__c IN: prevVendorSheetLineIds AND buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.recordtype.name = 'AP'];
                    
                   
                     system.debug('csl1------------>'+csl1);
                 
                    
                    set<String> PaymentAppIds = New set<String>();
                    
                    for(Integer i=0; i<csl1.Size();i++){
                        PaymentAppIds.add(csl1[i].buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c);
                    }
                    
                    system.debug('PaymentAppIds------->'+PaymentAppIds);
                    
                    List<buildertek__SOV_Continuation_Sheet_Lines__c> NewCOcslList = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                    
                    if(!PaymentAppIds.isEmpty()){
                        NewCOcslList = [SELECT Id, Name, 
                                        buildertek__Item_No__c, 
                                        buildertek__Sheet_Item_No__c,
                                        buildertek__Description_of_Work__c,
                                        buildertek__Budget_Grouping__c,
                                        buildertek__Grouping__c,
                                        buildertek__Grouping2__c,
                                        buildertek__Scheduled_Value__c,
                                        buildertek__Work_Completed__c,
                                        buildertek__Status__c,
                                        buildertek__Vendor_Work_Completed_from_Previous_Appl__c,
                                        buildertek__Vendor_Work_Completed_This_Period__c,
                                        buildertek__Vendor_Material_Presently_Stored__c,
                                        buildertek__Work_Completed_from_Previous_Application__c,
                                        buildertek__Material_Presently_Stored__c,
                                        buildertek__Total__c,
                                        buildertek__New_G_C__c,
                                        buildertek__Balance_To_Finish__c,
                                        buildertek__Vendor_Sheet_line_Id__c,
                                        buildertek__SOV_Continuation_Sheet__c,
                                        buildertek__Is_Created_In_This_App__c,
                                        buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.buildertek__Status__c,
                                        buildertek__Change_Order_Payment_Tracking__c,
                                        buildertek__Old_Tracking_Id__c,
                                        buildertek__Change_Order__c
                                        FROM buildertek__SOV_Continuation_Sheet_Lines__c WHERE  buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c IN:PaymentAppIds  AND buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__r.recordtype.name = 'AP' AND buildertek__Vendor_Sheet_line_Id__c = null];
                    }
                    
                    
                    for(Integer i=0; i<NewCOcslList.Size();i++){
                        system.debug('test 11--->');
                        buildertek__SOV_Continuation_Sheet_Lines__c NewcslCopy = NewCOcslList[i].clone(false,true);
                        NewcslCopy.buildertek__SOV_Continuation_Sheet__c = continutionSheet[0].Id;
                        NewcslCopy.buildertek__Work_Completed__c = NewCOcslList[i].buildertek__Vendor_Work_Completed_This_Period__c;
                        NewcslCopy.buildertek__Work_Completed_from_Previous_Application__c = NewCOcslList[i].buildertek__Vendor_Work_Completed_from_Previous_Appl__c;
                        NewcslCopy.buildertek__Status__c = 'Pending';
                        NewcslCopy.buildertek__Vendor_Material_Presently_Stored__c = NewCOcslList[i].buildertek__Vendor_Material_Presently_Stored__c;
                        NewcslCopy.buildertek__Material_Presently_Stored__c = NewCOcslList[i].buildertek__Material_Presently_Stored__c;
                        NewcslCopy.buildertek__Is_Created_In_This_App__c = false;
                        NewcslCopy.buildertek__Budget_Grouping__c =  NewCOcslList[i].buildertek__Budget_Grouping__c;
                        NewcslCopy.buildertek__Grouping__c =  NewCOcslList[i].buildertek__Grouping__c;
                        NewcslCopy.buildertek__Grouping2__c =  NewCOcslList[i].buildertek__Grouping2__c;
                        NewcslCopy.buildertek__Item_No__c = itemInc;
                        if(isCOEnable== true){
                            system.debug('NewcslCopy.buildertek__Budget_Grouping__c12----------->'+NewcslCopy.buildertek__Budget_Grouping__c);
                            if(NewcslCopy.buildertek__Budget_Grouping__c  == 'Change Orders'){
                                system.debug('NewCOcslList[i].buildertek__Change_Order__c122---->'+NewCOcslList[i].buildertek__Change_Order__c);
                                NewcslCopy.buildertek__Old_Tracking_Id__c =  NewCOcslList[i].buildertek__Change_Order_Payment_Tracking__c;
                                NewcslCopy.buildertek__Change_Order__c =  NewCOcslList[i].buildertek__Change_Order__c;
                                system.debug('comap--->'+ COPAYAPPTracMap.get(NewCOcslList[i].buildertek__Change_Order_Payment_Tracking__c));
                                // cslCopy.buildertek__Change_Order_Payment_Tracking__c = COPAYAPPTracMap.get(ARcslCopy.buildertek__Change_Order_Payment_Tracking__c);
                            }
                            
                        }
                        NewcslCopy.buildertek__Vendor_Sheet_line_Id__c =  NewCOcslList[i].Id;  
                        continutionSheetLine.add(NewcslCopy);
                        itemInc++;
                    }
                    
                    for(buildertek__SOV_Continuation_Sheet_Lines__c conLine : csl1){
                        system.debug('conLineId--->'+conLine.Id);
                        NewVendorConnectionMap.put(conLine.buildertek__Vendor_Sheet_line_Id__c,conLine);
                    }
                    
                    for(Integer i=0; i<csl.Size();i++){
                        buildertek__SOV_Continuation_Sheet_Lines__c cslCopy = csl[i].clone(false,true);
                        cslCopy.buildertek__SOV_Continuation_Sheet__c = continutionSheet[0].Id;
                        system.debug('VlineId------>'+csl[i].buildertek__Vendor_Sheet_line_Id__c); 
                        system.debug('testvsovloine0---->'+NewVendorConnectionMap.get(csl[i].buildertek__Vendor_Sheet_line_Id__c));
                        if(NewVendorConnectionMap.get(csl[i].buildertek__Vendor_Sheet_line_Id__c)!=null){
                            cslCopy.buildertek__Work_Completed__c = NewVendorConnectionMap.get(csl[i].buildertek__Vendor_Sheet_line_Id__c).buildertek__Vendor_Work_Completed_This_Period__c;
                            cslCopy.buildertek__Work_Completed_from_Previous_Application__c = NewVendorConnectionMap.get(csl[i].buildertek__Vendor_Sheet_line_Id__c).buildertek__Vendor_Work_Completed_from_Previous_Appl__c;
                            cslCopy.buildertek__Status__c = 'Pending';
                            cslCopy.buildertek__Vendor_Material_Presently_Stored__c = NewVendorConnectionMap.get(csl[i].buildertek__Vendor_Sheet_line_Id__c).buildertek__Vendor_Material_Presently_Stored__c;
                            cslCopy.buildertek__Material_Presently_Stored__c = NewVendorConnectionMap.get(csl[i].buildertek__Vendor_Sheet_line_Id__c).buildertek__Material_Presently_Stored__c;
                            cslCopy.buildertek__Is_Created_In_This_App__c = false;
                            cslCopy.buildertek__Budget_Grouping__c =   NewVendorConnectionMap.get(csl[i].buildertek__Vendor_Sheet_line_Id__c).buildertek__Budget_Grouping__c;
                            cslCopy.buildertek__Grouping__c = NewVendorConnectionMap.get(csl[i].buildertek__Vendor_Sheet_line_Id__c).buildertek__Grouping__c;
                            cslCopy.buildertek__Grouping2__c = NewVendorConnectionMap.get(csl[i].buildertek__Vendor_Sheet_line_Id__c).buildertek__Grouping2__c;
                            // cslCopy.buildertek__Item_No__c = itemInc;
                            if(isCOEnable== true){
                                system.debug('cslCopy.buildertek__Budget_Grouping__c----------->'+cslCopy.buildertek__Budget_Grouping__c);
                                if(cslCopy.buildertek__Budget_Grouping__c  == 'Change Orders'){
                                    system.debug('csl[i].buildertek__Change_Order__c---->'+csl[i].buildertek__Change_Order__c);
                                    cslCopy.buildertek__Old_Tracking_Id__c =  NewVendorConnectionMap.get(csl[i].buildertek__Vendor_Sheet_line_Id__c).buildertek__Change_Order_Payment_Tracking__c;
                                    cslCopy.buildertek__Change_Order__c =  NewVendorConnectionMap.get(csl[i].buildertek__Vendor_Sheet_line_Id__c).buildertek__Change_Order__c;
                                    //system.debug('comap--->'+ COPAYAPPTracMap.get(csl[i].buildertek__Change_Order_Payment_Tracking__c));
                                    // cslCopy.buildertek__Change_Order_Payment_Tracking__c = COPAYAPPTracMap.get(ARcslCopy.buildertek__Change_Order_Payment_Tracking__c);
                                }
                                
                            }
                            cslCopy.buildertek__Vendor_Sheet_line_Id__c =  NewVendorConnectionMap.get(csl[i].buildertek__Vendor_Sheet_line_Id__c).Id;
                            continutionSheetLine.add(cslCopy);
                            
                        }
                        
                        
                        // itemInc++;
                    }
                    
                    
                    if(ARcontinutionSheetLine.size() > 0){
                        if(prevVendorSheetLineIds.size() > 0){
                            system.debug('test 2--->');
                            for(Integer i=0; i<ARcontinutionSheetLine.Size();i++){
                                buildertek__SOV_Continuation_Sheet_Lines__c ARcslCopy = ARcontinutionSheetLine[i].clone(false,true);
                                ARcslCopy.buildertek__SOV_Continuation_Sheet__c = continutionSheet[0].Id;
                                ARcslCopy.buildertek__Work_Completed_from_Previous_Application__c = ARcslCopy.buildertek__Work_Completed_from_Previous_Application__c + ARcslCopy.buildertek__Work_Completed__c + ARcslCopy.buildertek__Material_Presently_Stored__c;
                                ARcslCopy.buildertek__Vendor_Material_Presently_Stored__c = 0;
                                ARcslCopy.buildertek__Material_Presently_Stored__c = 0;
                                ARcslCopy.buildertek__Is_Created_In_This_App__c = false;
                                ARcslCopy.buildertek__Work_Completed__c = 0;
                                ARcslCopy.buildertek__Status__c = 'Pending';
                                //  ARcslCopy.buildertek__Item_No__c=itemInc;
                                if(isCOEnable== true){
                                    system.debug('ARcslCopy.buildertek__Budget_Grouping__c--->'+ARcslCopy.buildertek__Budget_Grouping__c);
                                    if(ARcslCopy.buildertek__Budget_Grouping__c  == 'Change Orders'){
                                        system.debug('ARcslCopy.buildertek__Change_Order__c--->'+ARcslCopy.buildertek__Change_Order__c);
                                        ARcslCopy.buildertek__Old_Tracking_Id__c =  ARcslCopy.buildertek__Change_Order_Payment_Tracking__c;
                                        ARcslCopy.buildertek__Change_Order__c =  ARcslCopy.buildertek__Change_Order__c;
                                         system.debug('comap--->'+ COPAYAPPTracMap.get(ARcslCopy.buildertek__Change_Order_Payment_Tracking__c));
                                        ARcslCopy.buildertek__Change_Order_Payment_Tracking__c = COPAYAPPTracMap.get(ARcslCopy.buildertek__Change_Order_Payment_Tracking__c);
                                    }
                                }
                                continutionSheetLine.add(ARcslCopy);
                               // itemInc++;
                            }
                            
                        }else{
                            system.debug('test 3--->');
                            system.debug('else-0-0--');
                            for(Integer i=0; i<ARcontinutionSheetLine.Size();i++){
                                buildertek__SOV_Continuation_Sheet_Lines__c ARcslCopy = ARcontinutionSheetLine[i].clone(false,true);
                                ARcslCopy.buildertek__SOV_Continuation_Sheet__c = continutionSheet[0].Id;
                                ARcslCopy.buildertek__Work_Completed_from_Previous_Application__c = ARcslCopy.buildertek__Work_Completed_from_Previous_Application__c +ARcslCopy.buildertek__Work_Completed__c + ARcslCopy.buildertek__Material_Presently_Stored__c ;
                                ARcslCopy.buildertek__Vendor_Material_Presently_Stored__c = 0;
                                
                                ARcslCopy.buildertek__Material_Presently_Stored__c = 0;
                                ARcslCopy.buildertek__Is_Created_In_This_App__c = false;
                                ARcslCopy.buildertek__Status__c = 'Pending';
                                ARcslCopy.buildertek__Work_Completed__c = 0 ;
                                if(isCOEnable== true){
                                    system.debug('ARcslCopy.buildertek__Budget_Grouping__c------->'+ARcslCopy.buildertek__Budget_Grouping__c);
                                    if(ARcslCopy.buildertek__Budget_Grouping__c  == 'Change Orders'){
                                        system.debug('ARcslCopy.buildertek__Change_Order__c---->'+ARcslCopy.buildertek__Change_Order__c);
                                        ARcslCopy.buildertek__Change_Order__c =  ARcslCopy.buildertek__Change_Order__c;
                                        ARcslCopy.buildertek__Old_Tracking_Id__c =  ARcslCopy.buildertek__Change_Order_Payment_Tracking__c;
                                        system.debug('ARTracking-->'+ COPAYAPPTracMap.get(ARcslCopy.buildertek__Change_Order_Payment_Tracking__c));
                                        ARcslCopy.buildertek__Change_Order_Payment_Tracking__c = COPAYAPPTracMap.get(ARcslCopy.buildertek__Change_Order_Payment_Tracking__c);
                                    }
                                }
                                ARcslCopy.buildertek__Item_No__c=itemInc;
                                continutionSheetLine.add(ARcslCopy);
                                itemInc++;
                            }
                        }
                    }
                    if(!continutionSheetLine.isEmpty()){
                        insert continutionSheetLine;
                    }  
                }  
            }else{
                buildertek__SOV_Continuation__c contRec = new buildertek__SOV_Continuation__c();
                contRec.Name = 'Continuation Sheet - '+clondedParentRecordID.buildertek__Application__c;
                contRec.buildertek__SOV_Payment_Application__c = clondedParentRecordID.id;
                insert contRec;
            }
            return clondedParentRecordID.id ;
        }
        return null;
    }
    @AuraEnabled
    public static string updateClonedRecord(String recordId,string newRecId){
        try{
            
            List<buildertek__SOV_Payment_Application__c> paymentold = [select id,buildertek__Status__c from buildertek__SOV_Payment_Application__c where id=:recordId];
            buildertek__SOV_Payment_Application__c paymentnew = [select id,buildertek__Status__c from buildertek__SOV_Payment_Application__c where id=:newRecId];
            if(paymentold.size() > 0){
                paymentnew.buildertek__Status__c = 'Pending'  /*paymentold[0].buildertek__Status__c*/;
                update paymentnew;
            }
            return 'success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
}