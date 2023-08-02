public with sharing class TakeOffLineTriggerHandler {

    public static Buildertek__Select_Sheet__c[] selectSheetsALLFIELDS;
    public static Map<Id, Buildertek__Select_Sheet__c> selectSheetsALLFieldsMap;
  //   public static Boolean isFirstTime = true;
   // public static Boolean isFirstTime1 = false;
    
    /**
    * @Use :    Updates the Related Buildertek__Select_Sheet__c[] records with the desired values
    *           for fields being tracked and updated
    * @Handle:  TakeOffLineTriggerHandler:After:Update
    * @Param:   Buildertek__Select_Sheet__c: Trigger.oldMap, Trigger.newMap
    */
    public static void handleFieldChanges(
        Map<Id, Buildertek__Project_Takeoff_Lines__c> oldTakeOffLines,
        Map<Id, Buildertek__Project_Takeoff_Lines__c> newTakeOffLines) {
            // system.debug('oldTakeOffLines->'+oldTakeOffLines);
            // system.debug('isFirstTime1'+isFirstTime1);
            selectSheetsUpdates(oldTakeOffLines, newTakeOffLines);
          //  isFirstTime1 = true;
           // system.debug('isFirstTime1'+isFirstTime1);
        }

    /**
    * @Use :    Prepares and updates Buildertek__Select_Sheet__c[] records
    * @Handle:  TakeOffLineTriggerHandler.selectSheetsUpdates
    * @Param:   Buildertek__Select_Sheet__c: Trigger.oldMap, Trigger.newMap
    */
    public static void selectSheetsUpdates(
        Map<Id, Buildertek__Project_Takeoff_Lines__c> oldTakeOffLines,
        Map<Id, Buildertek__Project_Takeoff_Lines__c> newTakeOffLines) {

        Map<String, String> takeOffLineSelectSheetsMap = getTakeOffLineSelectSheets();
        Buildertek__Select_Sheet__c[] selectSheets = new Buildertek__Select_Sheet__c[]{};
        Map<Id, Set<Id>> tOLSelectSheetMap = getTOLSelectSheetMap(newTakeOffLines, takeOffLineSelectSheetsMap);

        for(Buildertek__Project_Takeoff_Lines__c TakeOffLine : newTakeOffLines.values()) {

            Buildertek__Select_Sheet__c[] selectSheetsToUpdate =
                (Buildertek__Select_Sheet__c[])
                compareAndPrepareSelectSheet(
                    takeOffLineSelectSheetsMap,
                    takeOffLine,
                    oldTakeOffLines.get(TakeOffLine.Id),
                    tOLSelectSheetMap
                );

            /**Logic to handle all the associated Sheet records */
            selectSheets.addAll(selectSheetsToUpdate);
        }

        System.debug('** selectSheets for update -              ----------------------->: ' +
                        JSON.serialize(selectSheets)
                    );
        Database.update(selectSheets, true);
    }

    /**
    * @Use :    Prepares a Source & Target Field API map to transfer
    *           Buildertek__Project_Takeoff_Lines__c values
    * @Handle:  TakeOffLineTriggerHandler.selectSheetsUpdates
    * @Param:   N/A
    */
    public static Map<String, String> getTakeOffLineSelectSheets() {

        Map<String, String> fieldApiMap = new Map<String, String>();
        fieldApiMap.put('buildertek__Quantity__c', 'buildertek__Quantity__c');
        fieldApiMap.put('buildertek__Price_Book__c', 'buildertek__BT_Price_Book__c');
        /** Handle location based on availability */
        fieldApiMap.put('buildertek__Location__c', 'buildertek__Location_Picklist__c');
        /** */
        fieldApiMap.put('buildertek__TL_SERVICE_CATEGORY__c', 'buildertek__Service_Category__c');
        fieldApiMap.put('buildertek__Build_Phase__c', 'buildertek__Build_Phase__c');
        // fieldApiMap.put('buildertek__UOM_PL__c', 'buildertek__UOM__c');

        return fieldApiMap;
    }

    /**
    * @Use :    Evaluates and prepares Buildertek__Select_Sheet__c records for a single
    *           Buildertek__Project_Takeoff_Lines__c
    * @Handle:  TakeOffLineTriggerHandler.selectSheetsUpdates
    * @Param:   Map<String, String> TakeOffLineSelectSheetsMap,
                Sobject newTakeOffLine,
                Sobject oldTakeOffLine,
                Map<Id, Set<Id>> tOLSelectSheetMap
    */
    public static Sobject[] compareAndPrepareSelectSheet(
        Map<String, String> TakeOffLineSelectSheetsMap,
        Sobject newTakeOffLine,
        Sobject oldTakeOffLine,
        Map<Id, Set<Id>> tOLSelectSheetMap) {

        Sobject[] selectSheets = new SObject[]{};
        Set<Id> selectSheetIds = tOLSelectSheetMap.get(newTakeOffLine.Id);
        Map<String, String> locationPicklist = fetchLocationPicklist();

        if(selectSheetIds != NULL && !selectSheetIds.isEmpty()) {

            for(Id selectSheetId : selectSheetIds) {

                /**SelectSheetPreparation */
                Sobject selectSheet = (Sobject) new Buildertek__Select_Sheet__c(Id = selectSheetId);
                /**DOne */

                for(String sourceFieldApi : TakeOffLineSelectSheetsMap.keyset()) {

                    if(newTakeOffLine.get(sourceFieldApi) != oldTakeOffLine.get(sourceFieldApi)) {

                        Id selectSheetIdQuery = selectSheetId;
                        if(selectSheetIdQuery != NULL &&
                            selectSheetsALLFieldsMap.get(selectSheetIdQuery) != NULL) {


                            Sobject oldSelectSheetsQueried = selectSheetsALLFieldsMap.get(selectSheetIdQuery);
                            String targetFieldAPi = TakeOffLineSelectSheetsMap.get(sourceFieldApi);

                            System.debug('**   targetFieldAPi --------------------->: ' + targetFieldAPi);
                            if(targetFieldAPi != 'buildertek__Location_Picklist__c') {

                                if(newTakeOffLine.get(sourceFieldApi) != oldSelectSheetsQueried.get(targetFieldAPi)) {

                                    selectSheet.put(targetFieldAPi, newTakeOffLine.get(sourceFieldApi));
                                }
                            }
                            else {

                                System.debug('**   targetFieldAPi (handled here)--------------------->: ' + targetFieldAPi);

                                /** Location Picklist handler */
                                if(newTakeOffLine.get(sourceFieldApi) != oldSelectSheetsQueried.get(targetFieldAPi)) {

                                    if(locationPicklist.keySet().contains(String.valueOf(newTakeOffLine.get(sourceFieldApi)))) {

                                        selectSheet.put(targetFieldAPi, newTakeOffLine.get(sourceFieldApi));
                                    }
                                }
                            }
                        }
                    }
                }

                selectSheets.add(selectSheet);
            }

        }

        return selectSheets;
    }

    /**
    * @Use :    Prepares a Map for Location picklist present on Buildertek__Select_Sheet__c, so that
    *           the data can be compared and skipped if the value isn't present in
    *           Buildertek__Select_Sheet__c.buildertek__Location_Picklist__c
    * @Handle:  TakeOffLineTriggerHandler.compareAndPrepareSelectSheet
    * @Param:   N/A
    */
    public static Map<String, String> fetchLocationPicklist() {

        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult =
            Buildertek__Select_Sheet__c.buildertek__Location_Picklist__c.getDescribe();
        List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry picklistEntry: picklist) {

            options.put(picklistEntry.getValue(), picklistEntry.getLabel());
        }

        return options;
    }

    /**
    * @Use :    Stores Buildertek__Select_Sheet__c records for comparison and provides, the Set of
    *           related records to be updated
    * @Handle:  TakeOffLineTriggerHandler.selectSheetsUpdates
    * @Param:   Map<id, Buildertek__Project_Takeoff_Lines__c> newTakeOffLines,
                Map<String, String> takeOffLineSelectSheetsMap
    */
    public static Map<Id, Set<Id>> getTOLSelectSheetMap(
        Map<id, Buildertek__Project_Takeoff_Lines__c> newTakeOffLines,
        Map<String, String> takeOffLineSelectSheetsMap) {

            Map<Id, Set<Id>> tOLSelectSheetMap = new Map<Id, Set<Id>>();
            Buildertek__Select_Sheet__c[] selectSheets =
                [
                    SELECT
                    Id,
                    Takeoff_Line__c
                    FROM
                    Buildertek__Select_Sheet__c
                    WHERE
                    Takeoff_Line__c IN :newTakeOffLines.keySet()
                ];

            selectSheetsALLFields =
                Database.query(
                    'SELECT Id, Takeoff_Line__c, ' +
                    String.join(takeOffLineSelectSheetsMap.values(), ',') +
                    ' FROM Buildertek__Select_Sheet__c WHERE ID IN :selectSheets'
                );
            selectSheetsALLFieldsMap = new Map<Id, Buildertek__Select_Sheet__c>(selectSheetsALLFields);

            for(Buildertek__Select_Sheet__c selectSheet : selectSheets) {

                if(tOLSelectSheetMap.get(selectSheet.Takeoff_Line__c) == NULL) {

                    Set<Id> sheetIds = new Set<Id>();
                    sheetIds.add(selectSheet.Id);
                    tOLSelectSheetMap.put(selectSheet.Takeoff_Line__c, sheetIds);
                }
                else {

                    Set<Id> sheetIds = tOLSelectSheetMap.get(selectSheet.Takeoff_Line__c);
                    sheetIds.add(selectSheet.Id);
                    tOLSelectSheetMap.put(selectSheet.Takeoff_Line__c, sheetIds);
                }
            }

            System.debug('**  tOLSelectSheetMap-------------------->: ' + JSON.serialize(tOLSelectSheetMap));
            return tOLSelectSheetMap;
        }


    public static void afterInsert(
        Map<Id, Buildertek__Project_Takeoff_Lines__c> oldTakeOffLines,
        Map<Id, Buildertek__Project_Takeoff_Lines__c> newTakeOffLines) {

        }
  /* public static void afterUpdate(Map<Id, buildertek__Project_Takeoff_Lines__c> oldTakeOffLineMap, Map<Id, buildertek__Project_Takeoff_Lines__c> newTakeOffLineMap, 
                           List<buildertek__Project_Takeoff_Lines__c> oldTakeOffLines, List<buildertek__Project_Takeoff_Lines__c> newTakeOffLines
                           ){
           list<ID> takeoffLineId = new list<ID>();                    
           List<buildertek__Select_Sheet__c> selectionsheetlist = new List<buildertek__Select_Sheet__c>();                    
                               for(buildertek__Project_Takeoff_Lines__c takeofflirec : newTakeOffLines){
                                    takeoffLineId.add(takeofflirec.id);   
                               } 
                               selectionsheetlist = [Select id,Name,buildertek__Takeoff_Line__c,buildertek__Location_Picklist__c,
                                                     buildertek__Build_Phase__c,buildertek__Quantity__c,buildertek__Service_Category__c
                                                     from buildertek__Select_Sheet__c where
                                                    buildertek__Takeoff_Line__c IN: takeoffLineId];   
                               for(buildertek__Project_Takeoff_Lines__c takeofflirec: newTakeOffLines){
                                   for(buildertek__Select_Sheet__c bomlineRec: selectionsheetlist){
                                       if(takeofflirec.id == bomlineRec.buildertek__Takeoff_Line__c){
                                           bomlineRec.buildertek__Location_Picklist__c = takeofflirec.buildertek__Location__c; 
                                           bomlineRec.buildertek__Build_Phase__c = takeofflirec.buildertek__Build_Phase__c; 
                                           bomlineRec.buildertek__Quantity__c = takeofflirec.buildertek__Quantity__c;
                                           bomlineRec.buildertek__Service_Category__c = takeofflirec.buildertek__TL_SERVICE_CATEGORY__c;
                                       }
                                   }
                               }
                               update selectionsheetlist;
   }*/
}