public with sharing class BOMLineTriggerHelper
{
    public Map<Id, List<Select_Sheet__c>> getBOMLineFromBOMIds(Set<Id> bomIds)
    {
        Map<Id, List<Select_Sheet__c>> mapBOMIdAndBOMLines = new Map<Id, List<Select_Sheet__c>>();
        /* Comment added by Harika, regarding CAES-54 ticket, Date: 01-08-2022*/
        //for(Select_Sheet__c thisBOMLine : [SELECT Id,Selection_Sheet_Takeoff__c,Takeoff_Line__c,Takeoff_Line__r.TL_SERVICE_CATEGORY__c,Takeoff_Line__r.Product_Code__c FROM Select_Sheet__c WHERE Selection_Sheet_Takeoff__c IN : bomIds AND (Takeoff_Line__r.TL_SERVICE_CATEGORY__c = 'Work Comp' OR Takeoff_Line__r.TL_SERVICE_CATEGORY__c = 'Ins' OR Takeoff_Line__r.Product_Code__c = '69201198')])
        for(Select_Sheet__c thisBOMLine : [SELECT Id,Selection_Sheet_Takeoff__c,Takeoff_Line__c,Takeoff_Line__r.TL_SERVICE_CATEGORY__c,Takeoff_Line__r.Product_Code__c FROM Select_Sheet__c WHERE Selection_Sheet_Takeoff__c IN : bomIds AND (Takeoff_Line__r.TL_SERVICE_CATEGORY__c = 'Work Comp' OR Takeoff_Line__r.TL_SERVICE_CATEGORY__c = 'Insurance' OR Takeoff_Line__r.Product_Code__c = '69201198')])
        {
            if(!mapBOMIdAndBOMLines.containsKey(thisBOMLine.Selection_Sheet_Takeoff__c))
            {
                mapBOMIdAndBOMLines.put(thisBOMLine.Selection_Sheet_Takeoff__c, new List<Select_Sheet__c>());
            }
            
            mapBOMIdAndBOMLines.get(thisBOMLine.Selection_Sheet_Takeoff__c).add(thisBOMLine);
        }

        return mapBOMIdAndBOMLines;
    }
   /* public static void afterUpdate(Map<Id, buildertek__Select_Sheet__c> oldTakeOffLineMap, Map<Id, buildertek__Select_Sheet__c> newTakeOffLineMap, 
                           List<buildertek__Select_Sheet__c> oldTakeOffLines, List<buildertek__Select_Sheet__c> newTakeOffLines
                           ){
           list<ID> takeoffLineId = new list<ID>();     
                               Map<Id, buildertek__Project_Takeoff_Lines__c> updates = new Map<Id, buildertek__Project_Takeoff_Lines__c>();
           List<buildertek__Project_Takeoff_Lines__c> selectionsheetlist = new List<buildertek__Project_Takeoff_Lines__c>();
                               List<buildertek__Project_Takeoff_Lines__c> selectionsheetlist1 = new List<buildertek__Project_Takeoff_Lines__c>();
                               for(buildertek__Select_Sheet__c bomlinerec : newTakeOffLines){
                                    takeoffLineId.add(bomlinerec.buildertek__Takeoff_Line__c);   
                               } 
                               selectionsheetlist = [Select id,Name,buildertek__Location__c,
                                                     buildertek__Build_Phase__c,buildertek__Quantity__c,buildertek__TL_SERVICE_CATEGORY__c
                                                     from buildertek__Project_Takeoff_Lines__c where
                                                    ID IN: takeoffLineId];   
                               for(buildertek__Select_Sheet__c takeofflirec: newTakeOffLines){
                                   for(buildertek__Project_Takeoff_Lines__c bomlineRec: selectionsheetlist){
                                       if(takeofflirec.buildertek__Takeoff_Line__c == bomlineRec.id ){
                                          /* bomlineRec.buildertek__Location_Picklist__c = takeofflirec.buildertek__Location__c; 
                                           bomlineRec.buildertek__Build_Phase__c = takeofflirec.buildertek__Build_Phase__c; 
                                           bomlineRec.buildertek__Quantity__c = takeofflirec.buildertek__Quantity__c;
                                           bomlineRec.buildertek__Service_Category__c = takeofflirec.buildertek__TL_SERVICE_CATEGORY__c;*/
                                   /*        bomlineRec.buildertek__Location__c = takeofflirec.buildertek__Location_Picklist__c; 
                                           bomlineRec.buildertek__Build_Phase__c = takeofflirec.buildertek__Build_Phase__c; 
                                           bomlineRec.buildertek__Quantity__c = takeofflirec.buildertek__Quantity__c;
                                           bomlineRec.buildertek__TL_SERVICE_CATEGORY__c = takeofflirec.buildertek__Service_Category__c;
                                           selectionsheetlist1.add(bomlineRec);
                                       }
                                   }
                               }
                               update selectionsheetlist1;
   }*/
}