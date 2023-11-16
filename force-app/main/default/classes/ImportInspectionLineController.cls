public with sharing class ImportInspectionLineController {
    @AuraEnabled
    public static String insertData(String strfromle, String inspecId) {
        String returnresponse = '';

        try {
            List<buildertek__Inspection_Line__c> InspectionLineListtoInsert = new List<buildertek__Inspection_Line__c>();
            List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strfromle, List<fieldWrapper>.class);

            for (fieldWrapper wrapper : datalist) {
                if (String.isNotBlank(wrapper.Description) || 
                    String.isNotBlank(wrapper.Status) || 
                    String.isNotBlank(wrapper.Comments) || 
                    String.isNotBlank(wrapper.DateDue)) {
                    buildertek__Inspection_Line__c InspecLine = new buildertek__Inspection_Line__c();
                    InspecLine.buildertek__Inspection__c = inspecId;
                    InspecLine.buildertek__Description__c = wrapper.Description;
                    InspecLine.buildertek__Status__c = wrapper.Status;
                    InspecLine.buildertek__Comments__c = wrapper.Comments;
                    if (String.isNotBlank(wrapper.DateDue)) {
                        InspecLine.buildertek__Date_Inspection_Due__c = Date.parse(wrapper.DateDue);
                    }
                    InspectionLineListtoInsert.add(InspecLine);
                }
            }

            if (!InspectionLineListtoInsert.isEmpty()) {
                insert InspectionLineListtoInsert;
                returnresponse = 'SUCCESS';
            }
        } catch (Exception e) {
            returnresponse = 'ERROR: ' + e.getMessage();
            System.debug('error-->' + e.getMessage());
            System.debug('error line--->' + e.getLineNumber());
        }

        return returnresponse;
    }

    public class fieldWrapper {
        public String Description;
        public String Status;
        public String Comments;
        public String DateDue;
    }
}