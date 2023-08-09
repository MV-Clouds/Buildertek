public with sharing class ImportScheduleController {
    public virtual class ResponseBase {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String strMessage;
        @AuraEnabled public String strRecordId;
    }
    
    @AuraEnabled
    public static ResponseBase importSchedules(Id budgetId, String fileData) {
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
                    List<buildertek__Project_Task__c> listBudgets = new List<buildertek__Project_Task__c>();
                    listCSVData = getListOfFileContentsAsStrings(strFileData);
                    
                    for(Integer intIndex = 1; intIndex < listCSVData.size(); intIndex++) {
                        if(Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Schedule__c.isCreateable()){
                            buildertek__Project_Task__c budget = new buildertek__Project_Task__c(buildertek__Schedule__c = budgetId);
                        
                        for(Integer intInnerIndex = 0; intInnerIndex < listCSVData.get(intIndex).size(); intInnerIndex++) {
                            switch on listCSVData.get(0).get(intInnerIndex) {
                                when 'Task Name' {
                                    if(Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isCreateable()){
                                        budget.Name = listCSVData.get(intIndex).get(intInnerIndex);
                                    }
                                }
                                when 'Dependency' {
                                    if(Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Dependency__c.isCreateable()){
                                        budget.buildertek__Dependency__c = listCSVData.get(intIndex).get(intInnerIndex);
                                    }
                                }
                                
                                when 'Start Date' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                        if(Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Start__c.isCreateable()){
                                            budget.buildertek__Start__c = Date.valueOf(listCSVData.get(intIndex).get(intInnerIndex));
                                        }
                                    }
                                }
                                
                                when 'Duration' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                        if(Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Duration__c.isCreateable()){
                                            budget.buildertek__Duration__c = Decimal.valueOf(listCSVData.get(intIndex).get(intInnerIndex));
                                        }
                                    }
                                }
                            
                                when 'Required Completion Date' {
                                    if(String.isNotBlank(listCSVData.get(intIndex).get(intInnerIndex))) {
                                        if(Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Required_Completion_Date__c.isCreateable()){
                                            budget.buildertek__Required_Completion_Date__c = Date.valueOf(listCSVData.get(intIndex).get(intInnerIndex));
                                        }
                                    }
                                }
                            }
                        }
                    
                        listBudgets.add(budget);
                    }
                    }
                    if(!listBudgets.isEmpty()) {
                        insert listBudgets;
                        response.strMessage = 'Budget line items inserted successfully.';
                    }
                    else {
                        response.isSuccess = false;
                        response.strMessage = 'No budget line items present.';
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