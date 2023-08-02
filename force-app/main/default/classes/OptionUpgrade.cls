public with sharing class OptionUpgrade {

    @AuraEnabled
    public static optionWrapper getProductDetails(String recordId, String searchNameValue, String searchTypeValue, String searchManufacturerValue, String searchFamilyValue, String searchCategoryValue, String selectedPriceBook, Boolean priceBookFilter) {
        buildertek__Question__c option = [SELECT Id, Name, buildertek__Question_Group__c, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Manufacturer__c, buildertek__Manufacturer__r.Name,
                                            buildertek__Section__c, buildertek__Cost__c, buildertek__Upgrade_Costs__c, buildertek__Total_Sales_Price__c, buildertek__Price_Book__c,
                                            buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__r.buildertek__Price_Book__c FROM buildertek__Question__c WHERE Id =: recordId];

        List<Product2> productList = new List<Product2>();

        string orgCurr = UserInfo.getDefaultCurrency();

        System.debug('-- option --');
        // if (option.buildertek__Section__c != null) {
            // String sectionId = option.buildertek__Section__c;
            String queryList = 'SELECT Id, Name, buildertek__Selection_Category_Lookup__c, buildertek__Product_Type__r.Name, buildertek__Manufacturer__r.Name, Family, buildertek__Category__c, buildertek__Category__r.Name, (SELECT Id, Name, UnitPrice, Pricebook2.Id, Pricebook2.Name FROM PricebookEntries) FROM Product2';

            if (searchNameValue != null && searchNameValue != '') {
                queryList = queryList + ' WHERE Name LIKE \'' + searchNameValue + '%\'';
            }

            if (searchTypeValue != null && searchTypeValue != '') {
                if (queryList.contains('WHERE')) {
                    queryList = queryList + ' AND buildertek__Product_Type__r.Name LIKE \'' + searchTypeValue + '%\'';
                } else{
                    queryList = queryList + ' WHERE buildertek__Product_Type__r.Name LIKE \'' + searchTypeValue + '%\'';
                }
            }

            if (searchManufacturerValue != null && searchManufacturerValue != '') {
                if (queryList.contains('WHERE')) {
                    queryList = queryList + ' AND buildertek__Manufacturer__r.Name LIKE \'' + searchManufacturerValue + '%\'';
                } else{
                    queryList = queryList + ' WHERE buildertek__Manufacturer__r.Name LIKE \'' + searchManufacturerValue + '%\'';
                }
            }

            if (searchFamilyValue != null && searchFamilyValue != '') {
                if (queryList.contains('WHERE')) {
                    queryList = queryList + ' AND Family LIKE \'' + searchFamilyValue + '%\'';
                } else{
                    queryList = queryList + ' WHERE Family LIKE \'' + searchFamilyValue + '%\'';
                }
            }

            if (searchCategoryValue != null && searchCategoryValue != '') {
                if (queryList.contains('WHERE')) {
                    queryList = queryList + ' AND buildertek__Category__r.Name LIKE \'' + searchCategoryValue + '%\'';
                } else{
                    queryList = queryList + ' WHERE buildertek__Category__r.Name LIKE \'' + searchCategoryValue + '%\'';
                }
            }

            productList = Database.query(queryList);
        // }

        Set<ID> productsIds = new Set<ID>();
        for (Product2 product : productList) {
            productsIds.add(product.Id);
        }

        List<ContentDocumentLink> contentLinkList = new List<ContentDocumentLink>();
        if (productsIds.size() > 0) {
            contentLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: productsIds];
        }

        Map<String, String> priceBookMap = new Map<String, String>();
        list<pricebook2> PriceList = [SELECT Id, Name FROM pricebook2 ORDER BY Name ASC ];
        for (pricebook2 p : PriceList){
            priceBookMap.put(p.Name, p.Id);
        }

        String priceBookValue;
        if (priceBookFilter == false) {
            priceBookValue = option.buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__r.buildertek__Price_Book__c;
            if (priceBookValue == null || priceBookValue == '') {
                priceBookValue = priceBookMap.get('Standard Price Book');
            }
        } else {
            priceBookValue = selectedPriceBook;
        }

        optionWrapper optionWrapperData = new optionWrapper();
        optionWrapperData.option = option;
        optionWrapperData.projectPriceBook = priceBookValue;
        optionWrapperData.priceBookMap = priceBookMap;


        List<productWrapper> prodWrapperList = new List<productWrapper>();

        Integer prodCount = 0;
        for (Product2 product : productList) {

            boolean checkPriceBook = false;
            for (PricebookEntry priceBookEntry : product.PricebookEntries) {
                if (priceBookValue != '' && priceBookEntry.Pricebook2Id == priceBookValue) {
                    checkPriceBook = true;
                }
            }
            if (checkPriceBook == true || priceBookValue == '') {
                productWrapper prodWrapper = new productWrapper();
                prodWrapper.product = product;
                List<ContentDocumentLink> contentDocs = new List<ContentDocumentLink>();
                for (ContentDocumentLink content : contentLinkList) {
                    if (content.LinkedEntityId == product.Id) {
                        contentDocs.add(content);
                    }
                }
                prodWrapper.contentDocsList = contentDocs;
                prodWrapperList.add(prodWrapper);
                prodCount++;
            }

        }
        optionWrapperData.productWrapperList = prodWrapperList;
        optionWrapperData.productCount = prodCount;
        optionWrapperData.orgCurr = orgCurr;
        return optionWrapperData;
    }

    @AuraEnabled
    public static String upgradeOption(buildertek__Question__c optionValue, Product2 productValue){

        buildertek__Question__c newOption  = optionValue.clone();
        newOption.buildertek__Product__c = productValue.Id;
        newOption.buildertek__Manufacturer__c = productValue.buildertek__Manufacturer__c;
        newOption.buildertek__Selected__c = true;
        newOption.buildertek__Upgrade__c = true;
        newOption.buildertek__Date_Option_Upgraded__c = System.Today();
        newOption.buildertek__Original_Option__c = optionValue.Id;
        newOption.buildertek__Question_Group__c = optionValue.buildertek__Question_Group__c;
        insert newOption;

        optionValue.buildertek__Selected__c = false;
        update optionValue;

        return newOption.Id;
    }

    @AuraEnabled
    public static List<String> getProductFamily(String searchFamilyValue){
        List<String> productFamilyList = new List<String>();
        Schema.DescribeFieldResult prodFamily = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> entries = prodFamily.getPicklistValues();

        if(!String.isBlank(searchFamilyValue)){
            for (Schema.PicklistEntry entry : entries) {
                if (entry.getLabel().toLowerCase().contains(searchFamilyValue.toLowerCase())) {
                    productFamilyList.add(entry.getLabel());
                }
            }
        } else{
            for (Schema.PicklistEntry entry : entries) {
                productFamilyList.add(entry.getLabel());
            }
        }
        productFamilyList.sort();
        return productFamilyList;
    }

    @AuraEnabled
    public static List<String> getProductCategory(String searchCategoryValue){
        List<String> CategoryList = new List<String>();
        List<buildertek__Category__c> allCategoryList = [SELECT Id, Name FROM buildertek__Category__c ORDER BY name ASC];

        if(!String.isBlank(searchCategoryValue)){
            for (buildertek__Category__c category : allCategoryList) {
                if (category.Name.toLowerCase().contains(searchCategoryValue.toLowerCase())) {
                    CategoryList.add(category.Name);
                }
            }
        } else{
            for (buildertek__Category__c category : allCategoryList) {
                CategoryList.add(category.Name);
            }
        }
        return CategoryList;
    }

    @AuraEnabled
    public static List<String> getProductType(String searchTypeValue){
        List<String> productTypeList = new List<String>();
        List<buildertek__Product_Type__c> prodTypeList = [SELECT Id, Name FROM buildertek__Product_Type__c ORDER BY Name ASC];

        if(!String.isBlank(searchTypeValue)){
            for (buildertek__Product_Type__c prodType : prodTypeList) {
                if (prodType.Name.toLowerCase().contains(searchTypeValue.toLowerCase())) {
                    productTypeList.add(prodType.Name);
                }
            }
        } else{
            for (buildertek__Product_Type__c prodType : prodTypeList) {
                productTypeList.add(prodType.Name);
            }
        }
        return productTypeList;
    }

    @AuraEnabled
    public static List<String> getProductName(String searchNameValue){
        List<String> productNameList = new List<String>();
        List<Product2> productList = [SELECT Id, Name FROM Product2 ORDER BY name ASC];

        if(!String.isBlank(searchNameValue)){
            for (Product2 prod : productList) {
                if (prod.Name.toLowerCase().contains(searchNameValue.toLowerCase())) {
                    productNameList.add(prod.Name);
                }
            }
        } else{
            for (Product2 prod : productList) {
                productNameList.add(prod.Name);
            }
        }
        return productNameList;
    }

    @AuraEnabled
    public static List<String> getManufacturer(String searchManufacturerValue){
        List<String> ManufacturerList = new List<String>();
        List<Account> accountList = [SELECT Id, Name FROM Account ORDER BY name ASC];

        if(!String.isBlank(searchManufacturerValue)){
            for (Account acc : accountList) {
                if (acc.Name.toLowerCase().contains(searchManufacturerValue.toLowerCase())) {
                    ManufacturerList.add(acc.Name);
                }
            }
        } else{
            for (Account acc : accountList) {
                ManufacturerList.add(acc.Name);
            }
        }
        return ManufacturerList;
    }

    @AuraEnabled
    public static buildertek__Question__c getOptionRecord(String recordId){
        buildertek__Question__c optRecord = [SELECT Id ,Name ,buildertek__Price_Book__c ,buildertek__Product__c,buildertek__Quantity__c,buildertek__Cost__c,
                                                buildertek__Markup__c,buildertek__Upgrade_Costs__c,buildertek__Question_Group__c,buildertek__Manufacturer__c,
                                                buildertek__Selected__c,buildertek__Default_Option__c,buildertek__Upgrade__c,buildertek__Original_Option__c,
                                                buildertek__Date_Option_Upgraded__c FROM buildertek__Question__c WHERE Id =: recordId];
        return optRecord;
    }

    @AuraEnabled
    public static String cloneOptionRecord(buildertek__Question__c optionRec, String recordId){
    
        buildertek__Question__c optionClone  = optionRec.clone(false, false, false, false);
        insert optionClone;

        buildertek__Question__c getOption=[SELECT Id , buildertek__Original_Option__c, name FROM buildertek__Question__c WHERE Id =: recordId];
        getOption.buildertek__Original_Option__c = optionClone.Id;
        update getOption;

        return optionClone.Id;
         
    }

    public class optionWrapper{
        @AuraEnabled
        public buildertek__Question__c option {get;set;}

        @AuraEnabled
        public String projectPriceBook {get;set;}

        @AuraEnabled
        public Integer productCount {get;set;}

        @AuraEnabled
        public Map<String, String> priceBookMap {get;set;}

        @AuraEnabled
        public List<productWrapper> productWrapperList {get;set;}

        @AuraEnabled public String orgCurr;
    }

    public class productWrapper{
        @AuraEnabled
        public Product2 product {get;set;}

        @AuraEnabled
        public List<ContentDocumentLink> contentDocsList {get;set;}
    }

}