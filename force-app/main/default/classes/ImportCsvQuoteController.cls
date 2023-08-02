public with sharing class ImportCsvQuoteController {
    // public Blob fileContent {get; set;}
    // public String strFileName {get; set;}
    
    // public ImportBudgetController(ApexPages.StandardSetController controller) {}
    
    public virtual class ResponseBase {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String strMessage;
        @AuraEnabled public String strRecordId;
    }
    
    @AuraEnabled
    public static ResponseBase importBudgets(Id budgetId, String fileData) {
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        
        try {
            if(fileData != null) {
                List<List<String>> listCSVData;
                String strFileData;
                Blob fileContent = EncodingUtil.base64Decode(fileData);
                
                try {
                    // strFileData = EncodingUtil.base64Encode(EncodingUtil.base64Decode(fileData));
                    strFileData = fileContent.toString();
                }
                catch(Exception ex) {
                    try {
                        strFileData = EncodingUtil.base64Encode(fileContent);
                    }
                    catch(Exception iex) {
                        response.isSuccess = false;
                        response.strMessage = iex.getMessage();
                    }
                }
                
                System.debug('strFileData ::: '+strFileData);
                
                if(!String.isBlank(strFileData) && response.isSuccess) {
                    List<buildertek__Quote_Item__c > listQuotes = new List<buildertek__Quote_Item__c >();
                    listCSVData = getListOfFileContentsAsStrings(strFileData);
					Map<String,buildertek__Quote_Item__c > quoteItemMap = new Map<String,buildertek__Quote_Item__c >();

                    //get id from name 
                    List<String> productList = new List<String>();
                    List<String> costCodeList = new List<String>();
                    List<String> groupingList = new List<String>();
                    
                    Map<String,Product2> productMap=new Map<String,Product2>();
                    Map<String,buildertek__Cost_Codes__c> costCodeMap=new Map<String,buildertek__Cost_Codes__c>();
                    Map<String,buildertek__Quote_Line_Group__c> groupingMap=new Map<String,buildertek__Quote_Line_Group__c>();
                    
                    for(Integer intIndex = 1; intIndex < listCSVData.size(); intIndex++) {
                        for(Integer intInnerIndex = 0; intInnerIndex < listCSVData.get(intIndex).size(); intInnerIndex++) {
                            switch on listCSVData.get(0).get(intInnerIndex) {
                                when 'Product Description' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                        productList.add(listCSVData.get(intIndex).get(intInnerIndex).replace('\n',''));
                                    }
                                }
                                when 'Cost Code' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                        //quote.buildertek__Cost_Code__c = listCSVData.get(intIndex).get(intInnerIndex);
                                        costCodeList.add(listCSVData.get(intIndex).get(intInnerIndex).replace('\n',''));
                                    }
                                }
                                when 'Grouping' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                       // quote.buildertek__Grouping__c = listCSVData.get(intIndex).get(intInnerIndex).trim();
                                       groupingList.add(listCSVData.get(intIndex).get(intInnerIndex).replace('\n',''));
                                    }
                                }
                            }
                        }
                    }
                    List<Product2> productLst;
                    if(Schema.sObjectType.Product2.fields.Id.isAccessible()&&
                        Schema.sObjectType.Product2.fields.Name.isAccessible() ){
                        productLst=[select id,name from product2 where name in :productList];
                        }
                    List<buildertek__Cost_Codes__c> costCodeLst;
                    if(Schema.sObjectType.buildertek__Cost_Codes__c.fields.Id.isAccessible()&&
                        Schema.sObjectType.buildertek__Cost_Codes__c.fields.Name.isAccessible() ){
                         costCodeLst=[select id,name from buildertek__Cost_Codes__c where name in :costCodeList];
                        }
                     List<buildertek__Quote_Line_Group__c> groupingLst;
                    if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible()&&
                        Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible() ){
                        groupingLst=[select id,name from buildertek__Quote_Line_Group__c where name in :groupingList];
                        }
                    for(product2 pItem : productLst){
                        productMap.put(pItem.Name.toLowerCase(),pItem);
                    }
                    for(buildertek__Cost_Codes__c costCodeItem : costCodeLst){
                        costCodeMap.put(costCodeItem.Name.toLowerCase(),costCodeItem);
                    }
                    for(buildertek__Quote_Line_Group__c groupingItem : groupingLst){
                        groupingMap.put(groupingItem.Name.toLowerCase(),groupingItem);
                    } 
                    
                    //get quote Items
                    
                    for(Integer intIndex = 1; intIndex < listCSVData.size(); intIndex++) {
                        buildertek__Quote_Item__c  quote = new buildertek__Quote_Item__c (Quote__c = budgetId);
                        
                        for(Integer intInnerIndex = 0; intInnerIndex < listCSVData.get(intIndex).size(); intInnerIndex++) {
                            switch on listCSVData.get(0).get(intInnerIndex) {
                                when 'Grouping' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                       // quote.buildertek__Grouping__c = listCSVData.get(intIndex).get(intInnerIndex).trim();
                                       String groupingName=listCSVData.get(intIndex).get(intInnerIndex).replace('\n','');
                                        if(groupingMap.containsKey(groupingName.toLowerCase())){
                                            quote.buildertek__Grouping__c =groupingMap.get(groupingName.toLowerCase()).id;
                                        }
                                    }
                                }
                                
                                when 'Product Description' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                    	//quote.buildertek__Product__c =listCSVData.get(intIndex).get(intInnerIndex).trim();
                                        String productName=listCSVData.get(intIndex).get(intInnerIndex).replace('\n','');
                                        if(productMap.containsKey(productName.toLowerCase())){
                                            quote.buildertek__Product__c =productMap.get(productName.toLowerCase()).id;
                                        }
                                        if(productName!=''){
                                            quote.Name=productName;
                                        }
                                    }
                                }
                                
                                when 'Quantity' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                        quote.buildertek__Quantity__c = Decimal.valueOf(listCSVData.get(intIndex).get(intInnerIndex));
                                    }
                                }
                                
                                when 'Unit Cost' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                        quote.buildertek__Unit_Cost__c = Decimal.valueOf(listCSVData.get(intIndex).get(intInnerIndex));
                                    }
                                }
                                
                                when 'Cost Code' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                        //quote.buildertek__Cost_Code__c = listCSVData.get(intIndex).get(intInnerIndex);
                                        String costCodeName=listCSVData.get(intIndex).get(intInnerIndex).replace('\n','');
                                        if(costCodeMap.containsKey(costCodeName.toLowerCase())){
                                            quote.buildertek__Cost_Code__c =costCodeMap.get(costCodeName.toLowerCase()).id;
                                        }
                                    }
                                }
                                
                                when 'UOM' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                        quote.buildertek__UOM__c = listCSVData.get(intIndex).get(intInnerIndex);
                                    }
                                }
                                
                                when 'Markup' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                        quote.buildertek__Markup__c = Decimal.valueOf(listCSVData.get(intIndex).get(intInnerIndex).replace('%',''));
                                    }
                                }
                                
                                when 'quote Mods' {
                                    // quote.Product__c = listCSVData.get(intIndex).get(intInnerIndex);
                                }
                                
                                when 'Projected Costs' {
                                    // quote.Product__c = listCSVData.get(intIndex).get(intInnerIndex);
                                }
                            }
                        }
                        listQuotes.add(quote);
                        
                    }
                    
                    
                    if(!listQuotes.isEmpty()) {
                        if(Schema.sObjectType.buildertek__Quote_Item__c.isCreateable()&&
                            Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isCreateable()&&
                            Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isCreateable() &&
                			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isCreateable() &&
                			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Additional_Discount__c.isCreateable() &&
                            Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Description__c.isCreateable()&&
                            Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Applied_Markup__c.isCreateable() &&
                			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isCreateable() &&
                			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isCreateable() &&
                            Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isCreateable()&&
                            Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isCreateable() &&
                			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isCreateable() &&
                			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isCreateable() &&
                			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Vendor__c.isCreateable() ){
                                insert listQuotes;
                			}
                        response.strMessage = 'Quote line items inserted successfully.';
                    }
                    else {
                        response.isSuccess = false;
                        response.strMessage = 'No quote line items present.';
                    }
                }
                else {
                    response.isSuccess = false;
                    response.strMessage = 'Please select valid CSV file.';
                }
            }
        }
        catch(Exception ex) {
            response.isSuccess = false;
            response.strMessage = ex.getMessage();
        }
        
        return response;
    }
    
    /*
        @ Purpose     : Parse each row and column value into the element of List.
        @ Parameters  : String [ Contents of CSV file ].
        @ Return Type : List<List<String>> [ List of rows and Each row will have the list of columns ].
    */
    public static List<List<String>> getListOfFileContentsAsStrings(String strContents) {
        List<List<String>> listOfFileContentsAsStrings;
        if(String.isNotBlank(strContents)) {
            List<String> listLines;
            
            if(strContents.contains('\r')) {
                // Split up the file contents into List of rows [ Using new line ].
                listLines = strContents.split('\r');
            }
            else if(strContents.contains('\n')) {
                // Split up the file contents into List of rows [ Using new line ].
                listLines = strContents.split('\n');
            }
            
            if(listLines != Null && !listLines.isEmpty()) {
                // Appending cell values separated by New Lines.
                listLines = appendCellValuesSeparatedByNewLines(listLines);
                if(listLines != Null && !listLines.isEmpty()) {
                    
                    // Split up the each element of the list into List of columns [ Using comma ].
                    List<String> listRowContents;
                    listOfFileContentsAsStrings = new List<List<String>>();
                    for(String line : listLines) {
                        
                        if(line.contains(',')) {
                            listRowContents = line.split(',');
                            if(listRowContents != Null && !listRowContents.isEmpty()) {
                                
                                // Appending cell values separated by Commas.
                                listRowContents = appendCellValuesSeparatedByCommas(listRowContents);
                                if(listRowContents != Null && !listRowContents.isEmpty()) {
                                    listOfFileContentsAsStrings.add(listRowContents);
                                }
                            }   
                        }     
                    }
                }
            }
        }
        
        system.debug('listOfFileContentsAsStrings:-\n' + JSON.serialize(listOfFileContentsAsStrings));
        return listOfFileContentsAsStrings;
    }
    
    /*
        @ Purpose     : Appends the CSV cells which are separated by New Line.
        @ Parameters  : List<String> [ List holds the strings separated by New Line ].
        @ Return Type : List<String> [ List appends the strings belong to same CSV cell ].
    */
    public Static List<String> appendCellValuesSeparatedByNewLines(List<String> listValues) {
        
        List<String> listToAppendCellValues;
        if(listValues != Null && !listValues.isEmpty()) {
            
            Boolean isNewLineFound = False;
            String strValueToBeMerged = '';
            listToAppendCellValues = new List<String>();
            Integer intCountDoubleQuotes;
            
            for(String strValue : listValues) {
                
                if(!isNewLineFound) {
                    intCountDoubleQuotes = strValue.countMatches('\"');
                    if(intCountDoubleQuotes == 1) {
                        isNewLineFound = True;        
                    }
                }
                
                if(isNewLineFound) {
                   strValueToBeMerged += strValue + '\n';
                   if(strValue.contains('\",')) {
                       
                       intCountDoubleQuotes = strValue.countMatches('\"');
                       if(Math.mod(intCountDoubleQuotes,2) != 0) {
                       
                           isNewLineFound = False;
                           listToAppendCellValues.add(strValueToBeMerged);
                           strValueToBeMerged = '';
                       }
                   } 
                }
                else {
                    listToAppendCellValues.add(strValue);
                }
            }     
        }
        return listToAppendCellValues;
    }
    
    /*
        @ Purpose     : Appends the CSV cells which are separated by Commas.
        @ Parameters  : List<String> [ List holds the strings separated by Commas ].
        @ Return Type : List<String> [ List appends the strings belong to same CSV cell ].
    */
    public static List<String> appendCellValuesSeparatedByCommas(List<String> listValues) {
        
        List<String> listToAppendCellValues;
        if(listValues != Null && !listValues.isEmpty()) {
            
            Boolean isCommaFoundInTheValue;
            listToAppendCellValues = new List<String>();
            String strValueToBeMerged = '';
            Integer intCountDoubleQuotes = 0;
            
            for(String strValue : listValues) {
            
                if(isCommaFoundInTheValue == Null) {
                    if(strValue.startsWith('\"')) {
                        isCommaFoundInTheValue = True;
                        if(strValue.endsWith('\"')) {
                            if(strValue.contains('\n') || strValue.contains('\r')) {
                                isCommaFoundInTheValue = False;
                            }
                            else {
                                intCountDoubleQuotes = strValue.countMatches('\"');
                                if(Math.mod(intCountDoubleQuotes,2) == 0) {
                                    isCommaFoundInTheValue = False;
                                }
                            }
                        }
                    }
                }
                else if(strValue.endsWith('\"')) {
                    intCountDoubleQuotes = strValue.countMatches('\"');
                    if(Math.mod(intCountDoubleQuotes,2) != 0) {
                        isCommaFoundInTheValue = False;
                    }
                }
                
                if(isCommaFoundInTheValue != Null) {
                    if(isCommaFoundInTheValue) {
                        strValueToBeMerged += strValue + ',';   
                    }
                    else {
                        strValueToBeMerged += strValue;
                        if(strValueToBeMerged.contains('\"')) {
                            strValueToBeMerged = strValueToBeMerged.replaceAll('\\\"+','"');
                        }
                        listToAppendCellValues.add(strValueToBeMerged);
                        strValueToBeMerged = '';
                        isCommaFoundInTheValue = Null;
                    } 
                }
                else {
                    listToAppendCellValues.add(strValue);   
                }
            }
        }
        return listToAppendCellValues;
    }
}