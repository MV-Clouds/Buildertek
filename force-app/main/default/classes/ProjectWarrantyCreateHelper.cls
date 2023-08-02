public class ProjectWarrantyCreateHelper {
    public void OnBeforeInsertUpdate(List<buildertek__Warranty__c> newWarrantys){
        List<buildertek__Warranty__c> newWarrantyList = new List<buildertek__Warranty__c>();
        List<buildertek__Project__c> newProjectList = new List<buildertek__Project__c>();
        for(buildertek__Warranty__c warranty : newWarrantys){
            if(warranty.buildertek__Create_Warranty_On_Project_Creation__c){
                buildertek__Project__c newProject = new buildertek__Project__c();
                newProject.Name = 'New project '+String.valueOf(System.today());
                insert newProject;
                buildertek__Warranty__c newWarrantyRecord = new buildertek__Warranty__c();
                newWarrantyRecord.buildertek__Description__c = warranty.buildertek__Description__c;
                newWarrantyRecord.buildertek__Effective_Date__c = System.today();
                newWarrantyRecord.buildertek__Locked__c = false;
                newWarrantyRecord.buildertek__Project__c = newProject.Id;
                newWarrantyRecord.buildertek__Status__c = warranty.buildertek__Status__c;
                newWarrantyRecord.buildertek__Type__c = warranty.buildertek__Type__c;
                newWarrantyRecord.buildertek__Warranty_Manager__c = warranty.buildertek__Warranty_Manager__c;
                newWarrantyRecord.buildertek__Instructions__c = warranty.buildertek__Instructions__c;
                newWarrantyRecord.buildertek__Warranty__c = warranty.buildertek__Warranty__c;
                newWarrantyRecord.buildertek__Length_of_Warranty__c = warranty.buildertek__Length_of_Warranty__c;
                newWarrantyRecord.buildertek__Create_Warranty_On_Project_Creation__c = false;
                if(newWarrantyRecord.buildertek__Effective_Date__c != null && newWarrantyRecord.buildertek__Length_of_Warranty__c != null){
                    if(newWarrantyRecord.buildertek__Length_of_Warranty__c.contains('month') || newWarrantyRecord.buildertek__Length_of_Warranty__c.contains('months')){
                        List<string> s = newWarrantyRecord.buildertek__Length_of_Warranty__c.split(' ');
                        integer addingDays = integer.valueOf(s[0]) * 30;
                        newWarrantyRecord.buildertek__Due_Date__c = newWarrantyRecord.buildertek__Effective_Date__c.adddays(addingDays);
                    }
                    if(newWarrantyRecord.buildertek__Length_of_Warranty__c.contains('year') || newWarrantyRecord.buildertek__Length_of_Warranty__c.contains('years')){
                        List<string> s = newWarrantyRecord.buildertek__Length_of_Warranty__c.split(' ');
                        integer addingDays = integer.valueOf(s[0]) * 365;
                        newWarrantyRecord.buildertek__Due_Date__c = newWarrantyRecord.buildertek__Effective_Date__c.adddays(addingDays);
                    }
                }else{
                    newWarrantyRecord.buildertek__Due_Date__c = warranty.buildertek__Due_Date__c;
                }
                newWarrantyList.add(newWarrantyRecord);
            }
        }
        //insert newWarrantyList;
    }
    
    /*public void OnBeforeUpdate(List<buildertek__Warranty__c> oldWarrantys, List<buildertek__Warranty__c> newWarrantys){
        List<buildertek__Warranty__c> newWarrantyList = new List<buildertek__Warranty__c>();
        List<buildertek__Project__c> newProjectList = new List<buildertek__Project__c>();
        for(buildertek__Warranty__c warranty : newWarrantys){
            if(warranty.buildertek__Create_Warranty_On_Project_Creation__c){
                buildertek__Project__c newProject = new buildertek__Project__c();
                newProject.Name = 'Project From Update Trigger '+String.valueOf(System.today());
                insert newProject;
                buildertek__Warranty__c newWarrantyRecord = new buildertek__Warranty__c();
                newWarrantyRecord.buildertek__Description__c = 'Warranty From Trigger '+String.valueOf(System.today());
                newWarrantyRecord.buildertek__Effective_Date__c = System.today();
                newWarrantyRecord.buildertek__Locked__c = false;
                newWarrantyRecord.buildertek__Project__c = newProject.Id;
                newWarrantyList.add(newWarrantyRecord);
            }
        }
        insert newWarrantyList;
    }*/
    
    
}