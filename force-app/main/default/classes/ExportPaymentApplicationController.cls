public class ExportPaymentApplicationController {
    public Id reportid{get;set;}
    public Decimal scheduleValueTotal{get;set;}
    public Decimal workFromPrevAppTotal{get;set;}
    public Decimal workCompletedthisperiod{get;set;}
    public Decimal materialpresentlystored{get;set;}  
    public Decimal completedandstored{get;set;}  
    public Decimal balancetofinsh{get;set;}  
    public Decimal retainage{get;set;} 
    public Decimal gc{get;set;}
    public Decimal workComp{get;set;}
    public Decimal TOTAL_EARNED_LESS_RETAINAGE{get;set;}
    public Decimal TOTAL_COMPLETED_STORED_TO_DATE{get;set;}
    public Decimal BALANCE_TO_FINISH{get;set;}
    public Decimal ratainageofCompletedwork{get;set;}
    public Decimal ratainageofStoredMatrial{get;set;}
    public Decimal total_retainage{get;set;}
    public Decimal BALANCE_TO_FINISH_PLUS_RETAINAGE{get;set;}
    public Decimal CURRENT_PAYMENT_DUE{get;set;}
    public Decimal ADDITIONS{get;set;}
    public Decimal DEDUCTIONS{get;set;}
    public Decimal NETCHANGES{get;set;}
    
    public String CurrencyCode{get;set;}
    
    public buildertek__SOV_Payment_Application__c paymentApp{ get; set; }
    public List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLineList{ get; set; }
    
    
    
    public Map<String,List<buildertek__SOV_Continuation_Sheet_Lines__c>> sheetLineGrpMap{ get; set; }
    public Map<String,ContinuationSheetLinesWrapper> calcMap {set;get;}
    
    public List<ContinuationSheetLinesWrapper> wrapList{ get; set; }
    
    
    public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    
    public ExportPaymentApplicationController(){
        
        
        CurrencyCode = UserInfo.getDefaultCurrency();
        
        Decimal scheduleValue=0.0;
        Decimal workFromPrevAppTotal1=0.0;
        Decimal workCompletedthisperiod1=0.0;
        Decimal materialpresentlystored1=0.0;
        Decimal completedandstored1=0.0;
        Decimal balancetofinsh1=0.0;
        Decimal retainage1=0.0;
        Decimal gc1=0.0;
        reportid = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        System.debug('Record Id------------'+reportid);
        paymentApp= [SELECT Id, OwnerId, Name, buildertek__Owner_Name__c,buildertek__Payment_Application_To__r.Name,
                     buildertek__Vendor__c, buildertek__Vendor__r.Name,buildertek__Vendor__r.BillingStreet,buildertek__Vendor__r.BillingCity,
                     buildertek__Vendor__r.BillingState,buildertek__Vendor__r.BillingCountry,  buildertek__Vendor__r.BillingPostalCode,
                     buildertek__Vendor__r.buildertek__City__c,  buildertek__Vendor__r.buildertek__State__c, buildertek__Vendor__r.buildertek__ZipCode__c,
                     buildertek__Project__c,buildertek__Project__r.buildertek__Auto_Number__c,
                     buildertek__Project__r.Name, buildertek__Architect__c,buildertek__Architect__r.Name, buildertek__Contract_For__c, buildertek__Application__c, buildertek__Period_To__c,buildertek__Retainage_of_Stored_Material_F__c, buildertek__Project_Number__c, buildertek__Retainage_of_Completed_Work_F__c,
                     buildertek__Contract_Date__c, buildertek__Original_Contract_Sum__c, buildertek__Change_Order_Additions__c, buildertek__Change_Order_Decuctions__c, buildertek__Net_Change_by_Change_Orders__c, buildertek__Contract_Sum_To_Date__c, buildertek__Retainage__c, 
                     buildertek__Retainage_of_Completed_Work__c, buildertek__Retainage_of_Stored__c, buildertek__Total_Retainage__c, buildertek__Total_Earned_Less_Retainage__c, buildertek__Total_Completed_and_Stored_To_Date__c, buildertek__Less__c, buildertek__Current_Payment_Due__c,
                     buildertek__Balance_To_Finish_Including_Retainage__c, buildertek__Certified_By__c, buildertek__Amount_Certified__c, buildertek__Certified_Date__c, buildertek__Payment_Application_To__c,buildertek__PA_Type__c, RecordTypeId, RecordType.Name, buildertek__Budget__c, buildertek__CO_Additions_Approved_This_Month__c, 
                     buildertek__CO_Deductions_Approved_in_Previous_Month__c, buildertek__Status__c,buildertek__Payment_Application_To__r.BillingStreet,buildertek__Payment_Application_To__r.BillingCity,
                     buildertek__Payment_Application_To__r.BillingState, buildertek__Payment_Application_To__r.BillingCountry,
                     buildertek__Payment_Application_To__r.BillingPostalCode, buildertek__Payment_Application_To__r.buildertek__ZipCode__c,
                     buildertek__Payment_Application_To__r.buildertek__City__c,  buildertek__Payment_Application_To__r.buildertek__State__c,
                     buildertek__isCommunityUser__c,buildertek__Submission_Date__c, buildertek__Opportunity__c FROM buildertek__SOV_Payment_Application__c where id=:reportid];
        System.debug('Record---------------------'+paymentApp);
        List<buildertek__SOV_Continuation__c> continuationSheetList=[SELECT Id, Name, buildertek__SOV_Payment_Application__c FROM buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__c=:paymentApp.Id];
        Set<Id> sheetIds=new Set<Id>();
        for(buildertek__SOV_Continuation__c sheet:continuationSheetList){
            sheetIds.add(sheet.id);
        }
        
        
        sheetLineList=[SELECT buildertek__Description_of_Work__c,buildertek__Item_No__c, buildertek__Scheduled_Value__c, buildertek__Work_Completed__c,
                       Id, Name, buildertek__Work_Completed_from_Previous_Application__c,buildertek__Sheet_Item_No__c,buildertek__Grouping__c,
                       buildertek__Grouping2__c,buildertek__Budget_Grouping__c,
                       buildertek__Material_Presently_Stored__c, buildertek__Total__c, buildertek__G_C__c,buildertek__New_G_C__c, buildertek__Balance_To_Finish__c,buildertek__Balance_to_Pay__c,
                       buildertek__SOV_Continuation_Sheet__c,buildertek__New_Retainage__c,buildertek__percent1__c,buildertek__percent2__c,buildertek__percent3__c,buildertek__less10_hold_back__c 
                       FROM buildertek__SOV_Continuation_Sheet_Lines__c where buildertek__SOV_Continuation_Sheet__c in : sheetIds];
        
        
        sheetLineGrpMap = new  Map<String,List<buildertek__SOV_Continuation_Sheet_Lines__c>>();
        calcMap = new Map<String,ContinuationSheetLinesWrapper>();
        wrapList = new List<ContinuationSheetLinesWrapper>();
        // System.debug(sheetLineGrpMap);
        for(buildertek__SOV_Continuation_Sheet_Lines__c sheetLine : sheetLineList){
            
            if(sheetLine.buildertek__Grouping__c != null){
                list<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLineList1 = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                if(sheetLineGrpMap.get(sheetLine.buildertek__Grouping__c)!=null){
                    sheetLineList1= sheetLineGrpMap.get(sheetLine.buildertek__Grouping__c);
                    sheetLineList1.add(sheetLine);
                    sheetLineGrpMap.put(sheetLine.buildertek__Grouping__c,sheetLineList1);                
                    
                }else{
                    sheetLineList1.add(sheetLine);
                    sheetLineGrpMap.put(sheetLine.buildertek__Grouping__c,sheetLineList1);
                    
                }
                System.debug(calcMap);
                ContinuationSheetLinesWrapper wrapVal = new ContinuationSheetLinesWrapper(); 
                if(calcMap.containsKey(sheetLine.buildertek__Grouping__c))
                {
                    wrapVal = calcMap.get(sheetLine.buildertek__Grouping__c);                             
                    wrapVal.sheetLines = sheetLineGrpMap.get(sheetLine.buildertek__Grouping__c);
                    System.debug('******wrapVal*******'+wrapVal);
                    if(wrapval!=null && wrapval.scheduleValueTotal1!=null)
                        wrapVal.scheduleValueTotal1 = wrapval.scheduleValueTotal1 + sheetLine.buildertek__Scheduled_Value__c;
                    if(wrapval!=null && wrapVal.workFromPrevAppTotal1!=null)
                        wrapVal.workFromPrevAppTotal1 = wrapval.workFromPrevAppTotal1 + sheetLine.buildertek__Work_Completed_from_Previous_Application__c;
                    wrapVal.groupVal = sheetLine.buildertek__Grouping__c;
                    if(wrapval!=null && wrapVal.workcompletedTotal1!=null)
                        wrapVal.workcompletedTotal1= wrapVal.workcompletedTotal1+sheetLine.buildertek__Work_Completed__c;
                    if(wrapval!=null && wrapVal.materialsStoredTotal1!=null)
                        wrapVal.materialsStoredTotal1=wrapVal.materialsStoredTotal1+sheetLine.buildertek__Material_Presently_Stored__c;
                    if(wrapval!=null && wrapVal.totalCompletedStored1!=null)
                        wrapVal.totalCompletedStored1=wrapVal.totalCompletedStored1+sheetLine.buildertek__Total__c;
                    if(wrapval!=null && wrapVal.balancetofinsh1!=null)
                        wrapVal.balancetofinsh1=wrapVal.balancetofinsh1+sheetLine.buildertek__Balance_To_Finish__c;
                    if(wrapval!=null && wrapVal.retainage1!=null)
                        wrapVal.retainage1=wrapVal.retainage1+sheetLine.buildertek__New_Retainage__c;
                    if(wrapval!=null && wrapVal.gcVal!=null){
                        if(sheetLine.buildertek__New_G_C__c != null){
                            wrapVal.gcVal=wrapVal.gcVal+sheetLine.buildertek__New_G_C__c;
                        }else{
                            wrapVal.gcVal=wrapVal.gcVal;
                        }
                    }
                    
                    //wrapList.add(wrapVal);
                    //System.debug('wrapList----------'+wrapList);
                }else{
                    ContinuationSheetLinesWrapper wrap = new ContinuationSheetLinesWrapper();
                    wrap.sheetLines = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                    wrap.sheetLines.add(sheetLine);
                    wrap.scheduleValueTotal1 = sheetLine.buildertek__Scheduled_Value__c;
                    wrap.workFromPrevAppTotal1 = sheetLine.buildertek__Work_Completed_from_Previous_Application__c;
                    wrap.groupVal = sheetLine.buildertek__Grouping__c;
                    wrap.workcompletedTotal1=sheetLine.buildertek__Work_Completed__c;
                    wrap.materialsStoredTotal1=sheetLine.buildertek__Material_Presently_Stored__c;
                    wrap.totalCompletedStored1=sheetLine.buildertek__Total__c;
                    wrap.balancetofinsh1=sheetLine.buildertek__Balance_To_Finish__c;
                    wrap.retainage1=sheetLine.buildertek__New_Retainage__c;
                    wrap.gcVal=sheetLine.buildertek__New_G_C__c;
                    calcMap.put(sheetLine.buildertek__Grouping__c,wrap);
                    wrapList.add(wrap);
                    System.debug('wrapList----------'+wrapList);
                }
            }
            if(sheetLine.buildertek__Grouping__c == null && sheetLine.buildertek__Budget_Grouping__c==null){
                list<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLineList1 = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                if(sheetLineGrpMap.get('No Grouping')!=null){
                    sheetLineList1= sheetLineGrpMap.get('No Grouping');
                    sheetLineList1.add(sheetLine);
                    sheetLineGrpMap.put('No Grouping',sheetLineList1);
                    
                }else{
                    sheetLineList1.add(sheetLine);
                    sheetLineGrpMap.put('No Grouping',sheetLineList1);
                }
                ContinuationSheetLinesWrapper wrapVal = new ContinuationSheetLinesWrapper();
                if(calcMap.containsKey('No Grouping'))
                {
                    wrapVal = calcMap.get('No Grouping');                             
                    wrapVal.sheetLines = sheetLineGrpMap.get('No Grouping');
                    System.debug('******wrapVal*******'+wrapVal);
                    if(wrapval!=null && wrapval.scheduleValueTotal1!=null){
                        if(sheetLine.buildertek__Scheduled_Value__c != null){
                            wrapVal.scheduleValueTotal1 = wrapval.scheduleValueTotal1 + sheetLine.buildertek__Scheduled_Value__c;
                        }else{
                            wrapVal.scheduleValueTotal1 = wrapval.scheduleValueTotal1;
                        }
                    }
                    
                    if(wrapval!=null && wrapVal.workFromPrevAppTotal1!=null)
                        wrapVal.workFromPrevAppTotal1 = wrapval.workFromPrevAppTotal1 + sheetLine.buildertek__Work_Completed_from_Previous_Application__c;
                    wrapVal.groupVal = 'No Grouping';
                    if(wrapval!=null && wrapVal.workcompletedTotal1!=null)
                        wrapVal.workcompletedTotal1= wrapVal.workcompletedTotal1+sheetLine.buildertek__Work_Completed__c;
                    if(wrapval!=null && wrapVal.materialsStoredTotal1!=null)
                        wrapVal.materialsStoredTotal1=wrapVal.materialsStoredTotal1+sheetLine.buildertek__Material_Presently_Stored__c;
                    if(wrapval!=null && wrapVal.totalCompletedStored1!=null)
                        wrapVal.totalCompletedStored1=wrapVal.totalCompletedStored1+sheetLine.buildertek__Total__c;
                    if(wrapval!=null && wrapVal.balancetofinsh1!=null)
                        wrapVal.balancetofinsh1=wrapVal.balancetofinsh1+sheetLine.buildertek__Balance_To_Finish__c;
                    if(wrapval!=null && wrapVal.retainage1!=null)
                        wrapVal.retainage1=wrapVal.retainage1+sheetLine.buildertek__New_Retainage__c;
                    
                    if(wrapval!=null && wrapVal.gcVal!=null){
                        if(sheetLine.buildertek__New_G_C__c != null){
                            wrapVal.gcVal=wrapVal.gcVal+sheetLine.buildertek__New_G_C__c;
                        }else{
                            wrapVal.gcVal=wrapVal.gcVal;
                        }
                    }
                    
                    // wrapList.add(wrapVal);
                    System.debug('wrapList----------'+wrapList);
                }else{
                    ContinuationSheetLinesWrapper wrap = new ContinuationSheetLinesWrapper();
                    wrap.sheetLines = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                    wrap.sheetLines.add(sheetLine);
                    if(sheetLine.buildertek__Scheduled_Value__c != null){
                        wrap.scheduleValueTotal1 = sheetLine.buildertek__Scheduled_Value__c; 
                    }
                    
                    wrap.workFromPrevAppTotal1 = sheetLine.buildertek__Work_Completed_from_Previous_Application__c;
                    wrap.groupVal = 'No Grouping';
                    wrap.workcompletedTotal1=sheetLine.buildertek__Work_Completed__c;
                    wrap.materialsStoredTotal1=sheetLine.buildertek__Material_Presently_Stored__c;
                    wrap.totalCompletedStored1=sheetLine.buildertek__Total__c;
                    wrap.balancetofinsh1=sheetLine.buildertek__Balance_To_Finish__c;
                    wrap.retainage1=sheetLine.buildertek__New_Retainage__c;
                    wrap.gcVal=sheetLine.buildertek__New_G_C__c;
                    calcMap.put('No Grouping',wrap);
                    system.debug('wrap-----'+wrap);
                    wrapList.add(wrap);
                    System.debug('wrapList----------'+wrapList);
                }
                
            }
            if(sheetLine.buildertek__Grouping__c == null && sheetLine.buildertek__Budget_Grouping__c!=null){
                list<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLineList1 = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                if(sheetLineGrpMap.get(sheetLine.buildertek__Budget_Grouping__c)!=null){
                    sheetLineList1= sheetLineGrpMap.get(sheetLine.buildertek__Budget_Grouping__c);
                    sheetLineList1.add(sheetLine);
                    sheetLineGrpMap.put(sheetLine.buildertek__Budget_Grouping__c,sheetLineList1);
                }else{
                    sheetLineList1.add(sheetLine);
                    sheetLineGrpMap.put(sheetLine.buildertek__Budget_Grouping__c,sheetLineList1);
                }
                ContinuationSheetLinesWrapper wrapVal = new ContinuationSheetLinesWrapper();
                if(calcMap.containsKey(sheetLine.buildertek__Budget_Grouping__c))
                {
                    wrapVal = calcMap.get(sheetLine.buildertek__Budget_Grouping__c);                             
                    wrapVal.sheetLines = sheetLineGrpMap.get(sheetLine.buildertek__Budget_Grouping__c);
                    System.debug('******wrapVal*******'+wrapVal);
                    if(wrapval!=null && wrapval.scheduleValueTotal1!=null){
                        if( sheetLine.buildertek__Scheduled_Value__c != null){
                            wrapVal.scheduleValueTotal1 = wrapval.scheduleValueTotal1 + sheetLine.buildertek__Scheduled_Value__c;  
                        }else{
                            wrapVal.scheduleValueTotal1 = wrapval.scheduleValueTotal1;
                        }
                    }
                    
                    if(wrapval!=null && wrapVal.workFromPrevAppTotal1!=null)
                        wrapVal.workFromPrevAppTotal1 = wrapval.workFromPrevAppTotal1 + sheetLine.buildertek__Work_Completed_from_Previous_Application__c;
                    wrapVal.groupVal = sheetLine.buildertek__Budget_Grouping__c;
                    if(wrapval!=null && wrapVal.workcompletedTotal1!=null)
                        wrapVal.workcompletedTotal1= wrapVal.workcompletedTotal1+sheetLine.buildertek__Work_Completed__c;
                    if(wrapval!=null && wrapVal.materialsStoredTotal1!=null)
                        wrapVal.materialsStoredTotal1=wrapVal.materialsStoredTotal1+sheetLine.buildertek__Material_Presently_Stored__c;
                    if(wrapval!=null && wrapVal.totalCompletedStored1!=null)
                        wrapVal.totalCompletedStored1=wrapVal.totalCompletedStored1+sheetLine.buildertek__Total__c;
                    if(wrapval!=null && wrapVal.balancetofinsh1!=null)
                        wrapVal.balancetofinsh1=wrapVal.balancetofinsh1+sheetLine.buildertek__Balance_To_Finish__c;
                    if(wrapval!=null && wrapVal.retainage1!=null)
                        wrapVal.retainage1=wrapVal.retainage1+sheetLine.buildertek__New_Retainage__c;
                    if(wrapval!=null && wrapVal.gcVal!=null){
                        if(sheetLine.buildertek__New_G_C__c != null){
                            wrapVal.gcVal=wrapVal.gcVal+sheetLine.buildertek__New_G_C__c;
                        }else{
                            wrapVal.gcVal=wrapVal.gcVal;
                        }
                    }
                    
                    // wrapList.add(wrapVal);
                    System.debug('wrapList----------'+wrapList);
                }else{
                    ContinuationSheetLinesWrapper wrap = new ContinuationSheetLinesWrapper();
                    wrap.sheetLines = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                    wrap.sheetLines.add(sheetLine);
                    if(sheetLine.buildertek__Scheduled_Value__c != null){
                        wrap.scheduleValueTotal1 = sheetLine.buildertek__Scheduled_Value__c;
                    }
                    
                    wrap.workFromPrevAppTotal1 = sheetLine.buildertek__Work_Completed_from_Previous_Application__c;
                    wrap.groupVal = sheetLine.buildertek__Budget_Grouping__c;
                    wrap.workcompletedTotal1=sheetLine.buildertek__Work_Completed__c;
                    wrap.materialsStoredTotal1=sheetLine.buildertek__Material_Presently_Stored__c;
                    wrap.gcVal=sheetLine.buildertek__New_G_C__c;
                    wrap.totalCompletedStored1=sheetLine.buildertek__Total__c;
                    wrap.balancetofinsh1=sheetLine.buildertek__Balance_To_Finish__c;
                    wrap.retainage1=sheetLine.buildertek__New_Retainage__c;
                    calcMap.put(sheetLine.buildertek__Budget_Grouping__c,wrap);
                    wrapList.add(wrap);
                    System.debug('wrapList----------'+wrapList);
                }
            }   
        }
        
        
        
        system.debug('wrapList----------->'+wrapList);
        
        
        
        for(ContinuationSheetLinesWrapper Wlist : wrapList){
            system.debug('total Completed stored---------->'+Wlist.totalCompletedStored1);
            system.debug('total schedule Value--------->'+Wlist.scheduleValueTotal1);
            system.debug('divided value-------->'+Wlist.totalCompletedStored1 / Wlist.scheduleValueTotal1);
            system.debug('gcValue------>'+(Wlist.totalCompletedStored1 / Wlist.scheduleValueTotal1)*100);
            
            Wlist.gcVal = (Wlist.totalCompletedStored1 / Wlist.scheduleValueTotal1)*100;
        }
        
        
        system.debug('sheetLineGrpMap***********'+sheetLineGrpMap.size());
        for(buildertek__SOV_Continuation_Sheet_Lines__c line :sheetLineList){
            if(line.buildertek__Scheduled_Value__c != null){
                scheduleValue +=line.buildertek__Scheduled_Value__c;
            }
            if(line.buildertek__Work_Completed_from_Previous_Application__c != null){
                workFromPrevAppTotal1 +=line.buildertek__Work_Completed_from_Previous_Application__c;
            }
            if(line.buildertek__Work_Completed__c != null){
                workCompletedthisperiod1 +=line.buildertek__Work_Completed__c;
            }
            if(line.buildertek__Material_Presently_Stored__c != null){
                materialpresentlystored1 +=line.buildertek__Material_Presently_Stored__c;
            }
            if(line.buildertek__Total__c != null){
                completedandstored1 +=line.buildertek__Total__c;
            }
            if(line.buildertek__Balance_To_Finish__c != null){
                balancetofinsh1 +=line.buildertek__Balance_To_Finish__c;
            }
            if(line.buildertek__New_Retainage__c != null){
                retainage1 +=line.buildertek__New_Retainage__c;
            }
            if(line.buildertek__New_G_C__c != null){
                gc1 +=line.buildertek__New_G_C__c;
            }
        }
        scheduleValueTotal=scheduleValue;
        workFromPrevAppTotal=workFromPrevAppTotal1;
        workCompletedthisperiod=workCompletedthisperiod1;
        materialpresentlystored=materialpresentlystored1;
        completedandstored=completedandstored1;
        balancetofinsh=balancetofinsh1;
        retainage=retainage1;
        workComp=workFromPrevAppTotal+workCompletedthisperiod;
        gc= (completedandstored / scheduleValueTotal)*100;
        //TOTAL_COMPLETED_STORED_TO_DATE=completedandstored-(workComp+materialpresentlystored);
        //BALANCE_TO_FINISH=paymentApp.buildertek__Contract_Sum_To_Date__c-TOTAL_COMPLETED_STORED_TO_DATE;
        ratainageofCompletedwork=(paymentApp.buildertek__Retainage_of_Completed_Work_F__c);
        ratainageofStoredMatrial=(paymentApp.buildertek__Retainage_of_Stored_Material_F__c);
        total_retainage=ratainageofCompletedwork+ratainageofStoredMatrial;
        System.debug('total_retainage--------'+total_retainage);
        if(paymentApp.buildertek__Total_Completed_and_Stored_To_Date__c!=null){
            TOTAL_EARNED_LESS_RETAINAGE=(paymentApp.buildertek__Total_Earned_Less_Retainage__c);
        }
        if(TOTAL_EARNED_LESS_RETAINAGE!=null && paymentApp.Contract_Sum_To_Date__c!=null){
            BALANCE_TO_FINISH_PLUS_RETAINAGE=paymentApp.Contract_Sum_To_Date__c-TOTAL_EARNED_LESS_RETAINAGE;
        }
        if(TOTAL_EARNED_LESS_RETAINAGE!=null && paymentApp.Less__c!=null){
            CURRENT_PAYMENT_DUE=TOTAL_EARNED_LESS_RETAINAGE-paymentApp.Less__c;
        }
        
        System.debug('buildertek__CO_Additions_Approved_This_Month__c------------'+paymentApp.buildertek__CO_Additions_Approved_This_Month__c);
        System.debug('buildertek__Change_Order_Additions__c------------'+paymentApp.buildertek__Change_Order_Additions__c);
        if(paymentApp.buildertek__CO_Additions_Approved_This_Month__c==null){
            paymentApp.buildertek__CO_Additions_Approved_This_Month__c = 0; 
        }
        
        if(paymentApp.buildertek__Change_Order_Additions__c==null){
            paymentApp.buildertek__Change_Order_Additions__c = 0; 
        }
        ADDITIONS=paymentApp.buildertek__CO_Additions_Approved_This_Month__c+paymentApp.buildertek__Change_Order_Additions__c;
        if(paymentApp.buildertek__CO_Deductions_Approved_in_Previous_Month__c==null){
            paymentApp.buildertek__CO_Deductions_Approved_in_Previous_Month__c = 0; 
        }
        
        if(paymentApp.buildertek__Change_Order_Decuctions__c==null){
            paymentApp.buildertek__Change_Order_Decuctions__c = 0; 
        }
        DEDUCTIONS=paymentApp.buildertek__CO_Deductions_Approved_in_Previous_Month__c+paymentApp.buildertek__Change_Order_Decuctions__c;
        NETCHANGES=ADDITIONS-DEDUCTIONS;
    }
    
    public class ContinuationSheetLinesWrapper{
        public List<buildertek__SOV_Continuation__c> continuationSheetList{set;get;}
        public List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLines{set;get;}
        public Decimal scheduleValueTotal1{set;get;}
        public Decimal workFromPrevAppTotal1{set;get;}
        public Decimal workcompletedTotal1{set;get;}
        public Decimal materialsStoredTotal1{set;get;}
        public Decimal totalCompletedStored1{set;get;}
        public Decimal balancetofinsh1{set;get;}
        public Decimal retainage1{set;get;}
        public Decimal gcVal{set;get;}       
        public String groupVal{set;get;}
        
    }
    
}