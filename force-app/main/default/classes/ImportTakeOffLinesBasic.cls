public with sharing class ImportTakeOffLinesBasic{
    public virtual class ResponseBase{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String strMessage;
    }

    @AuraEnabled
    public static ResponseBase importRecords(Id takeOffId, String fileData){
        ResponseBase response = new ResponseBase();
        System.debug('fileData----> '+fileData);
        Id productFamilyId = null;

        try {

            List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(fileData, List<fieldWrapper>.class);

            Map<String, Product2> existingProductMap = new Map<String, Product2>();
            Map<String, buildertek__Build_Phase__c> buildPhasemap = new Map<String, buildertek__Build_Phase__c>();
            Map<String, buildertek__Trade_Type__c> existingTradeTypeMap = new Map<String, buildertek__Trade_Type__c>();
            Map<String, buildertek__Cost_Codes__c> existingCostCodeMap = new Map<String, buildertek__Cost_Codes__c>();
            Map<String, Account> accountMap = new Map<String, Account>();
            Map<String, PricebookEntry> PBEMap = new Map<String, PricebookEntry>();
            Map<String, Pricebook2> PBMap = new Map<String, Pricebook2>();

            List<String> productList = new List<String>();
            List<String> priceBookList = new List<String>();
            List<String> vendorList = new List<String>();
            for (fieldWrapper data : dataList) {
                productList.add(data.Product);
                priceBookList.add(data.PriceBook);
                vendorList.add(data.Vendor);
            }
            
            // Find existing products
            for (Product2 prod : [SELECT Id, Name FROM Product2 WHERE Name IN :productList]) {
                existingProductMap.put(prod.Name, prod);
            }

            // Find existing pricebooks
            for (Pricebook2 pricebook : [SELECT Id, Name FROM Pricebook2 WHERE Name IN :priceBookList]) {
                PBMap.put(pricebook.Name, pricebook);
            }

            // Find existing vendors
            for (Account Acc : [SELECT Id, Name FROM Account WHERE Name IN :vendorList]) {
                accountMap.put(Acc.Name, Acc);
            }

            // Find existing pricebookentries
            for (PricebookEntry pricebookentry : [SELECT Id, Name, Pricebook2Id, Product2Id, Product2.Name, Pricebook2.Name FROM PricebookEntry WHERE Product2.Name IN :productList]) {
                PBEMap.put(pricebookentry.Id, pricebookentry);
            }

            // Find existing build phases
            for (buildertek__Build_Phase__c newbuildphase : [SELECT Id, Name FROM buildertek__Build_Phase__c]) {
                buildPhasemap.put(newbuildphase.Name, newbuildphase);
            }

            // Find existing trade types
            for (buildertek__Trade_Type__c tradeTypeRec : [SELECT Id, Name FROM buildertek__Trade_Type__c]) {
                existingTradeTypeMap.put(tradeTypeRec.Name, tradeTypeRec);
            }

            // Find existing cost codes
            for (buildertek__Cost_Codes__c costCodeRec : [SELECT Id, Name FROM buildertek__Cost_Codes__c]) {
                existingCostCodeMap.put(costCodeRec.Name, costCodeRec);
            }


            List<buildertek__Project_Takeoff_Lines__c> TakeoffLinesToInsert = new List<buildertek__Project_Takeoff_Lines__c>();

            for (fieldWrapper wrapper : datalist) {
                
                buildertek__Project_Takeoff_Lines__c TakeoffLine = new buildertek__Project_Takeoff_Lines__c();
                TakeoffLine.buildertek__Project_Takeoff__c = takeOffId;

                String productName = wrapper.Product;
                if (String.isNotBlank(productName) && existingProductMap.containsKey(productName)){
                    productFamilyId = existingProductMap.get(productName).Id;
                    TakeoffLine.buildertek__Product__c = productFamilyId;
                    TakeoffLine.buildertek__Description__c = productName;
                } else {
                    TakeoffLine.buildertek__Description__c = productName;
                }
                
                String tempPBphase = wrapper.PriceBook;
                if (String.isNotBlank(tempPBphase) && PBMap.containsKey(tempPBphase) && productFamilyId != null) {
                    for (PricebookEntry pbe : PBEMap.values()) {
                        if (pbe.Pricebook2Id == PBMap.get(tempPBphase).Id &&
                            pbe.Product2Id == productFamilyId) {
                            TakeoffLine.buildertek__Price_Book__c = PBMap.get(tempPBphase).Id;
                            break;
                        }
                    }
                    productFamilyId = null;
                }
                
                String vendorName = wrapper.Vendor;
                if (String.isNotBlank(vendorName) && accountMap.containsKey(vendorName)){
                    TakeoffLine.buildertek__Vendor__c = accountMap.get(vendorName).Id;
                }
                TakeoffLine.buildertek__StockKeepingUnit__c = wrapper.ProductSKU;
                TakeoffLine.buildertek__Product_Code__c = wrapper.ProductCode;

                String buildPhase = wrapper.BuildPhase;
                if (String.isNotBlank(buildPhase) && buildPhasemap.containsKey(buildPhase)){
                    TakeoffLine.buildertek__Build_Phase__c = buildPhasemap.get(buildPhase).Id;
                }
                TakeoffLine.buildertek__Category__c = wrapper.CategoryPL;

                String tradeType = wrapper.TradeType;
                if (String.isNotBlank(tradeType) && existingTradeTypeMap.containsKey(tradeType)){
                    TakeoffLine.buildertek__Trade_Type__c = existingTradeTypeMap.get(tradeType).Id;
                }
                TakeoffLine.buildertek__Location__c = wrapper.Location;
               
                String quant = wrapper.Quantity;
                if (String.isNotBlank(quant)){
                    TakeoffLine.buildertek__Quantity__c = Decimal.valueOf(quant);
                } else {
                    TakeoffLine.buildertek__Quantity__c = 0;
                }
                TakeoffLine.buildertek__UOM_PL__c = wrapper.UOM;

                String codeco = wrapper.CostCode;
                if (String.isNotBlank(codeco) && existingCostCodeMap.containsKey(codeco)){
                    TakeoffLine.buildertek__Cost_Code__c = existingCostCodeMap.get(codeco).Id;
                }
                TakeoffLinesToInsert.add(TakeoffLine);

            }

            if (!TakeoffLinesToInsert.isEmpty()) {
                insert TakeoffLinesToInsert;
                response.isSuccess = true;
                response.strMessage = 'Takeoff Lines inserted Successfully.';
            } else {
                response.isSuccess = false;
                response.strMessage = 'File is empty.';
            }
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }

            System.debug('error-->' + e.getMessage());
            System.debug('error line--->' + e.getLineNumber());
            response.isSuccess = false;
            response.strMessage = e.getMessage();
        }
        
        return response;
    }

    public class fieldWrapper{
        public String Product;
        public String PriceBook;
        public String Vendor;
        public String ProductSKU;
        public String ProductCode;
        public String BuildPhase;
        public String CategoryPL;
        public String TradeType;
        public String Location;
        public String Quantity;
        public String UOM;
        public String CostCode;
       
    }

}