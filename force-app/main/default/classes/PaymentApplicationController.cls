public  without sharing class PaymentApplicationController {
    public Decimal scheduleValueTotal{get;set;}
    public Decimal workFromPrevAppTotal{get;set;}
    public Decimal workCompletedthisperiod{get;set;}
    public Decimal materialpresentlystored{get;set;}  
    public Decimal completedandstored{get;set;}
    public Decimal totalper{get;set;}  
    public Decimal totalper11{get;set;}
    public Decimal totalper22{get;set;}
    public Decimal balancetofinsh{get;set;}  
    public Decimal retainage{get;set;} 
    public Decimal ADDITIONS{get;set;}
    public Decimal DEDUCTIONS{get;set;}
    public Decimal NETCHANGES{get;set;}
    public Decimal retainageValue{get;set;}
    
    public String CurrencyCode{get;set;}
    
    public Decimal add1{get;set;}
    public Decimal add2{get;set;}
    
    public Decimal ded1{get;set;}
    public Decimal ded2{get;set;}
    
    public Id reportid{get;set;}
    public buildertek__SOV_Payment_Application__c paymentApp{ get; set; }
    public List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLineList{ get; set; }
    public  List<AggregateResult> groupedResults{ get; set; }
    
    public Map<String,List<buildertek__SOV_Continuation_Sheet_Lines__c>> sheetLineGrpMap{ get; set; }
    public Map<String,ContinuationSheetLinesWrapper> calcMap {set;get;}
    
    public List<ContinuationSheetLinesWrapper> wrapList{ get; set; }
    public ContinuationDetails cd{ get; set; }
    
    
    public  PaymentApplicationController(){
        
        
        CurrencyCode = UserInfo.getDefaultCurrency();
        
        
        
        
        Decimal scheduleValue=0.0;
        Decimal workFromPrevAppTotal1=0.0;
        Decimal workCompletedthisperiod1=0.0;
        Decimal materialpresentlystored1=0.0;
        Decimal completedandstored1=0.0;
        Decimal totalper1=0.0;
        Decimal totalper2=0.0;
        Decimal totalper3=0.0;
        Decimal balancetofinsh1=0.0;
        Decimal retainage1=0.0;
        reportid = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        System.debug('Record Id------------'+reportid);
        if(reportid!=null){
            paymentApp= [SELECT Id, OwnerId, Name, buildertek__Owner_Name__c,buildertek__Retainage_of_Completed_Work_F__c,buildertek__Retainage_of_Stored_Material_F__c,buildertek__Payment_Application_To__r.Name, buildertek__Vendor__c, buildertek__Vendor__r.Name,buildertek__Vendor__r.BillingStreet,buildertek__Vendor__r.BillingCity,buildertek__Vendor__r.BillingState,buildertek__Vendor__r.BillingPostalCode,buildertek__Vendor__r.BillingCountry, buildertek__Project__c,buildertek__Project__r.buildertek__Auto_Number__c,
                         buildertek__Project__r.Name,buildertek__Project__r.buildertek__Address__c,buildertek__Project__r.buildertek__City__c,buildertek__Project__r.buildertek__State__c,buildertek__Project__r.buildertek__Zip__c,buildertek__Project__r.buildertek__Country__c, buildertek__Architect__c,buildertek__Architect__r.Name, buildertek__Contract_For__c, buildertek__Application__c, buildertek__Period_To__c, buildertek__Project_Number__c, buildertek__Submission_Date__c,
                         buildertek__Contract_Date__c, buildertek__Original_Contract_Sum__c, buildertek__Change_Order_Additions__c, buildertek__Change_Order_Decuctions__c, buildertek__Net_Change_by_Change_Orders__c, buildertek__Contract_Sum_To_Date__c, buildertek__Retainage__c, 
                         buildertek__Retainage_of_Completed_Work__c, buildertek__Retainage_of_Stored__c,buildertek__Total_Completed__c, buildertek__Total_Retainage__c, buildertek__Total_Earned_Less_Retainage__c, buildertek__Total_Completed_and_Stored_To_Date__c, buildertek__Less__c, buildertek__Current_Payment_Due__c,
                         buildertek__Balance_To_Finish_Including_Retainage__c, buildertek__Certified_By__c, buildertek__Amount_Certified__c, buildertek__Certified_Date__c, buildertek__Payment_Application_To__c, RecordTypeId, RecordType.Name, buildertek__Budget__c, buildertek__CO_Additions_Approved_This_Month__c, 
                         buildertek__CO_Deductions_Approved_in_Previous_Month__c, buildertek__Status__c,buildertek__Payment_Application_To__r.BillingStreet,buildertek__Payment_Application_To__r.BillingCity,buildertek__Payment_Application_To__r.BillingPostalCode,
                         buildertek__Payment_Application_To__r.BillingState, buildertek__Payment_Application_To__r.BillingCountry,buildertek__isCommunityUser__c, buildertek__Opportunity__c,buildertek__Certified_By__r.Name,buildertek__Project__r.buildertek__Project_NOS__c  FROM buildertek__SOV_Payment_Application__c where id=:reportid];
            System.debug('Record---------------------'+paymentApp.buildertek__CO_Additions_Approved_This_Month__c);
            System.debug('Record---------------------'+paymentApp.buildertek__Change_Order_Additions__c);
            System.debug('Record---------------------'+paymentApp.buildertek__CO_Deductions_Approved_in_Previous_Month__c);
            System.debug('Record---------------------'+paymentApp.buildertek__Change_Order_Decuctions__c);
            if(paymentApp!=null){
                if(paymentApp.buildertek__CO_Additions_Approved_This_Month__c==null){
                    add1=0.00;
                }else{
                    add1=paymentApp.buildertek__CO_Additions_Approved_This_Month__c;
                }
                System.debug('add1---------------------'+add1);
                if(paymentApp.buildertek__Change_Order_Additions__c==null){
                    add2=0.00;
                }else{
                    add2=paymentApp.buildertek__Change_Order_Additions__c;
                }
                System.debug('add2---------------------'+add2);
                if(paymentApp.buildertek__CO_Deductions_Approved_in_Previous_Month__c==null){
                    ded1=0.00;
                }else{
                    ded1=paymentApp.buildertek__CO_Deductions_Approved_in_Previous_Month__c;
                }
                System.debug('ded1---------------------'+ded1);
                if(paymentApp.buildertek__Change_Order_Decuctions__c==null){
                    ded2=0.00;
                }else{
                    ded2=paymentApp.buildertek__Change_Order_Decuctions__c;
                }
                System.debug('ded2---------------------'+ded2);   
                if(paymentApp.buildertek__Retainage__c==null){
                    retainageValue=0;
                }else{
                    retainageValue=paymentApp.buildertek__Retainage__c;
                }
                System.debug('retainageValue---------------------'+retainageValue);   
                
                ADDITIONS= add1+add2;
                
                DEDUCTIONS=ded1+ded2;
                NETCHANGES=ADDITIONS-DEDUCTIONS;
                
            }           
            List<buildertek__SOV_Continuation__c> continuationSheetList=[SELECT Id, Name, buildertek__SOV_Payment_Application__c FROM buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__c=:paymentApp.Id];
            Set<Id> sheetIds=new Set<Id>();
            for(buildertek__SOV_Continuation__c sheet:continuationSheetList){
                sheetIds.add(sheet.id);
            }
            sheetLineList=[SELECT buildertek__Description_of_Work__c,buildertek__Item_No__c, buildertek__Scheduled_Value__c, buildertek__Work_Completed__c,
                           Id, Name, buildertek__Work_Completed_from_Previous_Application__c,buildertek__Sheet_Item_No__c,buildertek__Grouping__c,
                           buildertek__Grouping2__c,buildertek__Budget_Grouping__c,buildertek__New_G_C__c,
                           buildertek__Material_Presently_Stored__c, buildertek__Total__c, buildertek__G_C__c, buildertek__Balance_To_Finish__c,buildertek__Balance_to_Pay__c,
                           buildertek__SOV_Continuation_Sheet__c,buildertek__Retainage__c,buildertek__percent1__c,buildertek__percent2__c,buildertek__percent3__c,buildertek__less10_hold_back__c, buildertek__New_Retainage__c,buildertek__Vendor_Work_Completed_This_Period__c,buildertek__Vendor_Material_Presently_Stored__c,buildertek__Vendor_Total__c,buildertek__Vendor_G_C__c,buildertek__Vendor_Balance_To_Finish__c FROM buildertek__SOV_Continuation_Sheet_Lines__c where buildertek__SOV_Continuation_Sheet__c in : sheetIds];
            
            /* start The Code */
            List<AggregateResult> groupedResults = [SELECT SUM(buildertek__Scheduled_Value__c) scheduleValue,
                                                    SUM(buildertek__Work_Completed_from_Previous_Application__c) fromPrevApp,
                                                    SUM(buildertek__Work_Completed__c) workCompleted,
                                                    SUM(buildertek__Material_Presently_Stored__c) materialStored,
                                                    SUM(buildertek__Total__c) totalWork,
                                                    SUM(buildertek__G_C__c) gcTotal,
                                                    SUM(buildertek__Balance_To_Finish__c) balanceTotal,
                                                    buildertek__SOV_Continuation_Sheet__c
                                                    FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                                    WHERE buildertek__SOV_Continuation_Sheet__c in : sheetIds
                                                    GROUP BY buildertek__SOV_Continuation_Sheet__c];
            cd = new ContinuationDetails();
            if(groupedResults.size() > 0){
                cd.scheduleValueTotal = (Decimal)groupedResults[0].get('scheduleValue'); 
                cd.workFromPrevAppTotal = (Decimal)groupedResults[0].get('fromPrevApp');
                cd.workcompletedTotal = (Decimal)groupedResults[0].get('workCompleted');
                cd.materialsStoredTotal = (Decimal)groupedResults[0].get('materialStored');
                cd.totalCompletedStored = (Decimal)groupedResults[0].get('totalWork');
                cd.totalWorkBy10 = ((Decimal)groupedResults[0].get('totalWork'))/10;
                // cd.gcTotal = (Decimal)groupedResults[0].get('gcTotal');
                cd.gcTotal = ( (Decimal)groupedResults[0].get('totalWork') / (Decimal)groupedResults[0].get('scheduleValue') ) * 100;
                cd.balanceTotal = (Decimal)groupedResults[0].get('balanceTotal');
                cd.materialsStoredTotal10 =  ((Decimal)groupedResults[0].get('materialStored'))/10;
                cd.workcompletedTotal10 =    ( ( (Decimal)groupedResults[0].get('workCompleted'))+( (Decimal)groupedResults[0].get('fromPrevApp')))/10;     
                
                system.debug('cdcddddddddddddddddddddddddddddddd'+cd);
            }
            
            
            /*End the code */
            
            
            
            sheetLineGrpMap = new  Map<String,List<buildertek__SOV_Continuation_Sheet_Lines__c>>();
            calcMap = new Map<String,ContinuationSheetLinesWrapper>();
            wrapList = new List<ContinuationSheetLinesWrapper>();
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
                        if(wrapval!=null && wrapVal.workcompletedTotal1!=null){
                            if(sheetLine.buildertek__Work_Completed__c != null){
                                wrapVal.workcompletedTotal1= wrapVal.workcompletedTotal1+sheetLine.buildertek__Work_Completed__c;
                            }else{
                                wrapVal.workcompletedTotal1= wrapVal.workcompletedTotal1;
                            }
                        }
                        
                        
                        if(wrapval!=null && wrapVal.gcVal!=null){
                            if(sheetLine.buildertek__New_G_C__c != null){
                                wrapVal.gcVal=wrapVal.gcVal+sheetLine.buildertek__New_G_C__c;
                            }else{
                                wrapVal.gcVal=wrapVal.gcVal;
                            }
                        }
                        
                        
                        if(wrapval!=null && wrapVal.materialsStoredTotal1!=null){
                            if(sheetLine.buildertek__percent3__c != null){
                                wrapVal.materialsStoredTotal1=wrapVal.materialsStoredTotal1+sheetLine.buildertek__Material_Presently_Stored__c;
                            }else{
                                wrapVal.materialsStoredTotal1=wrapVal.materialsStoredTotal1; 
                            }
                            
                        }
                        
                        if(wrapval!=null && wrapVal.totalCompletedStored1!=null)
                            wrapVal.totalCompletedStored1=wrapVal.totalCompletedStored1+sheetLine.buildertek__Total__c;
                        if(wrapval!=null && wrapVal.balancetofinsh1!=null)
                            wrapVal.balancetofinsh1=wrapVal.balancetofinsh1+sheetLine.buildertek__New_Retainage__c;
                        if(wrapval!=null && wrapVal.retainage1!=null)
                            wrapVal.retainage1=wrapVal.retainage1+sheetLine.buildertek__Balance_to_Pay__c;
                        if(wrapval!=null && wrapVal.per1!=null){
                            if(sheetLine.buildertek__percent1__c != null){
                                wrapVal.per1=wrapVal.per1+sheetLine.buildertek__percent1__c;
                            }else{
                                wrapVal.per1=wrapVal.per1;
                            }
                        }
                        
                        if(wrapval!=null && wrapVal.per2!=null){
                            if(sheetLine.buildertek__percent2__c != null){
                                wrapVal.per2=wrapVal.per2+sheetLine.buildertek__percent2__c;
                            }else{
                                wrapVal.per2=wrapVal.per2;
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
                        if(sheetLine.buildertek__Work_Completed__c != null){
                            wrap.workcompletedTotal1=sheetLine.buildertek__Work_Completed__c;
                        }
                        
                        if(sheetLine.buildertek__New_G_C__c != null){
                            wrap.gcVal=sheetLine.buildertek__New_G_C__c;
                        }
                        
                        wrap.materialsStoredTotal1=sheetLine.buildertek__Material_Presently_Stored__c;
                        wrap.totalCompletedStored1=sheetLine.buildertek__Total__c;
                        wrap.balancetofinsh1=sheetLine.buildertek__New_Retainage__c;
                        wrap.retainage1=sheetLine.buildertek__Balance_to_Pay__c;
                        if(sheetLine.buildertek__percent1__c !=null){
                            if(sheetLine.buildertek__percent1__c != null){
                                wrap.per1=sheetLine.buildertek__percent1__c; 
                            }
                            
                        }
                        if(sheetLine.buildertek__percent2__c!=null){
                            wrap.per2=sheetLine.buildertek__percent2__c;
                        }
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
                        
                        if(wrapval!=null && wrapVal.gcVal!=null){
                            if(sheetLine.buildertek__New_G_C__c != null){
                                wrapVal.gcVal=wrapVal.gcVal+sheetLine.buildertek__New_G_C__c;
                            }else{
                                wrapVal.gcVal=wrapVal.gcVal;
                            }
                        }
                        
                        
                        if(wrapval!=null && wrapVal.workFromPrevAppTotal1!=null)
                            wrapVal.workFromPrevAppTotal1 = wrapval.workFromPrevAppTotal1 + sheetLine.buildertek__Work_Completed_from_Previous_Application__c;
                        wrapVal.groupVal = 'No Grouping';
                        if(wrapval!=null && wrapVal.workcompletedTotal1!=null){
                            if(sheetLine.buildertek__Work_Completed__c != null){
                                wrapVal.workcompletedTotal1= wrapVal.workcompletedTotal1+sheetLine.buildertek__Work_Completed__c;
                            }else{
                                wrapVal.workcompletedTotal1= wrapVal.workcompletedTotal1;
                            }
                        }
                        
                        
                         if(wrapval!=null && wrapVal.gcVal!=null){
                            if(sheetLine.buildertek__New_G_C__c != null){
                                wrapVal.gcVal=wrapVal.gcVal+sheetLine.buildertek__New_G_C__c;
                            }else{
                                wrapVal.gcVal=wrapVal.gcVal;
                            }
                        }
                        
                        
                        system.debug(wrapval);
                        system.debug(wrapVal.materialsStoredTotal1);
                        system.debug(sheetLine);
                        system.debug(sheetLine.buildertek__percent3__c);
                        if(wrapval!=null && wrapVal.materialsStoredTotal1!=null){
                            if(sheetLine.buildertek__percent3__c != null){
                                wrapVal.materialsStoredTotal1=wrapVal.materialsStoredTotal1+sheetLine.buildertek__Material_Presently_Stored__c; 
                            }else{
                                wrapVal.materialsStoredTotal1=wrapVal.materialsStoredTotal1;
                            }
                        }
                        
                        if(wrapval!=null && wrapVal.totalCompletedStored1!=null)
                            wrapVal.totalCompletedStored1=wrapVal.totalCompletedStored1+sheetLine.buildertek__Total__c;
                        if(wrapval!=null && wrapVal.balancetofinsh1!=null)
                            wrapVal.balancetofinsh1=wrapVal.balancetofinsh1+sheetLine.buildertek__New_Retainage__c;
                        if(wrapval!=null && wrapVal.retainage1!=null)
                            wrapVal.retainage1=wrapVal.retainage1+sheetLine.buildertek__Balance_to_Pay__c;
                        if(wrapval!=null && wrapVal.per1!=null){
                            if(sheetLine.buildertek__percent1__c != null){
                                wrapVal.per1=wrapVal.per1+sheetLine.buildertek__percent1__c; 
                            }else{
                                wrapVal.per1=wrapVal.per1;
                            }
                        }
                        
                        if(wrapval!=null && wrapVal.per2!=null){
                            if(sheetLine.buildertek__percent2__c != null){
                                wrapVal.per2=wrapVal.per2+sheetLine.buildertek__percent2__c;
                            }else{
                                wrapVal.per2=wrapVal.per2;
                            }
                        }
                        
                        
                        // wrapList.add(wrapVal);
                        System.debug('wrapList----------'+JSON.serialize(wrapList));
                    }else{
                        ContinuationSheetLinesWrapper wrap = new ContinuationSheetLinesWrapper();
                        wrap.sheetLines = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                        wrap.sheetLines.add(sheetLine);
                        if(sheetLine.buildertek__Scheduled_Value__c != null){
                            wrap.scheduleValueTotal1 = sheetLine.buildertek__Scheduled_Value__c; 
                        }
                        
                        wrap.workFromPrevAppTotal1 = sheetLine.buildertek__Work_Completed_from_Previous_Application__c;
                        wrap.groupVal = 'No Grouping';
                        if(sheetLine.buildertek__Work_Completed__c != null){
                            wrap.workcompletedTotal1=sheetLine.buildertek__Work_Completed__c;
                        }
                        
                        if(sheetLine.buildertek__New_G_C__c != null){
                            wrap.gcVal=sheetLine.buildertek__New_G_C__c;
                        }
                        
                        wrap.materialsStoredTotal1=sheetLine.buildertek__Material_Presently_Stored__c;
                        wrap.totalCompletedStored1=sheetLine.buildertek__Total__c;
                        wrap.balancetofinsh1=sheetLine.buildertek__New_Retainage__c;
                        wrap.retainage1=sheetLine.buildertek__Balance_to_Pay__c;
                        if(sheetLine.buildertek__percent1__c!=null){
                            wrap.per1=sheetLine.buildertek__percent1__c;
                        }
                        if(sheetLine.buildertek__percent2__c!=null){
                            wrap.per2=sheetLine.buildertek__percent2__c;
                        }
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
                        if(wrapval!=null && wrapval.scheduleValueTotal1!=null)
                            wrapVal.scheduleValueTotal1 = wrapval.scheduleValueTotal1 + sheetLine.buildertek__Scheduled_Value__c;
                        if(wrapval!=null && wrapVal.workFromPrevAppTotal1!=null)
                            wrapVal.workFromPrevAppTotal1 = wrapval.workFromPrevAppTotal1 + sheetLine.buildertek__Work_Completed_from_Previous_Application__c;
                        wrapVal.groupVal = sheetLine.buildertek__Budget_Grouping__c;
                        if(wrapval!=null && wrapVal.workcompletedTotal1!=null){
                            if(sheetLine.buildertek__Work_Completed__c != null){
                                wrapVal.workcompletedTotal1= wrapVal.workcompletedTotal1+sheetLine.buildertek__Work_Completed__c;
                            }else{
                                wrapVal.workcompletedTotal1= wrapVal.workcompletedTotal1;
                            }
                            
                        }
                        
                        if(wrapval!=null && wrapVal.gcVal!=null){
                            if(sheetLine.buildertek__New_G_C__c != null){
                                wrapVal.gcVal=wrapVal.gcVal+sheetLine.buildertek__New_G_C__c;
                            }else{
                                wrapVal.gcVal=wrapVal.gcVal;
                            }
                        }
                        
                        
                        if(wrapval!=null && wrapVal.materialsStoredTotal1!=null)
                            wrapVal.materialsStoredTotal1=wrapVal.materialsStoredTotal1+sheetLine.buildertek__Material_Presently_Stored__c;
                        if(wrapval!=null && wrapVal.totalCompletedStored1!=null)
                            wrapVal.totalCompletedStored1=wrapVal.totalCompletedStored1+sheetLine.buildertek__Total__c;
                        if(wrapval!=null && wrapVal.balancetofinsh1!=null)
                            wrapVal.balancetofinsh1=wrapVal.balancetofinsh1+sheetLine.buildertek__New_Retainage__c;
                        if(wrapval!=null && wrapVal.retainage1!=null)
                            wrapVal.retainage1=wrapVal.retainage1+sheetLine.buildertek__Balance_to_Pay__c;
                        if(wrapval!=null && wrapVal.per1!=null){
                            if(sheetLine.buildertek__percent1__c != null){
                                wrapVal.per1=wrapVal.per1+sheetLine.buildertek__percent1__c;
                            }else{
                                wrapVal.per1=wrapVal.per1;
                            }
                        }
                        
                        if(wrapval!=null && wrapVal.per2!=null){
                            if(sheetLine.buildertek__percent2__c != null){
                                wrapVal.per2=wrapVal.per2+sheetLine.buildertek__percent2__c;
                            }else{
                                wrapVal.per2=wrapVal.per2;
                            }
                        }
                        
                        // wrapList.add(wrapVal);
                        System.debug('wrapList----------'+wrapList);
                    }else{
                        ContinuationSheetLinesWrapper wrap = new ContinuationSheetLinesWrapper();
                        wrap.sheetLines = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
                        wrap.sheetLines.add(sheetLine);
                        wrap.scheduleValueTotal1 = sheetLine.buildertek__Scheduled_Value__c;
                        wrap.workFromPrevAppTotal1 = sheetLine.buildertek__Work_Completed_from_Previous_Application__c;
                        wrap.groupVal = sheetLine.buildertek__Budget_Grouping__c;
                        if(sheetLine.buildertek__Work_Completed__c != null){
                            wrap.workcompletedTotal1=sheetLine.buildertek__Work_Completed__c;
                        }
                        
                        if(sheetLine.buildertek__New_G_C__c != null){
                            wrap.gcVal=sheetLine.buildertek__New_G_C__c;
                        }
                        
                        if(sheetLine.buildertek__percent3__c!=null){
                            wrap.materialsStoredTotal1=sheetLine.buildertek__Material_Presently_Stored__c;
                        }
                        if(sheetLine.buildertek__percent1__c!=null){
                            wrap.per1=sheetLine.buildertek__percent1__c;
                        }
                        if(sheetLine.buildertek__percent2__c!=null){
                            wrap.per2=sheetLine.buildertek__percent2__c;
                        }
                        wrap.totalCompletedStored1=sheetLine.buildertek__Total__c;
                        wrap.balancetofinsh1=sheetLine.buildertek__New_Retainage__c;
                        wrap.retainage1=sheetLine.buildertek__Balance_to_Pay__c;
                        calcMap.put(sheetLine.buildertek__Budget_Grouping__c,wrap);
                        wrapList.add(wrap);
                        System.debug('wrapList----------'+wrapList);
                        System.debug('CalMap =========== '+calcMap);
                        
                    }
                }   
            }
            
            system.debug('sheetLineGrpMap***********'+sheetLineGrpMap.size());
            System.debug('CalMap =========== '+calcMap);
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
                if(line.buildertek__percent3__c != null){
                    totalper1 +=line.buildertek__percent3__c;
                }
                if(line.buildertek__percent1__c != null){
                    totalper2 +=line.buildertek__percent1__c;
                }
                if(line.buildertek__percent2__c != null){
                    totalper3 +=line.buildertek__percent2__c;
                }
                if(line.buildertek__New_Retainage__c != null){
                    balancetofinsh1 +=line.buildertek__New_Retainage__c;
                }
                if(line.buildertek__Balance_to_Pay__c != null){
                    retainage1 +=line.buildertek__Balance_to_Pay__c;
                }
            }
            scheduleValueTotal=scheduleValue;
            workFromPrevAppTotal=workFromPrevAppTotal1;
            workCompletedthisperiod=workCompletedthisperiod1;
            materialpresentlystored=materialpresentlystored1;
            completedandstored=completedandstored1;
            balancetofinsh=balancetofinsh1;
            retainage=retainage1;
            totalper=totalper1;
            totalper11=totalper2;
            totalper22=totalper3;
        }
    }
    
    public class ContinuationSheetLinesWrapper{
        public List<buildertek__SOV_Continuation__c> continuationSheetList{set;get;}
        public List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLines{set;get;}
        public Decimal scheduleValueTotal1{set;get;}
        public Decimal workFromPrevAppTotal1{set;get;}
        public Decimal workcompletedTotal1{set;get;}
        public Decimal materialsStoredTotal1{set;get;}
        public Decimal per1{set;get;}
        public Decimal per2{set;get;}
        public Decimal totalCompletedStored1{set;get;}
        public Decimal balancetofinsh1{set;get;}
        public Decimal retainage1{set;get;}
        public String groupVal{set;get;}
        public Decimal gcVal{set;get;}  
        
    }
    
    public class ContinuationDetails{
        public buildertek__SOV_Continuation__c continuationSheet{set;get;}
        public List<buildertek__SOV_Continuation_Sheet_Lines__c> sheetLines{set;get;}
        public Decimal scheduleValueTotal{set;get;}
        public Decimal workFromPrevAppTotal{set;get;}
        public Decimal workcompletedTotal{set;get;}
        public Decimal materialsStoredTotal{set;get;}
        public Decimal totalCompletedStored{set;get;}
        public Decimal gcTotal{set;get;}
        public Decimal balanceTotal{set;get;}
        public Boolean isApplication{set;get;}
        public String projectId{set;get;}
        public Decimal materialsStoredTotal10{set;get;}
        public Decimal workcompletedTotal10{set;get;}
        public Decimal totalWorkBy10{set;get;}
        
    }
    
}