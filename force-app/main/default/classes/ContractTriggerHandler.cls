/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved.

Developed By: Sagar
Date:  20-Sep-2017
*/
public without sharing class ContractTriggerHandler{
    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipContractUpdateTrigger = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public ContractTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(Contract__c[] newContracts){
        List<buildertek__Contract__c> contractList;
        if (Schema.sObjectType.buildertek__Contract__c.fields.id.isAccessible() && Schema.sObjectType.buildertek__Contract__c.fields.Auto_Number1__c.isAccessible() && Schema.sObjectType.buildertek__Contract__c.fields.Project__c.isAccessible() && Schema.sObjectType.buildertek__Contract__c.fields.CREATEDDATE.isAccessible()){
            
            contractList = [Select Id, buildertek__Auto_Number1__c
                            from buildertek__Contract__c
                            where Project__c = :newContracts[0].Project__c
                            ORDER BY CREATEDDATE DESC
                            LIMIT 1];
            system.debug('contractList -------> ' + contractList);
            
        }
        if (!Test.isRunningTest()){
            BT_Utils.genrateAutoNumber(contractList, newContracts, 'Auto_Number1__c');
        }
    }
    
    public void OnBeforeUpdate(Contract__c[] oldContracts, Contract__c[] updatedContracts, Map<ID, Contract__c> ContractMap){
    }
    
    public void OnBeforeDelete(Contract__c[] ContractToDelete, Map<ID, Contract__c> ContractMap){
        for (buildertek__Contract__c cont : ContractToDelete){
            if (cont.buildertek__Status__c == 'Accepted' || cont.buildertek__Status__c == 'Approved' || cont.buildertek__Status__c == 'Out for Bid' || cont.buildertek__Status__c == 'Out for Signature'){
                cont.adderror('You Cannot be deleted this Contract.Because it has already been ' + cont.buildertek__Status__c);
                
            }
        }
    }
    
    public void OnAfterInsert(Contract__c[] newContracts, Map<ID, Contract__c> newContractsMap){
        SET<Id> projectIds = new SET<Id>();
        RecordType rt;
        // if(Schema.sObjectType.RecordType.fields.id.isAccessible() && Schema.sObjectType.RecordType.fields.Name.isAccessible() && Schema.sObjectType.RecordType.fields.sObjectType.isAccessible()){
        
        rt = [SELECT Id, Name
              FROM RecordType
              WHERE sObjectType = 'buildertek__Contract__c' AND Name = 'Prime Contract'];
        // }
        Map<String, Decimal> contractAmountMap = new Map<String, Decimal>();
        Map<String, Decimal> projectContractAmountMap = new Map<String, Decimal>();
        List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
        for (buildertek__Contract__c cont : newContracts){
            projectIds.add(cont.buildertek__Project__c);
        }
        if (projectIds.size() > 0){
            List<buildertek__Project__c> projectDetails;
            // if(Schema.sObjectType.buildertek__Project__c.fields.id.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Contract_Amount__c.isAccessible()){
            projectDetails = [SELECT Id, buildertek__Contract_Amount__c
                              FROM buildertek__Project__c
                              WHERE Id IN :projectIds];
            // }
            for (buildertek__Project__c proj : projectDetails){
                projectContractAmountMap.put(proj.Id, proj.buildertek__Contract_Amount__c);
            }
        }
        for (buildertek__Contract__c cont : newContracts){
            if (cont.RecordTypeId == rt.Id && cont.buildertek__Status__c == 'Approved' && cont.buildertek__Project__c != null){
                system.debug('&&&&&&&&&&&&&&&&&&&'+cont.buildertek__Status__c);
                if (projectContractAmountMap.get(cont.buildertek__Project__c) == null){
                    contractAmountMap.put(cont.Id, cont.buildertek__Revised_Contract_Amount__c);
                } else{
                    decimal finalTotalAmount = projectContractAmountMap.get(cont.buildertek__Project__c)+cont.buildertek__Revised_Contract_Amount__c;
                    contractAmountMap.put(cont.Id, finalTotalAmount);
                }
                buildertek__Project__c proj = new buildertek__Project__c();
                proj.Id = cont.buildertek__Project__c;
                proj.buildertek__Contract_Amount__c = contractAmountMap.get(cont.Id);
                projectList.add(proj);
            }
        }
        if (projectList.size() > 0){
            // if(Schema.sObjectType.buildertek__Project__c.fields.id.isUpdateable() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Contract_Amount__c.isUpdateable()){
            
            update projectList;
            // }
        }
    }
    
    public void OnAfterUpdate(Contract__c[] oldContracts, Contract__c[] updatedContracts, Map<ID, Contract__c> ContractMap, Map<Id, Contract__c> oldContractsMap){
        system.debug('afterUpdate');
        SET<Id> projectIds = new SET<Id>();
        RecordType rt;
        if (Schema.sObjectType.RecordType.fields.id.isAccessible() && Schema.sObjectType.RecordType.fields.Name.isAccessible() && Schema.sObjectType.RecordType.fields.sObjectType.isAccessible()){
            rt = [SELECT Id
                  FROM RecordType
                  WHERE sObjectType = 'buildertek__Contract__c' AND Name = 'Prime Contract'];
        }
        Map<String, Decimal> contractAmountMap = new Map<String, Decimal>();
        Map<String, Decimal> projectContractAmountMap = new Map<String, Decimal>();
        List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
        for (buildertek__Contract__c cont : updatedContracts){
            projectIds.add(cont.buildertek__Project__c);
        }
        if (projectIds.size() > 0){
            List<buildertek__Project__c> projectDetails;
            projectDetails = [SELECT Id, buildertek__Contract_Amount__c
                              FROM buildertek__Project__c
                              WHERE Id IN :projectIds];
            system.debug('projectDetails--->' + projectDetails);
            for (buildertek__Project__c proj : projectDetails){
                system.debug('projectDetailsamount--->' + proj.buildertek__Contract_Amount__c);
                projectContractAmountMap.put(proj.Id, proj.buildertek__Contract_Amount__c);
            }
        }
        for (buildertek__Contract__c cont : updatedContracts){
            if (cont.RecordTypeId == rt.Id && cont.buildertek__Status__c == 'Approved' && cont.buildertek__Project__c != null && oldContractsMap.get(cont.Id).buildertek__Status__c != cont.buildertek__Status__c){
                system.debug('%%%%%%%%%%%%%%%%%%%%%----->'+cont.buildertek__Status__c);
                
                if (projectContractAmountMap.get(cont.buildertek__Project__c) == null){
                    contractAmountMap.put(cont.Id, cont.buildertek__Revised_Contract_Amount__c);
                } else{
                    decimal finalTotalAmount = projectContractAmountMap.get(cont.buildertek__Project__c)+cont.buildertek__Revised_Contract_Amount__c;
                    contractAmountMap.put(cont.Id, finalTotalAmount);
                }
                buildertek__Project__c proj = new buildertek__Project__c();
                proj.Id = cont.buildertek__Project__c;
                proj.buildertek__Contract_Amount__c = contractAmountMap.get(cont.Id);
                projectList.add(proj);
            } else if (cont.RecordTypeId == rt.Id && oldContractsMap.get(cont.Id).buildertek__Status__c == 'Approved' && cont.buildertek__Status__c != 'Approved'){
                if (projectContractAmountMap.get(cont.buildertek__Project__c) != null){
                    decimal finalTotalAmount = projectContractAmountMap.get(cont.buildertek__Project__c)-cont.buildertek__Revised_Contract_Amount__c;
                    buildertek__Project__c proj = new buildertek__Project__c();
                    proj.Id = cont.buildertek__Project__c;
                    proj.buildertek__Contract_Amount__c = finalTotalAmount;
                    projectList.add(proj);
                }
            } else if (cont.RecordTypeId == rt.Id && oldContractsMap.get(cont.Id).buildertek__Status__c == cont.buildertek__Status__c && cont.buildertek__Status__c == 'Approved' && oldContractsMap.get(cont.Id).buildertek__Revised_Contract_Amount__c != cont.buildertek__Revised_Contract_Amount__c){
                if (projectContractAmountMap.get(cont.buildertek__Project__c) != null){
                    decimal finalTotalAmount = projectContractAmountMap.get(cont.buildertek__Project__c)-oldContractsMap.get(cont.Id).buildertek__Revised_Contract_Amount__c;
                    finalTotalAmount = finalTotalAmount + cont.buildertek__Revised_Contract_Amount__c;
                    buildertek__Project__c proj = new buildertek__Project__c();
                    proj.Id = cont.buildertek__Project__c;
                    proj.buildertek__Contract_Amount__c = finalTotalAmount;
                    projectList.add(proj);
                }
            }
        }
        if (projectList.size() > 0){
            update projectList;
            
        }
    }
    
    public void OnBeforeUpdate(Contract__c[] newContracts, Map<ID, Contract__c> newContractsMap){
    }
    
    public void OnAfterDelete(Contract__c[] oldContracts){
        SET<Id> projectIds = new SET<Id>();
        RecordType rt;
        Map<String, Decimal> contractAmountMap = new Map<String, Decimal>();
        Map<String, Decimal> projectContractAmountMap = new Map<String, Decimal>();
        rt = [SELECT Id
              FROM RecordType
              WHERE sObjectType = 'buildertek__Contract__c' AND Name = 'Prime Contract'];
        List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
        for (buildertek__Contract__c cont : oldContracts){
            projectIds.add(cont.buildertek__Project__c);
        }
        if (projectIds.size() > 0){
            List<buildertek__Project__c> projectDetails;
            // if(Schema.sObjectType.buildertek__Project__c.fields.id.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Contract_Amount__c.isAccessible()){
            projectDetails = [SELECT Id, buildertek__Contract_Amount__c
                              FROM buildertek__Project__c
                              WHERE Id IN :projectIds];
            // }
            for (buildertek__Project__c proj : projectDetails){
                projectContractAmountMap.put(proj.Id, proj.buildertek__Contract_Amount__c);
            }
        }
        /*Commented because not used - 07-06-2021*/
       /* for (buildertek__Contract__c cont : oldContracts){
            if (cont.buildertek__Project__c != null){
                decimal finalTotalAmount = projectContractAmountMap.get(cont.buildertek__Project__c)-cont.buildertek__Revised_Contract_Amount__c != null ? cont.buildertek__Revised_Contract_Amount__c : 0;
                contractAmountMap.put(cont.Id, finalTotalAmount);
            }
        }*/
        if (projectList.size() > 0){
            update projectList;
        }
    }
    
    
    public void AfterUpdateRSalesPrice(Contract__c[] newContracts){
                    decimal amount = 0;
            for (buildertek__Contract__c co : newContracts){
                
                if(co.buildertek__Budget__c != null){
                     buildertek__Budget__c po = [SELECT Id, buildertek__Project_Sales_Price__c,buildertek__Sales_Price__c,buildertek__Current_Contract_Amount__c  FROM buildertek__Budget__c WHERE Id = :co.buildertek__Budget__c];
                
                List<buildertek__Contract__c> l_co = [SELECT Id, buildertek__Revised_Contract_Amount__c FROM buildertek__Contract__c WHERE buildertek__Budget__c = :po.Id];
                for(buildertek__Contract__c am_co : l_co) {
                    amount = am_co.buildertek__Revised_Contract_Amount__c;  
                }
                po.buildertek__Project_Sales_Price__c = amount;
                    po.buildertek__Current_Contract_Amount__c = amount;
                update po;
                
                }
               
                
            }
            
        }
      
    
   
    
    
    
}