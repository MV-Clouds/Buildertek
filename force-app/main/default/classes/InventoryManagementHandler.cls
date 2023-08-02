public class InventoryManagementHandler{
    public static void UniqueProductId(Map<Id,Inventory_Management__c> oldMap,List<Inventory_Management__c> lstIM){
        for(Inventory_Management__c objIM : lstIM){
            if(oldMap != null){
                if(oldMap.get(objIM.Id).Product_Name__c != objIM.Product_Name__c){
                    objIM.Product_Id__c = objIM.Product_Name__c;
                }
            }
            else{
                objIM.Product_Id__c = objIM.Product_Name__c;
            }
        }
    }
}