public with sharing class walkThroughController {

    @AuraEnabled
    public static List<buildertek__Category__c> getCategoryRecords() {
        return [SELECT Id, Name FROM buildertek__Category__c WHERE buildertek__Use_for_Walk_Through__c = true ORDER BY buildertek__Order_Id__c ASC NULLS LAST, Name ASC];
    }

    public class FieldWrapper {
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String fieldType { get; set; }
        @AuraEnabled public String fieldLabel { get; set; }
        @AuraEnabled public Object fieldValue { get; set; }
        @AuraEnabled public List<String> picklistValues { get; set; }
    }
    
    @AuraEnabled
    public static List<FieldWrapper> getFieldDetails(String objectName, String recordId) {
        List<FieldWrapper> fieldList = new List<FieldWrapper>();
        List<String> queryFields = new List<String>();

        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();

        for (Schema.SObjectField field : objectDescribe.fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (fieldDescribe.isUpdateable()) {
                String fieldName = fieldDescribe.getName();
                String fieldType = fieldDescribe.getType().name();
                String fieldLabel = fieldDescribe.getLabel();
                queryFields.add(fieldName);

                FieldWrapper fieldWrapper = new FieldWrapper();
                fieldWrapper.fieldName = fieldName;
                fieldWrapper.fieldType = fieldType;
                fieldWrapper.fieldLabel = fieldLabel;
                fieldWrapper.fieldValue = null;

                if (fieldType == 'Picklist') {
                    fieldWrapper.picklistValues = new List<String>();
                    List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
                    for (Schema.PicklistEntry picklistEntry : picklistValues) {
                        fieldWrapper.picklistValues.add(picklistEntry.getLabel());
                    }
                }

                fieldList.add(fieldWrapper);
            }
        }

        String query = 'SELECT ' + String.join(queryFields, ', ') + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';
        SObject record = Database.query(query);

        for (FieldWrapper field : fieldList) {
            field.fieldValue = record.get(field.fieldName);
        }

        return fieldList;
    }

    @AuraEnabled
    public static Map<String, Object> fetchDataAndFieldSetValues(String wtRecordId, String categoryId, String sObjectName, String fieldSetName) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            List<String> queryFields = new List<String>();

            List<Map<String, Object>> fieldSetValues = new List<Map<String, Object>>();
            Schema.SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey(fieldSetName)) {
                for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    Map<String, Object> fieldData = new Map<String, Object>();
                    fieldData.put('label', f.getLabel());
                    fieldData.put('required', f.getDBRequired() || f.getRequired());
                    fieldData.put('type', f.getType());
                    fieldData.put('name', f.getFieldPath());
                    String fieldName = f.getFieldPath();
                    queryFields.add(fieldName);

                    Schema.DescribeFieldResult fieldDescribe = objToken.getDescribe().fields.getMap().get(f.getFieldPath()).getDescribe();
                    fieldData.put('editable', fieldDescribe.isUpdateable());

                    if (String.valueOf(f.getType()) == 'PICKLIST') {
                        List<String> pickListValuesList = getDropDown(sObjectName, String.valueOf(f.getFieldPath()));
                        fieldData.put('pickListValuesList', pickListValuesList);
                    }

                    fieldSetValues.add(fieldData);
                }
            }
            
            result.put('FieldSetValues', fieldSetValues);

            List<buildertek__Walk_Through_Line_Items__c> walkThroughLines = new List<buildertek__Walk_Through_Line_Items__c>();

            String wtQueryString = 'SELECT ' + String.join(queryFields, ', ') + ' FROM buildertek__Walk_Through_Line_Items__c WHERE buildertek__Walk_Through_List__c =: wtRecordId AND buildertek__BT_Category__c =: categoryId ORDER BY CreatedDate DESC, buildertek__Description__c';
            walkThroughLines = Database.query(wtQueryString);

            result.put('WalkthroughLineItems', walkThroughLines);

        } catch (Exception e) {
            System.debug('Error ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            result.put('Error', e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static List<String> getDropDown(String objName, String fieldName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String, Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }

    @AuraEnabled
    public static String updateRecord(String recordId, Map<String, Object> newFieldValues) {
        try {

            buildertek__Walk_Through_List__c recordToUpdate = [SELECT Id FROM buildertek__Walk_Through_List__c WHERE Id = :recordId LIMIT 1];

            for (String fieldName : newFieldValues.keySet()) {
                if (recordToUpdate.getSObjectType().getDescribe().fields.getMap().containsKey(fieldName)) {
                    Object fieldValue = newFieldValues.get(fieldName);
                    if (fieldValue instanceof String) {
                        Schema.DescribeFieldResult fieldDescribe = recordToUpdate.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe();
                        if (fieldDescribe.getType() == Schema.DisplayType.Integer || fieldDescribe.getType() == Schema.DisplayType.Double || fieldDescribe.getType() == Schema.DisplayType.Currency) {
                            recordToUpdate.put(fieldName, Decimal.valueOf((String) fieldValue));
                        } else if (fieldDescribe.getType() == Schema.DisplayType.Date){
                            String dateString = String.valueOf(fieldValue);
                            Date dateVal = Date.valueOf(dateString);
                            recordToUpdate.put(fieldName, dateVal);
                        } else if (fieldDescribe.getType() == Schema.DisplayType.DateTime){
                            String dateTimeString = fieldValue + ':00';
                            Datetime dt = parseDatetimeString(dateTimeString);
                            recordToUpdate.put(fieldName, dt);
                        } else if (fieldDescribe.getType() == Schema.DisplayType.Time){
                            String timeString = String.valueOf(fieldValue);
                            String[] strTimeSplit = timeString.split(':');
                            Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                                ,Integer.valueOf(strTimeSplit[1]) //min
                                                                ,0                                //sec
                                                                ,0); 
                            recordToUpdate.put(fieldName, timeChange);
                        } else {
                            recordToUpdate.put(fieldName, fieldValue);
                        }
                    } else {
                        recordToUpdate.put(fieldName, fieldValue);
                    }
                } else {
                    System.debug('Field ' + fieldName + ' does not exist in the object schema.');
                }
            }

            update recordToUpdate;

            return 'success';
        } catch (Exception e) {
            System.debug('error message -->'+e.getMessage());
            System.debug('error line number -->'+e.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            // return e.getMessage();
            String errorMessage = e.getMessage();

            if (errorMessage.contains('STRING_TOO_LONG')) {
                List<String> parts = errorMessage.split(':');
                String maxLengthString;

                if (parts.size() > 1) {
                    String errorMes = parts[1].trim();
                    String errorMes1 = parts[3].trim();

                    Pattern pattern = Pattern.compile('\\(max length=(\\d+)\\)');
                    Matcher matcher = pattern.matcher(errorMes1);

                    if (matcher.find()) {
                        maxLengthString = matcher.group(1);
                        System.debug('Max Length: ' + maxLengthString);
                    } else {
                        System.debug('Max Length not found.');
                    }
                    List<String> errorMessageParts = errorMes.split(',');

                    if (errorMessageParts.size() > 1) {
                        String errorType = errorMessageParts[0].trim();
                        String fieldName = errorMessageParts[1].trim();
                        
                        errorMessage = 'The field ' + fieldName + ' exceeds the maximum allowed length of ' + maxLengthString + ' characters. Please reduce the length of the input for this field.';
                        System.debug(errorMessage);
                    } else {
                        System.debug('Error Message not found.');
                    }
                } else {
                    System.debug('Error Message not found.');
                }
            }

            return errorMessage;
           
        }
    }

    public static Datetime parseDatetimeString(String dateTimeString) {
        Datetime dt;

        List<String> dateTimeParts = dateTimeString.split('T');
        List<String> dateParts = dateTimeParts[0].split('-');
        List<String> timeParts = dateTimeParts[1].split(':');

        Integer year = Integer.valueOf(dateParts[0]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer day = Integer.valueOf(dateParts[2]);
        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1]);
        Integer second = Integer.valueOf(timeParts[2]);

        dt = Datetime.newInstance(year, month, day, hour, minute, second);
        return dt;
    }

    @AuraEnabled
    public static String deleteRecord(String recordId) {
        try {
            buildertek__Walk_Through_Line_Items__c walkthroughlineItem = new buildertek__Walk_Through_Line_Items__c(Id = recordId);
            delete walkthroughlineItem;
            return 'success';
        } catch (Exception e) {
            System.debug('error message -->'+e.getMessage());
            System.debug('error line number -->'+e.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            return e.getMessage();
        }
    }

    @AuraEnabled
	public static String getFieldSet(String objName, String fieldSetName){
		String result = '';
		List<String> pickListValuesList = new List<String>();
		try{
			SObjectType objToken = Schema.getGlobalDescribe().get(objName);
			Schema.DescribeSObjectResult d = objToken.getDescribe();
			Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
			if (FsMap.containsKey(fieldSetName)){
				for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
					if (result != ''){
						result += ',';
					}
					String jsonPart = '{';
					jsonPart += '"label":"' + f.getLabel()+'",';
					jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
					jsonPart += '"type":"' + (f.getType())+'",';
					jsonPart += '"name":"' + f.getFieldPath()+'"';
					if (String.valueOf(f.getType()) == 'PICKLIST'){
						pickListValuesList = getDropDown(objName, String.valueOf(f.getFieldPath()));
						jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
					}
					jsonPart += '}';
					result += jsonPart;
				}
			}

		} catch (Exception e){
			result += e.getLineNumber()+' : ' + e.getMessage();
			throw new AuraHandledException(e.getMessage());
		}
		return '[' + result + ']';
	}

    @AuraEnabled
    public static List<RecordType> getRecordType(String ObjectAPIName) {
        System.debug('ObjectAPIName: ' + ObjectAPIName);
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = :ObjectAPIName];
        System.debug('recordTypes: ' + recordTypes);
        return recordTypes;
    }

    @AuraEnabled
	public static String saveData(buildertek__Walk_Through_Line_Items__c allData ){
		String result = '';
		try{
			insert allData;
			result = 'Record Inserted Successfully';
		} catch (Exception e){
			result = e.getMessage();
			List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
		}
		return result;
	}

    @AuraEnabled
    public static List<pricebookWrapper> getPricebookList(string recordId){
        try {
            List<pricebookWrapper> priceWrapper = new List<pricebookWrapper>();
        
            pricebookWrapper priceWrap = new pricebookWrapper();
            priceWrap.defaultValue= new pricebook2();
            priceWrap.priceWrapList = new List<pricebook2>();
            List<pricebook2> PriceList = [SELECT Id, Name FROM pricebook2 WHERE buildertek__BT_Visible__c = true ORDER BY Name ASC ];
            priceWrap.priceWrapList=PriceList;
            
            if(PriceList.size() > 0){
                if(recordId != null){
                    buildertek__Walk_Through_List__c walkThroughList = [Select Id, Name , buildertek__Project__c , buildertek__Project__r.buildertek__Price_Book__c , buildertek__Project__r.buildertek__Price_Book__r.Name From buildertek__Walk_Through_List__c  WHERE Id = :recordId];
                    if(walkThroughList.buildertek__Project__c != null && walkThroughList.buildertek__Project__r.buildertek__Price_Book__c !=null){
                        pricebook2 selectedPriceList = [SELECT Id, Name FROM pricebook2 where Id=:walkThroughList.buildertek__Project__r.buildertek__Price_Book__c LIMIT 1];
                        if(selectedPriceList != null){
                            priceWrap.defaultValue= selectedPriceList;
                        }
                        else{
                            priceWrap.defaultValue = PriceList[0];
                        }
                    }
                    else{
                        priceWrap.defaultValue = PriceList[0];
                    }
                }
            }

            priceWrapper.add(priceWrap);
            return priceWrapper;
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
        
    }

    @AuraEnabled
    public static list<productfamilyClass> getProductfamilyRecords(String ObjectName, string parentId){
        try {
            Map<String, String> options = new Map<String, String>();
            List<sObject> returnList = new List<sObject>();
            list<string> ProdIds = new list<string>();

            if (ObjectName == 'Product2' && parentId != null){
                list<pricebookEntry> PElist;

                PElist = [SELECT id, Product2Id FROM pricebookEntry WHERE pricebook2Id = :parentId];

                for (pricebookEntry PE : PElist){
                    ProdIds.add(PE.Product2Id);
                }
            }

            List<AggregateResult> productfamlylst = [SELECT toLabel(Family) familyLabel
                                                    FROM Product2
                                                    WHERE (Id IN :ProdIds AND family != null)
                                                    group by family];
            list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();

            if (productfamlylst.size() > 0){
                for (AggregateResult agg : productfamlylst){
                    productfamilyClass pf = new productfamilyClass();
                    pf.productfamilyvalues = string.valueof(agg.get('familyLabel'));
                    pfwrapperlst.add(pf);
                }
                system.debug('pfwrapperlst---->' + pfwrapperlst);
            }

            return pfwrapperlst;

        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
        
    }

    @AuraEnabled
    public static List<productWrapper> getProductsthroughPriceBook2(string priceBookId, string productFamilyLabel, String searchProduct ) {
        try {
            String queryString = 'SELECT Id, Product2Id, Product2.buildertek__Quote_Group__c, Product2.Name, Product2.ProductCode, '
                            + 'Product2.buildertek__Vendor__r.Name, Product2.buildertek__Cost_Code__r.Name, Product2.Description, '
                            + 'toLabel(Product2.Family),Product2.buildertek__Instructions__c, Product2.IsActive, buildertek__Unit_Cost__c, buildertek__Markup__c, '
                            + 'buildertek__Discount__c, Pricebook2.Name, UnitPrice, Product2.QuantityUnitOfMeasure '
                            + 'FROM PricebookEntry WHERE Pricebook2Id = :priceBookId AND IsActive = True';
    
            if (String.isNotBlank(searchProduct)) {
                queryString += ' AND (Product2.Name LIKE :searchProduct OR Product2.ProductCode LIKE :searchProduct)';
            }
        
            if (productFamilyLabel != 'All') {
                queryString += ' AND Product2.Family = :productFamilyLabel';
            }
        
            queryString += ' ORDER BY Product2.Family ASC NULLS LAST, Product2.Name ASC NULLS LAST LIMIT 100';
        
            List<PriceBookEntry> pEntries = Database.query(queryString);    

            List<productWrapper> products = new List<productWrapper>();
            for (PriceBookEntry pEntry: pEntries) {
                productWrapper aProduct = new productWrapper();
                aProduct.Id = pEntry.Product2Id;
                aProduct.Vendor = pEntry.Product2.buildertek__Vendor__r.Name;
                aProduct.CostCode = pEntry.Product2.buildertek__Cost_Code__r.Name;
                aProduct.Name = pEntry.Product2.Name;
                aProduct.ProductCode = pEntry.Product2.ProductCode;
                aProduct.Description = pEntry.Product2.Description;
                aProduct.Family = pEntry.Product2.Family;
                aProduct.IsActive = pEntry.Product2.IsActive;
                aProduct.UnitPrice = pEntry.UnitPrice;            
                aProduct.Size = pEntry.Pricebook2.Name;
                aProduct.Selected = false;
                aProduct.MarkUp = pEntry.buildertek__Markup__c;
                aProduct.Discount = pEntry.buildertek__Discount__c;
                aProduct.UnitCost = pEntry.buildertek__Unit_Cost__c;
                aProduct.Phase = pEntry.Product2.buildertek__Quote_Group__c;
                aProduct.QuantityUnitOfMeasure = pEntry.Product2.QuantityUnitOfMeasure;     
                aProduct.Instructions = pEntry.Product2.buildertek__Instructions__c;     
                products.add(aProduct);
            }

            return products;
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }

    public class productWrapper{
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String ProductCode;
        @AuraEnabled
        public String Description;
        @AuraEnabled
        public String Family;
        @AuraEnabled
        public Boolean IsActive;
        @AuraEnabled
        public Decimal UnitPrice;
        @AuraEnabled
        public String Size;
        @AuraEnabled
        public Boolean Selected;
        @AuraEnabled
        public Decimal UnitCost;
        @AuraEnabled
        public String Phase;
        @AuraEnabled
        public Decimal MarkUp;
        @AuraEnabled
        public Decimal Discount;
        @AuraEnabled
        public String Vendor;
        @AuraEnabled
        public String CostCode;
        @AuraEnabled
        public String QuantityUnitOfMeasure; 
        @AuraEnabled
        public String PriceBookId; 
        @AuraEnabled
        public String PriceBookName;
        @AuraEnabled
        public String PriceBookEntryId;
        @AuraEnabled 
        public List<String> ProductFamilySet;
        @AuraEnabled
        public String Instructions;
    }

    public class pricebookWrapper{
        @AuraEnabled
        public List<pricebook2> priceWrapList;

        @AuraEnabled
        public pricebook2 defaultValue;
    }

    @AuraEnabled
    public list<productfamilyClass> pfwrapperlst{ get; set; }

    public class productfamilyClass{
        @AuraEnabled
        public string productfamilyvalues{ get; set; }
    }

    @AuraEnabled
    public static list<buildertek__Admin_Interface_Node_Configuration__c> getSharinPixSetting(){
        try {
            List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__SharinPix_Feature__c, buildertek__SharinPix_Pre_Sub_Token__c, buildertek__SharinPix_Post_Sub_Token__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name =: 'SharinPix Configuration'];
            if (!adminInterfaceNodeConfigurations.isEmpty()) {
                return adminInterfaceNodeConfigurations;
            } else {
                return null;
            }
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }

}