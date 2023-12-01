/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  19-Sep-2017
*/
public without sharing class ChangeOrderTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipChangeOrderUpdateTrigger = false;
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public ChangeOrderTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(buildertek__Change_Order__c[] newChangeOrder){
        List<buildertek__Change_Order__c> coList;
        
        coList = [Select Id, Auto_Number__c from buildertek__Change_Order__c 
                  where Project__c =:newChangeOrder[0].Project__c 
                  ORDER BY CREATEDDATE DESC  LIMIT 1];        
        
        System.debug('coList : '+coList);
        BT_Utils.genrateAutoNumber(coList, newChangeOrder, 'Auto_Number__c');
        for(buildertek__Change_Order__c newCO : newChangeOrder){
            newCO.buildertek__Date_Created__c = system.today();        
        }                            
    }
    
    public void OnBeforeUpdate(buildertek__Change_Order__c[] oldChangeOrder, buildertek__Change_Order__c[] updatedChangeOrder, Map<ID, buildertek__Change_Order__c> ChangeOrderMap, Map<ID, buildertek__Change_Order__c> oldChangeOrderMap){
       
       if(!blnSkipChangeOrderUpdateTrigger){

        Boolean isPaid = false;
        Boolean isPartiallyPaid = false;
        List<buildertek__Billings__c> invoiceList ;
        
        invoiceList= [select Id, Name, buildertek__Status__c from buildertek__Billings__c where buildertek__Change_Order__c =: Trigger.old[0].id];
        if(invoiceList.size() > 0){
            system.debug('Invoice List ---------> '+invoiceList);
            for(buildertek__Billings__c Inv : invoiceList){
                if(Inv.buildertek__Status__c == 'Paid'){
                    isPaid = true;
                    isPartiallyPaid = false;
                    break;
                }
                else if(Inv.buildertek__Status__c == 'Partially Paid'){
                    isPartiallyPaid = true;
                    isPaid = false;
                }
            }
        }
        if(isPaid){
            for(buildertek__Change_Order__c coList : updatedChangeOrder){
                if(coList.buildertek__Status__c == 'Customer Approved'){
                    coList.buildertek__Status__c = 'Customer Approved';    
                }else if(coList.buildertek__Status__c == 'Approved'){
                    coList.buildertek__Status__c = 'Approved';    
                }
                else if(coList.buildertek__Status__c == 'Rejected'){
                    coList.buildertek__Status__c = 'Rejected';
                }
                else{
                    coList.buildertek__Status__c = 'Paid';    
                }  
            }
        }else if(isPartiallyPaid){
            for(buildertek__Change_Order__c coList : updatedChangeOrder){
                if(coList.buildertek__Status__c == 'Customer Approved'){
                    coList.buildertek__Status__c = 'Customer Approved';    
                }else if(coList.buildertek__Status__c == 'Approved'){
                    coList.buildertek__Status__c = 'Approved';    
                }
                else if(coList.buildertek__Status__c == 'Rejected'){
                    coList.buildertek__Status__c = 'Rejected';
                }
                else{
                    coList.buildertek__Status__c = 'Partially Paid';    
                } 
            }    
        }

        List<buildertek__Budget_Line_Group__c> budgetLineGroup = [SELECT Id FROM buildertek__Budget_Line_Group__c WHERE Name = 'Change Order' LIMIT 1];
        Id budgetLineGroupId;
        if (budgetLineGroup.size() > 0) {
            budgetLineGroupId = budgetLineGroup[0].Id;
        } else {
            buildertek__Budget_Line_Group__c lineGroup = new buildertek__Budget_Line_Group__c();
            lineGroup.Name = 'Change Order';
            insert lineGroup;
            budgetLineGroupId = lineGroup.Id;
        }
        Map<Id, buildertek__Budget_Item__c> budgetLineMap = new Map<Id, buildertek__Budget_Item__c>();
        for(buildertek__Change_Order__c newCO : updatedChangeOrder){
            newCO.buildertek__Date_Created__c = system.today();       
            
            if (newCO.buildertek__Budget__c != oldChangeOrderMap.get(newCO.Id).buildertek__Budget__c && newCO.buildertek__Budget__c != null && newCO.buildertek__Budget_Line__c == null) {
                buildertek__Budget_Item__c budgetLine = new buildertek__Budget_Item__c();
                budgetLine.Name = newCO.Name + ' budget line';
                budgetLine.buildertek__Budget__c = newCO.buildertek__Budget__c;
                budgetLine.buildertek__Unit_Price__c = newCO.buildertek__Total_Costs__c;
                budgetLine.buildertek__Sales_Price__c = newCo.buildertek__Total_Costs__c;
                // budgetLine.buildertek__Markup__c = (newCO.buildertek__Margin__c / (1 - newCO.buildertek__Margin__c));
                if(newCO.buildertek__Calculated_Margin__c != null){
                    budgetLine.buildertek__Markup__c = (((newCO.Total_Costs__c - newCO.buildertek__Total_Amount_Tax__c)/newCO.Total_Costs__c)*100)*-1;
                }
                budgetLine.buildertek__Quantity__c = 1;
                budgetLine.buildertek__Group__c = budgetLineGroupId;
                budgetLineMap.put(newCO.Id, budgetLine);
            } 
        }

        insert budgetLineMap.values();

        for(buildertek__Change_Order__c changeOrder : updatedChangeOrder){
            for (Id key : budgetLineMap.keySet()) {
                if (changeOrder.Id == key) {
                    changeOrder.buildertek__Budget_Line__c = budgetLineMap.get(changeOrder.Id).Id;
                }
            }
        }

        //will delete automatically created budget line if unlinked from the change order on update
        // for(buildertek__Change_Order__c changeOrder : oldChangeOrder){
        //     for(buildertek__Change_Order__c changeOrder2 : updatedChangeOrder){
        //         if(changeOrder.Id == changeOrder2.Id){
        //             if(changeOrder.buildertek__Budget_Line__c != changeOrder2.buildertek__Budget_Line__c && changeOrder.buildertek__Budget_Line__c != null) 
        //             {
        //                 string Name  = changeOrder.Name + ' budget line';
        //                 buildertek__Budget_Item__c  oldBudgetLine = [SELECT Id, buildertek__Item_Name__c, Name FROM buildertek__Budget_Item__c WHERE ID =: changeOrder.buildertek__Budget_Line__c];
        //                 if(oldBudgetLine.Name == Name){
        //                     delete oldBudgetLine;
        //                 }
        //             }
        //         }
        //     }
        // }


        // Create New Budget Line From ADD CO Button
        for(buildertek__Change_Order__c changeOrder : updatedChangeOrder){
            for(buildertek__Change_Order__c changeOrder2 : oldChangeOrder){
                if(changeOrder.Id == changeOrder2.Id){
                    if(changeOrder.buildertek__Total_Amount_Tax__c != changeOrder2.buildertek__Total_Amount_Tax__c){
                        //check if the budget line is same as the old budget line
                        if(changeOrder.buildertek__Budget_Line__c == changeOrder2.buildertek__Budget_Line__c && changeOrder.buildertek__Budget_Line__c != null){
                            //check if the name if the budget line is same as the name of the change order + ' budget line'
                            string Name  = changeOrder.Name + ' budget line';
                            buildertek__Budget_Item__c  oldBudgetLine = [SELECT Id, buildertek__Item_Name__c, Name FROM buildertek__Budget_Item__c WHERE ID =: changeOrder.buildertek__Budget_Line__c];
                            if(oldBudgetLine.Name == Name){
                                oldBudgetLine.buildertek__CO_Total__c = changeOrder.buildertek__Total_Amount_Tax__c;
                                update oldBudgetLine;
                            }
                        }
                    }

                }
            }
        }

        //BUIL -3336 ------- Remove BUDGET from change order when Budget Line Removed from Change Order.   
        for(buildertek__Change_Order__c changeOrder:updatedChangeOrder){
            System.debug('Inside if comndition');
            System.debug(changeOrder.buildertek__Budget_Line__c);
            System.debug(oldChangeOrderMap.get(changeOrder.Id).buildertek__Budget_Line__c != changeOrder.buildertek__Budget_Line__c);
            System.debug(changeOrder.buildertek__Budget__c);
            if(changeOrder.buildertek__Budget_Line__c ==null && oldChangeOrderMap.get(changeOrder.Id).buildertek__Budget_Line__c != changeOrder.buildertek__Budget_Line__c && changeOrder.buildertek__Budget__c!=null){
                changeOrder.buildertek__Budget__c = null;
            }
        }


    }

    }
    
    public void OnBeforeDelete(buildertek__Change_Order__c[] ChangeOrderToDelete, Map<ID, buildertek__Change_Order__c> ChangeOrderMap){
        system.debug('ChangeOrderToDelete------->'+ChangeOrderToDelete);
        for(buildertek__Change_Order__c changeOrder : ChangeOrderToDelete) {
            if(changeOrder.buildertek__Status__c != null){
                //* whole condition breakDown {changeOrder.buildertek__Status__c.equalsIgnoreCase('Approved') || changeOrder.buildertek__Status__c.equalsIgnoreCase('Paid')|| changeOrder.buildertek__Status__c.equalsIgnoreCase('Partially Paid') || changeOrder.buildertek__Status__c.equalsIgnoreCase('Customer Approved')}
                if(changeOrder.buildertek__Status__c.equalsIgnoreCase('Customer Approved')) {
                       changeOrder.addError('You cannot delete this Change Order because it has already been '+changeOrder.buildertek__Status__c);
                   }
            }
        }
    }
    
    public void OnAfterInsert(buildertek__Change_Order__c[] newChangeOrder, Map<ID, buildertek__Change_Order__c> newChangeOrderMap){ 
        
        //----------------------------------------------------------------------------
        
        //  Code for giving permission to master sov for community
        List<buildertek__Change_Order__Share> rfqshareList = new List<buildertek__Change_Order__Share>();
        
        list<buildertek__Change_Order__c>  SOVRec  = [select Id, name,RecordTypeId, recordtype.name,  buildertek__Status__c, buildertek__Vendor__c  from buildertek__Change_Order__c where Id IN: newChangeOrder AND recordtype.name = 'Vendor'];
        system.debug('masterSovList---->'+ SOVRec );
        
        set<Id> vendorIds = new set<Id>();
        map<Id,User> vendorUserMap = new map<Id,User>();
        list<Network> netRec = [SELECT Id,Status FROM Network where Status = 'Live'];
        
        list<User> usersList = new list<User>();
        
        if(netRec.size() > 0){
            string strQry = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId,Email,buildertek__Account_Id__c, isPortalEnabled '+
                'FROM User Where isPortalEnabled=true ';    
            usersList = Database.query(strQry);
        }
        
        
        if(usersList.size() > 0){
            for(User usr: usersList){
                vendorUserMap.put(usr.AccountId,usr);
            }
        }
        
        system.debug('vendorUserMap'+vendorUserMap);
        system.debug('usersList--------------->'+ usersList);
        
        list<Id> oldVendorIds= New list<Id>();
        List<Id> sovIds = new List<Id>();
        
        // ----------------------------------------------------
        
        //  -----------------------------------------------------------------
        
        for (buildertek__Change_Order__c rfqVendor : SOVRec){
            for(User usr1: usersList){
                
                system.debug('usrrec--->'+usersList ); 
                if(rfqVendor.recordtype.name == 'Vendor' && rfqVendor.buildertek__Vendor__c != null){
                    system.debug(rfqVendor.buildertek__Vendor__c);
                    system.debug(usr1.AccountId);
                    system.debug('rfqVendor.buildertek__Vendor__c------->'+rfqVendor.buildertek__Vendor__c);
                    if(rfqVendor.buildertek__Vendor__c == usr1.AccountId ){
                        buildertek__Change_Order__Share rfqshare=new buildertek__Change_Order__Share();
                        rfqshare.ParentId= rfqVendor.Id;
                        rfqshare.UserOrGroupId=usr1.Id;
                        rfqshare.AccessLevel= 'All';
                        rfqshare.RowCause=Schema.buildertek__Change_Order__Share.RowCause.Manual;             
                        rfqshareList.add(rfqshare);
                        system.debug('rfqshare--->'+rfqshare); 
                    } 
                    
                }
            } 
        }
        
        system.debug('rfqshareList -------> '+rfqshareList);
        if(rfqshareList.size()>0){
            Database.SaveResult[] lsr = Database.insert(rfqshareList,false);
        }
        
        SET<Id> changeOrderIdSet = new SET<Id>();
        SET<Id> changeOrderContractIdSet = new SET<Id>();
        Map<String, Decimal> contractMap = new Map<String, Decimal>();
        List<buildertek__Contract__c> contractToUpdateList = new List<buildertek__Contract__c>();
        List<buildertek__Contract_Item__c> contractItemsToInsert = new List<buildertek__Contract_Item__c>();
        List<buildertek__Budget_Item__c> budgetItemsToInsert = new List<buildertek__Budget_Item__c>();
        
        buildertek__Quote_Line_Group__c newContractGroup = new buildertek__Quote_Line_Group__c();
        buildertek__Budget_Line_Group__c newBudgetGroup = new buildertek__Budget_Line_Group__c();
        Map<String, String> groupNameMap = new  Map<String, String>();

        Map<Id, buildertek__Budget_Item__c> budgetLineMap = new Map<Id, buildertek__Budget_Item__c>();

        List<buildertek__Budget_Line_Group__c> budgetLineGroup = [SELECT Id FROM buildertek__Budget_Line_Group__c WHERE Name = 'Change Order' LIMIT 1];
        Id budgetLineGroupId;
        if (budgetLineGroup.size() > 0) {
            budgetLineGroupId = budgetLineGroup[0].Id;
        } else {
            buildertek__Budget_Line_Group__c lineGroup = new buildertek__Budget_Line_Group__c();
            lineGroup.Name = 'Change Order';
            insert lineGroup;
            budgetLineGroupId = lineGroup.Id;
        }

        for(buildertek__Change_Order__c changeOrder : newChangeOrder){
            if(changeOrder.buildertek__Status__c == 'Customer Approved'){
                changeOrderIdSet.add(changeOrder.Id);
                changeOrderContractIdSet.add(changeOrder.buildertek__Contract__c);
            }

            if (changeOrder.buildertek__Budget__c != null && changeOrder.buildertek__Budget_Line__c == null) {
                buildertek__Budget_Item__c budgetLine = new buildertek__Budget_Item__c();
                budgetLine.Name = changeOrder.Name + ' budget line';
                budgetLine.buildertek__Budget__c = changeOrder.buildertek__Budget__c;
                budgetLine.buildertek__Group__c = budgetLineGroupId;
                budgetLineMap.put(changeOrder.Id, budgetLine);
            }
            
        }

        insert budgetLineMap.values();


        List<buildertek__Change_Order__c> changeOrdersList ;
        
        changeOrdersList= [SELECT Id,
                           Name,
                           buildertek__Contract__c,
                           buildertek__Total_Amount_Tax__c 
                           FROM buildertek__Change_Order__c
                           WHERE buildertek__Contract__c IN: changeOrderContractIdSet
                           AND buildertek__Status__c = 'Customer Approved'];
        
        for(buildertek__Change_Order__c changeOrders : changeOrdersList){
            if(contractMap.get(changeOrders.buildertek__Contract__c) == null){
                contractMap.put(changeOrders.buildertek__Contract__c, changeOrders.buildertek__Total_Amount_Tax__c);    
            }else{
                decimal finalTotalAmount = contractMap.get(changeOrders.buildertek__Contract__c) + changeOrders.buildertek__Total_Amount_Tax__c; 
                contractMap.put(changeOrders.buildertek__Contract__c, finalTotalAmount);
            }
        }
        for(String contractId : contractMap.keySet()){
            if(contractId != null ){
                
                buildertek__Contract__c contractToUpdate = new buildertek__Contract__c();
                contractToUpdate.Id = contractId;
                contractToUpdate.buildertek__Change_Order_Amount__c = contractMap.get(contractId);
                contractToUpdateList.add(contractToUpdate);     
                
                
            }
        }
        List<buildertek__Contract_Line_Group__c> newContractGroupList = new List<buildertek__Contract_Line_Group__c>();
        if(contractToUpdateList.size() > 0){
            update contractToUpdateList; 
            
            SET<Id> contractIdSet = new SET<Id>();
            //Map<String, String> ContractGroupMap = new Map<String, String>();
            
            for(buildertek__Contract__c cont: contractToUpdateList){
                contractIdSet.add(cont.Id);    
            } 
            List<buildertek__Quote_Line_Group__c> groupList ;
            
            groupList= [SELECT Id,
                        Name
                        FROM buildertek__Quote_Line_Group__c
                        WHERE Name = 'Change Order'];
            
            if(groupList.size() > 0){
                //for(buildertek__Quote_Line_Group__c groups : groupList){
                //ContractGroupMap.put(groups.buildertek__Contract__c, groups.Id);
                system.debug(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isUpdateable());    
                
                
                newContractGroup.Id = groupList[0].Id;
                newContractGroup.Name = 'Change Order';
                //newContractGroup.buildertek__Contract__c = groups.buildertek__Contract__c;
                //newContractGroupList.add(newContractGroup);      
                
                
                //}
                update newContractGroup;
            }else{
                
                
                newContractGroup.Name = 'Change Order';
                //newContractGroup.buildertek__Contract__c = contractToUpdateList[0].Id;
                //newContractGroupList.add(newContractGroup); 
                insert newContractGroup;
                
                
                
            }
            /*for(buildertek__Quote_Line_Group__c grp : newContractGroupList){
            groupNameMap.put(grp.buildertek__Contract__c, grp.Id);        
            }*/
        } 

        List<buildertek__Change_Order__c> newCOList = new List<buildertek__Change_Order__c>();
        list<buildertek__Change_Order__c>  changeOrderList  = [select Id, name,buildertek__Budget_Line__c  from buildertek__Change_Order__c where Id IN: newChangeOrder];
        for(buildertek__Change_Order__c changeOrder : changeOrderList){
            for (Id key : budgetLineMap.keySet()) {
                if (changeOrder.Id == key) {
                    changeOrder.buildertek__Budget_Line__c = budgetLineMap.get(changeOrder.Id).Id;
                    newCOList.add(changeOrder);
                }
            }
        }
        if (newCOList.size() > 0) {
            update newCOList;
        }
        
        
        
        
        
        /*  List<buildertek__Change_Order_Item__c> COItemList = new List<buildertek__Change_Order_Item__c>();

            COItemList= [SELECT Id,
            buildertek__Cost_Code__c,
            Name,
            buildertek__Quantity__c,
            buildertek__Unit_Price__c,
            buildertek__Total__c,
            buildertek__Unit_Sales_Price__c,
            buildertek__Change_Order__c,
            buildertek__Change_Order__r.buildertek__Contract__c
            FROM buildertek__Change_Order_Item__c
            WHERE buildertek__Change_Order__c IN: changeOrderIdSet];

            if(COItemList.size() > 0){
            for(buildertek__Change_Order_Item__c coItem : COItemList){


            buildertek__Contract_Item__c contractItem = new buildertek__Contract_Item__c();
            contractItem.Name = coItem.Name;
            contractItem.buildertek__Contract__c = coItem.buildertek__Change_Order__r.buildertek__Contract__c;
            contractItem.buildertek__Quantity__c = coItem.buildertek__Quantity__c;
            contractItem.buildertek__Unit_Price__c = coItem.buildertek__Unit_Sales_Price__c;
            contractItem.buildertek__Contract_Item_Group__c = newContractGroup.Id;
            contractItemsToInsert.add(contractItem);


            } 
            if(contractItemsToInsert.size() > 0){
            // insert contractItemsToInsert;    
            }
            }      */                                                      
        
    }
    
    public void OnAfterUpdate(buildertek__Change_Order__c[] oldChangeOrder, buildertek__Change_Order__c[] updatedChangeOrder, Map<ID, buildertek__Change_Order__c> ChangeOrderMap, Map<Id, buildertek__Change_Order__c> oldChangeOrderMap){
        SET<Id> changeOrderIdSet = new SET<Id>();
        SET<Id> changeOrderContractIdSet = new SET<Id>();
        Set<Id> coIds = new Set<Id>();
        Set<Id> oldcoids = new Set<Id>();
        for(buildertek__Change_Order__c oldCO : oldChangeOrder){
            if(BT_UTILS.hasStringFieldValueChanged(ChangeOrderMap.get(oldCO.Id), oldCO, 'buildertek__Status__c')){
                coIds.add(oldCO.Id);
            }
        }
        system.debug('coIds--->'+coIds);
        ChangeOrderDAO.RollUpChangeOrderAmount(coIds);
        
        
        for(buildertek__Change_Order__c oldCO : oldChangeOrder){
            if(oldCO.buildertek__Status__c == 'Customer Approved'){
                if(oldCO.buildertek__Contract__c !=null){
                    changeOrderContractIdSet.add(oldCO.buildertek__Contract__c);
                }
            }
        }
        // changeOrderContractIdSet.add(oldcoids);
        system.debug('oldcoids---'+oldcoids);
        
        
        
        Map<String, Decimal> contractMap = new Map<String, Decimal>();
        List<buildertek__Contract__c> contractToUpdateList = new List<buildertek__Contract__c>();
        List<buildertek__Contract_Item__c> contractItemsToInsert = new List<buildertek__Contract_Item__c>();
        buildertek__Quote_Line_Group__c newContractGroup = new buildertek__Quote_Line_Group__c();
        List<buildertek__Budget_Item__c> budgetItemsToInsert = new List<buildertek__Budget_Item__c>();
        
        buildertek__Budget_Line_Group__c newBudgetGroup = new buildertek__Budget_Line_Group__c();
        
        Map<String, String> groupNameMap = new  Map<String, String>();
        for(buildertek__Change_Order__c changeOrder : updatedChangeOrder){
            if(changeOrder.buildertek__Status__c == 'Customer Approved'){
                changeOrderIdSet.add(changeOrder.Id);
                if(changeOrder.buildertek__Contract__c !=null){
                    changeOrderContractIdSet.add(changeOrder.buildertek__Contract__c);
                }
            }
            
        }
        List<buildertek__Change_Order__c> changeOrdersList;
        //system.debug('ChangeOrderList11.....>' +changeOrdersList);
        //  system.debug(Schema.sObjectType.buildertek__Change_Order__c.fields.Id.isAccessible());
        
        changeOrdersList = [SELECT Id,
                            Name,
                            buildertek__Contract__c,
                            buildertek__Total_Amount_Tax__c 
                            FROM buildertek__Change_Order__c
                            WHERE buildertek__Contract__c IN: changeOrderContractIdSet
                            AND buildertek__Status__c = 'Customer Approved'];
        system.debug('ChangeOrderList.....>' +changeOrdersList);
        
        if(changeOrdersList !=null){
            for(buildertek__Change_Order__c changeOrders : changeOrdersList){
                if(contractMap.get(changeOrders.buildertek__Contract__c) == null){
                    contractMap.put(changeOrders.buildertek__Contract__c, changeOrders.buildertek__Total_Amount_Tax__c);    
                }else{
                    decimal finalTotalAmount = contractMap.get(changeOrders.buildertek__Contract__c) + changeOrders.buildertek__Total_Amount_Tax__c; 
                    contractMap.put(changeOrders.buildertek__Contract__c, finalTotalAmount);
                }
            }
        }
        system.debug('Contract Map ---------> '+contractMap.keySet());
        for(String contractId : contractMap.keySet()){
            system.debug('contractId ---------> '+contractId);
            if(contractId != null ){
                
                buildertek__Contract__c contractToUpdate = new buildertek__Contract__c();
                contractToUpdate.Id = contractId;
                system.debug('CO Amount --------->'+contractMap.get(contractId));
                contractToUpdate.buildertek__Change_Order_Amount__c = contractMap.get(contractId);
                contractToUpdateList.add(contractToUpdate);              
                
                
            }
        }
        
        
        system.debug('contractToUpdateList --------------> '+contractToUpdateList);
        List<buildertek__Contract_Line_Group__c> newContractGroupList = new List<buildertek__Contract_Line_Group__c>();
        
        if(contractToUpdateList.size() > 0){
            update contractToUpdateList;
            
            SET<Id> contractIdSet = new SET<Id>();
            //Map<String, String> ContractGroupMap = new Map<String, String>();
            
            for(buildertek__Contract__c cont: contractToUpdateList){
                contractIdSet.add(cont.Id);    
            }
            List<buildertek__Quote_Line_Group__c> groupList;
            groupList = [SELECT Id,
                         Name
                         FROM buildertek__Quote_Line_Group__c
                         WHERE Name = 'Change Order'];
            
            system.debug('groupList ----------> '+groupList);
            if(groupList.size() > 0){
                //for(buildertek__Quote_Line_Group__c groups : groupList){
                //ContractGroupMap.put(groups.buildertek__Contract__c, groups.Id); 
                
                
                newContractGroup.Id = groupList[0].Id;
                system.debug(newContractGroup.Id);
                newContractGroup.Name = 'Change Order';
                //newContractGroup.buildertek__Contract__c = groups.buildertek__Contract__c;
                //newContractGroupList.add(newContractGroup);    
                update newContractGroup;
                
                //}
                
            }else{
                
                newContractGroup.Name = 'Change Order';
                //newContractGroup.buildertek__Contract__c = contractToUpdateList[0].Id;
                //newContractGroupList.add(newContractGroup); 
                insert newContractGroup;    
                
                
            }
            /*for(buildertek__Contract_Line_Group__c grp : newContractGroupList){
            groupNameMap.put(grp.buildertek__Contract__c, grp.Id);        
            }*/                
        } 
        
        system.debug('newBudgetGroup ----------> '+newBudgetGroup);
        
        List<buildertek__Budget_Line_Group__c> groupList1;
        groupList1 = [SELECT Id,
                      Name
                      FROM buildertek__Budget_Line_Group__c
                      WHERE Name = 'Change Order'];
        
        system.debug('groupList1 ----------> '+groupList1);
        if(groupList1.size() > 0){
            //for(buildertek__Quote_Line_Group__c groups : groupList){
            //ContractGroupMap.put(groups.buildertek__Contract__c, groups.Id); 
            
            
            newBudgetGroup.Id = groupList1[0].Id;
            system.debug(newBudgetGroup.Id);
            newBudgetGroup.Name = 'Change Order';
            //newContractGroup.buildertek__Contract__c = groups.buildertek__Contract__c;
            //newContractGroupList.add(newContractGroup);    
            update newBudgetGroup;
            //}
            
        }else{
            
            newBudgetGroup.Name = 'Change Order';
            //newContractGroup.buildertek__Contract__c = contractToUpdateList[0].Id;
            //newContractGroupList.add(newContractGroup); 
            insert newBudgetGroup;    
        }
            /*for(buildertek__Contract_Line_Group__c grp : newContractGroupList){
            groupNameMap.put(grp.buildertek__Contract__c, grp.Id);        
            }*/
            
            /*   List<buildertek__Change_Order_Item__c> COItemList = new List<buildertek__Change_Order_Item__c>();
            system.debug('CoITEMLIST11....>' +COItemList);

            COItemList= [SELECT Id,
            buildertek__Cost_Code__c,
            Name,
            buildertek__Quantity__c,
            buildertek__Unit_Price__c,
            buildertek__Total__c,
            buildertek__Unit_Sales_Price__c,
            buildertek__Change_Order__c,
            buildertek__Change_Order__r.buildertek__Contract__c
            FROM buildertek__Change_Order_Item__c
            WHERE buildertek__Change_Order__c IN: changeOrderIdSet and buildertek__Change_Order__r.buildertek__Contract__c !=null LIMIT 1];
            system.debug('CoITEMLIST....>' +COItemList);

            if(COItemList.size() > 0){
            for(buildertek__Change_Order_Item__c coItem : COItemList){
            buildertek__Contract_Item__c contractItem = new buildertek__Contract_Item__c();
            contractItem.Name = coItem.Name;
            contractItem.buildertek__Contract__c = coItem.buildertek__Change_Order__r.buildertek__Contract__c;
            contractItem.buildertek__Quantity__c = coItem.buildertek__Quantity__c;
            contractItem.buildertek__Unit_Price__c = coItem.buildertek__Unit_Sales_Price__c;
            system.debug('COL group is :'+newContractGroup.Id);
            contractItem.buildertek__Contract_Item_Group__c = newContractGroup.Id;
            contractItemsToInsert.add(contractItem);

            } 


            if(contractItemsToInsert.size() > 0){
            // insert contractItemsToInsert;    
            }
            } */
        
        List<buildertek__Change_Order_Item__c> COItemListForBudget = new List<buildertek__Change_Order_Item__c>();
        system.debug('CoITEMLIST11....>' +COItemListForBudget);
        
        Set<Id> budgetChangeOrderSet = new Set<Id>();
        /* for(buildertek__Change_Order__c oldChangeOrderItem : oldChangeOrder ){
        if(ChangeOrderMap.get(oldChangeOrderItem.Id).buildertek__Budget__c ! = oldChangeOrderItem.buildertek__Budget__c){
        budgetChangeOrderSet.add(oldChangeOrderItem.Id);
        }
        }*/
        
        for(buildertek__Change_Order__c oppRec : updatedChangeOrder){
            if(oldChangeOrderMap.get(oppRec.Id).buildertek__Budget__c != oppRec.buildertek__Budget__c ){
                budgetChangeOrderSet.add(oppRec.Id);    
            }
            
            if(budgetChangeOrderSet.size()>0){
                COItemListForBudget= [SELECT Id,
                                      buildertek__Cost_Code__c,
                                      Name,
                                      buildertek__Quantity__c,
                                      buildertek__Unit_Price__c,
                                      buildertek__Total__c,
                                      buildertek__Unit_Sales_Price__c,
                                      buildertek__Change_Order__c,
                                      buildertek__Budget_Item__c,
                                      buildertek__Budget_Item__r.buildertek__Budget__c,
                                      buildertek__Change_Order__r.buildertek__Contract__c,
                                      buildertek__Change_Order__r.buildertek__Budget__c 
                                      FROM buildertek__Change_Order_Item__c
                                      WHERE buildertek__Change_Order__c IN: budgetChangeOrderSet AND  buildertek__Change_Order__r.buildertek__Budget__c !=null LIMIT 1];
                
                //! this logic is creating new budget line from CO line which is inCorrect
                /*if(COItemListForBudget.size() > 0){
                    
                    for(buildertek__Change_Order_Item__c coItem : COItemListForBudget){
                        
                        buildertek__Budget_Item__c budgetLineItem = new buildertek__Budget_Item__c();
                        
                        budgetLineItem.Name = coItem.Name;
                        budgetLineItem.buildertek__Quantity__c = coItem.buildertek__Quantity__c;
                        budgetLineItem.buildertek__Sales_Price__c = coItem.buildertek__Unit_Sales_Price__c;
                        budgetLineItem.buildertek__Unit_Price__c = coItem.buildertek__Unit_Price__c;
                        budgetLineItem.buildertek__Budget__c = coItem.buildertek__Change_Order__r.buildertek__Budget__c ;
                        system.debug('COL group is :'+newContractGroup.Id);
                        budgetLineItem.buildertek__Group__c = newBudgetGroup.Id;
                        budgetItemsToInsert.add(budgetLineItem);
                        
                        
                    }
                    if(budgetItemsToInsert.size() > 0){
                        
                        
                        insert budgetItemsToInsert;    
                    }
                } */
                
            }
        }
        
        
        
        
        //----------------------------------------------------------------------------
        
        
        
        //  Code for giving permission to master sov for community
        List<buildertek__Change_Order__Share> rfqshareList = new List<buildertek__Change_Order__Share>();
        
        list<buildertek__Change_Order__c>  SOVRec  = [select Id, name,RecordTypeId, recordtype.name,  buildertek__Status__c, buildertek__Vendor__c  from buildertek__Change_Order__c where Id IN: updatedChangeOrder AND recordtype.name = 'Vendor'];
        system.debug('masterSovList---->'+ SOVRec );
        
        set<Id> vendorIds = new set<Id>();
        map<Id,User> vendorUserMap = new map<Id,User>();
        
        
        list<Network> netRec = [SELECT Id,Status FROM Network where Status = 'Live'];
        
        list<User> usersList = new list<User>();
        
        if(netRec.size() > 0){
            string strQry = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId,Email,buildertek__Account_Id__c, isPortalEnabled '+
                'FROM User Where isPortalEnabled=true ';    
            usersList = Database.query(strQry);
        }
        
        if(usersList.size() > 0){
            for(User usr: usersList){
                vendorUserMap.put(usr.AccountId,usr);
            }
        }
        
        system.debug('vendorUserMap'+vendorUserMap);
        system.debug('usersList--------------->'+ usersList);
        
        list<Id> oldVendorIds= New list<Id>();
        List<Id> sovIds = new List<Id>();
        
        
        // ----------------------------------------------------
        
        
        if(oldChangeOrder!= null){
            list<buildertek__Change_Order__c>  OldSOVRec  = [select Id, name,RecordTypeId, recordtype.name,  buildertek__Status__c, buildertek__Vendor__c  from buildertek__Change_Order__c where Id IN: oldChangeOrder AND recordtype.name = 'Vendor'];
            
            List<String> OldSOVRecIds = new List<String> ();
            
            for(buildertek__Change_Order__c SV :OldSOVRec){
                if(oldChangeOrderMap.get(SV.Id).buildertek__Vendor__c != SV.buildertek__Vendor__c){
                    OldSOVRecIds.add(SV.Id);
                }
                
            }
            
            List<buildertek__Change_Order__Share> OldSovShareRec =  [SELECT Id, ParentId
                                                                     FROM buildertek__Change_Order__Share
                                                                     WHERE ParentId IN: OldSOVRecIds AND RowCause = 'Manual']; 
            
            
            if(!OldSovShareRec.isEmpty()){
                delete OldSovShareRec;
            } 
        }
        
        //  -----------------------------------------------------------------
        
        for (buildertek__Change_Order__c rfqVendor : SOVRec){
            for(User usr1: usersList){
                
                system.debug('usrrec--->'+usersList ); 
                if(rfqVendor.recordtype.name == 'Vendor' && rfqVendor.buildertek__Vendor__c != null){
                    system.debug(rfqVendor.buildertek__Vendor__c);
                    system.debug(usr1.AccountId);
                    system.debug('rfqVendor.buildertek__Vendor__c------->'+rfqVendor.buildertek__Vendor__c);
                    if(rfqVendor.buildertek__Vendor__c == usr1.AccountId ){
                        buildertek__Change_Order__Share rfqshare=new buildertek__Change_Order__Share();
                        rfqshare.ParentId= rfqVendor.Id;
                        rfqshare.UserOrGroupId=usr1.Id;
                        rfqshare.AccessLevel= 'All';
                        rfqshare.RowCause=Schema.buildertek__Change_Order__Share.RowCause.Manual;             
                        rfqshareList.add(rfqshare);
                        system.debug('rfqshare--->'+rfqshare); 
                    } 
                }
            } 
        }
        
        system.debug('rfqshareList -------> '+rfqshareList);
        if(rfqshareList.size()>0){
            Database.SaveResult[] lsr = Database.insert(rfqshareList,false);
        }

        //----------------------------------------------------------------------------
        
    }

    // If user remove budget line from change order which is auto created from code then it should be deleted ---------------
    public void DeleteBudgetLine(buildertek__Change_Order__c[] oldChangeOrder, buildertek__Change_Order__c[] updatedChangeOrder, Map<ID, buildertek__Change_Order__c> ChangeOrderMap, Map<Id, buildertek__Change_Order__c> oldChangeOrderMap){
         System.debug('Inside Delete Budget line From Sales Invoice');
         list<buildertek__Budget_Item__c> BudgetLineToDELETE = new list<buildertek__Budget_Item__c>();
         Set<Id> BudgetLineToDELETESet = new Set<Id>();
         for(buildertek__Change_Order__c co : updatedChangeOrder){
             String BlName = co.Name + ' budget line';
             if(oldChangeOrderMap.get(co.id).buildertek__Budget_Line__c != null && co.buildertek__Budget_Line__c == null){
                list<buildertek__Budget_Item__c> BLlist = [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id =: oldChangeOrderMap.get(co.id).buildertek__Budget_Line__c AND Name =: BlName LIMIT 1];
                    for(buildertek__Budget_Item__c bl : BLlist){
                        BudgetLineToDELETESet.add(bl.Id);
                        }
                    }
             }
         if(!blnSkipChangeOrderUpdateTrigger && BudgetLineToDELETESet.size() > 0){
             System.debug('Budget line Is going to Delete From Change Order');
             for(buildertek__Budget_Item__c BL : [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id IN: BudgetLineToDELETESet]){
                     BudgetLineToDELETE.add(BL);
             }
             delete BudgetLineToDELETE;
         }
    }


    public void UpdateProjectValueInChangeOrder(buildertek__Change_Order__c[] updatedChangeOrder, Map<ID, buildertek__Change_Order__c> oldChangeOrderMap){
        list<id> OldcontractIds = new list<id>();
        Map<String, Decimal> contractMap = new Map<String, Decimal>();
        for(buildertek__Change_Order__c coRec : updatedChangeOrder){
            if(oldChangeOrderMap.get(coRec.Id).buildertek__Contract__c != coRec.buildertek__Contract__c){
                OldcontractIds.add(oldChangeOrderMap.get(coRec.Id).buildertek__Contract__c);
            }    
        }
        
        if(OldcontractIds.Size()>0){
            List<buildertek__Contract__c> ContractList = [select id,Name,buildertek__Change_Order_Amount__c from buildertek__Contract__c where Id IN: OldcontractIds];
            for(buildertek__Change_Order__c coRec : updatedChangeOrder){
                for(buildertek__Contract__c contractRec : ContractList){
                    if(contractRec.id == oldChangeOrderMap.get(coRec.Id).buildertek__Contract__c){
                        contractRec.buildertek__Change_Order_Amount__c = contractRec.buildertek__Change_Order_Amount__c - oldChangeOrderMap.get(coRec.Id).buildertek__Total_Amount_Tax__c;
                    } 
                }
            }
            update ContractList;
        }
        
    }
    
    public void changeOrderBeforeUpdate(buildertek__Change_Order__c[] newChangeOrder){
        system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%');
        list<id> coIds = new list<id>();
        list<id> projectIds = new list<id>();      
        for(buildertek__Change_Order__c CORec : newChangeOrder){
            if(CORec.buildertek__Status__c == 'Customer Approved'){
                // coIds.add(CORec.Id);
                projectIds.add(CORec.buildertek__Project__c);
            }
        }
        RecordType rt;
        rt = [SELECT Id FROM RecordType WHERE sObjectType = 'buildertek__Contract__c' AND Name = 'Prime Contract'];
        list<buildertek__Project__c> scheduleListAscItems = [Select Id, Name,
                                                             (select id,Name,buildertek__Project__c,RecordTypeId
                                                              from Contracts__r where RecordTypeId =: rt.id Order by createdDate ASC LIMIT 1) FROM buildertek__Project__c WHERE Id In :projectIds];
        Map<Id, buildertek__Contract__c> contractMap = new Map<Id, buildertek__Contract__c>();
        for(buildertek__Project__c projectRec : scheduleListAscItems){
            contractMap.put(projectRec.Id,projectRec.Contracts__r );
        }
        for(buildertek__Change_Order__c corec : newChangeOrder){
            if(contractMap.containskey(corec.buildertek__Project__c) && corec.buildertek__Status__c == 'Customer Approved'){
                corec.buildertek__Customer_Accepted_Date__c = System.today();
                corec.buildertek__Contract__c  = contractMap.get(corec.buildertek__Project__c).id;
            } 
        } 
    } 
    
    public void OnAfterDelete(buildertek__Change_Order__c[] oldChangeOrder){
        
    }
    
    public void checkPOBeforeUpdate(buildertek__Change_Order__c[] coList){
        List<Id> coIds = new List<Id>();
        for(buildertek__Change_Order__c co : coList){
            if(co.buildertek__Status__c == 'Company Rejected' || co.buildertek__Status__c == 'Customer Rejected'){
                coIds.add(co.Id);
            }
        }
        List<buildertek__Purchase_Order__c> POs = [select id,buildertek__Status__c,buildertek__Change_Order__c from buildertek__Purchase_Order__c where buildertek__Change_Order__c IN :coIds AND (buildertek__Status__c = 'Order Confirmed' OR buildertek__Status__c = 'Ordered' OR buildertek__Status__c = 'Paid' OR buildertek__Status__c = 'Partially Paid')];
        System.debug('PO List ---------------------------> '+POs);
        if(POs.size() > 0){
            for(buildertek__Change_Order__c coRec : coList){
                for(buildertek__Purchase_Order__c poRec : POs){
                    if(coRec.Id == poRec.buildertek__Change_Order__c){
                        System.debug('PO Record ********************************* '+poRec);
                        System.debug('Status---------------------------------------------> '+poRec.buildertek__Status__c);
                        coRec.addError('You cannot Reject this Change Order because the Purchase Order that is associated with this Change Order has already been '+poRec.buildertek__Status__c+'.');
                    }
                }
            }
        }
    }
    
    public void checkParentPOBeforeUpdate(buildertek__Change_Order__c[] coList){
        Set<Id> POIds = new Set<Id>();
        List<buildertek__Change_Order__c> coRecordsList = new List<buildertek__Change_Order__c>();
        for(buildertek__Change_Order__c coRecord : coList){
            if(coRecord.buildertek__Status__c == 'Company Rejected' || coRecord.buildertek__Status__c == 'Customer Rejected'){
                if(coRecord.buildertek__Purchase_Order__c != null){
                    POIds.add(coRecord.buildertek__Purchase_Order__c);
                    coRecordsList.add(coRecord);
                }
            }
        }
        
        if(!POIds.isEmpty()){
            Map<Id,buildertek__Purchase_Order__c> poRecords = new Map<Id,buildertek__Purchase_Order__c>([select Id,buildertek__Status__c from buildertek__Purchase_Order__c where Id IN :POIds AND (buildertek__Status__c = 'Order Confirmed' OR buildertek__Status__c = 'Ordered' OR buildertek__Status__c = 'Paid' OR buildertek__Status__c = 'Partially Paid' OR buildertek__Status__c = 'Vendor Accepted')]);
            if(!poRecords.isEmpty()){
                for(buildertek__Change_Order__c changeOrder : coRecordsList){
                    if(poRecords.get(changeOrder.buildertek__Purchase_Order__c) != null){
                        changeOrder.addError('There is an Approved Purchase Order associated with this Change Order. In order to Reject this Change Order you have to update the Status of the Purchase Order or Contact your System Administrator.');
                    }
                }
            }
        }
    }

    public void BudgetLineUpdate(List<buildertek__Change_Order__c> newList, Map<Id,buildertek__Change_Order__c> oldMap) {
        System.debug('newList--->>>'+newList);

        set<id> COIds=new set<id>();
        for(buildertek__Change_Order__c co:newList){
            buildertek__Change_Order__c coOld=oldmap.get(co.id);
            if(co.buildertek__Budget_Line__c!=coOld.buildertek__Budget_Line__c){
                COIds.add(co.Id);
                System.debug('COIds====>>>>'+COIds);
            }
        }
        List<buildertek__Change_Order_Item__c> coLineList = [SELECT Id, Name, buildertek__Budget_Item__c FROM buildertek__Change_Order_Item__c WHERE buildertek__Change_Order__c =: COIds];
        List<CO_Item_To_Budget_Item_Link__c> COItemToBudgetItemLinks = new List<CO_Item_To_Budget_Item_Link__c>();
        System.debug('coLineList===>>>'+coLineList);
        if(coLineList.size()>0){
            map<id,buildertek__Change_Order__c> coMap=new map<id,buildertek__Change_Order__c>([select id,Name,(select id,Name from buildertek__Change_Order_Items__r) from buildertek__Change_Order__c where id in:COIds]);
            List<buildertek__CO_Item_To_Budget_Item_Link__c> BudgetCoLinkList = new List<buildertek__CO_Item_To_Budget_Item_Link__c>();

            for(buildertek__Change_Order__c coRecord: newList){
                buildertek__Change_Order__c coOld=oldmap.get(coRecord.id);

                if(coRecord.buildertek__Budget_Line__c != coOld.buildertek__Budget_Line__c && coRecord.buildertek__Budget_Line__c != null){
                    System.debug('===In If===');
                    if(coMap.containskey(coRecord.id)){
                        buildertek__Change_Order__c ac1=coMap.get(coRecord.id);
                        List<buildertek__Change_Order_Item__c> lstCo = ac1.buildertek__Change_Order_Items__r;
                        System.debug('lstCo===>>>'+lstCo);

                        for (buildertek__Change_Order_Item__c coLine : lstCo) {
                            buildertek__CO_Item_To_Budget_Item_Link__c COItemToBudgetItemLink = new buildertek__CO_Item_To_Budget_Item_Link__c();
                            COItemToBudgetItemLink.CO_Item__c = coLine.Id;
                            COItemToBudgetItemLink.Budget_Item__c = coRecord.buildertek__Budget_Line__c;
                            COItemToBudgetItemLinks.add(COItemToBudgetItemLink);
                        }
                    }
                }
            }
            insert COItemToBudgetItemLinks;
            System.debug('COItemToBudgetItemLinks--->>>'+COItemToBudgetItemLinks);
            System.debug('<<<---Inserting Successfully--->>>');
        }
    }
    
    public void UpdateDateApproved(List<buildertek__Change_Order__c> coList,  Map<ID, buildertek__Change_Order__c> oldCOMap){
        List<Id> coIds = new List<Id>();
        for(buildertek__Change_Order__c co : coList){
            if(co.buildertek__Status__c == 'Company Rejected' || co.buildertek__Status__c == 'Customer Rejected'){
                coIds.add(co.Id);
            }
        }
        
        for (buildertek__Change_Order__c sovLine : coList){
            if((sovLine.buildertek__Status__c == 'Approved' || sovLine.buildertek__Status__c == 'Customer Accepted' || sovLine.buildertek__Status__c == 'Customer Approved') && ( oldCOMap.get(sovLine.Id).buildertek__Status__c != 'Approved' || oldCOMap.get(sovLine.Id).buildertek__Status__c != 'Customer Accepted' || oldCOMap.get(sovLine.Id).buildertek__Status__c != 'Customer Approved')){
                sovLine.buildertek__Date_Approved__c = System.Now();
                sovLine.buildertek__Customer_Accepted_Date__c = Date.today();
            }
        }
        
        
    }
    
    
    public  void UpdateDateApprovedOnInsert(List<buildertek__Change_Order__c> coList){
        if(!coList.isEmpty()){
            for(buildertek__Change_Order__c sovLine : coList){
                if(sovLine.buildertek__Status__c == 'Approved' || sovLine.buildertek__Status__c == 'Customer Accepted' || sovLine.buildertek__Status__c == 'Customer Approved'){
                    sovLine.buildertek__Date_Approved__c = System.Now();
                    sovLine.buildertek__Customer_Accepted_Date__c = Date.today();
                }
            }
        }
    }

    public void ManageBudgetLineOnInsert(List<buildertek__Change_Order__c> coList){       
        if(!coList.isEmpty()){
            for(buildertek__Change_Order__c co : coList){
                //get all the CO Items along with the budget item as well as the budet on that budget item
                List<buildertek__Change_Order_Item__c> coItemList = [SELECT Id, Name, buildertek__Budget_Item__c, buildertek__Budget_Item__r.buildertek__Budget__c FROM buildertek__Change_Order_Item__c WHERE buildertek__Change_Order__c =: co.Id];
                //loop through the CO Items and check if the budget item is not null
                for(buildertek__Change_Order_Item__c coItem : coItemList){
                    if(coItem.buildertek__Budget_Item__c != null){
                        //check if the budget on that budget item is same as the budget on the CO
                        if(coItem.buildertek__Budget_Item__r.buildertek__Budget__c != co.buildertek__Budget_Line__c){
                            //update the budget item with the budget on the CO
                            coItem.buildertek__Budget_Item__r.buildertek__Budget__c = co.buildertek__Budget_Line__c;
                        }
                        //create a new CO Item to Budget Item Link
                        buildertek__CO_Item_To_Budget_Item_Link__c COItemToBudgetItemLink = new buildertek__CO_Item_To_Budget_Item_Link__c();
                        COItemToBudgetItemLink.CO_Item__c = coItem.Id;
                        COItemToBudgetItemLink.Budget_Item__c = co.buildertek__Budget_Line__c;
                        //COItemToBudgetItemLink.buildertek__Auto_Roll_Up__c = true;
                        insert COItemToBudgetItemLink;
                    }else{
                        //create a new budget item
                        buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                        budgetItem.buildertek__Budget__c = co.buildertek__Budget__c;
                        budgetItem.Name = coItem.Name;
                        budgetItem.buildertek__Group__c = 'a0g1K00000JngPyQAJ';
                        insert budgetItem;
                        //create a new CO Item to Budget Item Link
                        buildertek__CO_Item_To_Budget_Item_Link__c COItemToBudgetItemLink = new buildertek__CO_Item_To_Budget_Item_Link__c();
                        COItemToBudgetItemLink.CO_Item__c = coItem.Id;
                        COItemToBudgetItemLink.Budget_Item__c = budgetItem.Id;
                        COItemToBudgetItemLink.buildertek__Auto_Roll_Up__c = true;
                        insert COItemToBudgetItemLink;
                    }
                }
                
            }
        }

    }

   // 3336 Changes
    public  void updateBudgetLineData(buildertek__Change_Order__c[] oldChangeOrder, buildertek__Change_Order__c[] updatedChangeOrder, Map<ID, buildertek__Change_Order__c> ChangeOrderMap, Map<Id, buildertek__Change_Order__c> oldChangeOrderMap){

        Set<Id> budgetItemSet= new Set<Id>();
        Set<Id> ids = changeOrderMap.keySet();


        for(buildertek__Change_Order__c changeOrder:updatedChangeOrder){
            if(changeOrder.buildertek__Budget_Line__c!=null && oldChangeOrderMap.get(changeOrder.Id).buildertek__Budget_Line__c != changeOrder.buildertek__Budget_Line__c){
                System.debug('Inside if comndition');
                System.debug(changeOrder.buildertek__Budget_Line__c);
                budgetItemSet.add(changeOrder.buildertek__Budget_Line__c);
            }

        }
        if(!budgetItemSet.isEmpty()){
            List<buildertek__Budget_Item__c> budgetItemList = [Select Id , Name , buildertek__Unit_Price__c, buildertek__Markup__c, buildertek__Quantity__c , (Select Id , Name , buildertek__Calculated_Margin__c , buildertek__Total_Amount_Tax__c, buildertek__Total_Costs__c From Change_Orders__r Where Id=:ids) From buildertek__Budget_Item__c WHERE Id=:budgetItemSet ];
            System.debug(budgetItemList.size());
            if(budgetItemList.size() > 0){
                for(buildertek__Budget_Item__c budgetItem: budgetItemList){

                    for(buildertek__Change_Order__c changeOrder: budgetItem.Change_Orders__r){
                        System.debug(budgetItem.buildertek__Unit_Price__c);
                        System.debug(budgetItem.buildertek__Unit_Price__c);
                        System.debug(changeOrder.Name+ 'CO NAME');
                        budgetItem.buildertek__Unit_Price__c= changeOrder.buildertek__Total_Costs__c;
                       //budgetItem.buildertek__Markup__c=(changeOrder.buildertek__Calculated_Margin__c/100)/(1-(changeOrder.buildertek__Calculated_Margin__c/100))*100; 
                        budgetItem.buildertek__Markup__c = (((changeOrder.buildertek__Total_Costs__c - changeOrder.buildertek__Total_Amount_Tax__c)/changeOrder.Total_Costs__c)*100)*-1;   

                        // budgetItem.buildertek__Unit_Price__c= budgetItem.buildertek__Unit_Price__c+changeOrder.buildertek__Total_Costs__c;
                        // budgetItem.buildertek__Markup__c=budgetItem.buildertek__Markup__c+ (changeOrder.buildertek__Calculated_Margin__c/100)/(1-(changeOrder.buildertek__Calculated_Margin__c/100))*100;    
                    }
                }
                update budgetItemList;
            }

        }


       
    }


    public void UpdateContractor(buildertek__Change_Order__c[] oldChangeOrder, buildertek__Change_Order__c[] updatedChangeOrder, Map<ID, buildertek__Change_Order__c> ChangeOrderMap, Map<Id, buildertek__Change_Order__c> oldChangeOrderMap){
        try {
            System.debug('in UpdateContractor');
            SET<Id> changeOrderContractIdSet = new SET<Id>();            
            Map<String, Decimal> contractMap = new Map<String, Decimal>();
            List<buildertek__Contract__c> contractToUpdateList = new List<buildertek__Contract__c>();
            List<buildertek__Change_Order__c> changeOrdersList;

            for(buildertek__Change_Order__c changeOrder : updatedChangeOrder){
                if(changeOrder.buildertek__Contract__c !=null){
                    changeOrderContractIdSet.add(changeOrder.buildertek__Contract__c);
                }  
            }
            System.debug('changeOrderContractIdSet'+changeOrderContractIdSet);

            List<String> desiredStatuses = new List<String>{
                'Customer Accepted', 
                'Customer Approved', 
                'Company Accepted', 
                'Company Approved', 
                'Accepted', 
                'Approved'
            };
            
            changeOrdersList = [SELECT Id, Name, buildertek__Contract__c, buildertek__Total_Amount_Tax__c FROM buildertek__Change_Order__c WHERE buildertek__Contract__c IN: changeOrderContractIdSet AND buildertek__Status__c IN: desiredStatuses];
            system.debug('ChangeOrderList.....>' +changeOrdersList);
            
            if(changeOrdersList.size() >  0){
                for(buildertek__Change_Order__c changeOrders : changeOrdersList){
                    if(contractMap.get(changeOrders.buildertek__Contract__c) == null){
                        contractMap.put(changeOrders.buildertek__Contract__c, changeOrders.buildertek__Total_Amount_Tax__c);    
                    }else{
                        decimal finalTotalAmount = contractMap.get(changeOrders.buildertek__Contract__c) + changeOrders.buildertek__Total_Amount_Tax__c; 
                        contractMap.put(changeOrders.buildertek__Contract__c, finalTotalAmount);
                    }
                }
            } else {
                for(String cont : changeOrderContractIdSet){
                    decimal finalTotalAmount = 0; 
                    contractMap.put(cont, finalTotalAmount);
                }
            }
            system.debug('Contract Map ---------> '+contractMap.keySet());

            for(String contractId : contractMap.keySet()){
                system.debug('contractId ---------> '+contractId);
                buildertek__Contract__c contractToUpdate = new buildertek__Contract__c();
                contractToUpdate.Id = contractId;
                system.debug('CO Amount --------->'+contractMap.get(contractId));
                contractToUpdate.buildertek__Change_Order_Amount__c = contractMap.get(contractId);
                contractToUpdateList.add(contractToUpdate);
            }                      
            system.debug('contractToUpdateList --------------> '+contractToUpdateList);
            
            if(contractToUpdateList.size() > 0){
                update contractToUpdateList;    
            } 
            
        } catch (Exception e) {
            System.debug('Exception occurred at line ' + e.getLineNumber() + ': ' + e.getMessage());
        }
    }

    // 3 methods for Ticket BUIL-3685 for total sales price field insert,update,delete rollup
    public void AfterInsertRollup(buildertek__Change_Order__c[] newChangeOrder, Map<ID, buildertek__Change_Order__c> newChangeOrderMap){
        try {
            List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
            Set<Id> prId = new Set<Id>();
            List<buildertek__Change_Order__c> COList = new List<buildertek__Change_Order__c>();

            for(buildertek__Change_Order__c co : newChangeOrder){
                if(co.buildertek__Status__c != 'Pending' && co.buildertek__Status__c != 'Company Rejected' && co.buildertek__Status__c != 'Customer Rejected' && co.buildertek__Project__c != null){
                    prId.add(co.buildertek__Project__c);
                }
            }
            System.debug('prid ==> ' + prId);

            COList = [SELECT Id,buildertek__Project__c,buildertek__Total_Amount_Tax__c FROM buildertek__Change_Order__c WHERE buildertek__Project__c IN :prId];
            System.debug('COList ==> ' + COList);

            for(buildertek__Project__c bpr : [SELECT Id,buildertek__Total_Change_Orders__c FROM buildertek__Project__c WHERE Id IN :prId]){
                bpr.buildertek__Total_Change_Orders__c = 0;
                for(buildertek__Change_Order__c bco : COList){
                    bpr.buildertek__Total_Change_Orders__c += bco.buildertek__Total_Amount_Tax__c;
                }
                projectList.add(bpr);
            }

            System.debug('projectList ==> '+projectList);
            if(projectList.size() > 0){
                upsert projectList;
            }
        } catch (Exception e) {
            System.debug('Exception in AfterInsertRollup ==> ' + e.getMessage());
            System.debug('Line ==> ' + e.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
        }
    }

    public void AfterUpdateRollup(buildertek__Change_Order__c[] oldChangeOrder, buildertek__Change_Order__c[] updatedChangeOrder, Map<ID, buildertek__Change_Order__c> ChangeOrderMap, Map<Id, buildertek__Change_Order__c> oldChangeOrderMap){
        try {
            List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
            Set<Id> newprId = new Set<Id>();
            Set<Id> oldprId = new Set<Id>();
            List<buildertek__Change_Order__c> newCOList = new List<buildertek__Change_Order__c>();
            List<buildertek__Change_Order__c> oldCOList = new List<buildertek__Change_Order__c>();
            
            // to update old 
            for(buildertek__Change_Order__c oldCO : oldChangeOrder){
                buildertek__Change_Order__c newCO = ChangeOrderMap.get(oldCO.Id);
                if(oldCO.buildertek__Project__c != newCO.buildertek__Project__c){
                    oldprId.add(oldCO.buildertek__Project__c);
                }
            }
            System.debug('update old newprId ==> ' + oldprId);
            if(oldprId.size() > 0){
                oldCOList = [SELECT Id,buildertek__Project__c,buildertek__Total_Amount_Tax__c FROM buildertek__Change_Order__c WHERE buildertek__Project__c IN :oldprId AND buildertek__Status__c NOT IN ('Pending','Company Rejected','Customer Rejected')];
            }
            System.debug('oldCOList ==> '+oldCOList);
            for(buildertek__Project__c bpr : [SELECT Id,buildertek__Total_Change_Orders__c FROM buildertek__Project__c WHERE Id IN :oldprId]){
                bpr.buildertek__Total_Change_Orders__c = 0;
                for(buildertek__Change_Order__c bco : oldCOList){
                    bpr.buildertek__Total_Change_Orders__c += bco.buildertek__Total_Amount_Tax__c;
                }
                projectList.add(bpr);
            }

            // to update new
            for(buildertek__Change_Order__c co : updatedChangeOrder){
                newprId.add(co.buildertek__Project__c);
            }
            System.debug('update new newprId ==> ' + newprId);
            if(newprId.size() > 0){
                newCOList = [SELECT Id,buildertek__Project__c,buildertek__Total_Amount_Tax__c FROM buildertek__Change_Order__c WHERE buildertek__Project__c IN :newprId AND buildertek__Status__c NOT IN ('Pending','Company Rejected','Customer Rejected')];
            }
            System.debug('newCOList ==> '+newCOList);
            for(buildertek__Project__c bpr : [SELECT Id,buildertek__Total_Change_Orders__c FROM buildertek__Project__c WHERE Id IN :newprId]){
                bpr.buildertek__Total_Change_Orders__c = 0;
                for(buildertek__Change_Order__c bco : newCOList){
                    bpr.buildertek__Total_Change_Orders__c += bco.buildertek__Total_Amount_Tax__c;
                }
                projectList.add(bpr);
            }

            System.debug('projectlist ==> '+projectList);
            if(projectList.size() > 0){
                upsert projectList;
            }
        } catch (Exception e) {
            System.debug('Exception in UpdateInsertRollup ==> ' + e.getMessage());
            System.debug('Line ==> ' + e.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
        }
    }

    public void AfterDeleteRollup(buildertek__Change_Order__c[] oldChangeOrder){
        try {
            
            List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
            Set<Id> prId = new Set<Id>();
            List<buildertek__Change_Order__c> COList = new List<buildertek__Change_Order__c>();

            for(buildertek__Change_Order__c co : oldChangeOrder){
                if(co.buildertek__Status__c != 'Pending' && co.buildertek__Status__c != 'Company Rejected' && co.buildertek__Status__c != 'Customer Rejected'){
                    prId.add(co.buildertek__Project__c);
                }
            }
            System.debug('prId ==> ' + prId);

            COList = [SELECT Id,buildertek__Project__c,buildertek__Total_Amount_Tax__c FROM buildertek__Change_Order__c WHERE buildertek__Project__c IN :prId];
            System.debug('CoList ==> '+COList);
            
            for(buildertek__Project__c bpr : [SELECT Id,buildertek__Total_Change_Orders__c FROM buildertek__Project__c WHERE Id IN :prId]){
                bpr.buildertek__Total_Change_Orders__c = 0;
                for(buildertek__Change_Order__c bco : COList){
                    bpr.buildertek__Total_Change_Orders__c += bco.buildertek__Total_Amount_Tax__c;
                }
                projectList.add(bpr);
            }
            
            System.debug('projectList ==> '+projectList);
            if(projectList.size() > 0){
                update projectList;
            }
        } catch (Exception e) {
            System.debug('Exception in deleteInsertRollup ==> ' + e.getMessage());
            System.debug('Line ==> ' + e.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
        }
    }

}