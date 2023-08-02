trigger Acct_Hierarchy_Maintenance on Account (Before Insert, Before Update, After Update, Before Delete) 
{
    // v.2 - Adds code to handle "inheritance" of Account Tier
    //
    
    if (trigger.isBefore && trigger.isInsert)
    {
        if (!RecursionControl.isRecursive)
        {
            set<Id> parentIds = new set<Id>();
            for(Account newAcct: trigger.new)
            {
                if(newAcct.parentId != null)
                {
                    parentIds.add(newAcct.parentId);
                }
            }
            if (parentIds.size() > 0)
            {
                Map<Id,Account> reportingParentMap = new Map<Id, Account>();
                // v.2 - Adds Account Tier to selected parent columns
                for (Account parentAcct : [SELECT Id, Reporting_Parent__c, Account_Tier__c from Account where Id in :parentIds])
                {
                    reportingParentMap.put(parentAcct.Id, parentAcct);
                }
                if(reportingParentMap.size() > 0)
                {
                    for (Account acct: trigger.new)
                    {
                        // v.2 - Set Account Tier to parents Account Tier
                        acct.Account_Tier__c = reportingParentMap.get(acct.ParentId).Account_Tier__c;
                        if(reportingParentMap.containsKey(acct.ParentID))
                        {
                            if (reportingParentMap.get(acct.ParentId).Reporting_Parent__c != null)
                            {
                                acct.Reporting_Parent__c = reportingParentMap.get(acct.ParentId).Reporting_Parent__c;
                            }
                            else
                            {
                                acct.Reporting_Parent__c = acct.ParentId;
                            }
                            // v2. - Added inheritance of Account Tier
                            if (reportingParentMap.get(acct.ParentId).Account_Tier__c != null)
                            {
                                acct.Account_Tier__c = reportingParentMap.get(acct.ParentId).Account_Tier__c;
                            }
                            else
                            {
                                acct.Reporting_Parent__c = null;
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    if (trigger.isBefore && trigger.isUpdate)
    {
        System.debug('** On beforeUpdate entry isRecursive = ' + String.valueOf(RecursionControl.isRecursive));
        Boolean parentChanged = false;
        if (!RecursionControl.isRecursive)
        {
            set<Id> parentIds = new set<Id>();
            for(Account newAcct: trigger.new)
            {
                if(newAcct.parentId != trigger.oldMap.get(newAcct.Id).ParentId) // Re-parented
                {
                    if (newAcct.ParentId == null)
                    {
                        newAcct.Reporting_Parent__c = null;
                    }
                    else                    
                    {
                        parentIds.add(newAcct.ParentId);
                    }
                }
                else
                {
                    // v.2 - Added code to prevent manual override of inherited attributes if the Account is still parented
                    if (newAcct.ParentId != null)
                    {
                        if(newAcct.Reporting_Parent__c != trigger.oldMap.get(newAcct.Id).Reporting_Parent__c)   
                        {
                            newAcct.addError('** Error: Reporting Account is inherited from the Parent Account; you are not allowed to change it.');
                        }
                        if(newAcct.Account_Tier__c != trigger.oldMap.get(newAcct.Id).Account_Tier__c)   
                        {
                            newAcct.addError('** Error: Account Tier is inherited from the Parent Account; you are not allowed to change it.');
                        }
                    }
                }
                
            }
            if (parentIds.size() > 0)
            {
                Map<Id,Account> reportingParentMap = new Map<Id, Account>();
                for (Account parentAcct : [SELECT Id, Reporting_Parent__c, Account_Tier__c from Account where Id in :parentIds])
                {
                    reportingParentMap.put(parentAcct.Id, parentAcct);  
                }
                if(reportingParentMap.size() > 0)
                
                {
                    for (Account acct: trigger.new)
                    {
                        if(reportingParentMap.containsKey(acct.ParentID)) // Reparented
                        {
                            // v.2 - Added line to inherit account tier
                            acct.Account_Tier__c = reportingParentMap.get(acct.ParentId).Account_Tier__c;                           
                            if (reportingParentMap.get(acct.ParentId).Reporting_Parent__c != null)
                            {
                                acct.Reporting_Parent__c = reportingParentMap.get(acct.ParentId).Reporting_Parent__c;
                            }
                            else
                            {
                                acct.Reporting_Parent__c = acct.parentId;
                            }
                        }
                    }
                }
            }
        }   
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        System.debug('** On afterUpdate entry isRecursive = ' + String.valueOf(RecursionControl.isRecursive));
        if (!RecursionControl.isRecursive)
        {       
            RecursionControl.isRecursive = true;    
            System.debug('** After afterUpdate check isRecursive = ' + String.valueOf(RecursionControl.isRecursive));
            List<Account> acctParentChanges = new List<Account>();      
            for(Account newAcct: trigger.new)
            {
                if (newAcct.parentID != trigger.oldMap.get(newAcct.Id).parentID ||
                    newAcct.Reporting_Parent__c != trigger.oldMap.get(newAcct.Id).Reporting_Parent__c ||
                    newAcct.Account_Tier__c != trigger.oldMap.get(newAcct.Id).Account_Tier__c) // Added this line to cascade Account Tier to children
                {
                    acctParentChanges.add(newAcct);
                }
            }
            if (acctParentChanges.size() > 0)
            {
                List<Account> updatedChildTree = AcctTriggerHelper.updateChildTree(acctParentChanges, false);
                update updatedChildTree;
            }
            RecursionControl.isRecursive = false;   
        }   
    }

    if (trigger.isBefore && trigger.isDelete)
    {
        List<Account> acctParentDeletes = new List<Account>();
        RecursionControl.isRecursive = true;
        System.debug('** On beforeDelete entry isRecursive set to ' + String.valueOf(RecursionControl.isRecursive));
        for (Account delAcct : trigger.old)
        {
                acctParentDeletes.add(delAcct);
        }
        if (acctParentDeletes.size() > 0)
        {
            List<Account> updatedChildTree = AcctTriggerHelper.updateChildTree(acctParentDeletes,true);
            update updatedChildTree;
        }
        RecursionControl.isRecursive = false;
    }   
}