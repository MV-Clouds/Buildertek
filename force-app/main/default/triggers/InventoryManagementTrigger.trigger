trigger InventoryManagementTrigger on Inventory_Management__c (before insert,before update) {
    InventoryManagementHandler.UniqueProductId(Trigger.oldMap,Trigger.New);
}