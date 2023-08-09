public with sharing class SelectSheetTriggerHandler {

    public static void handleFieldChanges(
        Map<Id, Buildertek__Select_Sheet__c> oldSelectSheets,
        Map<Id, Buildertek__Select_Sheet__c> newSelectSheets) {

        makeTOLupdates(oldSelectSheets, newSelectSheets);
    }

    public static void makeTOLupdates(
        Map<Id, Buildertek__Select_Sheet__c> oldSelectSheets,
        Map<Id, Buildertek__Select_Sheet__c> newSelectSheets) {

        Map<String, String> selectSheetTakeOffLinesMap = getSelectSheetTakeOffLines();
        Buildertek__Project_Takeoff_Lines__c[] projectTOLs = new Buildertek__Project_Takeoff_Lines__c[]{};
        for(Buildertek__Select_Sheet__c selectSheet : newSelectSheets.values()) {

            Buildertek__Project_Takeoff_Lines__c projectTOL =
                (Buildertek__Project_Takeoff_Lines__c)
                compareAndPrepareTOLs(
                    selectSheetTakeOffLinesMap,
                    selectSheet,
                    oldSelectSheets.get(selectSheet.Id)
                );

            projectTOLs.add(projectTOL);
        }

        Database.update(projectTOLs, true);
    }

    public static Map<String, String> getSelectSheetTakeOffLines() {

        Map<String, String> fieldApiMap = new Map<String, String>();
        fieldApiMap.put('buildertek__Quantity__c', 'buildertek__Quantity__c');

        return fieldApiMap;
    }

    public static Sobject compareAndPrepareTOLs(
        Map<String, String> selectSheetTakeOffLinesMap,
        Sobject newSelectSheet,
        Sobject oldSelectSheet) {

        Sobject projectTOL =
            new Buildertek__Project_Takeoff_Lines__c(
                Id = String.valueOf(newSelectSheet.get('Takeoff_Line__c'))
            );

        for(String sourceFieldApi : selectSheetTakeOffLinesMap.keyset()) {

            if(newSelectSheet.get(sourceFieldApi) != oldSelectSheet.get(sourceFieldApi)) {

                projectTOL.put(sourceFieldApi, newSelectSheet.get(sourceFieldApi));
            }
        }

        return projectTOL;
    }
}