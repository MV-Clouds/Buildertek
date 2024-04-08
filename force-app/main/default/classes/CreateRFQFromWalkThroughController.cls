public class CreateRFQFromWalkThroughController{
    @AuraEnabled
    public static ResponseBase createRFQFromWT(String walkThroughId){
        ResponseBase msg = new ResponseBase();
        try{

            List<buildertek__RFQ_Item__c> newRFQLines = new List<buildertek__RFQ_Item__c>();

            List<buildertek__Walk_Through_List__c> walkthroughrec = [SELECT Id, buildertek__Description__c, buildertek__Project__c, (SELECT Id, Name, buildertek__Details__c, buildertek__Description__c, buildertek__Trade_Type__c, buildertek__BT_Category__c, buildertek__BT_Cost_Code__c, buildertek__Anticipated_Finish_Date__c, buildertek__Anticipated_Start_Date__c
                                                                                                                                     FROM buildertek__Walk_Through_Line_Items__r)
                                                                     FROM buildertek__Walk_Through_List__c
                                                                     WHERE Id = :walkThroughId];

            if (!walkthroughrec.isEmpty()){
                buildertek__Walk_Through_Line_Items__c[] walkthroughlines = walkthroughrec[0].buildertek__Walk_Through_Line_Items__r;

                buildertek__RFQ__c newRFQrecord = new buildertek__RFQ__c();
                newRFQrecord.Name = walkthroughrec[0].buildertek__Description__c;
                newRFQrecord.buildertek__Project__c = walkthroughrec[0].buildertek__Project__c;

                insert newRFQrecord;

                buildertek__Walk_Through_List__c existingWalkThrough = new buildertek__Walk_Through_List__c();
                existingWalkThrough.Id = walkThroughId;
                existingWalkThrough.buildertek__BT_RFQ__c = newRFQrecord.Id;
                update existingWalkThrough;

                if (walkthroughlines.size() > 0){
                    for (buildertek__Walk_Through_Line_Items__c walkthroughline : walkthroughlines){
                        buildertek__RFQ_Item__c newRFQLine = new buildertek__RFQ_Item__c();
                        newRFQLine.buildertek__RFQ_Package__c = newRFQrecord.Id;
                        newRFQLine.Name = sliceDescriptionForName(walkthroughline.buildertek__Description__c);
                        newRFQLine.buildertek__Quantity__c = 1;
                        newRFQLine.buildertek__Description__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__Instructions__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__BT_Walk_Through_Line_Item__c = walkthroughline.Id;
                        newRFQLine.buildertek__Anticipated_Start_Date__c = walkthroughline.buildertek__Anticipated_Start_Date__c;
                        newRFQLine.buildertek__Anticipated_Finish_Date__c = walkthroughline.buildertek__Anticipated_Finish_Date__c;
                        newRFQLine.buildertek__Cost_Code__c = walkthroughline.buildertek__BT_Cost_Code__c;
                        newRFQLine.buildertek__BT_Category__c = walkthroughline.buildertek__BT_Category__c;
                        newRFQLine.buildertek__Trade_Type__c = walkthroughline.buildertek__Trade_Type__c;

                        newRFQLines.add(newRFQLine);
                    }

                    if (newRFQLines.size() > 0){
                        insert newRFQLines;

                        Map<String, String> mapOfWalkThroughLineIdAndRfqLineId = new Map<String, String>();
                        for (buildertek__RFQ_Item__c rfqLineItem : newRFQLines){
                            mapOfWalkThroughLineIdAndRfqLineId.put(rfqLineItem.buildertek__BT_Walk_Through_Line_Item__c, rfqLineItem.Id);
                        }
                        addFilesOnRfqLines(mapOfWalkThroughLineIdAndRfqLineId);
                        msg.Status = 'Success';
                        msg.Message = 'RFQ is Created Successfully';
                        msg.newRecordId = newRFQrecord.Id;
                    }
                } else{
                    msg.Status = 'Success';
                    msg.Message = 'RFQ is Created Successfully';
                    msg.newRecordId = newRFQrecord.Id;
                }
            } else{
                msg.Status = 'Failed';
                msg.Message = 'Walkthrough record not found';
            }

            return msg;
        } catch (Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();
            System.debug('error--> ' + exp.getMessage());
            System.debug('error line--> ' + exp.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c
                                                                                     FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(exp);
            }
            return msg;
        }
    }

    @AuraEnabled
    public static ResponseBase groupRrqTradeType(String walkThroughId, String grpType){
        ResponseBase msg = new ResponseBase();
        try{

            List<buildertek__RFQ__c> rfqList = new List<buildertek__RFQ__c>();
            Map<String, buildertek__RFQ__c> rfqAndGroupingMap = new Map<String, buildertek__RFQ__c>();
            List<buildertek__RFQ_Item__c> newRFQLines = new List<buildertek__RFQ_Item__c>();
            Map<String, List<buildertek__Walk_Through_Line_Items__c>> mapOfTradeTypeAndWalkThroughLines = new Map<String, List<buildertek__Walk_Through_Line_Items__c>>();
            List<buildertek__Walk_Through_List__c> walkthroughrec = [SELECT Id, buildertek__Description__c, buildertek__Project__c
                                                                     FROM buildertek__Walk_Through_List__c
                                                                     WHERE Id = :walkThroughId];

            if (grpType == 'tradeType'){
                List<buildertek__Walk_Through_Line_Items__c> walkthroughLineItemList = [SELECT Id, Name, buildertek__Details__c, buildertek__Description__c, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__BT_Category__r.Name, buildertek__BT_Category__c, buildertek__BT_Cost_Code__r.Name, buildertek__BT_Cost_Code__c, buildertek__Anticipated_Finish_Date__c, buildertek__Anticipated_Start_Date__c
                                                                                        FROM buildertek__Walk_Through_Line_Items__c
                                                                                        WHERE buildertek__Walk_Through_List__c = :walkThroughId
                                                                                        ORDER BY buildertek__Trade_Type__r.Name];

                Map<String, List<buildertek__Walk_Through_Line_Items__c>> tradeTypeNameAndWalkThroughLineListMap = new Map<String, List<buildertek__Walk_Through_Line_Items__c>>();

                for (buildertek__Walk_Through_Line_Items__c singleLine : walkthroughLineItemList){
                    if (singleLine.buildertek__Trade_Type__c != null){

                        if (!tradeTypeNameAndWalkThroughLineListMap.containsKey(singleLine.buildertek__Trade_Type__r.Name + '-' + singleLine.buildertek__Trade_Type__c)){
                            tradeTypeNameAndWalkThroughLineListMap.put(singleLine.buildertek__Trade_Type__r.Name + '-' + singleLine.buildertek__Trade_Type__c, new List<buildertek__Walk_Through_Line_Items__c>());
                        }

                        tradeTypeNameAndWalkThroughLineListMap.get(singleLine.buildertek__Trade_Type__r.Name + '-' + singleLine.buildertek__Trade_Type__c).add(singleLine);
                    }

                }

                rfqAndGroupingMap = createRFQ(walkthroughrec[0], tradeTypeNameAndWalkThroughLineListMap.keySet());

                if (rfqAndGroupingMap.values().size() > 0){
                    insert rfqAndGroupingMap.values();

                    newRFQLines = createRfqLineItemWithTradeType(walkthroughLineItemList, rfqAndGroupingMap);

                    if (newRFQLines.size() > 0){
                        insert newRFQLines;

                        Map<String, String> mapOfWalkThroughLineIdAndRfqLineId = new Map<String, String>();

                        for (buildertek__RFQ_Item__c rfqLineItem : newRFQLines){
                            mapOfWalkThroughLineIdAndRfqLineId.put(rfqLineItem.buildertek__BT_Walk_Through_Line_Item__c, rfqLineItem.Id);
                        }

                        addFilesOnRfqLines(mapOfWalkThroughLineIdAndRfqLineId);
                        msg.Status = 'Success';
                        msg.Message = 'All of your RFQs have been created';
                    }

                } else{
                    msg.Status = 'Error';
                    msg.Message = 'Grouping not Found for Trade Type';
                }

            } else if (grpType == 'costCode'){
                List<buildertek__Walk_Through_Line_Items__c> walkthroughLineItemList = [SELECT Id, Name, buildertek__Details__c, buildertek__Description__c, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__BT_Category__r.Name, buildertek__BT_Category__c, buildertek__BT_Cost_Code__r.Name, buildertek__BT_Cost_Code__c, buildertek__Anticipated_Finish_Date__c, buildertek__Anticipated_Start_Date__c
                                                                                        FROM buildertek__Walk_Through_Line_Items__c
                                                                                        WHERE buildertek__Walk_Through_List__c = :walkThroughId
                                                                                        ORDER BY buildertek__BT_Cost_Code__r.Name];

                Map<String, List<buildertek__Walk_Through_Line_Items__c>> costCodeNameAndWalkThroughLineListMap = new Map<String, List<buildertek__Walk_Through_Line_Items__c>>();

                for (buildertek__Walk_Through_Line_Items__c singleLine : walkthroughLineItemList){
                    if (singleLine.buildertek__BT_Cost_Code__c != null){
                        if (!costCodeNameAndWalkThroughLineListMap.containsKey(singleLine.buildertek__BT_Cost_Code__r.Name + '-' + singleLine.buildertek__BT_Cost_Code__c)){
                            costCodeNameAndWalkThroughLineListMap.put(singleLine.buildertek__BT_Cost_Code__r.Name + '-' + singleLine.buildertek__BT_Cost_Code__c, new List<buildertek__Walk_Through_Line_Items__c>());
                        }

                        costCodeNameAndWalkThroughLineListMap.get(singleLine.buildertek__BT_Cost_Code__r.Name + '-' + singleLine.buildertek__BT_Cost_Code__c).add(singleLine);
                    }
                }

                rfqAndGroupingMap = createRFQ(walkthroughrec[0], costCodeNameAndWalkThroughLineListMap.keySet());

                if (rfqAndGroupingMap.values().size() > 0){
                    insert rfqAndGroupingMap.values();

                    newRFQLines = createRfqLineItemWithCostCode(walkthroughLineItemList, rfqAndGroupingMap);

                    if (newRFQLines.size() > 0){
                        insert newRFQLines;

                        Map<String, String> mapOfWalkThroughLineIdAndRfqLineId = new Map<String, String>();

                        for (buildertek__RFQ_Item__c rfqLineItem : newRFQLines){
                            mapOfWalkThroughLineIdAndRfqLineId.put(rfqLineItem.buildertek__BT_Walk_Through_Line_Item__c, rfqLineItem.Id);
                        }

                        addFilesOnRfqLines(mapOfWalkThroughLineIdAndRfqLineId);

                        msg.Status = 'Success';
                        msg.Message = 'All of your RFQs have been created';
                    }

                } else{
                    msg.Status = 'Error';
                    msg.Message = 'Grouping not Found for Cost Code';
                }

            } else if (grpType == 'section'){
                List<buildertek__Walk_Through_Line_Items__c> walkthroughLineItemList = [SELECT Id, Name, buildertek__Details__c, buildertek__Description__c, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__BT_Category__r.Name, buildertek__BT_Category__c, buildertek__BT_Cost_Code__r.Name, buildertek__BT_Cost_Code__c, buildertek__Anticipated_Finish_Date__c, buildertek__Anticipated_Start_Date__c
                                                                                        FROM buildertek__Walk_Through_Line_Items__c
                                                                                        WHERE buildertek__Walk_Through_List__c = :walkThroughId
                                                                                        ORDER BY buildertek__BT_Category__r.Name];

                Map<String, List<buildertek__Walk_Through_Line_Items__c>> sectionNameAndWalkThroughLineListMap = new Map<String, List<buildertek__Walk_Through_Line_Items__c>>();

                for (buildertek__Walk_Through_Line_Items__c singleLine : walkthroughLineItemList){
                    if (singleLine.buildertek__BT_Category__c != null){

                        if (!sectionNameAndWalkThroughLineListMap.containsKey(singleLine.buildertek__BT_Category__r.Name + '-' + singleLine.buildertek__BT_Category__c)){
                            sectionNameAndWalkThroughLineListMap.put(singleLine.buildertek__BT_Category__r.Name + '-' + singleLine.buildertek__BT_Category__c, new List<buildertek__Walk_Through_Line_Items__c>());
                        }

                        sectionNameAndWalkThroughLineListMap.get(singleLine.buildertek__BT_Category__r.Name + '-' + singleLine.buildertek__BT_Category__c).add(singleLine);
                    }
                }

                rfqAndGroupingMap = createRFQ(walkthroughrec[0], sectionNameAndWalkThroughLineListMap.keySet());

                if (rfqAndGroupingMap.values().size() > 0){
                    insert rfqAndGroupingMap.values();

                    newRFQLines = createRfqLineItemWithSection(walkthroughLineItemList, rfqAndGroupingMap);

                    if (newRFQLines.size() > 0){
                        insert newRFQLines;

                        Map<String, String> mapOfWalkThroughLineIdAndRfqLineId = new Map<String, String>();

                        for (buildertek__RFQ_Item__c rfqLineItem : newRFQLines){
                            mapOfWalkThroughLineIdAndRfqLineId.put(rfqLineItem.buildertek__BT_Walk_Through_Line_Item__c, rfqLineItem.Id);
                        }

                        addFilesOnRfqLines(mapOfWalkThroughLineIdAndRfqLineId);

                        msg.Status = 'Success';
                        msg.Message = 'All of your RFQs have been created';
                    }

                } else{
                    msg.Status = 'Error';
                    msg.Message = 'Grouping not Found for Section';
                }

            }

            return msg;
        } catch (Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();
            System.debug('error--> ' + exp.getMessage());
            System.debug('error line--> ' + exp.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c
                                                                                     FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(exp);
            }
            return msg;
        }
    }

    public static Map<String, buildertek__RFQ__c> createRFQ(buildertek__Walk_Through_List__c walkThrough, set<String> groupingName){
        Map<String, buildertek__RFQ__c> rfqAndGroupingMap = new Map<String, buildertek__RFQ__c>();
        for (String singleKey : groupingName){
            buildertek__RFQ__c rfq = new buildertek__RFQ__c();
            List<String> res = singleKey.split('-', 2);
            rfq.Name = res[0] + '-' + walkThrough.buildertek__Description__c;
            rfq.buildertek__Project__c = walkThrough.buildertek__Project__c;
            rfqAndGroupingMap.put(singleKey, rfq);
        }
        return rfqAndGroupingMap;
    }

    public static List<buildertek__RFQ_Item__c> createRfqLineItemWithTradeType(List<buildertek__Walk_Through_Line_Items__c> walkthroughlines, Map<String, buildertek__RFQ__c> newRFQrecordGroupingMap){

        List<buildertek__RFQ_Item__c> newRFQLines = new List<buildertek__RFQ_Item__c>();

        if (walkthroughlines.size() > 0){
            for (String groupName : newRFQrecordGroupingMap.keySet()){
                List<String> tradeTypeList = groupName.split('-', 2);

                for (buildertek__Walk_Through_Line_Items__c walkthroughline : walkthroughlines){
                    String walkThroughTradeType = walkthroughline.buildertek__Trade_Type__c;

                    if (tradeTypeList[1] == walkThroughTradeType){
                        buildertek__RFQ_Item__c newRFQLine = new buildertek__RFQ_Item__c();
                        newRFQLine.buildertek__RFQ_Package__c = newRFQrecordGroupingMap.get(groupName).Id;
                        newRFQLine.Name = sliceDescriptionForName(walkthroughline.buildertek__Description__c);
                        newRFQLine.buildertek__Quantity__c = 1;
                        newRFQLine.buildertek__Description__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__Instructions__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__BT_Walk_Through_Line_Item__c = walkthroughline.Id;
                        newRFQLine.buildertek__Anticipated_Start_Date__c = walkthroughline.buildertek__Anticipated_Start_Date__c;
                        newRFQLine.buildertek__Anticipated_Finish_Date__c = walkthroughline.buildertek__Anticipated_Finish_Date__c;
                        newRFQLine.buildertek__Trade_Type__c = walkthroughline.buildertek__Trade_Type__c;
                        newRFQLine.buildertek__Cost_Code__c = walkthroughline.buildertek__BT_Cost_Code__c;
                        newRFQLine.buildertek__BT_Category__c = walkthroughline.buildertek__BT_Category__c;

                        newRFQLines.add(newRFQLine);
                    }
                }
            }
        }

        return newRFQLines;
    }

    public static List<buildertek__RFQ_Item__c> createRfqLineItemWithCostCode(List<buildertek__Walk_Through_Line_Items__c> walkthroughlines, Map<String, buildertek__RFQ__c> newRFQrecordGroupingMap){

        List<buildertek__RFQ_Item__c> newRFQLines = new List<buildertek__RFQ_Item__c>();

        if (walkthroughlines.size() > 0){
            for (String groupName : newRFQrecordGroupingMap.keySet()){
                List<String> costCodeList = groupName.split('-', 2);

                for (buildertek__Walk_Through_Line_Items__c walkthroughline : walkthroughlines){
                    String walkThroughCostCode = walkthroughline.buildertek__BT_Cost_Code__c;

                    if (costCodeList[1] == walkThroughCostCode){

                        buildertek__RFQ_Item__c newRFQLine = new buildertek__RFQ_Item__c();
                        newRFQLine.buildertek__RFQ_Package__c = newRFQrecordGroupingMap.get(groupName).Id;
                        newRFQLine.Name = sliceDescriptionForName(walkthroughline.buildertek__Description__c);
                        newRFQLine.buildertek__Quantity__c = 1;
                        newRFQLine.buildertek__Description__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__Instructions__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__BT_Walk_Through_Line_Item__c = walkthroughline.Id;
                        newRFQLine.buildertek__Anticipated_Start_Date__c = walkthroughline.buildertek__Anticipated_Start_Date__c;
                        newRFQLine.buildertek__Anticipated_Finish_Date__c = walkthroughline.buildertek__Anticipated_Finish_Date__c;
                        newRFQLine.buildertek__Cost_Code__c = walkthroughline.buildertek__BT_Cost_Code__c;
                        newRFQLine.buildertek__BT_Category__c = walkthroughline.buildertek__BT_Category__c;
                        newRFQLine.buildertek__Trade_Type__c = walkthroughline.buildertek__Trade_Type__c;

                        newRFQLines.add(newRFQLine);
                    }
                }
            }
        }

        return newRFQLines;
    }

    public static List<buildertek__RFQ_Item__c> createRfqLineItemWithSection(List<buildertek__Walk_Through_Line_Items__c> walkthroughlines, Map<String, buildertek__RFQ__c> newRFQrecordGroupingMap){

        List<buildertek__RFQ_Item__c> newRFQLines = new List<buildertek__RFQ_Item__c>();

        if (walkthroughlines.size() > 0){
            for (String groupName : newRFQrecordGroupingMap.keySet()){
                List<String> categoryList = groupName.split('-', 2);

                for (buildertek__Walk_Through_Line_Items__c walkthroughline : walkthroughlines){
                    String walkThroughCategory = walkthroughline.buildertek__BT_Category__c;

                    if (categoryList[1] == walkThroughCategory){

                        buildertek__RFQ_Item__c newRFQLine = new buildertek__RFQ_Item__c();
                        newRFQLine.buildertek__RFQ_Package__c = newRFQrecordGroupingMap.get(groupName).Id;
                        newRFQLine.Name = sliceDescriptionForName(walkthroughline.buildertek__Description__c);
                        newRFQLine.buildertek__Quantity__c = 1;
                        newRFQLine.buildertek__Description__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__Instructions__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__BT_Walk_Through_Line_Item__c = walkthroughline.Id;
                        newRFQLine.buildertek__Anticipated_Start_Date__c = walkthroughline.buildertek__Anticipated_Start_Date__c;
                        newRFQLine.buildertek__Anticipated_Finish_Date__c = walkthroughline.buildertek__Anticipated_Finish_Date__c;
                        newRFQLine.buildertek__BT_Category__c = walkthroughline.buildertek__BT_Category__c;
                        newRFQLine.buildertek__Cost_Code__c = walkthroughline.buildertek__BT_Cost_Code__c;
                        newRFQLine.buildertek__Trade_Type__c = walkthroughline.buildertek__Trade_Type__c;

                        newRFQLines.add(newRFQLine);
                    }
                }
            }
        }

        return newRFQLines;
    }

    public static void addFilesOnRfqLines(Map<String, String> mapOfWalkThroughLineIdAndRfqLineId){
        list<ContentDocumentLink> allCdLinks = new list<ContentDocumentLink>();

        allCdLinks = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility
                      FROM ContentDocumentLink
                      WHERE LinkedEntityId IN:mapOfWalkThroughLineIdAndRfqLineId.keySet()];

        list<ContentDocumentLink> allCdLinksToInsert = new list<ContentDocumentLink>();

        for (ContentDocumentLink cdl : allCdLinks){
            cdl.Id = null;
            cdl.LinkedEntityId = mapOfWalkThroughLineIdAndRfqLineId.get(cdl.LinkedEntityId);
            allCdLinksToInsert.add(cdl);
        }

        if (!allCdLinksToInsert.isEmpty()){
            database.Insert (allCdLinksToInsert, false);
        }
    }

    public static String sliceDescriptionForName(String description){
        if (description != null){
            if (description.length() > 80){
                description = description.substring(0, 79);
            }
        }
        return description;
    }

    public virtual class ResponseBase{
        @AuraEnabled
        public String Status{ get; set; }

        @AuraEnabled
        public String Message{ get; set; }

        @AuraEnabled
        public String newRecordId;

    }

}