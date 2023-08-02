trigger BOMLineTrigger on Select_Sheet__c (after insert,after update)
{
    //Insert default for BOM cost adjustment table calculations
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            Set<Id> bomIds = new Set<Id>();
            for(Select_Sheet__c thisBOMLine : Trigger.new)
            {
                if(thisBOMLine.Selection_Sheet_Takeoff__c!= null)
                bomIds.add(thisBOMLine.Selection_Sheet_Takeoff__c);
            }

            BOMLineTriggerHelper bolTriggerHelper = new BOMLineTriggerHelper();
            List<Project_Selection_Sheet_Takeoff__c> bomToUpdate = new List<Project_Selection_Sheet_Takeoff__c>();
            Map<Id, List<Select_Sheet__c>> mapBOMIdAndBOMLines = bolTriggerHelper.getBOMLineFromBOMIds(bomIds);

            for(Id bomId : mapBOMIdAndBOMLines.keySet())
            {
                Project_Selection_Sheet_Takeoff__c tempBOM = new Project_Selection_Sheet_Takeoff__c();
                tempBOM.Id = bomId;

                String glilStr = '';
                String tfStr = '';
                String wcStr = '';

                for(Select_Sheet__c thisBOMLine : mapBOMIdAndBOMLines.get(bomId))
                {
                    /* Comment added by Harika, regarding CAES-54 ticket, Date: 01-08-2022*/
                   // if(thisBOMLine.Takeoff_Line__r.TL_SERVICE_CATEGORY__c == 'Ins')
                    if(thisBOMLine.Takeoff_Line__r.TL_SERVICE_CATEGORY__c == 'Insurance')
                    glilStr += (glilStr != '' ? ',' : '') + '{\"singleExtendedCostVal\":null,\"proposalAmountVal\":null,\"productRate\":\"1.01\",\"percentageVal\":null,\"installCostVal\":null,\"extendedCostVal\":null,\"denominatorVal\":\"1000\",\"bomLineId\":"'+thisBOMLine.Id+'\",\"adjustedCost\":null}';

                    if(thisBOMLine.Takeoff_Line__r.Product_Code__c == '69201198')
                    tfStr += (tfStr != '' ? ',' : '') + '{\"singleExtendedCostVal\":null,\"proposalAmountVal\":null,\"productRate\":\"3500.00\",\"percentageVal\":null,\"installCostVal\":null,\"extendedCostVal\":null,\"denominatorVal\":null,\"bomLineId\":"'+thisBOMLine.Id+'\",\"adjustedCost\":null}';

                    if(thisBOMLine.Takeoff_Line__r.TL_SERVICE_CATEGORY__c == 'Work Comp')
                    wcStr += (wcStr != '' ? ',' : '') + '{\"singleExtendedCostVal\":\"\",\"proposalAmountVal\":null,\"productRate\":null,\"percentageVal\":null,\"installCostVal\":null,\"extendedCostVal\":null,\"denominatorVal\":\"100\",\"bomLineId\":"'+thisBOMLine.Id+'\",\"adjustedCost\":null}';
                }

                tempBOM.General_Liability_Insurance_Long__c = '[' + glilStr+']';
                tempBOM.Textura_Fee__c = '[' + tfStr+']';
                tempBOM.Workers_Comp__c = '[' + wcStr+']';

                bomToUpdate.add(tempBOM);
            }

            if(!bomToUpdate.isEmpty())
            {
                update bomToUpdate;
            }
        }
    }
  /*  if(Trigger.isAfter && Trigger.isUpdate){
     system.debug('TakeOffLineTriggerHandler.isFirstTime'+TakeOffLineTriggerHandler.isFirstTime);
        system.debug('TakeOffLineTriggerHandler.isFirstTime1'+TakeOffLineTriggerHandler.isFirstTime1);
        if(TakeOffLineTriggerHandler.isFirstTime || TakeOffLineTriggerHandler.isFirstTime1 == true){
            TakeOffLineTriggerHandler.isFirstTime = false;
            TakeOffLineTriggerHandler.isFirstTime1 = false;
            BOMLineTriggerHelper.afterUpdate(Trigger.oldMap, Trigger.newMap,Trigger.old, Trigger.new);
        }
      
    }*/
}