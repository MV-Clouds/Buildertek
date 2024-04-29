public class CreateRFQFromWalkThroughController{
    @AuraEnabled
    public static ResponseBase createRFQFromWT(String walkThroughId){
        ResponseBase msg = new ResponseBase();
        try{

            List<buildertek__RFQ_Item__c> newRFQLines = new List<buildertek__RFQ_Item__c>();

            List<buildertek__Walk_Through_List__c> walkthroughrec = [SELECT Id, buildertek__Description__c, buildertek__Project__c, (SELECT Id, Name,buildertek__Quantity__c, buildertek__Details__c, buildertek__Description__c, buildertek__Trade_Type__c, buildertek__BT_Category__c, buildertek__BT_Cost_Code__c, buildertek__Anticipated_Finish_Date__c, buildertek__Anticipated_Start_Date__c
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
                List<buildertek__Walk_Through_Line_Items__c> walkthroughLineItemList = [SELECT Id, Name, buildertek__Details__c, buildertek__Description__c, buildertek__Quantity__c,buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__BT_Category__r.Name, buildertek__BT_Category__c, buildertek__BT_Cost_Code__r.Name, buildertek__BT_Cost_Code__c, buildertek__Anticipated_Finish_Date__c, buildertek__Anticipated_Start_Date__c
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
                    }

                } else{
                    msg.Status = 'Error';
                    msg.Message = 'Grouping not Found for Trade Type';
                }

            } else if (grpType == 'costCode'){
                List<buildertek__Walk_Through_Line_Items__c> walkthroughLineItemList = [SELECT Id, Name, buildertek__Details__c,buildertek__Quantity__c, buildertek__Description__c, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__BT_Category__r.Name, buildertek__BT_Category__c, buildertek__BT_Cost_Code__r.Name, buildertek__BT_Cost_Code__c, buildertek__Anticipated_Finish_Date__c, buildertek__Anticipated_Start_Date__c
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
                    }

                } else{
                    msg.Status = 'Error';
                    msg.Message = 'Grouping not Found for Cost Code';
                }

            } else if (grpType == 'section'){
                List<buildertek__Walk_Through_Line_Items__c> walkthroughLineItemList = [SELECT Id, Name, buildertek__Details__c,buildertek__Quantity__c, buildertek__Description__c, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__BT_Category__r.Name, buildertek__BT_Category__c, buildertek__BT_Cost_Code__r.Name, buildertek__BT_Cost_Code__c, buildertek__Anticipated_Finish_Date__c, buildertek__Anticipated_Start_Date__c
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
        
        Set<Id> cdIds = new Set<Id>();
        for (ContentDocumentLink cdl : allCdLinksToInsert){
            cdIds.add(cdl.Id);
        }

        Set<String> rfqLineIds = new Set<String>();
        for (String rfqLineId : mapOfWalkThroughLineIdAndRfqLineId.values()){
            rfqLineIds.add(rfqLineId);
        }

        //Query all the CDLs to get the ContentDocument.LatestPublishedVersionId and ContentDocument.Title
        List<ContentDocumentLink> allCdLinksToQuery = [SELECT Id, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, ContentDocumentId, LinkedEntityId
                                                       FROM ContentDocumentLink
                                                       WHERE LinkedEntityId IN:rfqLineIds];

        //Create a map of RFQ Line and List of ContentDocumentLink 
        Map<String, List<ContentDocumentLink>> mapOfRfqLineAndCdLinks = new Map<String, List<ContentDocumentLink>>();
        for (ContentDocumentLink cdl : allCdLinksToQuery){
            if (!mapOfRfqLineAndCdLinks.containsKey(cdl.LinkedEntityId)){
                mapOfRfqLineAndCdLinks.put(cdl.LinkedEntityId, new List<ContentDocumentLink>());
            }
            mapOfRfqLineAndCdLinks.get(cdl.LinkedEntityId).add(cdl);
        }

        //Create ContentDistribution records for each CDL in allCdLinksToQuery
        List<ContentDistribution> allContentDistributionsToInsert = new List<ContentDistribution>();
        for (String rfqLineId : mapOfRfqLineAndCdLinks.keySet()){
            for (ContentDocumentLink cdl : mapOfRfqLineAndCdLinks.get(rfqLineId)){
                ContentDistribution cd = new ContentDistribution();
                cd.ContentVersionId = cdl.ContentDocument.LatestPublishedVersionId;
                cd.Name = cdl.ContentDocument.Title;
                cd.PreferencesAllowViewInBrowser= true;
                cd.PreferencesLinkLatestVersion=true;
                cd.PreferencesNotifyOnVisit=false;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;
                cd.RelatedRecordId = rfqLineId;
                allContentDistributionsToInsert.add(cd);
            }
        }

        if (!allContentDistributionsToInsert.isEmpty()){
            database.Insert (allContentDistributionsToInsert, false);
        }

        //Query all the ContentDistribution with ContentVersionId, DistributionPublicUrl
        List<ContentDistribution> allContentDistributionsToQuery = [SELECT Id, ContentVersionId, DistributionPublicUrl, Name, RelatedRecordId
                                                                   FROM ContentDistribution
                                                                   WHERE Id IN:allContentDistributionsToInsert];

        //Create a map where ContentDistribution Id is the key and the value is the RelatedRecordId
        Map<String, String> mapOfContentDistributionIdAndRelatedRecordId = new Map<String, String>();
        for (ContentDistribution cd : allContentDistributionsToQuery){
            mapOfContentDistributionIdAndRelatedRecordId.put(cd.Id, cd.RelatedRecordId);
        }

        //Create a map of RFQ Line and List of ContentDistribution
        Map<String, List<ContentDistribution>> mapOfRfqLineAndContentDistributions = new Map<String, List<ContentDistribution>>();
        for (ContentDistribution cd : allContentDistributionsToQuery){
            if (!mapOfRfqLineAndContentDistributions.containsKey(cd.RelatedRecordId)){
                mapOfRfqLineAndContentDistributions.put(cd.RelatedRecordId, new List<ContentDistribution>());
            }
            mapOfRfqLineAndContentDistributions.get(cd.RelatedRecordId).add(cd);
        }

        //cretea record for buildertek__Public_File__c for each ContentDistribution
        List<buildertek__Public_File__c> allPublicFilesToInsert = new List<buildertek__Public_File__c>();
        for (String rfqLineId : mapOfRfqLineAndContentDistributions.keySet()){
            for (ContentDistribution cd : mapOfRfqLineAndContentDistributions.get(rfqLineId)){
                buildertek__Public_File__c publicfile = new buildertek__Public_File__c();
                publicfile.buildertek__File_Name__c = cd.Name;
                publicfile.buildertek__Content_Distrubution__c = cd.Id;
                publicfile.buildertek__Content_Version__c = cd.ContentVersionId;
                publicfile.buildertek__Public_URL__c = cd.DistributionPublicUrl;
                allPublicFilesToInsert.add(publicfile);
            }
        }

        if (!allPublicFilesToInsert.isEmpty()){
            database.Insert (allPublicFilesToInsert, false);
        }

        //create a map where ContentDistribution Id is the key and the value is the buildertek__Public_File__c 
        Map<String, buildertek__Public_File__c> mapOfContentDistributionIdAndPublicFile = new Map<String, buildertek__Public_File__c>();
        for (buildertek__Public_File__c publicFile : allPublicFilesToInsert){
            mapOfContentDistributionIdAndPublicFile.put(publicFile.buildertek__Content_Distrubution__c, publicFile);
        }

        //Create a map of RelatedRecordId and List of buildertek__Public_File__c
        Map<String, List<buildertek__Public_File__c>> mapOfRfqLineAndPublicFiles = new Map<String, List<buildertek__Public_File__c>>();
        for (buildertek__Public_File__c publicFile : allPublicFilesToInsert){
            if (!mapOfRfqLineAndPublicFiles.containsKey(mapOfContentDistributionIdAndRelatedRecordId.get(publicFile.buildertek__Content_Distrubution__c))){
                mapOfRfqLineAndPublicFiles.put(mapOfContentDistributionIdAndRelatedRecordId.get(publicFile.buildertek__Content_Distrubution__c), new List<buildertek__Public_File__c>());
            }
            mapOfRfqLineAndPublicFiles.get(mapOfContentDistributionIdAndRelatedRecordId.get(publicFile.buildertek__Content_Distrubution__c)).add(publicFile);
        }

        //iterate and debug the map
        for (String rfqLineId : mapOfRfqLineAndPublicFiles.keySet()){
            for (buildertek__Public_File__c publicFile : mapOfRfqLineAndPublicFiles.get(rfqLineId)){
                System.debug('rfqLineId--> ' + rfqLineId + ' publicFile--> ' + publicFile);
                System.debug('publicFile Id => ' + publicFile.Id);
            }
        }

        //Create a record of buildertek__Public_Folder__c for each RFQ Line
        List<buildertek__Public_Folder__c> allPublicFoldersToInsert = new List<buildertek__Public_Folder__c>();
        for (String rfqLineId : mapOfRfqLineAndPublicFiles.keySet()){
            buildertek__Public_Folder__c publicfol = new buildertek__Public_Folder__c();
            publicfol.Name = 'Walkthrough Files';
            publicfol.buildertek__Description__c = 'Public Folder for ' + rfqLineId;
            publicfol.buildertek__RelatedToId__c = rfqLineId;
            allPublicFoldersToInsert.add(publicfol);
        }

        if (!allPublicFoldersToInsert.isEmpty()){
            database.Insert (allPublicFoldersToInsert, false);
        }

        //Create a map of RFQ Line and buildertek__Public_Folder__c.Id
        Map<String, String> mapOfRfqLineAndPublicFolderId = new Map<String, String>();
        for (buildertek__Public_Folder__c publicFolder : allPublicFoldersToInsert){
            mapOfRfqLineAndPublicFolderId.put(publicFolder.buildertek__RelatedToId__c, publicFolder.Id);
        }

        //Iterate and debug the map
        for (String rfqLineId : mapOfRfqLineAndPublicFolderId.keySet()){
            System.debug('rfqLineId--> ' + rfqLineId + ' publicFolderId--> ' + mapOfRfqLineAndPublicFolderId.get(rfqLineId));
        }

        //We have a field on RFQ Line where we can store the Public Folder Id
        List<buildertek__RFQ_Item__c> rfqLineToUpdate = new List<buildertek__RFQ_Item__c>();
        for (String rfqLineId : mapOfRfqLineAndPublicFolderId.keySet()){
            buildertek__RFQ_Item__c rfqLine = new buildertek__RFQ_Item__c();
            rfqLine.Id = rfqLineId;
            rfqLine.buildertek__Public_Folder__c = mapOfRfqLineAndPublicFolderId.get(rfqLineId);
            rfqLineToUpdate.add(rfqLine);
        }

        if (!rfqLineToUpdate.isEmpty()){
            database.Update (rfqLineToUpdate, false);
        }


        //Create a map of Public Folder Id and publicfile list, we hvae 2 list where RFQ Line is the key and the value is the list of public files and public folder
        Map<String, List<buildertek__Public_File__c>> mapOfPublicFolderIdAndPublicFiles = new Map<String, List<buildertek__Public_File__c>>();
        for (String rfqLineId : mapOfRfqLineAndPublicFiles.keySet()){
            if (!mapOfPublicFolderIdAndPublicFiles.containsKey(mapOfRfqLineAndPublicFolderId.get(rfqLineId))){
                mapOfPublicFolderIdAndPublicFiles.put(mapOfRfqLineAndPublicFolderId.get(rfqLineId), new List<buildertek__Public_File__c>());
            }
            mapOfPublicFolderIdAndPublicFiles.get(mapOfRfqLineAndPublicFolderId.get(rfqLineId)).addAll(mapOfRfqLineAndPublicFiles.get(rfqLineId));
        }

        //Iterate and debug the map
        for (String publicFolderId : mapOfPublicFolderIdAndPublicFiles.keySet()){
            for (buildertek__Public_File__c publicFile : mapOfPublicFolderIdAndPublicFiles.get(publicFolderId)){
                System.debug('publicFolderId--> ' + publicFolderId + ' publicFile--> ' + publicFile);
            }
        }

        //create a record of buildertek__Public_File_Folder_Jn__c for each Public Folder and Public File
        List<buildertek__Public_File_Folder_Jn__c> allPublicFileFolderJnToInsert = new List<buildertek__Public_File_Folder_Jn__c>();
        for (String publicFolderId : mapOfPublicFolderIdAndPublicFiles.keySet()){
            for (buildertek__Public_File__c publicFile : mapOfPublicFolderIdAndPublicFiles.get(publicFolderId)){
                buildertek__Public_File_Folder_Jn__c publicFileFolderJn = new buildertek__Public_File_Folder_Jn__c();
                publicFileFolderJn.buildertek__Public_File__c = publicFile.Id;
                publicFileFolderJn.buildertek__Public_Folder__c = publicFolderId;
                allPublicFileFolderJnToInsert.add(publicFileFolderJn);
            }
        }

        //iterate and debug the list
        for (buildertek__Public_File_Folder_Jn__c publicFileFolderJn : allPublicFileFolderJnToInsert){
            System.debug('publicFileFolderJn--> ' + publicFileFolderJn);
        }

        if (!allPublicFileFolderJnToInsert.isEmpty()){
            database.Insert (allPublicFileFolderJnToInsert, false);
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