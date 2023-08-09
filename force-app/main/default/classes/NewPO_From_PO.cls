public with sharing class NewPO_From_PO {
    //get the PO Lines
    @AuraEnabled
    public static List<buildertek__Purchase_Order_Item__c> getPOLines(String recordId) {
        List<buildertek__Purchase_Order_Item__c> POLines = [SELECT Id,Name,buildertek__Quantity__c,buildertek__Unit_Price__c,buildertek__Tax__c,buildertek__Purchase_Order__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c =: recordId];
        System.debug('POLines---->>>'+POLines);
        return POLines;
    }

    //Create New PO from the selected PO Line
    @AuraEnabled
    public static String createNewPo(String recordId, List<buildertek__Purchase_Order_Item__c> POLineList) {
        Map<ID, buildertek__Purchase_Order_Item__c> POLineMap = new Map<ID, buildertek__Purchase_Order_Item__c>([SELECT Id, buildertek__Quantity__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c =: recordId]);
        boolean isChecked = true;
        String msg = '';

        for (buildertek__Purchase_Order_Item__c POLine : POLineList) {
            if(POLineMap.get(POLine.Id).buildertek__Quantity__c < POLine.buildertek__Quantity__c){
                isChecked = false;
                    msg = 'You can not enter a Quantity greater than the old Quantity. Please enter a Quantity that is equal to or less than the original Quantity.';
                    System.debug('IF False');
                    System.debug(msg);
                }
        }
        if(isChecked){
            System.debug('IF True');
            buildertek__Purchase_Order__c po = [SELECT Id, Name, buildertek__Vendor__c, buildertek__Project__c FROM buildertek__Purchase_Order__c WHERE Id =: recordId];
            buildertek__Purchase_Order__c newPO = new buildertek__Purchase_Order__c();
            newPO.buildertek__Vendor__c = po.buildertek__Vendor__c;
            newPO.buildertek__Status__c = 'Open';
            newPO.buildertek__Type__c = 'Material';            
            newPO.buildertek__Project__c = po.buildertek__Project__c;
            newPO.buildertek__Old_Purchase_Order__c = po.Id;
            insert newPO;

            List<buildertek__Purchase_Order_Item__c> deletePolineList = new List<buildertek__Purchase_Order_Item__c>();
            List<buildertek__Purchase_Order_Item__c> updatePolineList = new List<buildertek__Purchase_Order_Item__c>();
            List<buildertek__Purchase_Order_Item__c> newPolineList = new List<buildertek__Purchase_Order_Item__c>();
            for (buildertek__Purchase_Order_Item__c POLine : POLineList) {
                if (POLineMap.get(POLine.Id).buildertek__Quantity__c == POLine.buildertek__Quantity__c) {
                    deletePolineList.add(POLine);
                } else if (POLineMap.get(POLine.Id).buildertek__Quantity__c > POLine.buildertek__Quantity__c) {
                    buildertek__Purchase_Order_Item__c oldPoLine =POLineMap.get(POLine.Id);
                    oldPoLine.buildertek__Quantity__c = POLineMap.get(POLine.Id).buildertek__Quantity__c - POLine.buildertek__Quantity__c;
                    updatePolineList.add(oldPoLine);
                }
                buildertek__Purchase_Order_Item__c newPoLine = new buildertek__Purchase_Order_Item__c();
                newPoLine.Name = POLine.Name;
                newPoLine.buildertek__Quantity__c = POLine.buildertek__Quantity__c;
                newPoLine.buildertek__Unit_Price__c = POLine.buildertek__Unit_Price__c;
                newPoLine.buildertek__Tax__c = POLine.buildertek__Tax__c;
                newPoLine.buildertek__Purchase_Order__c = newPO.Id;
                newPolineList.add(newPoLine);
            }
            if (newPolineList.size() > 0) {
                insert newPolineList;
                System.debug('newPolineList--->>>'+newPolineList);
            }

            if (deletePolineList.size()>0) {
                delete deletePolineList;
                System.debug('Deleted Successfully');
            }
            if (updatePolineList.size()>0){
                update updatePolineList;
                System.debug('Updated sucessfully');
            }
            return newPO.Id;
        }
        return msg;
    }
}