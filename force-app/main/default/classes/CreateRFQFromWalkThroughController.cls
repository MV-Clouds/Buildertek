public class CreateRFQFromWalkThroughController{
    @AuraEnabled
    public static ResponseBase createRFQFromWT(String walkThroughId){
        ResponseBase msg = new ResponseBase();
        try{

            List<buildertek__RFQ_Item__c> newRFQLines = new List<buildertek__RFQ_Item__c>();

            List<buildertek__Walk_Through_List__c> walkthroughrec = [SELECT Id, buildertek__Description__c, buildertek__Project__c, (SELECT Id, Name,buildertek__Quantity__c, buildertek__Details__c, buildertek__Price__c, buildertek__Description__c, buildertek__Trade_Type__c, buildertek__BT_Category__c, buildertek__BT_Cost_Code__c, buildertek__Anticipated_Finish_Date__c, buildertek__Anticipated_Start_Date__c, buildertek__Product__c, buildertek__Price_Book__c
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
                        newRFQLine.buildertek__Quantity__c  = walkthroughline.buildertek__Quantity__c;
                        newRFQLine.buildertek__Description__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__Instructions__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__BT_Walk_Through_Line_Item__c = walkthroughline.Id;
                        newRFQLine.buildertek__Anticipated_Start_Date__c = walkthroughline.buildertek__Anticipated_Start_Date__c;
                        newRFQLine.buildertek__Anticipated_Finish_Date__c = walkthroughline.buildertek__Anticipated_Finish_Date__c;
                        newRFQLine.buildertek__Cost_Code__c = walkthroughline.buildertek__BT_Cost_Code__c;
                        newRFQLine.buildertek__BT_Category__c = walkthroughline.buildertek__BT_Category__c;
                        newRFQLine.buildertek__Trade_Type__c = walkthroughline.buildertek__Trade_Type__c;
                        newRFQLine.buildertek__Walk_Through_Unit_Cost__c = walkthroughline.buildertek__Price__c;
                        newRFQLine.buildertek__Product__c = walkthroughline.buildertek__Product__c;
                        newRFQLine.buildertek__Price_Book__c = walkthroughline.buildertek__Price_Book__c;

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
                        msg.projectId = walkthroughrec[0].buildertek__Project__c;
                    }
                } else{
                    msg.Status = 'Success';
                    msg.Message = 'RFQ is Created Successfully';
                    msg.newRecordId = newRFQrecord.Id;
                    msg.projectId = walkthroughrec[0].buildertek__Project__c;
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
                List<buildertek__Walk_Through_Line_Items__c> walkthroughLineItemList = [SELECT Id, Name, buildertek__Details__c, buildertek__Price__c, buildertek__Description__c, buildertek__Quantity__c,buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__BT_Category__r.Name, buildertek__BT_Category__c, buildertek__BT_Cost_Code__r.Name, buildertek__BT_Cost_Code__c, buildertek__Anticipated_Finish_Date__c, buildertek__Anticipated_Start_Date__c, buildertek__Product__c, buildertek__Price_Book__c
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

                        update assignRfqLinesOnWalkThroughLines(newRFQLines);

                        Map<String, String> mapOfWalkThroughLineIdAndRfqLineId = new Map<String, String>();

                        for (buildertek__RFQ_Item__c rfqLineItem : newRFQLines){
                            mapOfWalkThroughLineIdAndRfqLineId.put(rfqLineItem.buildertek__BT_Walk_Through_Line_Item__c, rfqLineItem.Id);
                        }

                        addFilesOnRfqLines(mapOfWalkThroughLineIdAndRfqLineId);
                        msg.Status = 'Success';
                        msg.Message = 'All of your RFQs have been created';
                        msg.projectId = walkthroughrec[0].buildertek__Project__c;
                    }

                } else{
                    msg.Status = 'Error';
                    msg.Message = 'Grouping not Found for Trade Type';
                }

            } else if (grpType == 'costCode'){
                List<buildertek__Walk_Through_Line_Items__c> walkthroughLineItemList = [SELECT Id, Name, buildertek__Details__c,buildertek__Price__c, buildertek__Quantity__c, buildertek__Description__c, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__BT_Category__r.Name, buildertek__BT_Category__c, buildertek__BT_Cost_Code__r.Name, buildertek__BT_Cost_Code__c, buildertek__Anticipated_Finish_Date__c, buildertek__Anticipated_Start_Date__c, buildertek__Product__c, buildertek__Price_Book__c
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

                        update assignRfqLinesOnWalkThroughLines(newRFQLines);

                        Map<String, String> mapOfWalkThroughLineIdAndRfqLineId = new Map<String, String>();

                        for (buildertek__RFQ_Item__c rfqLineItem : newRFQLines){
                            mapOfWalkThroughLineIdAndRfqLineId.put(rfqLineItem.buildertek__BT_Walk_Through_Line_Item__c, rfqLineItem.Id);
                        }

                        addFilesOnRfqLines(mapOfWalkThroughLineIdAndRfqLineId);

                        msg.Status = 'Success';
                        msg.Message = 'All of your RFQs have been created';
                        msg.projectId = walkthroughrec[0].buildertek__Project__c;
                    }

                } else{
                    msg.Status = 'Error';
                    msg.Message = 'Grouping not Found for Cost Code';
                }

            } else if (grpType == 'section'){
                List<buildertek__Walk_Through_Line_Items__c> walkthroughLineItemList = [SELECT Id, Name, buildertek__Details__c,buildertek__Price__c,buildertek__Quantity__c, buildertek__Description__c, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__BT_Category__r.Name, buildertek__BT_Category__c, buildertek__BT_Cost_Code__r.Name, buildertek__BT_Cost_Code__c, buildertek__Anticipated_Finish_Date__c, buildertek__Anticipated_Start_Date__c, buildertek__Product__c, buildertek__Price_Book__c
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

                        update assignRfqLinesOnWalkThroughLines(newRFQLines);

                        Map<String, String> mapOfWalkThroughLineIdAndRfqLineId = new Map<String, String>();

                        for (buildertek__RFQ_Item__c rfqLineItem : newRFQLines){
                            mapOfWalkThroughLineIdAndRfqLineId.put(rfqLineItem.buildertek__BT_Walk_Through_Line_Item__c, rfqLineItem.Id);
                        }

                        addFilesOnRfqLines(mapOfWalkThroughLineIdAndRfqLineId);

                        msg.Status = 'Success';
                        msg.Message = 'All of your RFQs have been created';
                        msg.projectId = walkthroughrec[0].buildertek__Project__c;
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
                        newRFQLine.buildertek__Quantity__c  = walkthroughline.buildertek__Quantity__c;
                        newRFQLine.buildertek__Description__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__Instructions__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__BT_Walk_Through_Line_Item__c = walkthroughline.Id;
                        newRFQLine.buildertek__Anticipated_Start_Date__c = walkthroughline.buildertek__Anticipated_Start_Date__c;
                        newRFQLine.buildertek__Anticipated_Finish_Date__c = walkthroughline.buildertek__Anticipated_Finish_Date__c;
                        newRFQLine.buildertek__Trade_Type__c = walkthroughline.buildertek__Trade_Type__c;
                        newRFQLine.buildertek__Cost_Code__c = walkthroughline.buildertek__BT_Cost_Code__c;
                        newRFQLine.buildertek__BT_Category__c = walkthroughline.buildertek__BT_Category__c;
                        newRFQLine.buildertek__Walk_Through_Unit_Cost__c = walkthroughline.buildertek__Price__c;
                        newRFQLine.buildertek__Product__c = walkthroughline.buildertek__Product__c;
                        newRFQLine.buildertek__Price_Book__c = walkthroughline.buildertek__Price_Book__c;

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
                        newRFQLine.buildertek__Quantity__c  = walkthroughline.buildertek__Quantity__c;
                        newRFQLine.buildertek__Description__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__Instructions__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__BT_Walk_Through_Line_Item__c = walkthroughline.Id;
                        newRFQLine.buildertek__Anticipated_Start_Date__c = walkthroughline.buildertek__Anticipated_Start_Date__c;
                        newRFQLine.buildertek__Anticipated_Finish_Date__c = walkthroughline.buildertek__Anticipated_Finish_Date__c;
                        newRFQLine.buildertek__Cost_Code__c = walkthroughline.buildertek__BT_Cost_Code__c;
                        newRFQLine.buildertek__BT_Category__c = walkthroughline.buildertek__BT_Category__c;
                        newRFQLine.buildertek__Trade_Type__c = walkthroughline.buildertek__Trade_Type__c;
                        newRFQLine.buildertek__Walk_Through_Unit_Cost__c = walkthroughline.buildertek__Price__c;
                        newRFQLine.buildertek__Product__c = walkthroughline.buildertek__Product__c;
                        newRFQLine.buildertek__Price_Book__c = walkthroughline.buildertek__Price_Book__c;

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
                        newRFQLine.buildertek__Quantity__c  = walkthroughline.buildertek__Quantity__c;
                        newRFQLine.buildertek__Description__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__Instructions__c = walkthroughline.buildertek__Details__c;
                        newRFQLine.buildertek__BT_Walk_Through_Line_Item__c = walkthroughline.Id;
                        newRFQLine.buildertek__Anticipated_Start_Date__c = walkthroughline.buildertek__Anticipated_Start_Date__c;
                        newRFQLine.buildertek__Anticipated_Finish_Date__c = walkthroughline.buildertek__Anticipated_Finish_Date__c;
                        newRFQLine.buildertek__BT_Category__c = walkthroughline.buildertek__BT_Category__c;
                        newRFQLine.buildertek__Cost_Code__c = walkthroughline.buildertek__BT_Cost_Code__c;
                        newRFQLine.buildertek__Trade_Type__c = walkthroughline.buildertek__Trade_Type__c;
                        newRFQLine.buildertek__Walk_Through_Unit_Cost__c = walkthroughline.buildertek__Price__c;     
                        newRFQLine.buildertek__Product__c = walkthroughline.buildertek__Product__c;
                        newRFQLine.buildertek__Price_Book__c = walkthroughline.buildertek__Price_Book__c;                   

                        newRFQLines.add(newRFQLine);
                    }
                }
            }
        }

        return newRFQLines;
    }

    public static List<buildertek__Walk_Through_Line_Items__c> assignRfqLinesOnWalkThroughLines(List<buildertek__RFQ_Item__c> rfqLineItems){
        List<buildertek__Walk_Through_Line_Items__c> listOfWalkThroughToUpdate = new List<buildertek__Walk_Through_Line_Items__c>();

        for (buildertek__RFQ_Item__c singleRfqLine : rfqLineItems){
            buildertek__Walk_Through_Line_Items__c singleWalkThroughLine = new buildertek__Walk_Through_Line_Items__c();
            singleWalkThroughLine.Id = singleRfqLine.buildertek__BT_Walk_Through_Line_Item__c;
            singleWalkThroughLine.buildertek__BT_RFQ_Line__c = singleRfqLine.Id;
            listOfWalkThroughToUpdate.add(singleWalkThroughLine);
        }

        return listOfWalkThroughToUpdate;
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

        Set<String> rfqLineIds = new Set<String>();
        for (String rfqLineId : mapOfWalkThroughLineIdAndRfqLineId.values()){
            rfqLineIds.add(rfqLineId);
        }

        
        List<buildertek__Public_Folder__c> publicFolderList = new List<buildertek__Public_Folder__c>();
        for (String rfqLineId : rfqLineIds){
            buildertek__Public_Folder__c publicFolder = new buildertek__Public_Folder__c();
            publicFolder.Name = 'Images from Walkthrough';
            publicFolder.buildertek__Description__c = 'Images from Walkthrough';
            publicFolder.buildertek__RelatedToId__c = rfqLineId;
            publicFolderList.add(publicFolder);
        }
        
        if (!publicFolderList.isEmpty()){
            insert publicFolderList;
        }

        //update buildertek__Public_Folder__c on buildertek__RFQ_Item__c record by iterating over publicFolderList
        List<buildertek__RFQ_Item__c> rfqLineItemsToUpdate = new List<buildertek__RFQ_Item__c>();
        for (buildertek__Public_Folder__c publicFolder : publicFolderList){
            buildertek__RFQ_Item__c rfqLineItem = new buildertek__RFQ_Item__c();
            rfqLineItem.Id = publicFolder.buildertek__RelatedToId__c;
            rfqLineItem.buildertek__Public_Folder__c = publicFolder.Id;
            rfqLineItemsToUpdate.add(rfqLineItem);
        }

        if (!rfqLineItemsToUpdate.isEmpty()){
            update rfqLineItemsToUpdate;
        }
        
        
        //Make a map of RFQ Line Id and Public Folder Id
        Map<String, String> mapOfRfqLineIdAndPublicFolderId = new Map<String, String>();
        for (buildertek__Public_Folder__c publicFolder : publicFolderList){
            mapOfRfqLineIdAndPublicFolderId.put(publicFolder.buildertek__RelatedToId__c, publicFolder.Id);
        }
        
        //Query all the CDLs to get the ContentDocument.LatestPublishedVersionId and ContentDocument.Title
        List<ContentDocumentLink> allCdLinksToQuery = [SELECT Id, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, ContentDocumentId, LinkedEntityId
                                                       FROM ContentDocumentLink
                                                       WHERE LinkedEntityId IN:rfqLineIds];

        //Create a map of LinkedEntityId and List of ContentDocument.LatestPublishedVersionId
        Map<String, List<Id>> mapOfLinkedEntityIdAndCvIds = new Map<String, List<Id>>();
        for (ContentDocumentLink cdl : allCdLinksToQuery){
            if (!mapOfLinkedEntityIdAndCvIds.containsKey(cdl.LinkedEntityId)){
                mapOfLinkedEntityIdAndCvIds.put(cdl.LinkedEntityId, new List<Id>());
            }
            mapOfLinkedEntityIdAndCvIds.get(cdl.LinkedEntityId).add(cdl.ContentDocument.LatestPublishedVersionId);
        }

        //Create a set of ContentDocument.LatestPublishedVersionId
        Set<Id> cvIds = new Set<Id>();
        for (ContentDocumentLink cdl : allCdLinksToQuery){
            cvIds.add(cdl.ContentDocument.LatestPublishedVersionId);
        }

        List<buildertek__Public_File__c> ExisitingPublicFile = [SELECT Id, Name, buildertek__File_Name__c, buildertek__Content_Distrubution__c, buildertek__Content_Version__c, buildertek__Public_URL__c
                                                                FROM buildertek__Public_File__c
                                                                WHERE buildertek__Content_Version__c IN:cvIds];

        //Create a map of ContentDocument.LatestPublishedVersionId and Public File Id
        Map<Id, Id> mapOfCvIdAndPublicFileId = new Map<Id, Id>();
        for (buildertek__Public_File__c publicFile : ExisitingPublicFile){
            mapOfCvIdAndPublicFileId.put(publicFile.buildertek__Content_Version__c, publicFile.Id);
        }

        //Create a map of LinkedEntityId and List of Public File Id
        Map<String, List<Id>> mapOfLinkedEntityIdAndPublicFileId = new Map<String, List<Id>>();
        for (ContentDocumentLink cdl : allCdLinksToQuery){
            if (mapOfCvIdAndPublicFileId.containsKey(cdl.ContentDocument.LatestPublishedVersionId)){
                if (!mapOfLinkedEntityIdAndPublicFileId.containsKey(cdl.LinkedEntityId)){
                    mapOfLinkedEntityIdAndPublicFileId.put(cdl.LinkedEntityId, new List<Id>());
                }
                mapOfLinkedEntityIdAndPublicFileId.get(cdl.LinkedEntityId).add(mapOfCvIdAndPublicFileId.get(cdl.ContentDocument.LatestPublishedVersionId));
            }
        }

        //iterate over the cvIds and check if Public File already exists and if not add that cvId to a new set of cvIds
        Set<Id> cvIdsToInsert = new Set<Id>();
        for (Id cvId : cvIds){
            Boolean isExists = false;
            for (buildertek__Public_File__c publicFile : ExisitingPublicFile){
                if (publicFile.buildertek__Content_Version__c == cvId){
                    isExists = true;
                    break;
                }
            }
            if (!isExists){
                cvIdsToInsert.add(cvId);
            }
        }

        //Create list of ContentDocumentLink whose ContentDocument.LatestPublishedVersionId is in cvIdsToInsert
        List<ContentDocumentLink> cdLinksToInsert = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : allCdLinksToQuery){
            if (cvIdsToInsert.contains(cdl.ContentDocument.LatestPublishedVersionId)){
                cdLinksToInsert.add(cdl);
            }
        }
        
        //Create record of ContentDistribution
        List<ContentDistribution> cdList = new List<ContentDistribution>();
        for (ContentDocumentLink cdl : cdLinksToInsert){
            ContentDistribution cd = new ContentDistribution();
            cd.Name = cdl.ContentDocument.Title;
            cd.ContentVersionId = cdl.ContentDocument.LatestPublishedVersionId;
            cd.RelatedRecordId = cdl.LinkedEntityId;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            cdList.add(cd);
        }

        if (!cdList.isEmpty()){
            insert cdList;
        }

        //Create a map of RelatedRecordId and List of ContentDistribution Id
        Map<Id, List<Id>> mapOfRelatedRecordIdAndCdId = new Map<Id, List<Id>>();
        for (ContentDistribution cd : cdList){
            if (!mapOfRelatedRecordIdAndCdId.containsKey(cd.RelatedRecordId)){
                mapOfRelatedRecordIdAndCdId.put(cd.RelatedRecordId, new List<Id>());
            }
            mapOfRelatedRecordIdAndCdId.get(cd.RelatedRecordId).add(cd.Id);
        }

        //query all the ContentDistribution to get the Name, ContentVersionId, DistributionPublicUrl
        List<ContentDistribution> cdListToQuery = [SELECT Id, Name, ContentVersionId, DistributionPublicUrl, RelatedRecordId
                                                   FROM ContentDistribution
                                                   WHERE Id IN:cdList];

        //Create a list of Public File
        List<buildertek__Public_File__c> publicFileList = new List<buildertek__Public_File__c>();
        for (ContentDistribution cd : cdListToQuery){
            buildertek__Public_File__c publicFile = new buildertek__Public_File__c();
            publicFile.buildertek__File_Name__c = cd.Name;
            publicFile.buildertek__Content_Distrubution__c = cd.Id;
            publicFile.buildertek__Content_Version__c = cd.ContentVersionId;
            publicFile.buildertek__Public_URL__c = cd.DistributionPublicUrl;
            publicFileList.add(publicFile);
        }

        if (!publicFileList.isEmpty()){
            insert publicFileList;
        }

        //Create a map of ContentDistribution Id and Public File Id
        Map<Id, Id> mapOfContentDistributionIdAndPublicFileId = new Map<Id, Id>();
        for (buildertek__Public_File__c publicFile : publicFileList){
            mapOfContentDistributionIdAndPublicFileId.put(publicFile.buildertek__Content_Distrubution__c, publicFile.Id);
        }

        //Create a map of RelatedRecordId and List of Public File Id
        Map<String, List<Id>> mapOfRelatedRecordIdAndPublicFileId = new Map<String, List<Id>>();
        for (ContentDistribution cd : cdListToQuery){
            if (mapOfContentDistributionIdAndPublicFileId.containsKey(cd.Id)){
                if (!mapOfRelatedRecordIdAndPublicFileId.containsKey(cd.RelatedRecordId)){
                    mapOfRelatedRecordIdAndPublicFileId.put(cd.RelatedRecordId, new List<Id>());
                }
                mapOfRelatedRecordIdAndPublicFileId.get(cd.RelatedRecordId).add(mapOfContentDistributionIdAndPublicFileId.get(cd.Id));
            }
        }

        //By iterating over rfqLineIds, create a map of RFQ Line Id and List of Public File Id from mapOfLinkedEntityIdAndPublicFileId and mapOfRelatedRecordIdAndPublicFileId
        Map<String, List<Id>> mapOfRfqLineIdAndPublicFileId = new Map<String, List<Id>>();
        for (String rfqLineId : rfqLineIds){
            if (mapOfLinkedEntityIdAndPublicFileId.containsKey(rfqLineId)){
                mapOfRfqLineIdAndPublicFileId.put(rfqLineId, mapOfLinkedEntityIdAndPublicFileId.get(rfqLineId));
            }
            if (mapOfRelatedRecordIdAndPublicFileId.containsKey(rfqLineId)){
                mapOfRfqLineIdAndPublicFileId.put(rfqLineId, mapOfRelatedRecordIdAndPublicFileId.get(rfqLineId));
            }
        }

        //iterate and debug the mapOfRfqLineIdAndPublicFileId
        for (String rfqLineId : mapOfRfqLineIdAndPublicFileId.keySet()){
            System.debug('rfqLineId--> ' + rfqLineId);
            System.debug('Public File Ids--> ' + mapOfRfqLineIdAndPublicFileId.get(rfqLineId));
        }

        //Create a map of Public Folder Id and List of Public File Id by iterating over publicFolderList
        Map<String, List<Id>> mapOfPublicFolderIdAndPublicFileId = new Map<String, List<Id>>();
        for (buildertek__Public_Folder__c publicFolder : publicFolderList){
            if (mapOfRfqLineIdAndPublicFileId.containsKey(publicFolder.buildertek__RelatedToId__c)){
                mapOfPublicFolderIdAndPublicFileId.put(publicFolder.Id, mapOfRfqLineIdAndPublicFileId.get(publicFolder.buildertek__RelatedToId__c));
            }
        }

        //Create a record of buildertek__Public_File_Folder_Jn__c by iterating over mapOfPublicFolderIdAndPublicFileId
        List<buildertek__Public_File_Folder_Jn__c> publicFileFolderJnList = new List<buildertek__Public_File_Folder_Jn__c>();
        for (String publicFolderId : mapOfPublicFolderIdAndPublicFileId.keySet()){
            for (Id publicFileId : mapOfPublicFolderIdAndPublicFileId.get(publicFolderId)){
                buildertek__Public_File_Folder_Jn__c publicFileFolderJn = new buildertek__Public_File_Folder_Jn__c();
                publicFileFolderJn.buildertek__Public_File__c = publicFileId;
                publicFileFolderJn.buildertek__Public_Folder__c = publicFolderId;
                publicFileFolderJnList.add(publicFileFolderJn);
            }
        }

        if (!publicFileFolderJnList.isEmpty()){
            insert publicFileFolderJnList;
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

        @AuraEnabled
        public String projectId;
    }

}