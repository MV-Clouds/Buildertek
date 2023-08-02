public with sharing class ImportTakeOffLinesCSV{
    public virtual class ResponseBase{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String strMessage;
        @AuraEnabled
        public String strRecordId;
    }

    @AuraEnabled
    public static ResponseBase importRecords(Id budgetId, String fileData){
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        WrapperClass wrapper = new WrapperClass();
        Set<String> groupNames = new Set<String>();
        try{
            if (fileData != null){
                List<List<String>> listCSVData;
                String strFileData;
                Blob fileContent = EncodingUtil.base64Decode(fileData);
                try{
                    strFileData = fileContent.toString();
                } catch (Exception ex){
                    try{
                        strFileData = EncodingUtil.base64Encode(fileContent);
                    } catch (Exception iex){
                        response.isSuccess = false;
                        response.strMessage = iex.getMessage();
                    }
                }

                if (!String.isBlank(strFileData) && response.isSuccess){
                    
                } else{
                    response.isSuccess = false;
                    response.strMessage = 'Please select valid CSV file.';
                }
            }
        } catch (Exception ex){
            response.isSuccess = false;
            response.strMessage = ex.getMessage();
            System.debug('Message:2:' + ex.getMessage());
            System.debug('Line:2:' + ex.getLineNumber());
        }
        return response;
    }

    /*
     @ Purpose     : Parse each row and column value into the element of List.
     @ Parameters  : String [ Contents of CSV file ].
     @ Return Type : List<List<String>> [ List of rows and Each row will have the list of columns ].
     */
    public static WrapperClass getListOfFileContentsAsStrings(String strContents){
        WrapperClass wrapper = new WrapperClass();
        List<List<String>> listOfFileContentsAsStrings;
        Set<String> groupNames = new Set<String>();
        if (String.isNotBlank(strContents)){
            List<String> listLines;

            if (strContents.contains('\r')){
                // Split up the file contents into List of rows [ Using new line ].
                listLines = strContents.split('\r');
            } else if (strContents.contains('\n')){
                // Split up the file contents into List of rows [ Using new line ].
                listLines = strContents.split('\n');
            }

            if (listLines != Null && !listLines.isEmpty()){
                // Appending cell values separated by New Lines.
                listLines = appendCellValuesSeparatedByNewLines(listLines);
                if (listLines != Null && !listLines.isEmpty()){

                    // Split up the each element of the list into List of columns [ Using comma ].
                    List<String> listRowContents;
                    listOfFileContentsAsStrings = new List<List<String>>();
                    for (String line : listLines){

                        if (line.contains(',')){
                            listRowContents = line.split(',');
                            if (listRowContents != Null && !listRowContents.isEmpty()){

                                // Appending cell values separated by Commas.
                                listRowContents = appendCellValuesSeparatedByCommas(listRowContents);
                                if (listRowContents != Null && !listRowContents.isEmpty()){
                                    listOfFileContentsAsStrings.add(listRowContents);
                                    groupNames.add(listRowContents[0].replace('\n', ''));
                                }
                            }
                        }
                    }
                }
            }
        }

        wrapper.listOfFileContentsAsStrings = listOfFileContentsAsStrings;
        wrapper.groupNames = groupNames;
        return wrapper;
    }

    /*
     @ Purpose     : Appends the CSV cells which are separated by New Line.
     @ Parameters  : List<String> [ List holds the strings separated by New Line ].
     @ Return Type : List<String> [ List appends the strings belong to same CSV cell ].
     */
    public Static List<String> appendCellValuesSeparatedByNewLines(List<String> listValues){

        List<String> listToAppendCellValues;
        if (listValues != Null && !listValues.isEmpty()){

            Boolean isNewLineFound = False;
            String strValueToBeMerged = '';
            listToAppendCellValues = new List<String>();
            Integer intCountDoubleQuotes;

            for (String strValue : listValues){

                if (!isNewLineFound){
                    intCountDoubleQuotes = strValue.countMatches('\"');
                    if (intCountDoubleQuotes == 1){
                        isNewLineFound = True;
                    }
                }

                if (isNewLineFound){
                    strValueToBeMerged += strValue + '\n';
                    if (strValue.contains('\",')){

                        intCountDoubleQuotes = strValue.countMatches('\"');
                        if (Math.mod(intCountDoubleQuotes, 2) != 0){

                            isNewLineFound = False;
                            listToAppendCellValues.add(strValueToBeMerged);
                            strValueToBeMerged = '';
                        }
                    }
                } else{
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
    public static List<String> appendCellValuesSeparatedByCommas(List<String> listValues){

        List<String> listToAppendCellValues;
        if (listValues != Null && !listValues.isEmpty()){

            Boolean isCommaFoundInTheValue;
            listToAppendCellValues = new List<String>();
            String strValueToBeMerged = '';
            Integer intCountDoubleQuotes = 0;

            for (String strValue : listValues){

                if (isCommaFoundInTheValue == Null){
                    if (strValue.startsWith('\"')){
                        isCommaFoundInTheValue = True;
                        if (strValue.endsWith('\"')){
                            if (strValue.contains('\n') || strValue.contains('\r')){
                                isCommaFoundInTheValue = False;
                            } else{
                                intCountDoubleQuotes = strValue.countMatches('\"');
                                if (Math.mod(intCountDoubleQuotes, 2) == 0){
                                    isCommaFoundInTheValue = False;
                                }
                            }
                        }
                    }
                } else if (strValue.endsWith('\"')){
                    intCountDoubleQuotes = strValue.countMatches('\"');
                    if (Math.mod(intCountDoubleQuotes, 2) != 0){
                        isCommaFoundInTheValue = False;
                    }
                }

                if (isCommaFoundInTheValue != Null){
                    if (isCommaFoundInTheValue){
                        strValueToBeMerged += strValue + ',';
                    } else{
                        strValueToBeMerged += strValue;
                        if (strValueToBeMerged.contains('\"')){
                            strValueToBeMerged = strValueToBeMerged.replaceAll('\\\"+', '"');
                        }
                        listToAppendCellValues.add(strValueToBeMerged);
                        strValueToBeMerged = '';
                        isCommaFoundInTheValue = Null;
                    }
                } else{
                    listToAppendCellValues.add(strValue);
                }
            }
        }
        return listToAppendCellValues;
    }
    
    @AuraEnabled
    public static String insertData(String recordId, String strFileData){
        // try{
        String returnresponse = '';
        system.debug('strFileData::::::'+strFileData);
        
        List<buildertek__Project_Takeoff_Lines__c> schItemToInsert = new List<buildertek__Project_Takeoff_Lines__c>();
        List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strFileData, List<fieldWrapper>.class);
        Map<String, String> myMap = new Map<String, String>();
        Map<String, Decimal> durationMap = new Map<String, Decimal>();
        set<String> tradeTypeName = new set<String>();
        set<String> productTypeName = new set<String>();
        set<String> categoryName = new set<String>();
        set<String> BuildPhaseName = new set<String>();
        set<String> PriceBookName = new set<String>();
        for (fieldWrapper wrapper : datalist){
            System.debug('wrapper::'+wrapper);
            if (wrapper.TradeType != null  && String.isNotBlank(wrapper.TradeType) &&
                wrapper.ProductType != null && String.isNotBlank(wrapper.ProductType) &&
                wrapper.BuildPhase != null && String.isNotBlank(wrapper.BuildPhase) &&
                wrapper.Category != null && String.isNotBlank(wrapper.Category) &&
                wrapper.PriceBook != null && String.isNotBlank(wrapper.PriceBook)){
                    tradeTypeName.add(wrapper.TradeType);
                    productTypeName.add(wrapper.ProductType);
                    categoryName.add(wrapper.Category);
                    BuildPhaseName.add(wrapper.BuildPhase);
                    PriceBookName.add(wrapper.PriceBook);
                }
        }
        Map<String,String> mapTradeTypeId = new Map<String,String>();
        List<buildertek__Trade_Type__c> tradeTypeRecList = [SELECT Id, Name FROM buildertek__Trade_Type__c WHERE Name = :tradeTypeName];
        system.debug('tradeTypeRecList'+tradeTypeRecList);
        if(tradeTypeRecList.size()>0){
            for(buildertek__Trade_Type__c tradetype :tradeTypeRecList){
                mapTradeTypeId.put(tradetype.Name,tradetype.Id);
                system.debug(mapTradeTypeId);
            }
        }
        Map<String,String> mapProductTypeId = new Map<String,String>();
        List<buildertek__Product_Type__c> productTypeRecList = [SELECT Id, Name FROM buildertek__Product_Type__c WHERE Name = :productTypeName];
        if(productTypeRecList.size()>0){
            for(buildertek__Product_Type__c producttype :productTypeRecList){
                mapProductTypeId.put(producttype.Name,producttype.Id);
            }
        }
        Map<String,String> mapCategoryId = new Map<String,String>();
        List<buildertek__Category__c> categoryRecList = [SELECT Id, Name FROM buildertek__Category__c WHERE Name = :categoryName];
        if(categoryRecList.size()>0){
            for(buildertek__Category__c category :categoryRecList){
                mapCategoryId.put(category.Name,category.Id);
            }
        }
        
        Map<String,String> mapBuildPhaseId = new Map<String,String>();
        List<buildertek__Build_Phase__c> buildPhaseRecList = [SELECT Id, Name FROM buildertek__Build_Phase__c WHERE Name = :BuildPhaseName];
        if(buildPhaseRecList.size()>0){
            for(buildertek__Build_Phase__c buildPhase :buildPhaseRecList){
                mapBuildPhaseId.put(buildPhase.Name,buildPhase.Id);
            }
        }

        Map<String,String> mapPriceBookId = new Map<String,String>();
        List<Pricebook2> priceBookRecList = [SELECT Id, Name FROM Pricebook2 WHERE Name = :PriceBookName];
        if(priceBookRecList.size()>0){
            for(Pricebook2 priceBook :priceBookRecList){
                mapPriceBookId.put(priceBook.Name,priceBook.Id);
            }
        }
        
        for (fieldWrapper wrapper : datalist){
            System.debug('wrapper::'+wrapper);
            
            buildertek__Project_Takeoff_Lines__c schItem = new buildertek__Project_Takeoff_Lines__c();
            schItem.buildertek__Project_Takeoff__c = recordId;
            system.debug(system.now());
           system.debug('***'+wrapper.LastEstimateDate);
            if(wrapper.LastEstimateDate != null){
                schItem.buildertek__TO_LAST_EST_DATE__c = Date.parse(wrapper.LastEstimateDate);
            }
            schItem.buildertek__TO_VERSION__c = wrapper.Version;
            schItem.buildertek__Build_Phase__c = mapBuildPhaseId.get(wrapper.BuildPhase);
            schItem.buildertek__TO_REC_TYPE__c = wrapper.RecordType;
            schItem.buildertek__Product_Type__c = mapProductTypeId.get(wrapper.ProductType);
            schItem.buildertek__Categories__c = mapCategoryId.get(wrapper.Category);
            schItem.buildertek__UOM_PL__c = wrapper.UOM;
            schItem.buildertek__StockKeepingUnit__c = wrapper.ProductSKU;
            schItem.buildertek__Product_Code__c = wrapper.ProductCode;
            schItem.buildertek__Trade_Type__c = mapTradeTypeId.get(wrapper.TradeType);
            schItem.buildertek__TO_SLAB_SF__c = wrapper.SlabSQF;
            schItem.buildertek__TO_SUMMARY_VALUE__c = wrapper.SummaryValue1;
            schItem.buildertek__TO_BUILD_REF1__c = wrapper.BuildReference1;
            schItem.buildertek__Base_Location__c = wrapper.BaseLocation;
            schItem.buildertek__Location__c = wrapper.Location;
            schItem.buildertek__Location_Detailed_Area__c = wrapper.LocationDetailedArea;
            schItem.buildertek__TO_LOCATION_DETAIL_REF__c = wrapper.LocationDetailReference1;
            schItem.buildertek__TO_INSTALL_LOC__c = wrapper.InstallLocation;
            schItem.buildertek__TO_INSTALL_LOC_REF__c = wrapper.InstallLocationReference;
            schItem.buildertek__TO_SR_NO__c = wrapper.SeriesNumber;
            schItem.buildertek__TO_SR_NO_SUB__c = wrapper.SubSeriesNumber;
            schItem.buildertek__TO_SUB_ITEM__c = wrapper.SubSeriesItem;
            schItem.buildertek__TO_AREA_REF__c = wrapper.AreaReference;
            schItem.buildertek__Quantity__c = wrapper.Quantity;
            schItem.buildertek__TO_MATERIAL_Value__c = wrapper.MaterialValue;
            schItem.buildertek__Length__c = wrapper.Length;
            schItem.buildertek__Width__c = wrapper.Width;
            schItem.buildertek__Height__c = wrapper.Height;
            schItem.buildertek__Thickness__c = wrapper.Thickness;
            schItem.buildertek__TO_TOP_SQFT__c = wrapper.TopSQFT;
            schItem.buildertek__Edge__c = wrapper.Edge;
            schItem.buildertek__TO_LINEAR_EDGE__c = wrapper.LinearEdge;
            schItem.buildertek__TO_LINEAR_FEET__c = wrapper.LinearFeet;
            schItem.buildertek__TO_SINK_CUT_OUT__c = wrapper.SinkCutOut;
            schItem.buildertek__TO_STOVE_CUT_OUT__c = wrapper.StoveCutOut;
            schItem.buildertek__TO_OTHER_CUT_OUT__c = wrapper.OtherCutOuts;
            schItem.buildertek__TL_SERVICE_CATEGORY__c = wrapper.ServiceCategory;
             schItem.buildertek__TL_QUANTITY_2__c = wrapper.Quantity2;
             schItem.buildertek__Slab_SQFT_2__c = wrapper.SlabSQFT2;
            schItem.buildertek__Suppress_Record__c = wrapper.SuppressRecord;
             schItem.buildertek__Product_Count__c = wrapper.ProductCount;
            schItem.buildertek__Price_Book__c = mapPriceBookId.get(wrapper.PriceBook);
            // system.debug(wrapper.UnitCount);
            system.debug(schItem.buildertek__TO_LAST_EST_DATE__c);
            //if(schItem.buildertek__Trade_Type__c != null && schItem.buildertek__Trade_Type__c!= ''){
            //schItem.buildertek__Required_Completion_Date__c = Date.valueOf(wrapper.StartDate).addDays(Integer.valueOf(wrapper.Duration));
            schItemToInsert.add(schItem);
            //}
        }
        system.debug('@@@ schItemToInsert = ' + schItemToInsert);
        if (schItemToInsert.size() > 0){
            system.debug(schItemToInsert.size());
            try{
                if (Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Trade_Type__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_LAST_EST_DATE__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TL_SERVICE_CATEGORY__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Categories__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Location__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Product_Type__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Quantity__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__UOM__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__StockKeepingUnit__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Product_Code__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Build_Phase__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Length__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Width__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Thickness__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Edge__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Height__c.isCreateable()&&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Base_Location__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Location_Detailed_Area__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_AREA_REF__c.isCreateable()&&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_BUILD_REF1__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_INSTALL_LOC__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_INSTALL_LOC_REF__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_ITEM_COUNT__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_LINEAR_FEET__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_LOCATION_DETAIL_REF__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_MATERIAL_Value__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_OTHER_CUT_OUT__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_REC_TYPE__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_SR_NO__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_SINK_CUT_OUT__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_SLAB_SF__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_STOVE_CUT_OUT__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_SUB_ITEM__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_SR_NO_SUB__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_SUMMARY_VALUE__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_TOP_SQFT__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_UNIT_COUNT__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_LINEAR_EDGE__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_VERSION__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__Price_Book__c.isCreateable()){
                        
                        // Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_YIELD__c.isCreateable()){
                        //system.debug( Schema.sObjectType.buildertek__Project_Takeoff_Lines__c.fields.buildertek__TO_SUB_ITEM__c.isCreateable());*/
                        insert schItemToInsert;
                        system.debug('schItemToInsert'+schItemToInsert);
                    }
                returnresponse = 'SUCCESS';
            } catch (Exception e){
                System.debug('Error::' + e.getMessage());
                System.debug('Error::' + e.getLineNumber());
                returnresponse = 'ERROR';
                // returnresponse = e.getMessage() +'{---}'+ e.getLineNumber() +'{---}'+ e.getStackTraceString();
                system.debug(returnresponse);
            }  
        }
        system.debug(returnresponse);
       return returnresponse;
    // }catch(Exception e){
    //     String Error = e.getMessage() + '{at line} : '+ e.getLineNumber() + '{Stack : }'+ e.getStackTraceString();
    //     return Error;
    //    }
    }

    public class fieldWrapper{
        public String LastEstimateDate;
        public String Version;
        public String BuildPhase;
        public String RecordType;
        public String ProductType;
        public String Category;
        public String UOM;
        public String ProductSKU;
        public String ProductCode;
        public String TradeType;
        public decimal SlabSQF;
        public String SummaryValue1;
        public String BuildReference1;
        public String BaseLocation;
        public String Location;
        public String LocationDetailedArea;
        public String LocationDetailReference1;
        public String InstallLocation;
        public String InstallLocationReference;
        public String SeriesNumber;
        public String SubSeriesNumber;
        public String SubSeriesItem;
        public String AreaReference;
        // Updated by: Poojan Gabani
        // Date:27-07-2023  Ticket No: TKS-20
        // Update Quantity Datatype to Decimal From Integer 
        public Decimal Quantity;
        public String MaterialValue;
        public decimal Length;
        public decimal Width;
        public decimal Height;
        public decimal Thickness;
        public decimal TopSQFT;
        public String Edge;
        public decimal LinearEdge;
        public decimal LinearFeet;
        public decimal SinkCutOut;
        public decimal StoveCutOut;
        public decimal OtherCutOuts;
        public String ServiceCategory;
         public decimal Quantity2;
        public decimal SlabSQFT2;
        public String SuppressRecord;
        public Integer ProductCount;
        public String PriceBook;
    }
    public class WrapperClass{
        public List<List<String>> listOfFileContentsAsStrings;
        public Set<String> groupNames;

    }
}