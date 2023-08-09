public class UploadBillHandler {
    
 @AuraEnabled  
    public static List<ContentDocument> getFiles(string recordId){ 
        Set<Id> recordIds=new Set<Id>{recordId};
        Set<Id> documentIds = new Set<Id>(); 
        List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:recordIds];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }      
        return [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];  
    } 
    
    @AuraEnabled  
    public static void deleteFiles(string sdocumentId){ 
        delete [SELECT Id,Title,FileType from ContentDocument WHERE id=:sdocumentId];       
    }  
    
    @AuraEnabled  
    public static String getLatestFiles(List<String> documentIds){
        String downloadURL;
        SET<Id> contentDocumentIds = new SET<Id>();
        List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument WHERE Id IN: documentIds LIMIT 1];
        for(ContentDocument CD : contentDocumentList){
            contentDocumentIds.add(CD.Id);    
        }
        List<ContentVersion> contentVersionList = [SELECT Id, Title, VersionData, FileType FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds LIMIT 1];
        String resultId = ImageUploadService.postImage(contentVersionList[0].VersionData, contentVersionList[0].FileType);
        return resultId;
    } 
    
    @AuraEnabled
    public static ImageUploadService.ResponseWrapper getImageResponse(String resultId){
        ImageUploadService.ResponseWrapper RW = new ImageUploadService.ResponseWrapper();
        RW = ImageUploadService.getImageResponse(resultId);
        return RW;
    }
    
    public class ResponseWrapper{
        @AuraEnabled public List<Object> pageResults;
        @AuraEnabled public List<Object> readResults;
        @AuraEnabled public String responseString;
    }
    
    @AuraEnabled
    public static List<FieldsClass> getSobjectFields(String objectName){
        List<FieldsClass> fieldClassList = new List<FieldsClass>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();        
        for (String fieldName: fieldMap.keySet()) {
            if(fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                fieldClassList.add(new FieldsClass(fieldName, fieldMap.get(fieldName).getDescribe().getLabel()));    
            }
        }  
        return fieldClassList;
    }
    
    public class FieldsClass{
        @AuraEnabled public String fieldName;
        @AuraEnabled public String fieldLabel;
        public FieldsClass(String fieldName, String fieldLabel){
            this.fieldName = fieldName;
            this.fieldLabel = fieldLabel;
        }        
    }
    
    @AuraEnabled
    public static List<buildertek__Field_Mapping__c> getFieldMappings(){
        List<buildertek__Field_Mapping__c> fieldMappingList = [SELECT Id, Name FROM buildertek__Field_Mapping__c];
        return fieldMappingList;
    }
    
    @AuraEnabled
    public static String createFieldMapping(String parentFields, String childFields, String fieldMappingName){
        List<ParentFieldMappingWrapper> parentFieldWrapperList = (List<ParentFieldMappingWrapper>)System.JSON.deserialize(parentFields, List<ParentFieldMappingWrapper>.class);
        List<ChildFieldMappingWrapper> childFieldWrapperList = (List<ChildFieldMappingWrapper>)System.JSON.deserialize(childFields, List<ChildFieldMappingWrapper>.class);
        system.debug('childFieldWrapperList -------> '+childFieldWrapperList);
        List<buildertek__Parent_Mapping__c> parentFieldMappingList = new List<buildertek__Parent_Mapping__c>(); 
        List<buildertek__Child_Mapping__c> childFieldMappingList = new List<buildertek__Child_Mapping__c>();
        List<buildertek__Parent_Mapping__c> existingParentMapping = [SELECT Id, buildertek__Mapping_Field__c FROM buildertek__Parent_Mapping__c];
        List<buildertek__Child_Mapping__c> existingChildMapping = [SELECT Id, buildertek__Mapping_Field__c FROM buildertek__Child_Mapping__c];
        /*if(existingParentMapping.size() > 0){
            DELETE existingParentMapping;    
        }
        if(existingChildMapping.size() > 0){
            DELETE existingChildMapping;    
        }*/
        buildertek__Field_Mapping__c fieldMapping = new buildertek__Field_Mapping__c();
        fieldMapping.Name = fieldMappingName;
        insert fieldMapping;
        for(ParentFieldMappingWrapper parentmap : parentFieldWrapperList){
            buildertek__Parent_Mapping__c parentFieldMapping = new buildertek__Parent_Mapping__c(); 
            system.debug('parent label ------>'+parentmap.label);
            if(parentmap.label != '' && parentmap.label != null){
                parentFieldMapping.buildertek__Field_Name__c = parentmap.label;
                parentFieldMapping.buildertek__Mapping_Field__c = parentmap.mappingField;
                parentFieldMapping.buildertek__Field_Mapping__c = fieldMapping.Id;
                parentFieldMapping.buildertek__Field_Value__c = parentmap.value;
                parentFieldMapping.buildertek__Field_Type__c = parentmap.fieldType;
                parentFieldMappingList.add(parentFieldMapping);
            }
        }
        if(parentFieldMappingList.size() > 0){
            insert parentFieldMappingList;    
        }
        List<String> labelsList = new List<String>();
        Integer count = 0;
        for(ChildFieldMappingWrapper childmap : childFieldWrapperList){
            buildertek__Child_Mapping__c childFieldMapping = new buildertek__Child_Mapping__c();
            system.debug('child label ------>'+childmap.label);
            if(childmap.label != '' && childmap.label != null){
                childFieldMapping.buildertek__Field_Name__c = childmap.label;
                childFieldMapping.buildertek__Field_Value__c = childmap.value;
                childFieldMapping.buildertek__Mapping_Field__c = childmap.mappingField;
                childFieldMapping.buildertek__Column_Number__c = childmap.columnIndex;
                childFieldMapping.buildertek__Table_Number__c = childmap.tableId;
                childFieldMapping.buildertek__Header_Label__c = childmap.label;
                childFieldMapping.buildertek__Field_Mapping__c = fieldMapping.Id;
                childFieldMappingList.add(childFieldMapping);
                labelsList.add(childmap.label);
            }
        }
        if(childFieldMappingList.size() > 0){
            insert childFieldMappingList;    
        }
        return fieldMapping.Id;
    }
    
    public class ParentFieldMappingWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String mappingField;
        @AuraEnabled public String fieldType;
    }
    
    public class ChildFieldMappingWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String mappingField;
        @AuraEnabled public Integer rowIndex;
        @AuraEnabled public Integer columnIndex;
        @AuraEnabled public Integer tableId;
        @AuraEnabled public String headerLabel;
    }
    
    @AuraEnabled
    public static ExistingMappingWrapper getExistingMapping(String fieldMappigId){
        buildertek__Field_Mapping__c fieldMapping = [SELECT Id, Name FROM buildertek__Field_Mapping__c WHERE Id =: fieldMappigId];
        List<buildertek__Parent_Mapping__c> existingParentMapping = [SELECT Id, Name, 
                                                                            buildertek__Field_Name__c, 
                                                                            buildertek__Mapping_Field__c,
                                                                     		buildertek__Field_Value__c
                                                                            FROM buildertek__Parent_Mapping__c 
                                                                            WHERE buildertek__Field_Mapping__c =: fieldMappigId];
        List<buildertek__Child_Mapping__c> existingChildMapping = [SELECT Id, Name, buildertek__Field_Name__c,
                                                                   					buildertek__Field_Value__c,
                                                                                    buildertek__Mapping_Field__c, 
                                                                                    buildertek__Column_Number__c, 
                                                                                    buildertek__Table_Number__c,
                                                                                    buildertek__Header_Label__c
                                                                                    FROM buildertek__Child_Mapping__c
                                                                                    WHERE buildertek__Field_Mapping__c =: fieldMappigId];    
        ExistingMappingWrapper EW = new ExistingMappingWrapper();
        EW.ParentFieldsMapping = existingParentMapping;
        EW.ChildFieldsMapping = existingChildMapping;
        EW.fieldMappingName = fieldMapping.Name;
        return EW;
    }
    
    public class ExistingMappingWrapper{
        @AuraEnabled public List<buildertek__Parent_Mapping__c> ParentFieldsMapping;
        @AuraEnabled public List<buildertek__Child_Mapping__c> ChildFieldsMapping;
        @AuraEnabled public String fieldMappingName;
    }
    
    @AuraEnabled
    public static ExistingMappingWrapper updateFieldMapping(String fieldMappingId, String fieldMappingName, List<buildertek__Parent_Mapping__c> parentFields, List<buildertek__Child_Mapping__c> childFields){
        system.debug('parentFields ------> '+parentFields);
        buildertek__Field_Mapping__c fieldMapping = [SELECT Id, Name FROM buildertek__Field_Mapping__c WHERE Id =: fieldMappingId];
        fieldMapping.Name = fieldMappingName;
        update fieldMapping;
        ExistingMappingWrapper EW = new ExistingMappingWrapper();
        if(parentFields.size() > 0){
            update parentFields;    
        }
        if(childFields.size() > 0){
            update childFields;    
        }
        EW.ParentFieldsMapping = parentFields;
        EW.ChildFieldsMapping = childFields;
        return EW;
    }
    
    @AuraEnabled
    public static InvoiceLineDetails createRecord(String tableData, String fieldsData, String fieldMappingId){
        system.debug('tableData -------> '+tableData);
        List<Object> fieldMap = (List<Object>)JSON.deserializeUntyped(fieldsData);
        system.debug('fieldMap ------> '+fieldMap);
        Map<String, Object> a2 = new Map<String, Object>();
        Map<String, Object> a3 = new Map<String, Object>();
        String a4;
        List<buildertek__Parent_Mapping__c> parentFieldMappingList = [SELECT Id, 
                                                                      			Name, 
                                                                      			buildertek__Mapping_Field__c, 
                                                                      			buildertek__Field_Name__c,
                                                                      			buildertek__Field_Type__c,
                                                                      			buildertek__Field_Value__c
                                                                      			FROM buildertek__Parent_Mapping__c 
                                                                      			WHERE buildertek__Field_Mapping__c =: fieldMappingId];
        buildertek__Billings__c invoiceRecord = new buildertek__Billings__c();
        Map<String, String> accountNameMap = new Map<String, String>();
        for(Account acc : [SELECT Id, Name FROM Account]){
            accountNameMap.put(acc.Name, acc.Id);       
        }
        for(buildertek__Parent_Mapping__c parentMap : parentFieldMappingList){
            /*for(Object obj : fieldMap){
                a2 = (Map<String, Object>)obj; 
                a3 = (Map<String, Object>)a2.get(parentMap.buildertek__Field_Name__c);
                if((Map<String, Object>)a2.get(parentMap.buildertek__Field_Name__c) != null){
                    system.debug(a3.get('type'));
                    if(parentMap.buildertek__Mapping_Field__c != null && parentMap.buildertek__Mapping_Field__c != ''){
                        if(a3.get('type') == 'number'){
                            system.debug(parentMap.buildertek__Mapping_Field__c);
                            if(a3.get('valueNumber') != null){
                                a4 = string.valueOf(a3.get('valueNumber'));
                                invoiceRecord.put(parentMap.buildertek__Mapping_Field__c, Decimal.valueOf(a4));    
                            }       
                        }else if(a3.get('type') == 'string'){
                            system.debug(parentMap.buildertek__Mapping_Field__c);
                            if(a3.get('valueString') != null){
                                system.debug('if');
                                a4 = String.valueOf(a3.get('valueString'));
                                if(parentMap.buildertek__Field_Name__c == 'CustomerName'){
                                    if(accountNameMap.get(a4) != null){
                                        invoiceRecord.put(parentMap.buildertek__Mapping_Field__c, accountNameMap.get(a4));    
                                    }else{
                                        invoiceRecord.put(parentMap.buildertek__Mapping_Field__c, '');    
                                    }
                                         
                                }else{
                                    invoiceRecord.put(parentMap.buildertek__Mapping_Field__c, a4); 
                                }   
                            }       
                        }else if(a3.get('type') == 'date'){
                            system.debug(parentMap.buildertek__Mapping_Field__c);
                            if(a3.get('text') != null){
                                a4 = String.valueOf(a3.get('text'));
                                if(a4.contains('/')){
                                    invoiceRecord.put(parentMap.buildertek__Mapping_Field__c, date.parse(a4));    
                                }else{
                                    invoiceRecord.put(parentMap.buildertek__Mapping_Field__c, date.valueOf(a4));       
                                }  
                            }       
                        }    
                    }    
                }
                
            } */
            if(parentMap.buildertek__Mapping_Field__c != null && parentMap.buildertek__Mapping_Field__c != ''){
                if(parentMap.buildertek__Field_Type__c == 'number'){
                	system.debug(parentMap.buildertek__Mapping_Field__c);
                    if(parentMap.buildertek__Field_Value__c != null && parentMap.buildertek__Field_Value__c != ''){
                        a4 = parentMap.buildertek__Field_Value__c;
                        if(a4.contains('$')){
                        	a4 = a4.replace('$', '');    
                        }
                        invoiceRecord.put(parentMap.buildertek__Mapping_Field__c, Decimal.valueOf(a4));    
                    }    
                }else if(parentMap.buildertek__Field_Type__c == 'string'){
                	system.debug(parentMap.buildertek__Mapping_Field__c);
                    if(parentMap.buildertek__Field_Value__c != null && parentMap.buildertek__Field_Value__c != ''){
                        system.debug('if');
                        a4 = parentMap.buildertek__Field_Value__c;
                        if(parentMap.buildertek__Field_Name__c == 'CustomerName'){
                            if(accountNameMap.get(a4) != null){
                                invoiceRecord.put(parentMap.buildertek__Mapping_Field__c, accountNameMap.get(a4));    
                            }else{
                                invoiceRecord.put(parentMap.buildertek__Mapping_Field__c, '');    
                            }
                            
                        }else{
                            invoiceRecord.put(parentMap.buildertek__Mapping_Field__c, a4); 
                        }   
                    }             
                }else if(parentMap.buildertek__Field_Type__c == 'date'){
                	if(parentMap.buildertek__Field_Value__c != null && parentMap.buildertek__Field_Value__c != ''){
                        a4 = parentMap.buildertek__Field_Value__c;
                        if(a4.contains('/')){
                            invoiceRecord.put(parentMap.buildertek__Mapping_Field__c, date.parse(a4));    
                        }else{
                            invoiceRecord.put(parentMap.buildertek__Mapping_Field__c, date.valueOf(a4));       
                        }  
                    }    
                }
            }
        }
        system.debug('invoiceRecord -----> '+invoiceRecord);
        insert invoiceRecord;
        List<tableClass> tableClassList = new List<tableClass>();
        List<Object> tablesList = (List<Object>)JSON.deserializeUntyped(tableData);
        Map<String, Object> tablesMap = new Map<String, Object>();
        List<Object> cellList = new List<Object>();
        Map<String, Object> cellsMap = new Map<String, Object>();
        for(Object obj : tablesList){
            tablesMap = (Map<String, Object>)obj;
            cellList = (List<Object>)tablesMap.get('cells');
            for(Object obj1 : cellList){
                cellsMap = (Map<String, Object>)obj1;
                if(cellsMap.get('rowIndex') != 0){
                    String textValue = String.valueOf(cellsMap.get('text'));
                    if(textValue.contains('$')){
                        textValue = textValue.replace('$', '');    
                    }
                    tableClassList.add(new tableClass(Integer.valueOf(cellsMap.get('rowIndex')), Integer.valueOf(cellsMap.get('columnIndex')), textValue, Integer.valueOf(cellsMap.get('tableId')), String.valueOf(cellsMap.get('headerLabel'))));    
                }
            }
        }
        Integer count = 1;
        Integer columnCount = 0;
        List<buildertek__Child_Mapping__c> existingChildMapping = [SELECT Id, Name, buildertek__Field_Name__c, 
                                                                                    buildertek__Mapping_Field__c, 
                                                                                    buildertek__Column_Number__c, 
                                                                                    buildertek__Table_Number__c,
                                                                                    buildertek__Header_Label__c
                                                                                    FROM buildertek__Child_Mapping__c
                                                                                    WHERE buildertek__Field_Mapping__c =: fieldMappingId
                                                                                    AND buildertek__Mapping_Field__c !=  null 
                                                                                    ORDER BY buildertek__Table_Number__c ASC];    
        List<buildertek__Billable_Lines__c> invoiceLinesList = new List<buildertek__Billable_Lines__c>();
        Map<String, Decimal> columnIndexMap = new Map<String, Decimal>();
        Map<String, Decimal> tableNumberMap = new Map<String, Decimal>();
        Map<String, Decimal> rowIndexMap = new Map<String, Decimal>();
        Map<String, String> mappedFieldMap = new Map<String, String>();
        for(buildertek__Child_Mapping__c childMap : existingChildMapping){
            if(childMap.buildertek__Header_Label__c != null && childMap.buildertek__Header_Label__c != ''){
                columnIndexMap.put(childMap.buildertek__Header_Label__c, childMap.buildertek__Column_Number__c); 
                tableNumberMap.put(childMap.buildertek__Header_Label__c, childMap.buildertek__Table_Number__c);
                mappedFieldMap.put(childMap.buildertek__Header_Label__c, childMap.buildertek__Mapping_Field__c);
            }  
        }
        system.debug('columnIndexMap ------> '+columnIndexMap);
        system.debug('tableNumberMap ------> '+tableNumberMap);
        system.debug('mappedFieldMap ------> '+mappedFieldMap);
        String invoiceLineJSON = '[';
        List<String> fieldValuesList = new List<String>();
        SET<Integer> tableIds = new SET<Integer>();
        SET<Integer> rowIds = new SET<Integer>();
        system.debug('tableClassList --------> '+tableClassList);
        for(tableClass tb : tableClassList){
            system.debug('hea'+tb.headerLabel);
            system.debug('table Id -------> '+tb.tableId+' == '+tableNumberMap.get(tb.headerLabel));
            system.debug('column Index -------> '+tb.columnIndex+' == '+columnIndexMap.get(tb.headerLabel));
            if(tb.tableId == tableNumberMap.get(tb.headerLabel) && tb.columnIndex == columnIndexMap.get(tb.headerLabel)){
                system.debug('mapped ------> '+mappedFieldMap.get(tb.headerLabel));
                if(mappedFieldMap.get(tb.headerLabel) != null){
                    String fieldType = getFieldType('buildertek__Billable_Lines__c', mappedFieldMap.get(tb.headerLabel));
                    fieldValuesList.add(mappedFieldMap.get(tb.headerLabel)+'-'+tb.text+'-'+fieldType+'-'+tb.tableId+'-'+tb.rowIndex);
                    tableIds.add(tb.tableId);
                    rowIds.add(tb.rowIndex);
                }    
            }       
        }
        String jsonString = '';
        Map<String, String> productNameMap = new Map<String, String>();
        for(Product2 prod : [SELECT Id, Name FROM Product2]){
            productNameMap.put(prod.Name.toLowerCase(), prod.Id);    
        }
        system.debug('tableIds --------> '+tableIds);
        system.debug('rowIds --------> '+rowIds);
        system.debug('fieldValuesList --------> '+fieldValuesList);
        for(Integer tabId : tableIds){
            for(Integer rowId : rowIds){
                jsonString += '{';
                for(String str : fieldValuesList){
                    String[] fields = str.split('-');
                    system.debug('fields 4 -------> '+fields[4]);
                    system.debug('fields 3 -------> '+fields[3]);
                    system.debug('fields 2 -------> '+fields[2]);
                    system.debug('fields 1 -------> '+fields[1]);
                    system.debug('is numeric -------> '+fields[3].isNumeric());
                    if(fields[3].isNumeric()){
                        system.debug('tab Id ------> '+tabId+' == '+Integer.valueOf(fields[3]));
                        system.debug('row Id ------> '+rowId+' == '+Integer.valueOf(fields[4]));
                    	if(tabId == Integer.valueOf(fields[3]) && rowId == Integer.valueOf(fields[4])){
                            if(fields[2] == 'CURRENCY' || fields[2] == 'PERCENT' || fields[2] == 'DOUBLE'){
                                if(fields[1].contains('$')){
                                    fields[1] = fields[1].replace('$', '');    
                                }else if(fields[1].contains('%')){
                                    fields[1] = fields[1].replace('%', '');    
                                }else if(fields[1].contains(',')){
                                	fields[1] = fields[1].replace(',', '');    
                                }
                                if(isNumber(fields[1])){
                                	if(fields[1] != null && fields[1] != ''){
                                        jsonString += '"'+fields[0]+'": '+Decimal.valueOf(fields[1])+',';     
                                    }else{
                                        jsonString += '"'+fields[0]+'": "",'; 
                                    }    
                                }
                            }else{
                                if(fields[0].contains('product')){
                                    system.debug('Field -------> '+fields[1].toLowerCase());
                                    system.debug('product Id -------> '+productNameMap.get(fields[1].toLowerCase()));
                                    if(productNameMap.get(fields[1].toLowerCase()) != null){
                                        jsonString += '"'+fields[0]+'": "'+productNameMap.get(fields[1].toLowerCase())+'",';     
                                    } 
                                }else{
                                    jsonString += '"'+fields[0]+'": "'+fields[1]+'",';    
                                }                            
                            }
                        }     
                    }
                    
                }
                jsonString += '"buildertek__Billings__c": "'+invoiceRecord.Id+'"';
                //jsonString = jsonString.removeEnd(',');
                jsonString += '},';
            }
        }
        jsonString = jsonString.removeEnd(',');
        system.debug('jsonString ------> '+jsonString);
        invoiceLineJSON += jsonString;
        invoiceLineJSON += ']';
        InvoiceLineDetails ILD = new InvoiceLineDetails();
        ILD.invoiceLineJson = invoiceLineJSON;
        ILD.invoiceId = invoiceRecord.Id;
        return ILD;
    }
    
    public class InvoiceLineDetails{
        @AuraEnabled public String invoiceLineJson;
        @AuraEnabled public String invoiceId;
    }
    
    @AuraEnabled
    public static String createIncoiceLineItems(String invoiceId, String invoiceLinesString){ 
        system.debug('invoiceLinesString --------> '+invoiceLinesString);
        system.debug('invoiceId --------> '+invoiceId);
		List<buildertek__Billable_Lines__c> invoiceLinesList = (List<buildertek__Billable_Lines__c>)System.JSON.deserialize(invoiceLinesString, List<buildertek__Billable_Lines__c>.class);  
        system.debug('invoiceLinesList ---------> '+invoiceLinesList);
        if(invoiceLinesList.size() > 0){
         	insert invoiceLinesList;   
        }
        return invoiceId;
    }
    
    @AuraEnabled
    public static List<buildertek__Field_Mapping__c> getAllFieldMappings(){
        List<buildertek__Field_Mapping__c> fieldMappingList = [SELECT Id, Name FROM buildertek__Field_Mapping__c];  
        return fieldMappingList;
    }
    
    public static String getFieldType(String objectName, String fieldName){
        SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        string fieldType = String.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType());
        return fieldType;
    }
    
    public static Boolean isNumber(String str){
    	Pattern isnumbers = Pattern.Compile('[0-9]*\\.?[0-9]*');
     	Matcher numberMatch = isnumbers.matcher(str);
     	return numberMatch.Matches();    
    } 
    
    public class tableClass{
        public Integer rowIndex;
        public Integer columnIndex;
        public String text;
        public Integer tableId;
        public String headerLabel;
        public tableClass(Integer rowIndex, Integer columnIndex, String text, Integer tableId, String headerLabel){
            this.rowIndex = rowIndex;
            this.columnIndex = columnIndex;
            this.text = text;
            this.tableId = tableId;
            this.headerLabel = headerLabel;
        }
    }
 }