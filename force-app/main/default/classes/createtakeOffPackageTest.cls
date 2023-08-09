@isTest
public class createtakeOffPackageTest {
    @isTest
    static void testMethod1(){
        List<String> packageIds = new  List<String>(); 
        List<String> packageLineIds = new  List<String>();
        buildertek__Package__c packageobj = new buildertek__Package__c();
        packageobj.buildertek__Package_Name__c = 'test';  
        insert packageobj;
        
        List<buildertek__Package__c> packagelst = [SELECT Id,
                                                   Name,
                                                   buildertek__Package_Name__c
                                                   FROM buildertek__Package__c];
        for(buildertek__Package__c item :packagelst){
            packageIds.add(item.Id);
        }
        
        Product_Type__c PT = new Product_Type__c();
        PT.Name = 'test';
        insert PT;
        
        Category__c C = new Category__c();
        C.Name = 'test';
        insert C;
        
        buildertek__Package_Line__c packageline = new buildertek__Package_Line__c();
        packageline.buildertek__Package_Name__c =packageobj.Id;
        packageline.buildertek__Product_Type__c = PT.Id;
        packageline.buildertek__Location__c = 'Kitchen';
        packageline.buildertek__UOM__c = 'Each';
        packageline.buildertek__Quantity__c = 25;
        packageline.buildertek__Category__c = C.Id;
        insert packageline;
        
        buildertek__Project_Takeoff__c projecttakeoff = new buildertek__Project_Takeoff__c();
        projecttakeoff.buildertek__Name__c  = 'test';
        insert projecttakeoff;
        
        buildertek__Project_Takeoff_Lines__c projecttakeoffline = new buildertek__Project_Takeoff_Lines__c();
        projecttakeoffline.buildertek__Project_Takeoff__c = projecttakeoff.Id;
        projecttakeoffline.buildertek__Product_Type__c = PT.Id;
        projecttakeoffline.buildertek__Location__c = 'Kitchen';
        projecttakeoffline.buildertek__UOM__c = 'Each';
        projecttakeoffline.buildertek__Quantity__c = 25;
        projecttakeoffline.buildertek__Categories__c = C.Id;
        insert projecttakeoffline;
        
        createtakeOffPackage.getPackageTakeoff();
      //  createtakeOffPackage.importPackageLines(packageIds,projecttakeoff.Id);
        createtakeOffPackage.getPackageTakeoffRecords(packageIds,projecttakeoff.Id,1,1,'','','','','',''); 
        createtakeOffPackage.getFilteredTakeoffRecords(packageIds,projecttakeoff.Id,1,1,'','','','','','','[]');
        List<String> deleteIds = new List<String>();
        deleteIds.add(projecttakeoffline.Id);
     //   createtakeOffPackage.importPackageLinesRecords(packageIds,projecttakeoff.Id);
        createtakeOffPackage.replaceTakeOffLinesRecords(deleteIds,packageIds,projecttakeoff.Id);
        packageLineIds.add(packageline.Id);
        createtakeOffPackage.replaceTakeOffLinesRecords2(deleteIds, packageLineIds, projecttakeoff.Id);
    }
}