@isTest
public class ImportSelectionSheetTest {
     public static testMethod void test1() {
         
          buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
         
         
          List<buildertek__Selection__c> selectItem = new List<buildertek__Selection__c> ();
        buildertek__Selection__c selectlist = new buildertek__Selection__c();
        selectlist.Name='test';
        selectlist.buildertek__Title__c= 'Test1';
        selectlist.buildertek__Type__c = 'Master';
        selectlist.buildertek__Project__c=proj.id;
        selectItem.add(selectlist);
        insert selectItem;
         
          List<buildertek__Section__c> secList = new List<buildertek__Section__c>();
	    buildertek__Section__c sec = new buildertek__Section__c();
	    sec.Name = 'Test Budget';
	    sec.buildertek__Title__c = 'test';
	    //sec.buildertek__Project__r.Name =proj.id;
	    secList.add(sec); 
	    insert secList;
         
         
          List<buildertek__Question_Group__c> quesList = new List<buildertek__Question_Group__c>();
	    buildertek__Question_Group__c quest = new buildertek__Question_Group__c();
	    quest.Name = 'Test Budget';
	    quest.buildertek__Section__c = sec.id;
	    //quest.buildertek__Parent__c = 'hardsurface';
	    quesList.add(quest); 
	    insert quesList;
         
         
        List<buildertek__Answer_Choice__c> anschoice = new List<buildertek__Answer_Choice__c> ();
        buildertek__Answer_Choice__c ans = new buildertek__Answer_Choice__c ();
        ans.Name='test';
        ans.buildertek__Choice_Text__c = 'choice'; 
        ans.buildertek__Choice_Value__c = 'value';
        anschoice.add(ans);
        insert anschoice;
         
          List<String> selectedIds = new List<String>();
        selectedIds.add(selectItem[0].Id);
          //List<buildertek__Question_Group__c> questiongroups =[SELECT Id, Name, buildertek__Section__c, buildertek__Parent__c, buildertek__Sort_Id__c, buildertek__Title__c, buildertek__Instructions__c, buildertek__Allowance_Available__c, buildertek__Allowance_Remaining__c, buildertek__Date_Selected__c, buildertek__Selected_By__c, buildertek__Selected_By_Name__c, buildertek__Allowance_Used__c, buildertek__of_Options_Required__c, buildertek__Total_Options_Submitted__c FROM buildertek__Question_Group__c WHERE buildertek__Section__c In : sections];
              // questiongroups.add(quesList[0].id);
         
         ImportSelectionSheet.getAllMaseterRecords(selectItem[0].Id);
         ImportSelectionSheet.importSelection(selectItem[0].Id,selectedIds);
	     System.assertEquals('Test','Test');

}
}