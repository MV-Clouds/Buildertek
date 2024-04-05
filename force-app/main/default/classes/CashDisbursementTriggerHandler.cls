public with sharing class CashDisbursementTriggerHandler {
    public static Boolean isSkipExecution = false;

    public void onBeforeInsert(List<buildertek__Payment__c> newcashDisbursement, Map<Id, buildertek__Payment__c> newcashDisbursementMap){
        String budgetLineGroupId ;
        
        List<buildertek__Budget_Line_Group__c> budgetLineGroups = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'No Grouping' LIMIT 1];
        
        if(budgetLineGroups.size() == 0){
            buildertek__Budget_Line_Group__c budgetLineGroup = new buildertek__Budget_Line_Group__c();
            budgetLineGroup.Name = 'No Grouping';
            insert budgetLineGroup;
            budgetLineGroupId = budgetLineGroup.Id;
        } else{
            budgetLineGroupId = budgetLineGroups[0].Id;
        }
        
        System.debug('budgetLineGroupId: ' + budgetLineGroupId);

        List<buildertek__Budget_Item__c> toInsertBudgetItems = new List<buildertek__Budget_Item__c>();
        for(buildertek__Payment__c CD : newcashDisbursement){
            //if budget line is null and budget is not null
            if(CD.buildertek__BT_Budget__c != null && CD.buildertek__BT_Budget_Line__c == null){
                buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                budgetItem.Name = CD.Name;
                budgetItem.buildertek__Budget__c = CD.buildertek__BT_Budget__c;
                budgetItem.buildertek__Group__c = budgetLineGroupId;
                budgetItem.buildertek__Contractor_Invoice_Payments__c = CD.buildertek__Payment_Amount__c;
                toInsertBudgetItems.add(budgetItem);
            }
        }

        if(toInsertBudgetItems.size() > 0){
            insert toInsertBudgetItems;
        }

        for(buildertek__Payment__c CD : newcashDisbursement){
            if(CD.buildertek__BT_Budget__c != null && CD.buildertek__BT_Budget_Line__c != null){
                for(buildertek__Budget_Item__c budgetItem : toInsertBudgetItems){
                    if(budgetItem.buildertek__Budget__c == CD.buildertek__BT_Budget__c && budgetItem.Name == CD.Name){
                        CD.buildertek__BT_Budget_Line__c = budgetItem.Id;
                    }
                }
            }
        }
    }

    public void onBeforeUpdate(List<buildertek__Payment__c> newCashDisbursement, Map<Id, buildertek__Payment__c> oldCashDisbursementMap){
        String budgetLineGroupId ;
        List<buildertek__Budget_Line_Group__c> budgetLineGroups = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'No Grouping' LIMIT 1];
        if(budgetLineGroups.size() == 0){
            buildertek__Budget_Line_Group__c budgetLineGroup = new buildertek__Budget_Line_Group__c();
            budgetLineGroup.Name = 'No Grouping';
            insert budgetLineGroup;
            budgetLineGroupId = budgetLineGroup.Id;
        } else{
            budgetLineGroupId = budgetLineGroups[0].Id;
        }

        List<buildertek__Budget_Item__c> toInsertBudgetItems = new List<buildertek__Budget_Item__c>();
        for(buildertek__Payment__c CD : newCashDisbursement){
            if(CD.buildertek__BT_Budget__c != null && CD.buildertek__BT_Budget_Line__c == null){
                buildertek__Payment__c oldCashDisbursement = oldCashDisbursementMap.get(CD.Id);
                if(oldCashDisbursement != null && oldCashDisbursement.buildertek__BT_Budget__c == null){
                    buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                    budgetItem.Name = CD.Name;
                    budgetItem.buildertek__Budget__c = CD.buildertek__BT_Budget__c;
                    budgetItem.buildertek__Group__c = budgetLineGroupId;
                    budgetItem.buildertek__Contractor_Invoice_Payments__c = CD.buildertek__Payment_Amount__c;
                    toInsertBudgetItems.add(budgetItem);
                }
            }
        }

        if(toInsertBudgetItems.size() > 0){
            insert toInsertBudgetItems;
        }

        for(buildertek__Payment__c CD : newCashDisbursement){
            if(CD.buildertek__BT_Budget__c != null && CD.buildertek__BT_Budget_Line__c == null){
                for(buildertek__Budget_Item__c budgetItem : toInsertBudgetItems){
                    if(budgetItem.buildertek__Budget__c == CD.buildertek__BT_Budget__c && budgetItem.Name == CD.Name){
                        CD.buildertek__BT_Budget_Line__c = budgetItem.Id;
                    }
                }
            }
        }

        Map<Id, buildertek__Payment__c> toDeleteBudgetItems = new Map<Id, buildertek__Payment__c>();
        for(buildertek__Payment__c CD : newCashDisbursement){
            buildertek__Payment__c oldCashDisbursement = oldCashDisbursementMap.get(CD.Id);
            if(oldCashDisbursement != null && oldCashDisbursement.buildertek__BT_Budget_Line__c != null && CD.buildertek__BT_Budget_Line__c != oldCashDisbursement.buildertek__BT_Budget_Line__c){
                CD.buildertek__BT_Budget__c = null;
                toDeleteBudgetItems.put(oldCashDisbursement.buildertek__BT_Budget_Line__c, oldCashDisbursement);
            }
        }

        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id IN: toDeleteBudgetItems.keySet()];
            List<buildertek__Budget_Item__c> toDeleteBudgetLine = new List<buildertek__Budget_Item__c>();

            for(buildertek__Budget_Item__c budgetItem : toDeleteBudgetItemsList){
                if(toDeleteBudgetItems.get(budgetItem.Id).Name == budgetItem.Name){
                    toDeleteBudgetLine.add(budgetItem);
                    toDeleteBudgetItems.remove(budgetItem.Id);
                }
            }

            if(toDeleteBudgetLine.size() > 0 && isSkipExecution == false){
                BudgetItemTriggerHandler.blnSkipBudgetItemTrigger = true;
                delete toDeleteBudgetLine;
                BudgetItemTriggerHandler.blnSkipBudgetItemTrigger = false;
            }
        }

        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name, buildertek__Contractor_Invoice_Payments__c FROM buildertek__Budget_Item__c WHERE Id IN: toDeleteBudgetItems.keySet()];
            for(buildertek__Budget_Item__c budgetItem : toDeleteBudgetItemsList){
                budgetItem.buildertek__Contractor_Invoice_Payments__c -= toDeleteBudgetItems.get(budgetItem.Id).buildertek__Total_Amount__c;
            }
            update toDeleteBudgetItemsList;
        }
    }

    public void onBeforeDelete(List<buildertek__Payment__c> oldCashDisbursement, Map<Id, buildertek__Payment__c> oldCashDisbursementMap){
        
        Map<Id, buildertek__Payment__c> toDeleteBudgetItems = new Map<Id, buildertek__Payment__c>();
        for(buildertek__Payment__c CD : oldCashDisbursement){
            if(CD.buildertek__BT_Budget_Line__c != null){
                toDeleteBudgetItems.put(CD.buildertek__BT_Budget_Line__c, CD);
            }
        }

        if (toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id IN: toDeleteBudgetItems.keySet()];
            List<buildertek__Budget_Item__c> toDeleteBudgetLine = new List<buildertek__Budget_Item__c>();

            for(buildertek__Budget_Item__c budgetItem : toDeleteBudgetItemsList){
                if(toDeleteBudgetItems.get(budgetItem.Id).Name == budgetItem.Name){
                    toDeleteBudgetLine.add(budgetItem);
                    toDeleteBudgetItems.remove(budgetItem.Id);
                }
            }

            if (toDeleteBudgetItems.size() > 0){
                delete toDeleteBudgetItemsList;
            }

            if(toDeleteBudgetLine.size() > 0){
                List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name, buildertek__Contractor_Invoice_Payments__c FROM buildertek__Budget_Item__c WHERE Id IN: toDeleteBudgetItems.keySet()];
                for(buildertek__Budget_Item__c budgetItem : toDeleteBudgetItemsList){
                    budgetItem.buildertek__Contractor_Invoice_Payments__c -= toDeleteBudgetItems.get(budgetItem.Id).buildertek__Total_Amount__c;
                }
                update toDeleteBudgetItemsList;
            }
        }
    }

}