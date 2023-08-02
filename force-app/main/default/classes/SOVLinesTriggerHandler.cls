public class SOVLinesTriggerHandler {
    public static Boolean isFirstTime = True;
    public static Boolean blnSkipSheetLineTrigger = false;
    public static void beforeInsert(List<buildertek__Schedule_of_Value_Lines__c> SOVLineList){
        
    }
    
    
    public static void afterUpdate(List<buildertek__Schedule_of_Value_Lines__c> SOVLineList){
        
        system.debug('SOVLineList-->'+SOVLineList);
        Set<Id> sovIds=new Set<Id>();
        for(buildertek__Schedule_of_Value_Lines__c SOVLine:SOVLineList){
            sovIds.add(SOVLine.Id);
        }
        
        
        
        List<buildertek__Schedule_of_Value_Lines__c> SovLinesList = [select Id, Name, buildertek__Status__c,buildertek__Vendor_SOV_Line__r.buildertek__Status__c, buildertek__Vendor_SOV_Line__r.buildertek__Rejection_Reason__c, buildertek__Vendor_SOV_Line__c, buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where Id IN: sovIds  LIMIT 10000];
        
        Set<Id> VendorsovIds=new Set<Id>();
        for(buildertek__Schedule_of_Value_Lines__c SOVLine:SovLinesList){
            VendorsovIds.add(SOVLine.buildertek__Vendor_SOV_Line__c);
        }
        
        system.debug('VendorsovIds---->'+VendorsovIds);
        
        List<buildertek__Schedule_of_Value_Lines__c> vendorsovlist = [select Id,buildertek__Vendor_SOV_Line__c, buildertek__Status__c, buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Vendor_SOV_Line__c IN: VendorsovIds   LIMIT 10000];
        
        system.debug('vendorsovlist----->'+vendorsovlist);
        
        set<Id> vendorsovlineids = new set<Id>();
        if(!vendorsovlist.isEmpty()){
            list<buildertek__Schedule_of_Value_Lines__c> newVendorUpdateList = new list<buildertek__Schedule_of_Value_Lines__c>();
            for(buildertek__Schedule_of_Value_Lines__c sov1 :vendorsovlist){
                buildertek__Schedule_of_Value_Lines__c newVendor = new buildertek__Schedule_of_Value_Lines__c();
                // newVendor.buildertek__Status__c = 'Rejected';
                newVendor.buildertek__Rejection_Reason__c = sov1.buildertek__Rejection_Reason__c;
                system.debug('vline------>'+sov1.buildertek__Vendor_SOV_Line__c);
                system.debug('sline-------->'+ vendorsovlineids.contains(sov1.buildertek__Vendor_SOV_Line__c));
                if(sov1.buildertek__Vendor_SOV_Line__c != null  && !vendorsovlineids.contains(sov1.buildertek__Vendor_SOV_Line__c)){
                    vendorsovlineids.add(sov1.buildertek__Vendor_SOV_Line__c);
                    newVendor.Id = sov1.buildertek__Vendor_SOV_Line__c;
                    newVendorUpdateList.add(newVendor);
                }
                
                system.debug('newVendorUpdateList---->'+newVendorUpdateList);
            }
            if(!newVendorUpdateList.isEmpty()){
                SOVLinesTriggerHandler.blnSkipSheetLineTrigger = true;
                update newVendorUpdateList;
                SOVLinesTriggerHandler.blnSkipSheetLineTrigger = false;
                
            }
        }
        
        
        
        
    }
    
    public static void updateSOVLine(List<buildertek__Schedule_of_Value_Lines__c> SOVLineList){
        system.debug('trigger called'+SOVLineList);
        set<Id> sovid = new set<Id>();
        Map<Id,string> sovmap = new Map<Id,String>();
        Map<Id,Id> VendorMap = new Map<Id,Id>();
        for(buildertek__Schedule_of_Value_Lines__c sov :SOVLineList){
            sovid.add(sov.buildertek__Schedule_of_Values__c);
        }
        if(sovid.size()>0){
            List<buildertek__Schedule_of_Values__c> sovdata = [SELECT Id,
                                                               buildertek__Type__c,buildertek__Vendor__c from buildertek__Schedule_of_Values__c where id IN:sovid   LIMIT 10000];
            for(buildertek__Schedule_of_Values__c sov:sovdata){
                sovmap.put(sov.Id,sov.buildertek__Type__c);
                VendorMap.put(sov.Id,sov.buildertek__Vendor__c);
            }
            system.debug('****************************'+sovmap);
        }
        for(buildertek__Schedule_of_Value_Lines__c sov:SOVLineList){
            system.debug('$$$'+sovmap.get(sov.buildertek__Schedule_of_Values__c));
            if(sovmap.get(sov.buildertek__Schedule_of_Values__c) == 'Standard'){
                sov.buildertek__Is_Processed__c = true;
                sov.buildertek__Is_Created_First_time__c = true;
            }
            system.debug('%%%%%%%%%%%%%%%%%5'+sov.buildertek__Schedule_of_Values__r.buildertek__Vendor__c);
            system.debug('$$$'+VendorMap.get(sov.buildertek__Schedule_of_Values__c));
            
            //if(sov.buildertek__Schedule_of_Values__r.buildertek__Vendor__c != null){
            if(VendorMap.get(sov.buildertek__Schedule_of_Values__c) != null){
                sov.buildertek__Vendor__c = VendorMap.get(sov.buildertek__Schedule_of_Values__c);
            }
        } 
    }
    
    // This method used to update SOV record status based on SOV line records status
    public static void updateSOVStatusBasedOnSOVLinesStatusOnAfterUpdate(List<buildertek__Schedule_of_Value_Lines__c> sovLinesList, Map<ID, buildertek__Schedule_of_Value_Lines__c> sovLinesOldMap){
        List<Id> sovIds = New List<Id>();
        
        List<buildertek__Schedule_of_Values__c> parentSOVList = new List<buildertek__Schedule_of_Values__c>();
        
        for(buildertek__Schedule_of_Value_Lines__c sovLineRec : sovLinesList){
            if(sovLineRec.buildertek__Status__c != sovLinesOldMap.get(sovLineRec.Id).buildertek__Status__c){
                sovIds.add(sovLineRec.buildertek__Schedule_of_Values__c);
            }
        }
        if(!sovIds.isEmpty()){
            List<buildertek__Schedule_of_Values__c> sovList = [SELECT Id, buildertek__Status__c, buildertek__Type__c,RecordTypeId, recordtype.name, 
                                                               (SELECT Id, buildertek__Status__c FROM buildertek__Schedule_of_Values_Lines__r) 
                                                               FROM buildertek__Schedule_of_Values__c WHERE Id IN: sovIds  LIMIT 10000];
            
            for(buildertek__Schedule_of_Values__c sovRec : sovList){
                boolean allChildStatusApproved = false;
                boolean atleastOneChlidStatusRejected = false;
                boolean otherThanApprovedOrRejected = false;
                if(sovRec.recordtype.name == 'Vendor'){
                    for(buildertek__Schedule_of_Value_Lines__c sovLineRec : sovRec.buildertek__Schedule_of_Values_Lines__r){
                        if(sovLineRec.buildertek__Status__c == 'Approved'){
                            allChildStatusApproved = true;
                        }
                        else if(sovLineRec.buildertek__Status__c == 'Rejected'){
                            allChildStatusApproved = false;
                            atleastOneChlidStatusRejected = true;
                            break;
                        }
                        else{
                            allChildStatusApproved = false;
                            otherThanApprovedOrRejected = true;
                            //break;
                        }
                    }
                    if(atleastOneChlidStatusRejected == true){
                        buildertek__Schedule_of_Values__c sovwrecs = new buildertek__Schedule_of_Values__c();
                        sovwrecs.Id = sovRec.Id;
                        parentSOVList.add(sovwrecs); 
                    }
                    else if(allChildStatusApproved == true && otherThanApprovedOrRejected == false){
                        buildertek__Schedule_of_Values__c sovwrecs = new buildertek__Schedule_of_Values__c();
                        sovwrecs.buildertek__Status__c = 'Company Approved';
                        sovwrecs.Id = sovRec.Id;
                        parentSOVList.add(sovwrecs);
                    }
                }
            }
            if(!parentSOVList.isEmpty()){
                SOVLinesTriggerHandler.blnSkipSheetLineTrigger = true;
                update parentSOVList;
                SOVLinesTriggerHandler.blnSkipSheetLineTrigger = false;
                
            }
        }
    }
    
    // This method used to update SOV record status based on SOV line records status
    public static void updateSOVStatusBasedOnSOVLinesStatus(List<buildertek__Schedule_of_Value_Lines__c> sovLinesList){
        List<Id> sovIds = New List<Id>();
        
        List<buildertek__Schedule_of_Values__c> parentSOVList = new List<buildertek__Schedule_of_Values__c>();
        
        for(buildertek__Schedule_of_Value_Lines__c sovLineRec : sovLinesList){
            sovIds.add(sovLineRec.buildertek__Schedule_of_Values__c);
        }
        if(!sovIds.isEmpty()){
            List<buildertek__Schedule_of_Values__c> sovList = [SELECT Id, buildertek__Status__c, buildertek__Type__c,RecordTypeId, recordtype.name, 
                                                               (SELECT Id, buildertek__Status__c FROM buildertek__Schedule_of_Values_Lines__r) 
                                                               FROM buildertek__Schedule_of_Values__c WHERE Id IN: sovIds  LIMIT 10000];
            
            for(buildertek__Schedule_of_Values__c sovRec : sovList){
                boolean allChildStatusApproved = false;
                boolean atleastOneChlidStatusRejected = false;
                boolean otherThanApprovedOrRejected = false;
                if(sovRec.recordtype.name == 'Vendor'){
                    for(buildertek__Schedule_of_Value_Lines__c sovLineRec : sovRec.buildertek__Schedule_of_Values_Lines__r){
                        if(sovLineRec.buildertek__Status__c == 'Approved'){
                            allChildStatusApproved = true;
                        }
                        else if(sovLineRec.buildertek__Status__c == 'Rejected'){
                            allChildStatusApproved = false;
                            atleastOneChlidStatusRejected = true;
                            break;
                        }
                        else{
                            allChildStatusApproved = false;
                            otherThanApprovedOrRejected = true;
                            //break;
                        }
                    }
                    if(atleastOneChlidStatusRejected == true){
                        /* buildertek__Schedule_of_Values__c sovwrecs = new buildertek__Schedule_of_Values__c();
sovwrecs.buildertek__Status__c = 'Partially Rejected';
sovwrecs.Id = sovRec.Id;
parentSOVList.add(sovwrecs);*/
                    }
                    else if(allChildStatusApproved == true && otherThanApprovedOrRejected == false){
                        buildertek__Schedule_of_Values__c sovwrecs = new buildertek__Schedule_of_Values__c();
                        sovwrecs.buildertek__Status__c = 'Company Approved';
                        sovwrecs.Id = sovRec.Id;
                        parentSOVList.add(sovwrecs);
                    }
                }
            }
            if(!parentSOVList.isEmpty()){
                SOVLinesTriggerHandler.blnSkipSheetLineTrigger = true;
                update parentSOVList;
                SOVLinesTriggerHandler.blnSkipSheetLineTrigger = false;
                
            }
        }
    }
    
    
    
    public Static void OnBeforeDelete(List<buildertek__Schedule_of_Value_Lines__c> PaymentToDelete){
        
        
        
        Set<Id> parentIds=new Set<Id>();
        for(buildertek__Schedule_of_Value_Lines__c SOVLine:PaymentToDelete){
            parentIds.add(SOVLine.buildertek__Schedule_of_Values__c);
        }
        
        system.debug('parentIds---->'+parentIds);
        
        Set<Id> slineIds=new Set<Id>();
        for(buildertek__Schedule_of_Value_Lines__c SOVLine:PaymentToDelete){
            slineIds.add(SOVLine.Id);
        }
        
        
        
        
        List<buildertek__Schedule_of_Value_Lines__c> vendorsovlist = [select Id,buildertek__Vendor_SOV_Line__c,buildertek__Vendor__c ,buildertek__Scheduled_Value__c, buildertek__Status__c, buildertek__Rejection_Reason__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Vendor_SOV_Line__c IN: slineIds  LIMIT 10000];
        system.debug('vendorsovlist--->'+vendorsovlist);
        
        if(!vendorsovlist.isEmpty()){
            delete vendorsovlist;
        }
        
        
        
        system.debug(PaymentToDelete);
        // List<buildertek__Schedule_of_Value_Lines__c> SOVlineList = [select Id,buildertek__Schedule_of_Values__c, buildertek__Schedule_of_Values__r.buildertek__Status__c from buildertek__Schedule_of_Value_Lines__c where Id IN:parentIds AND  (buildertek__Schedule_of_Values__r.buildertek__Status__c = 'Company Approved' OR buildertek__Schedule_of_Values__r.buildertek__Status__c = 'Customer Approved' )];
        Map<Id, buildertek__Schedule_of_Values__c> m = new Map<Id, buildertek__Schedule_of_Values__c>([Select Id,buildertek__Status__c From buildertek__Schedule_of_Values__c where Id IN:parentIds  LIMIT 10000]);   
        
        // system.debug(SOVlineList);
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
            
            
        }else{
            system.debug('PaymentToDelete'+PaymentToDelete);
            for (buildertek__Schedule_of_Value_Lines__c payment : PaymentToDelete){
                system.debug('hai');
                if (m.get(payment.buildertek__Schedule_of_Values__c).buildertek__Status__c  == 'Company Approved' || m.get(payment.buildertek__Schedule_of_Values__c).buildertek__Status__c  == 'Customer Approved' ){
                    String status = '';
                    if(m.get(payment.buildertek__Schedule_of_Values__c).buildertek__Status__c  == 'Company Approved'){
                        status = 'Company Approved';
                    }else if(m.get(payment.buildertek__Schedule_of_Values__c).buildertek__Status__c  == 'Customer Approved'){
                        status = 'Customer Approved';
                    }
                    system.debug('helo');
                    //  If(m.keySet().contains(ch.buildertek__Schedule_of_Value__c))
                    payment.adderror('You cannot delete this SOV Line because the SOV Status has been set to '+status+'. Please contact your Administrator ' );
                    
                }
            }
        }
        
        
        
    }
    
    public Static void OnBeforeupdate( list<buildertek__Schedule_of_Value_Lines__c> newSovValues,  Map<ID, buildertek__Schedule_of_Value_Lines__c> oldSovMap){
        
        set<Id>payid = new set<Id>();
        system.debug('newSovValues'+newSovValues);
        system.debug('oldSovMap'+oldSovMap);
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        system.debug(userRec[0]);
        // if(userRec[0].IsPortalEnabled == true){
        /*  if(boolean.valueof(portalCode) == true){
for (buildertek__Schedule_of_Value_Lines__c payments : newSovValues){
buildertek__Schedule_of_Value_Lines__c oldpayment = oldSovMap.get(payments.Id);
system.debug('oldpayment'+oldpayment);
if (oldpayment.buildertek__Status__c == 'Vendor Submitted' || oldpayment.buildertek__Status__c == 'Company Approved' ){
system.debug('helo');
payments.adderror('You cannot Edit this SOV, because it has Already ' + oldpayment.buildertek__Status__c);

}
}
}else{
// system.debug('oldSovValues'+oldSovValues);
for (buildertek__Schedule_of_Value_Lines__c payments : newSovValues){
buildertek__Schedule_of_Value_Lines__c oldpayment = oldSovMap.get(payments.Id);
system.debug('oldpayment'+oldpayment);
if (oldpayment.buildertek__Status__c == 'Customer Approved' || oldpayment.buildertek__Status__c == 'Company Approved' ){
system.debug('helo');
payments.adderror('You cannot Edit this SOV, because it has Already ' + oldpayment.buildertek__Status__c);

}
}
}*/
        
    }
    
    public static void updateOriginalScheduledValue(List<buildertek__Schedule_of_Value_Lines__c> sovLinesList){
        system.debug('sovLinesList------------>'+sovLinesList);
        if(!sovLinesList.isEmpty()){
            for(buildertek__Schedule_of_Value_Lines__c sovLine : sovLinesList){
                sovLine.buildertek__Original_Scheduled_Value__c = sovLine.buildertek__Scheduled_Value__c;
            }
        }
    }
    
    
    
    public Static void updateNewOriginalScheduledValue( list<buildertek__Schedule_of_Value_Lines__c> newSovValues,  Map<ID, buildertek__Schedule_of_Value_Lines__c> oldSovMap){
        

        for (buildertek__Schedule_of_Value_Lines__c sovLine : newSovValues){
            if(sovLine.buildertek__Scheduled_Value__c != null && (oldSovMap.get(sovLine.Id).buildertek__Scheduled_Value__c == null || oldSovMap.get(sovLine.Id).buildertek__Scheduled_Value__c == 0)){
                sovLine.buildertek__Original_Scheduled_Value__c = sovLine.buildertek__Scheduled_Value__c;
            }
        }
    }
    
    
    
}