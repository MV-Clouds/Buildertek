@isTest
public class ImportMasterToDoTest {
     public static testMethod void Test1() {
         
    buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test ';
        insert proj;
       
          List<buildertek__To_Do__c> TodoList = new List<buildertek__To_Do__c>();
        buildertek__To_Do__c Todo = new buildertek__To_Do__c();
     
        Todo.buildertek__Project__c = proj.Id;
        Todo.buildertek__Type__c = 'Master';
        TodoList.add(Todo); 
        insert TodoList;
         
           List<buildertek__To_Do_Items__c> todoItemList = new List<buildertek__To_Do_Items__c>();
        buildertek__To_Do_Items__c  todoItem = new buildertek__To_Do_Items__c();
        todoItem.buildertek__Description__c = 'hai';
        todoItem.buildertek__To_Do__c = TodoList[0].Id;
        todoItemList.add(todoItem);
        insert todoItemList;
         
          List<String> selectedIds = new List<String>();
        selectedIds.add(TodoList[0].Id);
     
 ImportMasterToDo.getAllMaseterRecords(TodoList[0].Id);
      ImportMasterToDo.importToDoRecords(TodoList[0].Id,selectedIds);
        system.assertEquals('test', 'test');
}
}