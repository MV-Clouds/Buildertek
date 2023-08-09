public class ImportSelectionSheet {
    @AuraEnabled
    public Static List<buildertek__Selection__c> getAllMaseterRecords(String selectionId){
        List<buildertek__Selection__c> selections = [SELECT Id, Name, buildertek__Title__c, (Select id , name , buildertek__Total_Options__c  from buildertek__Sections__r) ,buildertek__Project__r.Name, buildertek__Visible_to_Customer__c, buildertek__Type__c FROM buildertek__Selection__c WHERE buildertek__Type__c =: 'Master' AND ID != : selectionId];
        if(selections.size()>0){
            return selections;
        }
        return null;
    }

    @AuraEnabled
    public Static String importSelection(String currentSelectionId,List<String> selectedSelectionId){
        System.debug('currentSelectionId '+currentSelectionId);
        System.debug('selectedSelectionId '+selectedSelectionId);
        try{

            List<buildertek__Section__c> sections = [SELECT Id, Name,buildertek__Selection__c, buildertek__Parent__c, buildertek__Sort_Id__c, buildertek__Title__c, buildertek__Instructions__c, buildertek__Allowance__c, buildertek__Due_Date__c, buildertek__Date_Selected__c, buildertek__Date_Approved__c, buildertek__Locked__c, buildertek__Visible_to_Customer__c, buildertek__Total_Options__c, buildertek__Total_Tested_Options__c, buildertek__Create_Change_Order_on_Overage__c ,(SELECT Id, Name, buildertek__Section__c, buildertek__Sort_Id__c, buildertek__Title__c, buildertek__Instructions__c, buildertek__Allowance_Available__c, buildertek__Allowance_Remaining__c, buildertek__Date_Selected__c, buildertek__Selected_By__c, buildertek__Selected_By_Name__c, buildertek__Allowance_Used__c, buildertek__of_Options_Required__c, buildertek__Total_Options_Submitted__c, buildertek__Parent__c FROM buildertek__Question_Groups__r),(SELECT Name, buildertek__Question_HTML__c, buildertek__Question_Text__c, buildertek__Display_Layout__c, buildertek__Help_Text__c, buildertek__Question_Type__c, buildertek__Choice_Template__c, buildertek__Repository_Area__c, buildertek__Auto_Number__c, buildertek__Sort_Id__c, buildertek__Question_Group__c, buildertek__Text_Question_Response_Data_Type__c, buildertek__Mandatory__c, buildertek__Cost__c, buildertek__Section__c, buildertek__Additional_Cost__c, buildertek__Instructions__c, buildertek__Vendor__c, buildertek__Manufacturer__c, buildertek__Image_Id__c, buildertek__Document_Id__c, buildertek__Product__c, buildertek__Display_Layout1__c, buildertek__Is_Selected_Item__c, buildertek__StockKeepingUnit__c, buildertek__ProductCode__c, buildertek__Finish__c, buildertek__Color__c, buildertek__Options_Name__c FROM buildertek__Questions__r) FROM buildertek__Section__c WHERE buildertek__Selection__c IN : selectedSelectionId];
            Map<Id,buildertek__Section__c> sectionMap = new Map<Id,buildertek__Section__c>();
            Map<Id,buildertek__Question_Group__c> questionGroupMap = new Map<Id,buildertek__Question_Group__c>();
            Map<Id,buildertek__Question__c> questionMap = new Map<Id,buildertek__Question__c>();
            Map<Id,buildertek__Answer_Choice__c> answerChoiceMap = new Map<Id,buildertek__Answer_Choice__c>();

            for (buildertek__Section__c check : sections) {
                System.debug('list of '+check);
            }

            if(sections.size()>0){
                for(buildertek__Section__c section : sections){
                    section.buildertek__Selection__c=currentSelectionId;
                    buildertek__Section__c sectionClone = section.clone(false,true);
                    sectionmap.put(section.Id,sectionClone);
                }
                System.debug('sectionMap '+sectionMap);
                insert sectionMap.values();

                List<buildertek__Question_Group__c> questiongroups =[SELECT Id, Name, buildertek__Section__c, buildertek__Parent__c, buildertek__Sort_Id__c, buildertek__Title__c, buildertek__Instructions__c, buildertek__Allowance_Available__c, buildertek__Allowance_Remaining__c, buildertek__Date_Selected__c, buildertek__Selected_By__c, buildertek__Selected_By_Name__c, buildertek__Allowance_Used__c, buildertek__of_Options_Required__c, buildertek__Total_Options_Submitted__c FROM buildertek__Question_Group__c WHERE buildertek__Section__c In : sections];
                if(questiongroups.size()>0){
                    for(buildertek__Question_Group__c questiongroup : questiongroups){
                        buildertek__Question_Group__c questiongroupClone = questiongroup.clone(false,true);
                        questiongroupClone.buildertek__Section__c=sectionMap.get(questiongroup.buildertek__Section__c).Id;
                        questionGroupMap.put(questiongroup.Id,questiongroupClone);
                    }
                    System.debug('questionGroupMap '+questionGroupMap);
                    insert questionGroupMap.values();

                    List<buildertek__Question__c> questions =[SELECT Id, Name, buildertek__Question_HTML__c, buildertek__Question_Text__c, buildertek__Display_Layout__c, buildertek__Help_Text__c, buildertek__Question_Type__c, buildertek__Choice_Template__c, buildertek__Repository_Area__c, buildertek__Auto_Number__c, buildertek__Sort_Id__c, buildertek__Question_Group__c, buildertek__Text_Question_Response_Data_Type__c, buildertek__Mandatory__c, buildertek__Cost__c, buildertek__Section__c, buildertek__Additional_Cost__c, buildertek__Instructions__c, buildertek__Vendor__c, buildertek__Manufacturer__c, buildertek__Image_Id__c, buildertek__Document_Id__c, buildertek__Product__c, buildertek__Display_Layout1__c, buildertek__Is_Selected_Item__c, buildertek__StockKeepingUnit__c, buildertek__ProductCode__c, buildertek__Finish__c, buildertek__Color__c, buildertek__Options_Name__c FROM buildertek__Question__c WHERE buildertek__Question_Group__c In : questiongroups];
                    if(questions.size()>0){
                        for(buildertek__Question__c question : questions){
                            buildertek__Question__c questionClone = question.clone(false,true);
                            questionClone.buildertek__Question_Group__c=questionGroupMap.get(question.buildertek__Question_Group__c).Id;
                            questionMap.put(question.Id,questionClone);
                        }
                        System.debug('questionMap '+questionMap);
                        insert questionMap.values();

                        List<buildertek__Answer_Choice__c> answerChoices = [SELECT Id, Name, buildertek__Allow_Text_Entry__c, buildertek__Choice_Description__c, buildertek__Choice_Template__c, buildertek__Choice_Text__c, buildertek__Choice_Value__c, buildertek__Sort_Id__c, buildertek__Question__c, buildertek__Photo_Ids__c, buildertek__Single_Select_Drop_Down__c, buildertek__Single_Select_Radio__c, buildertek__Single_Select_Horizontal_Radio__c, buildertek__Multi_Select_CheckBox__c, buildertek__Multi_Select_Horizontal_CheckBox__c, buildertek__Multi_Select_Drop_Down__c, buildertek__Simple_Text__c, buildertek__Long_Text__c, buildertek__Date__c, buildertek__Drop_Down_Value__c, buildertek__Text_Value__c, buildertek__Delete_Record__c, buildertek__Option_Details__c, buildertek__Selection_Type__c FROM buildertek__Answer_Choice__c WHERE buildertek__Question__c IN : questions];
                        if(answerChoices.size()>0){
                            for(buildertek__Answer_Choice__c answerChoice : answerChoices){
                                buildertek__Answer_Choice__c answerChoiceClone = answerChoice.clone(false,true);
                                answerChoiceClone.buildertek__Question__c = questionMap.get(answerChoice.buildertek__Question__c).Id;
                                answerChoiceMap.put(answerChoice.Id,answerChoiceClone);
                            }
                            System.debug('answerChoiceMap '+answerChoiceMap);
                            insert answerChoiceMap.values();
                        }
                    }
                }
           	return 'Success';
            }
        }catch(Exception e){
            System.debug('Error'+e.getLineNumber()+'::'+e.getMessage());
            return 'Error';
        }
        return 'Error';
    }
}