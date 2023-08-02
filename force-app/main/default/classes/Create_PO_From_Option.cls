public with sharing class Create_PO_From_Option {

    @AuraEnabled
    public static List<string> createPO(String recordId) {
        List<String> output = new List<String>();
        try {
            buildertek__Question__c option = [SELECT Id, Name, buildertek__Product__c, buildertek__Total_Cost_Per_Unit__c, buildertek__Quantity__c, buildertek__Selected__c, buildertek__Manufacturer__c, buildertek__Cost__c, buildertek__Manufacturer__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order_Line__c, buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c  FROM buildertek__Question__c WHERE Id =: recordId];

            if (option.buildertek__Selected__c == true) {
                if (option.buildertek__Product__c != null) {
                    Product2 prod = [SELECT Id, Name, (SELECT UnitPrice FROM PricebookEntries WHERE IsActive = True) FROM Product2 WHERE Id =: option.buildertek__Product__c];
                
                    if (option.buildertek__Purchase_Order_Line__c == null) {
                        if (option.buildertek__Purchase_Order__c == null) {
                            buildertek__Purchase_Order__c po = new buildertek__Purchase_Order__c();
                            po.buildertek__Description__c = option.buildertek__Manufacturer__r.Name;
                            po.buildertek__Vendor__c = option.buildertek__Manufacturer__c;
                            po.buildertek__Status__c = 'Open';
                            po.buildertek__Type__c = 'Material';
                            if (option.buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c != null) {
                                po.buildertek__Project__c = option.buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c;
                            }
                            insert po;
                            option.buildertek__Purchase_Order__c = po.Id;
                        }
                        
                        buildertek__Purchase_Order_Item__c poLine = new buildertek__Purchase_Order_Item__c();
                        poLine.buildertek__Purchase_Order__c = option.buildertek__Purchase_Order__c;
                        poLine.Name = prod.Name;
                        poLine.buildertek__Quantity__c = option.buildertek__Quantity__c;
                        
                        if (option.buildertek__Cost__c != null) {
                            poLine.buildertek__Unit_Price__c = option.buildertek__Total_Cost_Per_Unit__c;
                        } else if (prod.PricebookEntries.size() > 0) {
                            poLine.buildertek__Unit_Price__c = prod.PricebookEntries[0].UnitPrice;
                        }
                        
                        insert poLine;
                        
                        option.buildertek__Purchase_Order_Line__c = poLine.Id;
                        update option;
    
                        output.add('Success');
                        output.add(option.buildertek__Purchase_Order__c);
                        return output;
                    } else{
                        output.add('Error');
                        output.add('Duplicate');
                        return output;
                    }
                } else{
                    output.add('Error');
                    output.add('Add Product First');
                    return output;
                }
            } else{
                output.add('Error');
                output.add('Check Selected');
                return output;
            }
        } catch (Exception e) {
            System.debug('Error => '+e.getMessage());
            output.add('Error');
            output.add(e.getMessage());

            return output;
        }
    }
}