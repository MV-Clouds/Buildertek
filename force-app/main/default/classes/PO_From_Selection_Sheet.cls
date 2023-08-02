public with sharing class PO_From_Selection_Sheet {
    /*Description:- This method is used to create purchase order when user click on "create PO" button from Selection sheet*/
    @AuraEnabled
    public static void createPO(String recordId , List<buildertek__Question__c> selectedRowList){
        List<buildertek__Question__c> optionList = [SELECT Id, Name, buildertek__Selected__c, buildertek__Product__c, buildertek__Section__c, buildertek__Question_Group__c, buildertek__Product__r.Name , buildertek__Manufacturer__c, buildertek__Manufacturer__r.Name, buildertek__Quantity__c, buildertek__Cost__c, buildertek__Purchase_Order__c, buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c FROM buildertek__Question__c WHERE buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__c =: recordId AND buildertek__Selected__c = true AND buildertek__Manufacturer__c != null AND buildertek__Product__c != null AND buildertek__Purchase_Order__c = null];
        Integer maxSize = 80;

        List<String> manufacturerIds = new List<String>();
        List<Account> manufacturerList = new List<Account>();

        for (buildertek__Question__c option : selectedRowList) {
            System.debug('Option => '+option);
            if (!manufacturerIds.contains(option.buildertek__Manufacturer__c)) {
                manufacturerIds.add(option.buildertek__Manufacturer__c);
                manufacturerList.add(option.buildertek__Manufacturer__r);
            }
        }

        List<buildertek__Purchase_Order__c> poList = new List<buildertek__Purchase_Order__c>();
        for (Account manufacturer : manufacturerList) {
            buildertek__Purchase_Order__c po = new buildertek__Purchase_Order__c();
            System.debug('manufacturer => '+manufacturer);
            po.buildertek__Description__c = manufacturer.Name;
            po.buildertek__Vendor__c = manufacturer.Id;
            if (selectedRowList[0].buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c != null) {
                po.buildertek__Project__c = selectedRowList[0].buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c;
            }
            poList.add(po);
            System.debug('po => '+po);
        }
        insert poList;

        Map<Id, buildertek__Purchase_Order_Item__c> poItemMap = new Map<Id, buildertek__Purchase_Order_Item__c>();
        for (buildertek__Question__c option : selectedRowList){
            for (buildertek__Purchase_Order__c po : poList) {
                if (option.buildertek__Manufacturer__c == po.buildertek__Vendor__c) {
                    buildertek__Purchase_Order_Item__c poLine = new buildertek__Purchase_Order_Item__c();
                    poLine.buildertek__Purchase_Order__c = po.Id;
                    poLine.buildertek__Unit_Price__c = option.buildertek__Cost__c;
                    if(option.buildertek__Product__r.Name.length() <= maxSize){
                        poLine.Name = option.buildertek__Product__r.Name;
                    }else {
                        poLine.Name = option.buildertek__Product__r.Name.substring(0, maxSize);
                    }
                    poLine.buildertek__Description__c= option.buildertek__Product__r.Name;
                    poItemMap.put(option.Id, poLine);
                    System.debug('poLine => '+poLine);
                }
            }
        }
        insert poItemMap.values();

        for (buildertek__Question__c option : selectedRowList){
            for (Id key : poItemMap.keySet()) {
                if (option.Id == key) {
                    option.buildertek__Purchase_Order_Line__c = poItemMap.get(key).Id;
                    option.buildertek__Purchase_Order__c = poItemMap.get(key).buildertek__Purchase_Order__c;
                    System.debug('Update option => '+option);
                }
            }
        }
        update selectedRowList;

    }

    /* Description:- This method is used to get all  option records whose slected checkbox is checked , Manufacturer and Product are not null!!!!*/
    @AuraEnabled
    public static List<wrapper> getOption(String recordId) {
        List<wrapper> wpList = new List<wrapper>();
        // wp.getOptionList= new  List<buildertek__Question__c>();
        List<buildertek__Question__c> optionList = [SELECT Id, Name, buildertek__Selected__c, buildertek__Product__c, buildertek__Product__r.Name , 
                                                    buildertek__Manufacturer__c, buildertek__Manufacturer__r.Name, buildertek__Quantity__c, buildertek__Cost__c, 
                                                    buildertek__Purchase_Order__c,buildertek__Section__c,buildertek__Section__r.Name, buildertek__Question_Group__r.Name, 
                                                    buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c
                                                    FROM buildertek__Question__c WHERE buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__c =: recordId AND 
                                                    buildertek__Selected__c = true AND buildertek__Manufacturer__c != null AND buildertek__Product__c != null AND buildertek__Purchase_Order__c = null
                                                    ORDER BY buildertek__Manufacturer__c];

        buildertek__Selection__c sheet = new buildertek__Selection__c();
        sheet = [Select Id,Name From buildertek__Selection__c where ID =: recordId];
        System.debug('sheet---->>>>'+sheet);

        String vendorId = recordId;
        for (buildertek__Question__c option : optionList) {
            if (vendorId != option.buildertek__Manufacturer__c) {
                wrapper wp = new wrapper();

                Account acc = new Account();
                acc.Id = option.buildertek__Manufacturer__c;
                acc.Name = option.buildertek__Manufacturer__r.Name;
                wp.VendorData = acc;

                // buildertek__Selection__c sheet = new buildertek__Selection__c();
                sheet.Id = recordId;
                wp.SheetData = sheet;
                System.debug('wp.SheetData--->>>'+wp.SheetData);

                wp.getProjectId = option.buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c;
                wpList.add(wp);
                vendorId = option.buildertek__Manufacturer__c;
            } 
        }

        for (wrapper wpData : wpList) {
            List<optionData> optionDataList = new List<optionData>();
            for (buildertek__Question__c option : optionList) {
                if (wpData.VendorData.Id == option.buildertek__Manufacturer__c) {

                    optionData optionData = new optionData();
                    optionData.option = option;
                    optionData.selected = false;
                    optionDataList.add(optionData);

                }
            }
            wpData.optionDataList = optionDataList;
            
        }
        
        // buildertek__Selection__c getId =[SELECT Id, buildertek__Project__c FROM buildertek__Selection__c WHERE Id=:recordId LIMIT 1];
        // wp.getProjectId=getId.buildertek__Project__c;
        return wpList;
    }


    public class wrapper{
        @AuraEnabled
        public List<optionData> optionDataList{get;set;}

        @AuraEnabled
        public String getProjectId{get;set;}

        @AuraEnabled
        public Account VendorData{get;set;}

        @AuraEnabled
        public buildertek__Selection__c SheetData{get;set;}
    }

    public class optionData{
        @AuraEnabled
        public buildertek__Question__c option{get;set;}

        @AuraEnabled
        public Boolean selected{get;set;}
    }
       
}